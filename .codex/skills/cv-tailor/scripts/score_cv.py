#!/usr/bin/env python3
"""Compute a deterministic, honest Job Match Score for a tailored CV."""

from __future__ import annotations

import argparse
import json
import re
import unicodedata
from pathlib import Path
from typing import Any, Iterable


WEIGHTS = {
    "must_have_coverage": 35,
    "experience_evidence": 25,
    "nice_to_have_coverage": 15,
    "responsibility_alignment": 15,
    "document_quality": 10,
}


def normalize(value: str) -> str:
    decomposed = unicodedata.normalize("NFKD", value.casefold())
    without_accents = "".join(char for char in decomposed if not unicodedata.combining(char))
    return re.sub(r"[^a-z0-9+#.]+", " ", without_accents).strip()


def _variants(requirement: dict[str, Any]) -> list[str]:
    term = requirement.get("term") or requirement.get("canonical_term") or requirement.get("text") or ""
    aliases = requirement.get("aliases") or []
    return [item for item in [term, *aliases] if isinstance(item, str) and item.strip()]


def contains_requirement(text: str, requirement: dict[str, Any]) -> bool:
    normalized_text = normalize(text)
    return any(
        bool(
            normalized_variant
            and re.search(
                rf"(?<![a-z0-9]){re.escape(normalized_variant)}(?![a-z0-9])",
                normalized_text,
            )
        )
        for normalized_variant in (normalize(variant) for variant in _variants(requirement))
    )


def _sorted(items: Iterable[dict[str, Any]]) -> list[dict[str, Any]]:
    return sorted(items, key=lambda item: (str(item.get("id", "")), str(item.get("term", item.get("text", "")))))


def _group_requirements(payload: dict[str, Any]) -> tuple[list[dict[str, Any]], list[dict[str, Any]], list[dict[str, Any]]]:
    if "requirements" not in payload:
        return (
            _sorted(payload.get("must_have", [])),
            _sorted(payload.get("nice_to_have", [])),
            _sorted(payload.get("responsibilities", [])),
        )

    must: list[dict[str, Any]] = []
    nice: list[dict[str, Any]] = []
    responsibilities: list[dict[str, Any]] = []
    for item in payload.get("requirements", []):
        normalized_item = dict(item)
        normalized_item.setdefault("term", item.get("canonical_term") or item.get("text"))
        if item.get("category") == "responsibility":
            responsibilities.append(normalized_item)
        elif item.get("priority") == "preferred":
            nice.append(normalized_item)
        else:
            must.append(normalized_item)
    return _sorted(must), _sorted(nice), _sorted(responsibilities)


def _experience_text(cv_text: str) -> str:
    lines: list[str] = []
    in_experience = False
    for raw_line in cv_text.splitlines():
        stripped = raw_line.strip()
        if stripped.startswith("== "):
            heading = normalize(stripped[3:])
            in_experience = "experiencia" in heading or "experience" in heading
            continue
        if in_experience and stripped.startswith("- "):
            lines.append(stripped[2:])
    return "\n".join(lines)


def _supported_by_provenance(requirement: dict[str, Any], provenance: dict[str, Any]) -> bool:
    for bullet in provenance.get("bullets", []):
        generated = str(bullet.get("generated_text") or bullet.get("rendered_bullet") or "")
        if not contains_requirement(generated, requirement):
            continue
        excerpts = [str(bullet.get("source_excerpt") or "")]
        excerpts.extend(str(source.get("excerpt") or "") for source in bullet.get("sources", []))
        if bullet.get("source_id") and any(contains_requirement(excerpt, requirement) for excerpt in excerpts):
            return True
        if bullet.get("sources") and any(contains_requirement(excerpt, requirement) for excerpt in excerpts):
            return True
    return False


def _ratio(matched: int, total: int) -> float:
    return 1.0 if total == 0 else matched / total


def _document_quality(verification: dict[str, Any]) -> tuple[int, list[dict[str, str]]]:
    checks = {
        "compile_success": bool(verification.get("compile_success")),
        "one_page": verification.get("page_count") == 1,
        "searchable_text": bool(verification.get("searchable_text")),
        "links_valid": bool(verification.get("links_valid")),
        "clean_structure": not verification.get("forbidden_constructs") and not verification.get("placeholders"),
    }
    score = sum(2 for passed in checks.values() if passed)
    gaps = [
        {"type": "document_quality", "requirement": name}
        for name, passed in sorted(checks.items())
        if not passed
    ]
    return score, gaps


def score_cv(
    requirements: dict[str, Any],
    cv_text: str,
    provenance: dict[str, Any] | None = None,
    verification: dict[str, Any] | None = None,
    evidence_matrix: dict[str, Any] | None = None,
    provenance_validation: dict[str, Any] | None = None,
    evidence_matrix_validation: dict[str, Any] | None = None,
) -> dict[str, Any]:
    provenance = provenance or {"bullets": []}
    verification = verification or {}
    evidence_matrix = evidence_matrix or {"requirements": []}
    provenance_is_valid = provenance_validation is None or bool(provenance_validation.get("valid"))
    matrix_is_valid = evidence_matrix_validation is None or bool(evidence_matrix_validation.get("valid"))
    if not matrix_is_valid:
        evidence_matrix = {"requirements": []}
    must, nice, responsibilities = _group_requirements(requirements)
    experience_text = _experience_text(cv_text)

    must_matches = [item for item in must if contains_requirement(cv_text, item)]
    nice_matches = [item for item in nice if contains_requirement(cv_text, item)]
    responsibility_matches = [
        item
        for item in responsibilities
        if provenance_is_valid
        and contains_requirement(experience_text, item)
        and _supported_by_provenance(item, provenance)
    ]
    evidence_candidates = [item for item in must if item.get("expected_evidence", "experience") == "experience"]
    evidence_matches = [
        item
        for item in evidence_candidates
        if provenance_is_valid
        and contains_requirement(experience_text, item)
        and _supported_by_provenance(item, provenance)
    ]

    components = {
        "must_have_coverage": round(WEIGHTS["must_have_coverage"] * _ratio(len(must_matches), len(must))),
        "experience_evidence": round(
            WEIGHTS["experience_evidence"] * _ratio(len(evidence_matches), len(evidence_candidates))
        ),
        "nice_to_have_coverage": round(WEIGHTS["nice_to_have_coverage"] * _ratio(len(nice_matches), len(nice))),
        "responsibility_alignment": round(
            WEIGHTS["responsibility_alignment"] * _ratio(len(responsibility_matches), len(responsibilities))
        ),
    }
    document_score, document_gaps = _document_quality(verification)
    components["document_quality"] = document_score
    match_score = sum(components.values())

    gaps: list[dict[str, str]] = []
    if not provenance_is_valid:
        gaps.append({"type": "invalid_provenance", "requirement": "provenance-validation.json"})
    if not matrix_is_valid:
        gaps.append({"type": "invalid_evidence_matrix", "requirement": "evidence-matrix-validation.json"})
    for item in must:
        label = str(item.get("term") or item.get("canonical_term") or item.get("text"))
        if item not in must_matches:
            gaps.append({"type": "missing_must_have", "requirement": label})
        elif item.get("expected_evidence", "experience") == "experience" and item not in evidence_matches:
            gaps.append({"type": "missing_evidence", "requirement": label})
    for item in nice:
        if item not in nice_matches:
            gaps.append(
                {
                    "type": "missing_nice_to_have",
                    "requirement": str(item.get("term") or item.get("canonical_term") or item.get("text")),
                }
            )
    gaps.extend(document_gaps)

    matrix_status = {
        str(item.get("requirement_id")): str(item.get("status"))
        for item in evidence_matrix.get("requirements", [])
    }
    knockout_failed = [
        item
        for item in must
        if item.get("knockout")
        and (item.get("assessment") == "not_met" or matrix_status.get(str(item.get("id"))) == "contradicted")
    ]
    knockout_missing = [
        item
        for item in must
        if item.get("knockout")
        and item not in knockout_failed
        and (
            matrix_status.get(str(item.get("id"))) in {"missing", "partial", "unknown"}
            or (str(item.get("id")) not in matrix_status and item not in must_matches)
        )
    ]
    eligibility = "ineligible" if knockout_failed else "review" if knockout_missing else "eligible"

    evidence_ratio = _ratio(len(evidence_matches), len(evidence_candidates))
    if eligibility == "ineligible" or (evidence_candidates and evidence_ratio < 0.5):
        decision = "weak_match"
    elif match_score >= 80 and eligibility == "eligible":
        decision = "strong_match"
    elif match_score >= 60:
        decision = "potential_match"
    else:
        decision = "weak_match"

    if not provenance_is_valid or not matrix_is_valid or eligibility == "ineligible" or decision == "weak_match":
        recommendation = "reconsider"
    elif decision == "strong_match" and eligibility == "eligible":
        recommendation = "apply"
    else:
        recommendation = "apply_with_caveats"

    return {
        "schema_version": 1,
        "score_name": "Job Match Score",
        "disclaimer": "Estimativa local e determinística; não representa um ATS universal nem garante entrevista.",
        "match_score": match_score,
        "decision": decision,
        "recommendation": recommendation,
        "eligibility": eligibility,
        "input_validity": {
            "provenance": provenance_is_valid,
            "evidence_matrix": matrix_is_valid,
        },
        "components": components,
        "coverage": {
            "must_have": {"matched": len(must_matches), "total": len(must)},
            "experience_evidence": {"matched": len(evidence_matches), "total": len(evidence_candidates)},
            "nice_to_have": {"matched": len(nice_matches), "total": len(nice)},
            "responsibilities": {"matched": len(responsibility_matches), "total": len(responsibilities)},
        },
        "gaps": sorted(gaps, key=lambda item: (item["type"], item["requirement"])),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--requirements", required=True, type=Path)
    parser.add_argument("--cv", required=True, type=Path)
    parser.add_argument("--provenance", required=True, type=Path)
    parser.add_argument("--verification", required=True, type=Path)
    parser.add_argument("--evidence-matrix", type=Path)
    parser.add_argument("--provenance-validation", required=True, type=Path)
    parser.add_argument("--evidence-matrix-validation", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    result = score_cv(
        json.loads(args.requirements.read_text(encoding="utf-8")),
        args.cv.read_text(encoding="utf-8"),
        json.loads(args.provenance.read_text(encoding="utf-8")),
        json.loads(args.verification.read_text(encoding="utf-8")),
        json.loads(args.evidence_matrix.read_text(encoding="utf-8")) if args.evidence_matrix else None,
        json.loads(args.provenance_validation.read_text(encoding="utf-8")),
        json.loads(args.evidence_matrix_validation.read_text(encoding="utf-8")),
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
