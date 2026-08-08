#!/usr/bin/env python3
"""Run a dependency-free structural check of the Codex cv-tailor skill."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


REQUIRED_FILES = {
    "SKILL.md",
    "agents/assemble.md",
    "agents/audit.md",
    "agents/extract.md",
    "assets/resume.typ",
    "references/contracts.md",
    "references/evaluation-cases.md",
    "references/scoring.md",
    "references/workflow.md",
    "references/writing.md",
    "scripts/discover_master.py",
    "scripts/preflight_master.py",
    "scripts/score_cv.py",
    "scripts/validate_evidence_matrix.py",
    "scripts/validate_provenance.py",
    "scripts/validate_requirements.py",
    "scripts/verify_cv.py",
}
REQUIRED_PLACEHOLDERS = {
    "REPLACE_NAME",
    "REPLACE_LOCATION",
    "REPLACE_EMAIL",
    "REPLACE_PHONE",
    "REPLACE_GITHUB",
    "REPLACE_LINKEDIN",
    "REPLACE_SUMMARY",
    "REPLACE_CANONICAL_TITLE",
    "REPLACE_COMPANY",
    "REPLACE_WORK_LOCATION",
    "REPLACE_DATES",
    "REPLACE_GROUNDED_BULLET",
    "REPLACE_CATEGORY",
    "REPLACE_RELEVANT_SKILLS",
    "REPLACE_DEGREE",
    "REPLACE_INSTITUTION",
    "REPLACE_EDUCATION_LOCATION",
    "REPLACE_EDUCATION_DATES",
    "REPLACE_LANGUAGE_AND_LEVEL",
}
REQUIRED_WORKFLOW_COMMANDS = {
    "validate_requirements.py",
    "discover_master.py",
    "preflight_master.py",
    "validate_evidence_matrix.py",
    "validate_provenance.py",
    "verify_cv.py",
    "score_cv.py",
}


def self_check(skill_root: str | Path) -> dict[str, Any]:
    root = Path(skill_root).expanduser().resolve()
    errors: list[dict[str, str]] = []
    for relative in sorted(REQUIRED_FILES):
        if not (root / relative).is_file():
            errors.append({"type": "missing_required_file", "value": relative})

    skill_path = root / "SKILL.md"
    skill = skill_path.read_text(encoding="utf-8") if skill_path.is_file() else ""
    frontmatter = re.match(r"\A---\n(.*?)\n---\n", skill, flags=re.DOTALL)
    if not frontmatter:
        errors.append({"type": "invalid_frontmatter", "value": "missing delimiters"})
    else:
        values: dict[str, str] = {}
        for line in frontmatter.group(1).splitlines():
            if ":" in line:
                key, value = line.split(":", 1)
                values[key.strip()] = value.strip()
        if set(values) != {"name", "description"}:
            errors.append({"type": "invalid_frontmatter_keys", "value": ",".join(sorted(values))})
        if values.get("name") != "cv-tailor":
            errors.append({"type": "invalid_skill_name", "value": values.get("name", "")})
        description = values.get("description", "")
        if not description or len(description) > 1024 or "<" in description or ">" in description:
            errors.append({"type": "invalid_description", "value": description})

    workflow_path = root / "references" / "workflow.md"
    workflow = workflow_path.read_text(encoding="utf-8") if workflow_path.is_file() else ""
    for command in sorted(REQUIRED_WORKFLOW_COMMANDS):
        if command not in workflow:
            errors.append({"type": "workflow_command_missing", "value": command})

    template_path = root / "assets" / "resume.typ"
    template = template_path.read_text(encoding="utf-8") if template_path.is_file() else ""
    placeholders = set(re.findall(r"REPLACE_[A-Z0-9_]+", template))
    for placeholder in sorted(REQUIRED_PLACEHOLDERS - placeholders):
        errors.append({"type": "template_placeholder_missing", "value": placeholder})
    for forbidden in ("#table(", "#grid(", "#columns(", "#image(", "#pagebreak("):
        if forbidden in template:
            errors.append({"type": "forbidden_template_construct", "value": forbidden})

    return {
        "schema_version": 1,
        "valid": not errors,
        "required_files": len(REQUIRED_FILES),
        "template_placeholders": len(placeholders),
        "errors": sorted(errors, key=lambda item: (item["type"], item["value"])),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--skill-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    report = self_check(args.skill_root)
    rendered = json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
    else:
        print(rendered, end="")
    return 0 if report["valid"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
