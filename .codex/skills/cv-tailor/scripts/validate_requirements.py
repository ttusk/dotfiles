#!/usr/bin/env python3
"""Validate the Codex cv-tailor requirements contract with only the standard library."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path
from typing import Any

from score_cv import normalize


PRIORITIES = {"must", "preferred"}
CATEGORIES = {
    "authorization",
    "education",
    "experience",
    "language",
    "location",
    "other",
    "responsibility",
    "soft_skill",
    "technology",
}
EVIDENCE_TYPES = {"education", "experience", "profile", "skill"}
SENIORITIES = {"intern", "junior", "mid", "senior", "staff", "lead", "manager", "unspecified"}


def requirement_id(requirement: dict[str, Any]) -> str:
    identity = {
        "priority": requirement.get("priority"),
        "category": requirement.get("category"),
        "text": normalize(str(requirement.get("text") or "")),
        "canonical_term": normalize(str(requirement.get("canonical_term") or "")),
        "aliases": sorted(normalize(str(item)) for item in requirement.get("aliases") or []),
        "expected_evidence": requirement.get("expected_evidence"),
        "knockout": bool(requirement.get("knockout")),
    }
    digest = hashlib.sha256(
        json.dumps(identity, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    ).hexdigest()
    return f"req-{digest[:12]}"


def canonicalize_requirements(payload: dict[str, Any]) -> dict[str, Any]:
    canonical = json.loads(json.dumps(payload, ensure_ascii=False))
    items = []
    for requirement in canonical.get("requirements") or []:
        requirement["id"] = requirement_id(requirement)
        requirement["aliases"] = sorted(set(requirement.get("aliases") or []), key=lambda item: normalize(str(item)))
        items.append(requirement)
    canonical["requirements"] = sorted(items, key=lambda item: item["id"])
    return canonical


def validate_requirements(payload: dict[str, Any]) -> dict[str, Any]:
    errors: list[dict[str, Any]] = []
    if payload.get("schema_version") != 1:
        errors.append({"type": "invalid_schema_version"})

    source = payload.get("source")
    if not isinstance(source, dict):
        errors.append({"type": "missing_source"})
    else:
        if source.get("kind") not in {"pasted", "url"}:
            errors.append({"type": "invalid_source_kind"})
        if not re.fullmatch(r"[0-9a-f]{64}", str(source.get("sha256") or "")):
            errors.append({"type": "invalid_source_sha256"})
        if source.get("kind") == "url" and not source.get("url"):
            errors.append({"type": "missing_source_url"})
        if not source.get("captured_at"):
            errors.append({"type": "missing_capture_time"})

    if payload.get("language") not in {"pt", "en"}:
        errors.append({"type": "invalid_language"})
    if not str(payload.get("role") or "").strip():
        errors.append({"type": "missing_role"})

    seniority = payload.get("seniority")
    if not isinstance(seniority, dict):
        errors.append({"type": "missing_seniority"})
    else:
        if seniority.get("value") not in SENIORITIES:
            errors.append({"type": "invalid_seniority"})
        confidence = seniority.get("confidence")
        if not isinstance(confidence, (int, float)) or not 0 <= confidence <= 1:
            errors.append({"type": "invalid_seniority_confidence"})
        if not isinstance(seniority.get("evidence"), list):
            errors.append({"type": "invalid_seniority_evidence"})

    requirements = payload.get("requirements")
    if not isinstance(requirements, list) or not requirements:
        errors.append({"type": "missing_requirements"})
        requirements = []

    seen_ids: set[str] = set()
    for index, requirement in enumerate(requirements):
        if not isinstance(requirement, dict):
            errors.append({"type": "invalid_requirement", "index": index})
            continue
        requirement_id_value = str(requirement.get("id") or "")
        expected_id = requirement_id(requirement)
        if requirement_id_value != expected_id:
            errors.append(
                {
                    "type": "unstable_requirement_id",
                    "index": index,
                    "expected": expected_id,
                    "actual": requirement_id_value,
                }
            )
        if requirement_id_value in seen_ids:
            errors.append({"type": "duplicate_requirement_id", "index": index, "id": requirement_id_value})
        seen_ids.add(requirement_id_value)
        if requirement.get("priority") not in PRIORITIES:
            errors.append({"type": "invalid_priority", "index": index})
        if requirement.get("category") not in CATEGORIES:
            errors.append({"type": "invalid_category", "index": index})
        if requirement.get("expected_evidence") not in EVIDENCE_TYPES:
            errors.append({"type": "invalid_expected_evidence", "index": index})
        if not str(requirement.get("text") or "").strip():
            errors.append({"type": "missing_requirement_text", "index": index})
        if not str(requirement.get("canonical_term") or "").strip():
            errors.append({"type": "missing_canonical_term", "index": index})
        if not str(requirement.get("job_evidence") or "").strip():
            errors.append({"type": "missing_job_evidence", "index": index})
        if not isinstance(requirement.get("aliases"), list):
            errors.append({"type": "invalid_aliases", "index": index})
        if not isinstance(requirement.get("knockout"), bool):
            errors.append({"type": "invalid_knockout", "index": index})

    return {
        "schema_version": 1,
        "valid": not errors,
        "requirements": len(requirements),
        "errors": sorted(errors, key=lambda item: (item["type"], item.get("index", -1))),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--requirements", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--canonical-output", type=Path)
    args = parser.parse_args()
    payload = json.loads(args.requirements.read_text(encoding="utf-8"))
    if args.canonical_output:
        payload = canonicalize_requirements(payload)
        args.canonical_output.parent.mkdir(parents=True, exist_ok=True)
        args.canonical_output.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
    report = validate_requirements(payload)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return 0 if report["valid"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
