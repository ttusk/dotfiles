#!/usr/bin/env python3
"""Validate evidence-matrix coverage, source references, and knockout eligibility."""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path
from typing import Any

from score_cv import contains_requirement


STATUSES = {"supported", "partial", "missing", "contradicted", "unknown"}
STRENGTHS = {"professional_experience", "project", "declared_skill", "education", "profile", "none"}
ELIGIBILITY = {"eligible", "review", "ineligible"}
RECOMMENDATIONS = {"apply", "apply_with_caveats", "reconsider"}


def _source_text_by_id(master: dict[str, Any]) -> dict[str, str]:
    known: dict[str, str] = {}
    for key in ("profile", "skills"):
        special = master.get(key)
        if isinstance(special, dict) and special.get("source"):
            known[str(special["source"])] = str(special.get("text") or "")
    for experience in master.get("experiences", []):
        combined_text: list[str] = []
        if experience.get("source"):
            combined_text.extend(str(value) for value in (experience.get("fields") or {}).values())
            combined_text.extend(str(bullet.get("text") or "") for bullet in experience.get("bullets", []))
            known[str(experience["source"])] = "\n".join(combined_text)
        field_sources = experience.get("field_sources") or {}
        fields = experience.get("fields") or {}
        for field, source_id in field_sources.items():
            known[str(source_id)] = str(fields.get(field) or "")
        for bullet in experience.get("bullets", []):
            if bullet.get("source_id"):
                known[str(bullet["source_id"])] = str(bullet.get("text") or "")
    return known


def _expected_eligibility(
    requirement_by_id: dict[str, dict[str, Any]], entries: list[dict[str, Any]]
) -> str:
    statuses: dict[str, set[str]] = {}
    for entry in entries:
        statuses.setdefault(str(entry.get("requirement_id") or ""), set()).add(str(entry.get("status") or ""))
    knockout_statuses = [
        statuses.get(requirement_id, {"missing"})
        for requirement_id, requirement in requirement_by_id.items()
        if requirement.get("knockout")
    ]
    if any("contradicted" in values for values in knockout_statuses):
        return "ineligible"
    if any(values & {"partial", "missing", "unknown"} for values in knockout_statuses):
        return "review"
    return "eligible"


def validate_evidence_matrix(
    matrix: dict[str, Any], requirements: dict[str, Any], master: dict[str, Any]
) -> dict[str, Any]:
    errors: list[dict[str, Any]] = []
    if matrix.get("schema_version") != 1:
        errors.append({"type": "invalid_schema_version"})

    required_items = requirements.get("requirements")
    if not isinstance(required_items, list):
        errors.append({"type": "requirements_contract_missing"})
        required_items = []
    requirement_by_id = {
        str(item.get("id")): item for item in required_items if isinstance(item, dict) and item.get("id")
    }
    expected_ids = set(requirement_by_id)
    source_text_by_id = _source_text_by_id(master)
    known_sources = set(source_text_by_id)

    entries = matrix.get("requirements")
    if not isinstance(entries, list):
        errors.append({"type": "matrix_requirements_not_list"})
        entries = []
    entry_ids = [str(entry.get("requirement_id") or "") for entry in entries if isinstance(entry, dict)]
    for requirement_id, count in sorted(Counter(entry_ids).items()):
        if not requirement_id:
            errors.append({"type": "missing_requirement_id"})
        elif count > 1:
            errors.append({"type": "duplicate_requirement_id", "requirement_id": requirement_id})
    for requirement_id in sorted(expected_ids - set(entry_ids)):
        errors.append({"type": "missing_requirement", "requirement_id": requirement_id})
    for requirement_id in sorted(set(entry_ids) - expected_ids):
        errors.append({"type": "unknown_requirement_id", "requirement_id": requirement_id})

    for index, entry in enumerate(entries):
        if not isinstance(entry, dict):
            errors.append({"type": "invalid_matrix_entry", "index": index})
            continue
        status = str(entry.get("status") or "")
        strength = str(entry.get("strength") or "")
        source_ids = entry.get("source_ids") or []
        if status not in STATUSES:
            errors.append({"type": "invalid_status", "index": index, "value": status})
        if strength not in STRENGTHS:
            errors.append({"type": "invalid_strength", "index": index, "value": strength})
        if not isinstance(source_ids, list):
            errors.append({"type": "source_ids_not_list", "index": index})
            source_ids = []
        if status in {"supported", "partial", "contradicted"} and not source_ids:
            errors.append({"type": "missing_source_evidence", "index": index})
        for source_id in sorted({str(item) for item in source_ids}):
            if source_id not in known_sources:
                errors.append({"type": "unknown_source_id", "index": index, "source_id": source_id})
        requirement = requirement_by_id.get(str(entry.get("requirement_id") or ""))
        if status == "supported" and requirement and (requirement.get("canonical_term") or requirement.get("term")):
            cited_text = "\n".join(source_text_by_id.get(str(source_id), "") for source_id in source_ids)
            if not contains_requirement(cited_text, requirement):
                errors.append(
                    {
                        "type": "unsupported_source_evidence",
                        "index": index,
                        "requirement_id": str(entry.get("requirement_id") or ""),
                    }
                )
        if not str(entry.get("notes") or "").strip():
            errors.append({"type": "missing_notes", "index": index})

    expected_eligibility = _expected_eligibility(requirement_by_id, entries)
    actual_eligibility = str(matrix.get("eligibility") or "")
    if actual_eligibility not in ELIGIBILITY:
        errors.append({"type": "invalid_eligibility", "value": actual_eligibility})
    if actual_eligibility != expected_eligibility:
        errors.append(
            {
                "type": "eligibility_mismatch",
                "expected": expected_eligibility,
                "actual": actual_eligibility,
            }
        )

    recommendation = str(matrix.get("recommendation") or "")
    if recommendation not in RECOMMENDATIONS:
        errors.append({"type": "invalid_recommendation", "value": recommendation})
    elif expected_eligibility == "ineligible" and recommendation != "reconsider":
        errors.append({"type": "recommendation_conflicts_with_eligibility"})
    elif expected_eligibility == "review" and recommendation == "apply":
        errors.append({"type": "recommendation_conflicts_with_eligibility"})

    return {
        "schema_version": 1,
        "valid": not errors,
        "expected_requirements": len(expected_ids),
        "matrix_entries": len(entries),
        "known_source_ids": len(known_sources),
        "derived_eligibility": expected_eligibility,
        "errors": sorted(
            errors,
            key=lambda item: (
                str(item.get("type", "")),
                str(item.get("requirement_id", "")),
                int(item.get("index", -1)),
            ),
        ),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--matrix", required=True, type=Path)
    parser.add_argument("--requirements", required=True, type=Path)
    parser.add_argument("--master", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    report = validate_evidence_matrix(
        json.loads(args.matrix.read_text(encoding="utf-8")),
        json.loads(args.requirements.read_text(encoding="utf-8")),
        json.loads(args.master.read_text(encoding="utf-8")),
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return 0 if report["valid"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
