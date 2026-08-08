#!/usr/bin/env python3
"""Compile a Typst CV and verify the delivered PDF, text, links, and layout gates."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path
from typing import Any
from urllib.parse import urlparse


FORBIDDEN_PATTERNS = {
    "table": r"#table\s*\(",
    "grid": r"#grid\s*\(",
    "columns": r"#columns\s*\(",
    "image": r"#image\s*\(",
    "forced_pagebreak": r"#pagebreak\s*\(",
}
PLACEHOLDER_PATTERNS = [
    r"\{\{[^}]+\}\}",
    r"\[[A-ZÁÉÍÓÚÇ_ -]{3,}\]",
    r"\b(?:TODO|PLACEHOLDER)\b",
    r"\bREPLACE_[A-Z0-9_]+\b",
]


def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _extract_pdf(pdf_path: Path) -> tuple[int | None, str, list[str], str | None]:
    try:
        from pypdf import PdfReader
    except ImportError:
        return None, "", [], "pypdf is required; run with the bundled Codex Python runtime"

    reader = PdfReader(str(pdf_path))
    text = "\n".join((page.extract_text() or "") for page in reader.pages)
    links: list[str] = []
    for page in reader.pages:
        annotations = page.get("/Annots") or []
        for annotation_ref in annotations:
            annotation = annotation_ref.get_object()
            action = annotation.get("/A")
            uri = action.get("/URI") if action else None
            if uri:
                links.append(str(uri))
    return len(reader.pages), text, sorted(set(links)), None


def _valid_uri(uri: str) -> bool:
    if uri.startswith("mailto:"):
        return "@" in uri[7:]
    parsed = urlparse(uri)
    return parsed.scheme == "https" and bool(parsed.hostname) and "." in parsed.hostname


def _required_link_types(links: list[str]) -> dict[str, bool]:
    found = {"email": False, "github": False, "linkedin": False}
    for uri in links:
        if uri.startswith("mailto:") and _valid_uri(uri):
            found["email"] = True
            continue
        parsed = urlparse(uri)
        host = (parsed.hostname or "").casefold()
        path = parsed.path.casefold()
        if parsed.scheme == "https" and host in {"github.com", "www.github.com"} and path.strip("/"):
            found["github"] = True
        if parsed.scheme == "https" and host in {"linkedin.com", "www.linkedin.com"} and path.startswith("/in/"):
            found["linkedin"] = True
    return found


def verify_typst(
    typ_path: str | Path,
    pdf_path: str | Path,
    *,
    max_pages: int = 1,
    expected_text: list[str] | None = None,
    typst_executable: str | None = None,
    preview_dir: str | Path | None = None,
    pdftoppm_executable: str | None = None,
) -> dict[str, Any]:
    typ_path = Path(typ_path).resolve()
    pdf_path = Path(pdf_path).resolve()
    source = typ_path.read_text(encoding="utf-8")
    expected_text = expected_text or []
    typst = typst_executable or shutil.which("typst")
    if not typst:
        return {
            "compile_success": False,
            "error": "typst executable not found",
            "page_count": None,
            "searchable_text": False,
            "links_valid": False,
            "forbidden_constructs": [],
            "placeholders": [],
        }

    forbidden = sorted(name for name, pattern in FORBIDDEN_PATTERNS.items() if re.search(pattern, source))
    placeholders = sorted({match.group(0) for pattern in PLACEHOLDER_PATTERNS for match in re.finditer(pattern, source)})
    pdf_path.parent.mkdir(parents=True, exist_ok=True)
    completed = subprocess.run(
        [typst, "compile", str(typ_path), str(pdf_path)],
        capture_output=True,
        text=True,
        check=False,
    )
    compile_success = completed.returncode == 0 and pdf_path.is_file()
    page_count: int | None = None
    extracted_text = ""
    links: list[str] = []
    extraction_error: str | None = None
    if compile_success:
        page_count, extracted_text, links, extraction_error = _extract_pdf(pdf_path)

    normalized_text = " ".join(extracted_text.split()).casefold()
    missing_expected = [item for item in expected_text if item.casefold() not in normalized_text]
    searchable_text = len(normalized_text) >= 100 and not missing_expected
    invalid_links = [uri for uri in links if not _valid_uri(uri)]
    required_links = _required_link_types(links)
    missing_required_links = sorted(name for name, present in required_links.items() if not present)
    links_valid = not invalid_links and not missing_required_links
    page_limit_ok = page_count is not None and page_count <= max_pages

    previews: list[str] = []
    renderer = pdftoppm_executable or shutil.which("pdftoppm")
    if compile_success and preview_dir and renderer:
        preview_root = Path(preview_dir).resolve()
        preview_root.mkdir(parents=True, exist_ok=True)
        prefix = preview_root / pdf_path.stem
        render = subprocess.run(
            [renderer, "-png", "-r", "150", str(pdf_path), str(prefix)],
            capture_output=True,
            text=True,
            check=False,
        )
        if render.returncode == 0:
            previews = [str(path) for path in sorted(preview_root.glob(f"{pdf_path.stem}-*.png"))]

    valid = all(
        [
            compile_success,
            page_limit_ok,
            searchable_text,
            links_valid,
            not forbidden,
            not placeholders,
            not missing_expected,
        ]
    )
    return {
        "schema_version": 1,
        "valid": valid,
        "compile_success": compile_success,
        "compiler_exit_code": completed.returncode,
        "compiler_stderr": completed.stderr,
        "compiler_warnings": completed.stderr.casefold().count("warning"),
        "page_count": page_count,
        "max_pages": max_pages,
        "page_limit_ok": page_limit_ok,
        "searchable_text": searchable_text,
        "extracted_text_length": len(extracted_text),
        "missing_expected_text": missing_expected,
        "links": links,
        "invalid_links": invalid_links,
        "required_links": required_links,
        "missing_required_links": missing_required_links,
        "links_valid": links_valid,
        "forbidden_constructs": forbidden,
        "placeholders": placeholders,
        "extraction_error": extraction_error,
        "previews": previews,
        "typ_sha256": _sha256(typ_path),
        "pdf_sha256": _sha256(pdf_path) if compile_success else None,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--typ", required=True, type=Path)
    parser.add_argument("--pdf", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--max-pages", type=int, default=1)
    parser.add_argument("--expected-text", action="append", default=[])
    parser.add_argument("--preview-dir", type=Path)
    parser.add_argument("--pdftoppm")
    args = parser.parse_args()
    report = verify_typst(
        args.typ,
        args.pdf,
        max_pages=args.max_pages,
        expected_text=args.expected_text,
        preview_dir=args.preview_dir,
        pdftoppm_executable=args.pdftoppm,
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return 0 if report["valid"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
