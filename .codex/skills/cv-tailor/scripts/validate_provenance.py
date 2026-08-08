#!/usr/bin/env python3
"""Validate that every rendered CV bullet is grounded in current master-record sources."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path
from typing import Any

from score_cv import normalize


METRIC_RE = re.compile(
    r"(?<!\w)\d+(?:[.,]\d+)?\s*(?:%|x|ms|s|segundos?|min(?:utos?)?|h|horas?|dias?|meses?|anos?)(?!\w)",
    re.IGNORECASE,
)
EXCLUDED_PARTS = {"credenciais", "exports", "tmp", "versoes"}


def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _contains_claim(haystack: str, needle: str) -> bool:
    normalized_haystack = normalize(haystack)
    normalized_needle = normalize(needle)
    if not normalized_needle:
        return False
    return bool(
        re.search(
            rf"(?<![a-z0-9]){re.escape(normalized_needle)}(?![a-z0-9])",
            normalized_haystack,
        )
    )


def _experience_bullets(cv_text: str) -> list[str]:
    bullets: list[str] = []
    active = False
    for raw_line in cv_text.splitlines():
        line = raw_line.strip()
        if line.startswith("== "):
            heading = normalize(line[3:])
            active = "experiencia" in heading or "experience" in heading
            continue
        if active and line.startswith("- "):
            bullets.append(line[2:].strip())
    return bullets


def _safe_source(master_root: Path, relative_path: str) -> tuple[Path | None, str | None]:
    candidate = master_root / relative_path
    if candidate.is_symlink():
        return None, "source_symlink"
    resolved = candidate.resolve()
    try:
        relative = resolved.relative_to(master_root)
    except ValueError:
        return None, "source_outside_master"
    if any(part in EXCLUDED_PARTS for part in relative.parts):
        return None, "source_in_excluded_directory"
    if not resolved.is_file():
        return None, "source_missing"
    return resolved, None


def validate_provenance(
    provenance: dict[str, Any],
    master_root: str | Path,
    cv_text: str,
) -> dict[str, Any]:
    root = Path(master_root).expanduser().resolve()
    if not root.is_dir():
        raise ValueError(f"Master root is not a directory: {root}")

    actual_bullets = _experience_bullets(cv_text)
    entries = provenance.get("bullets", [])
    entry_by_text = {
        normalize(str(entry.get("generated_text") or entry.get("rendered_bullet") or "")): entry
        for entry in entries
    }
    errors: list[dict[str, Any]] = []
    matched = 0

    for index, bullet in enumerate(actual_bullets):
        entry = entry_by_text.get(normalize(bullet))
        if entry is None:
            errors.append({"type": "missing_bullet_provenance", "bullet_index": index, "bullet": bullet})
            continue
        matched += 1
        sources = entry.get("sources") or []
        if not sources:
            errors.append({"type": "missing_sources", "bullet_index": index})
            continue

        source_texts: list[str] = []
        for source in sources:
            relative_path = str(source.get("path") or "")
            source_path, source_error = _safe_source(root, relative_path)
            if source_error:
                errors.append({"type": source_error, "bullet_index": index, "path": relative_path})
                continue
            assert source_path is not None
            expected_hash = str(source.get("sha256") or "")
            actual_hash = _sha256(source_path)
            if not expected_hash or expected_hash != actual_hash:
                errors.append(
                    {
                        "type": "stale_source_hash",
                        "bullet_index": index,
                        "path": relative_path,
                        "expected": expected_hash,
                        "actual": actual_hash,
                    }
                )

            lines = source_path.read_text(encoding="utf-8").splitlines()
            line_start = int(source.get("line_start") or 0)
            line_end = int(source.get("line_end") or line_start)
            if line_start < 1 or line_end < line_start or line_end > len(lines):
                errors.append({"type": "invalid_source_lines", "bullet_index": index, "path": relative_path})
                continue
            actual_excerpt = "\n".join(lines[line_start - 1 : line_end])
            declared_excerpt = source.get("excerpt")
            if declared_excerpt is not None and normalize(str(declared_excerpt)) != normalize(actual_excerpt):
                errors.append(
                    {"type": "source_excerpt_mismatch", "bullet_index": index, "path": relative_path}
                )
            source_texts.append(actual_excerpt)

        joined_sources = "\n".join(source_texts)
        for claim in entry.get("claims") or []:
            if not _contains_claim(joined_sources, str(claim)):
                errors.append(
                    {"type": "unsupported_claim", "bullet_index": index, "claim": str(claim)}
                )
        for metric in METRIC_RE.findall(bullet):
            if normalize(metric) not in normalize(joined_sources):
                errors.append(
                    {"type": "unsupported_metric", "bullet_index": index, "metric": metric}
                )

    actual_normalized = {normalize(item) for item in actual_bullets}
    for entry in entries:
        rendered = str(entry.get("generated_text") or entry.get("rendered_bullet") or "")
        if normalize(rendered) not in actual_normalized:
            errors.append({"type": "orphan_provenance", "bullet": rendered})

    work_entries = provenance.get("work_entries") or []
    for work_index, work_entry in enumerate(work_entries):
        sources = work_entry.get("sources") or []
        if not sources:
            errors.append({"type": "missing_work_sources", "work_entry_index": work_index})
            continue

        source_texts: list[str] = []
        for source in sources:
            relative_path = str(source.get("path") or "")
            source_path, source_error = _safe_source(root, relative_path)
            if source_error:
                errors.append(
                    {"type": source_error, "work_entry_index": work_index, "path": relative_path}
                )
                continue
            assert source_path is not None
            expected_hash = str(source.get("sha256") or "")
            actual_hash = _sha256(source_path)
            if not expected_hash or expected_hash != actual_hash:
                errors.append(
                    {
                        "type": "stale_work_source_hash",
                        "work_entry_index": work_index,
                        "path": relative_path,
                        "expected": expected_hash,
                        "actual": actual_hash,
                    }
                )

            lines = source_path.read_text(encoding="utf-8").splitlines()
            line_start = int(source.get("line_start") or 0)
            line_end = int(source.get("line_end") or line_start)
            if line_start < 1 or line_end < line_start or line_end > len(lines):
                errors.append(
                    {"type": "invalid_work_source_lines", "work_entry_index": work_index, "path": relative_path}
                )
                continue
            actual_excerpt = "\n".join(lines[line_start - 1 : line_end])
            declared_excerpt = source.get("excerpt")
            if declared_excerpt is not None and normalize(str(declared_excerpt)) != normalize(actual_excerpt):
                errors.append(
                    {"type": "work_source_excerpt_mismatch", "work_entry_index": work_index, "path": relative_path}
                )
            source_texts.append(actual_excerpt)

        joined_sources = "\n".join(source_texts)
        field_claims = work_entry.get("field_claims")
        if not isinstance(field_claims, dict):
            errors.append({"type": "missing_work_field_claims", "work_entry_index": work_index})
            continue
        for field in ("company", "canonical_title", "dates"):
            rendered_value = str(work_entry.get(field) or "")
            claims = field_claims.get(field) or []
            if not rendered_value:
                errors.append({"type": "missing_work_field", "work_entry_index": work_index, "field": field})
            if not isinstance(claims, list) or not claims:
                errors.append(
                    {"type": "missing_work_field_claim", "work_entry_index": work_index, "field": field}
                )
                continue
            for claim in claims:
                normalized_claim = normalize(str(claim))
                if not _contains_claim(joined_sources, normalized_claim):
                    errors.append(
                        {
                            "type": "unsupported_work_claim",
                            "work_entry_index": work_index,
                            "field": field,
                            "claim": str(claim),
                        }
                    )
                if not _contains_claim(rendered_value, normalized_claim):
                    errors.append(
                        {
                            "type": "work_field_claim_mismatch",
                            "work_entry_index": work_index,
                            "field": field,
                            "claim": str(claim),
                        }
                    )
        for metric in METRIC_RE.findall(str(work_entry.get("dates") or "")):
            if normalize(metric) not in normalize(joined_sources):
                errors.append(
                    {"type": "unsupported_work_date", "work_entry_index": work_index, "metric": metric}
                )

    coverage = 1.0 if not actual_bullets else matched / len(actual_bullets)
    return {
        "schema_version": 1,
        "valid": not errors and coverage == 1.0,
        "coverage": coverage,
        "cv_bullets": len(actual_bullets),
        "provenance_entries": len(entries),
        "work_entries": len(work_entries),
        "errors": sorted(
            errors,
            key=lambda item: (
                item["type"],
                item.get("bullet_index", -1),
                item.get("work_entry_index", -1),
            ),
        ),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--provenance", required=True, type=Path)
    parser.add_argument("--master-root", required=True, type=Path)
    parser.add_argument("--cv", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    report = validate_provenance(
        json.loads(args.provenance.read_text(encoding="utf-8")),
        args.master_root,
        args.cv.read_text(encoding="utf-8"),
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return 0 if report["valid"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
