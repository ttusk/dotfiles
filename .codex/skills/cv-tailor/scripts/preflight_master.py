#!/usr/bin/env python3
"""Diagnose CV master-record completeness before tailoring a vacancy."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


FIELD_RE = re.compile(r"^\*\*([^*]+):\*\*\s*(.+)$", re.MULTILINE)
EMAIL_RE = re.compile(r"\b[^\s@]+@[^\s@]+\.[^\s@]+\b")
PHONE_RE = re.compile(r"(?:\+?\d[\d\s().-]{8,}\d)")
METRIC_RE = re.compile(
    r"(?<!\w)\d+(?:[.,]\d+)?\s*(?:%|x|ms|segundos?|minutos?|horas?|dias?|meses?|anos?|"
    r"testes?|serviços?|estágios?|usuários?|registros?|endpoints?|pipelines?|workers?)(?!\w)",
    re.IGNORECASE,
)
ORGANIZATION_FIELDS = {"empresa", "instituição", "instituições responsáveis", "projeto"}
ROLE_FIELDS = {"função", "cargo", "papel"}
PERIOD_FIELDS = {"período", "datas"}
STATUS_POINTS = {"missing": 0, "partial": 50, "present": 100}


def _fields(text: str) -> dict[str, str]:
    return {key.strip().casefold(): value.strip() for key, value in FIELD_RE.findall(text)}


def _category(status: str, evidence: list[str], issues: list[str]) -> dict[str, Any]:
    return {"status": status, "evidence": evidence, "issues": issues}


def preflight_master(master: dict[str, Any]) -> dict[str, Any]:
    profile_text = str((master.get("profile") or {}).get("text") or "")
    skills_text = str((master.get("skills") or {}).get("text") or "")
    profile_fields = _fields(profile_text)
    experiences = [item for item in master.get("experiences", []) if isinstance(item, dict)]

    personal_evidence = [
        label
        for label, present in (
            ("name", bool(profile_fields.get("nome") or profile_fields.get("name"))),
            ("location", bool(profile_fields.get("localização") or profile_fields.get("location"))),
        )
        if present
    ]
    personal_status = "present" if len(personal_evidence) == 2 else "partial" if personal_evidence else "missing"

    contact_evidence = []
    if EMAIL_RE.search(profile_text):
        contact_evidence.append("email")
    if PHONE_RE.search(profile_text):
        contact_evidence.append("phone")
    contact_status = "present" if len(contact_evidence) == 2 else "partial" if contact_evidence else "missing"

    experience_evidence = []
    experience_issues: list[str] = []
    for item in experiences:
        source = str(item.get("source") or "unknown")
        fields = {str(key).casefold(): value for key, value in (item.get("fields") or {}).items()}
        if item.get("bullets"):
            experience_evidence.append(f"{source}:bullets")
        else:
            experience_issues.append(f"{source}: no source-backed bullets")
        if not any(fields.get(key) for key in ORGANIZATION_FIELDS):
            experience_issues.append(f"{source}: organization/project missing")
        if not any(fields.get(key) for key in ROLE_FIELDS):
            experience_issues.append(f"{source}: canonical role missing")
        if not any(fields.get(key) for key in PERIOD_FIELDS):
            experience_issues.append(f"{source}: period missing")
    if not experiences or not experience_evidence:
        experience_status = "missing"
    elif experience_issues:
        experience_status = "partial"
    else:
        experience_status = "present"

    education_evidence = [key for key in profile_fields if key in {"formação", "educação", "education"}]
    education_status = "present" if education_evidence else "missing"
    skills_status = "present" if len(skills_text.strip()) >= 20 else "partial" if skills_text.strip() else "missing"

    metric_sources = [
        str(item.get("source"))
        for item in experiences
        if any(METRIC_RE.search(str(bullet.get("text") or "")) for bullet in item.get("bullets", []))
    ]
    metrics_status = "present" if metric_sources else "missing"
    language_evidence = [key for key in profile_fields if key in {"idiomas", "languages", "línguas"}]
    languages_status = "present" if language_evidence else "missing"

    categories = {
        "personal_data": _category(
            personal_status,
            personal_evidence,
            [] if personal_status == "present" else ["Add missing name/location only from verified data."],
        ),
        "professional_experience": _category(experience_status, experience_evidence, experience_issues),
        "education": _category(
            education_status,
            education_evidence,
            [] if education_evidence else ["Education is not explicitly recorded in the profile."],
        ),
        "technical_skills": _category(
            skills_status,
            [str((master.get("skills") or {}).get("source"))] if skills_text.strip() else [],
            [] if skills_status == "present" else ["Technical skills record is missing or too sparse."],
        ),
        "metric_achievements": _category(
            metrics_status,
            sorted(set(metric_sources)),
            [] if metric_sources else ["No verified metric was found; do not invent one."],
        ),
        "contact": _category(
            contact_status,
            contact_evidence,
            [] if contact_status == "present" else ["Add missing email/phone only from verified data."],
        ),
        "languages": _category(
            languages_status,
            language_evidence,
            [] if language_evidence else ["Language level is not explicitly recorded."],
        ),
    }
    overall = round(sum(STATUS_POINTS[item["status"]] for item in categories.values()) / len(categories))
    blockers = [
        name
        for name in ("personal_data", "professional_experience", "technical_skills", "contact")
        if categories[name]["status"] == "missing"
    ]
    return {
        "schema_version": 1,
        "ready_for_tailoring": not blockers,
        "overall_completeness": overall,
        "blockers": blockers,
        "categories": categories,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--master", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    report = preflight_master(json.loads(args.master.read_text(encoding="utf-8")))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return 0 if report["ready_for_tailoring"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
