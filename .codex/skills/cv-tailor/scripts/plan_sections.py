#!/usr/bin/env python3
"""Plan CV sections from the job context instead of filling a fixed template."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


VALID_LANGUAGES = {"pt", "en"}
VALID_MARKETS = {"brazil", "international", "unknown"}
VALID_SCOPES = {"local", "national", "multinational", "international", "unknown"}
VALID_INTERACTION = {"yes", "no", "unknown"}
VALID_LANGUAGE_SIGNALS = {"absent", "preferred", "required", "knockout"}
VALID_LANGUAGE_POLICIES = {"contextual", "always", "never"}

LANGUAGE_SIGNAL_RANK = {"absent": 0, "preferred": 1, "required": 2, "knockout": 3}


def _load_json(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError(f"Expected a JSON object in {path}")
    return value


def _language_signal(requirements: dict[str, Any]) -> str:
    language_requirements = [
        item
        for item in requirements.get("requirements", [])
        if isinstance(item, dict) and item.get("category") == "language"
    ]
    if any(item.get("knockout") for item in language_requirements):
        return "knockout"
    if any(item.get("priority") == "must" for item in language_requirements):
        return "required"
    if language_requirements:
        return "preferred"
    return "absent"


def _normalize_context(
    requirements: dict[str, Any], context: dict[str, Any] | None,
) -> tuple[dict[str, Any], list[str]]:
    raw = context or {}
    errors: list[str] = []

    document_language = raw.get("document_language") or requirements.get("language") or "pt"
    if document_language not in VALID_LANGUAGES:
        errors.append("document_language must be pt or en")
        document_language = requirements.get("language") if requirements.get("language") in VALID_LANGUAGES else "pt"

    market = raw.get("market", "unknown")
    if market not in VALID_MARKETS:
        errors.append(f"market must be one of {sorted(VALID_MARKETS)}")
        market = "unknown"

    company_scope = raw.get("company_scope", "unknown")
    if company_scope not in VALID_SCOPES:
        errors.append(f"company_scope must be one of {sorted(VALID_SCOPES)}")
        company_scope = "unknown"

    international_interaction = raw.get("international_interaction", "unknown")
    if international_interaction not in VALID_INTERACTION:
        errors.append(f"international_interaction must be one of {sorted(VALID_INTERACTION)}")
        international_interaction = "unknown"

    derived_language_signal = _language_signal(requirements)
    raw_language_signal = raw.get("explicit_language_signal")
    if raw_language_signal is None:
        explicit_language_signal = derived_language_signal
    elif raw_language_signal not in VALID_LANGUAGE_SIGNALS:
        errors.append(f"explicit_language_signal must be one of {sorted(VALID_LANGUAGE_SIGNALS)}")
        explicit_language_signal = derived_language_signal
    else:
        explicit_language_signal = max(
            (derived_language_signal, raw_language_signal),
            key=LANGUAGE_SIGNAL_RANK.get,
        )

    normalized = {
        "schema_version": 1,
        "document_language": document_language,
        "market": market,
        "company_scope": company_scope,
        "international_interaction": international_interaction,
        "explicit_language_signal": explicit_language_signal,
        "role": str(raw.get("role") or requirements.get("role") or ""),
        "evidence": [item for item in raw.get("evidence", []) if isinstance(item, str)],
    }
    return normalized, errors


def _section(decision: str, reason: str, *, priority: str = "optional") -> dict[str, str]:
    return {"decision": decision, "priority": priority, "reason": reason}


def _language_section(
    context: dict[str, Any], preferences: dict[str, Any],
) -> dict[str, str]:
    signal = context["explicit_language_signal"]
    policy = preferences.get("language_policy", "contextual")
    if policy not in VALID_LANGUAGE_POLICIES:
        policy = "contextual"

    if signal == "knockout":
        return _section("include", "language is an explicit knockout requirement", priority="required")
    if signal == "required":
        return _section("include", "language is an explicit job requirement", priority="required")
    if signal == "preferred":
        return _section("include", "language is an explicit job preference", priority="supporting")
    if policy == "always":
        return _section("include", "user preference requests languages", priority="optional")
    if policy == "never":
        return _section("omit", "user preference omits non-required languages", priority="optional")
    if context["document_language"] == "en":
        return _section("include", "English-language application makes language relevant", priority="supporting")

    international_context = (
        context["international_interaction"] == "yes"
        or context["company_scope"] in {"multinational", "international"}
        or context["market"] == "international"
    )
    if international_context:
        return _section("include", "international context makes language relevant", priority="supporting")

    if context["document_language"] == "pt" and context["market"] == "brazil":
        return _section("omit", "local Portuguese application has no language signal", priority="optional")

    return _section("omit", "no explicit or contextual reason to spend CV space on languages", priority="optional")


def plan_sections(
    requirements: dict[str, Any],
    context: dict[str, Any] | None = None,
    preferences: dict[str, Any] | None = None,
) -> dict[str, Any]:
    normalized_context, context_errors = _normalize_context(requirements, context)
    preferences = dict(preferences or {})
    section_policy = {
        "summary": _section("include", "targeted positioning for the named vacancy", priority="supporting"),
        "experience": _section("include", "primary evidence for the application", priority="required"),
        "projects": _section(
            "conditional",
            "include only when project evidence closes a relevant requirement",
            priority="supporting",
        ),
        "skills": _section("include", "compact list of selected relevant skills", priority="supporting"),
        "education": _section(
            "conditional",
            "include prominently only when required or useful for junior hiring",
            priority="supporting",
        ),
        "languages": _language_section(normalized_context, preferences),
    }

    if requirements.get("seniority", {}).get("value") in {"intern", "junior"}:
        section_policy["education"] = _section(
            "include", "junior or internship hiring benefits from visible education", priority="supporting"
        )
    if any(
        isinstance(item, dict) and item.get("category") == "education"
        for item in requirements.get("requirements", [])
    ):
        section_policy["education"] = _section(
            "include", "education is explicitly relevant to the vacancy", priority="required"
        )

    included_sections = [
        name for name, decision in section_policy.items() if decision["decision"] == "include"
    ]
    return {
        "schema_version": 1,
        "valid": not context_errors,
        "errors": context_errors,
        "application_context": normalized_context,
        "preferences": preferences,
        "section_policy": section_policy,
        "included_sections": included_sections,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--requirements", required=True, type=Path)
    parser.add_argument("--context", type=Path)
    parser.add_argument("--preferences", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    requirements = _load_json(args.requirements)
    context = _load_json(args.context) if args.context else None
    preferences = _load_json(args.preferences) if args.preferences else None
    report = plan_sections(requirements, context, preferences)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return 0 if report["valid"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
