#!/usr/bin/env python3
"""Discover and parse the editable CV master record without fixed filenames."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import unicodedata
from pathlib import Path
from typing import Any


EXCLUDED_FILES = {"index.md", "habilidades.md"}
EXCLUDED_DIRS = {"credenciais", "exports", "tmp", "versoes"}
FIELD_RE = re.compile(r"^\*\*([^*]+):\*\*\s*(.*)$")
EXCLUDED_BULLET_SECTIONS = {
    "evidencia",
    "evidencias",
    "evidence",
    "fonte",
    "fonte tecnica",
    "fontes",
    "fontes publicas",
    "links",
    "metadata",
    "metadados",
    "notas",
    "referencias",
    "references",
    "relacoes",
}


def _sha256(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def _normalize_heading(value: str) -> str:
    decomposed = unicodedata.normalize("NFKD", value.casefold())
    ascii_value = "".join(char for char in decomposed if not unicodedata.combining(char))
    return re.sub(r"[^a-z0-9]+", " ", ascii_value).strip()


def _without_frontmatter(lines: list[str]) -> list[tuple[int, str]]:
    numbered = list(enumerate(lines, start=1))
    if not lines or lines[0].strip() != "---":
        return numbered
    for index in range(1, len(lines)):
        if lines[index].strip() == "---":
            return numbered[index + 1 :]
    return numbered


def parse_career_note(path: Path, root: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    content = _without_frontmatter(lines)
    title = path.stem.replace("-", " ").title()
    fields: dict[str, str] = {}
    field_sources: dict[str, str] = {}
    bullets: list[dict[str, Any]] = []
    current_section = ""

    for line_number, line in content:
        stripped = line.strip()
        if stripped.startswith("# ") and title == path.stem.replace("-", " ").title():
            title = stripped[2:].strip()
        if stripped.startswith("## "):
            current_section = stripped[3:].strip()
        field_match = FIELD_RE.match(stripped)
        if field_match:
            key, value = field_match.groups()
            fields[key.strip()] = value.strip()
            field_sources[key.strip()] = f"{path.name}:L{line_number}"
        normalized_section = _normalize_heading(current_section)
        if stripped.startswith("- ") and normalized_section not in EXCLUDED_BULLET_SECTIONS:
            bullet_text = stripped[2:].strip()
            bullets.append(
                {
                    "text": bullet_text,
                    "section": current_section or None,
                    "line_start": line_number,
                    "line_end": line_number,
                    "source_id": f"{path.name}:L{line_number}",
                }
            )

    kind = "experience" if any(key in fields for key in ("Empresa", "Instituição", "Função", "Período")) else "project"
    return {
        "source": path.relative_to(root).as_posix(),
        "source_sha256": _sha256(text),
        "kind": kind,
        "title": title,
        "fields": fields,
        "field_sources": field_sources,
        "bullets": bullets,
    }


def _read_special(root: Path, filename: str) -> dict[str, str] | None:
    path = root / filename
    if not path.is_file() or path.is_symlink():
        return None
    text = path.read_text(encoding="utf-8")
    return {"source": filename, "source_sha256": _sha256(text), "text": text}


def discover_master(curriculo_root: str | Path) -> dict[str, Any]:
    root = Path(curriculo_root).expanduser().resolve()
    if not root.is_dir():
        raise ValueError(f"Currículo root is not a directory: {root}")
    if root.name in EXCLUDED_DIRS or "credenciais" in root.parts:
        raise ValueError("Refusing to discover a private or output-only directory")

    experiences: list[dict[str, Any]] = []
    for path in sorted(root.glob("*.md"), key=lambda item: item.name.casefold()):
        if path.name in EXCLUDED_FILES or path.name.startswith(".") or path.is_symlink():
            continue
        resolved = path.resolve()
        if resolved.parent != root:
            continue
        experiences.append(parse_career_note(resolved, root))

    return {
        "schema_version": 1,
        "root": str(root),
        "profile": _read_special(root, "index.md"),
        "skills": _read_special(root, "habilidades.md"),
        "experiences": experiences,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--curriculo", required=True, type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    payload = discover_master(args.curriculo)
    rendered = json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
    else:
        print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
