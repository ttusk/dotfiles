# pdf-inspector CLI reference

## Installed build

- Upstream: `https://github.com/firecrawl/pdf-inspector`
- Pinned tag: `v0.7.0`
- Commit: `20f24d1f8d4ade4f76224ef7c930c83f4423390a`
- License: MIT
- Installed binaries: `pdf2md`, `detect-pdf`, and `dump_ops`

Install the same build only after the user authorizes modifying their environment:

```bash
cargo install --git https://github.com/firecrawl/pdf-inspector.git --tag v0.7.0 --locked --force
```

The crate manifest reports internal package version `0.1.0`; use the Git tag and commit above to identify this installed build.

## Commands

```text
detect-pdf INPUT [--json] [--analyze]

pdf2md INPUT [OUTPUT]
  --json
  --raw
  --pages
  --select-pages 1,3,5-10
  --detect-only
  --analyze
```

Do not use `dump_ops` for ordinary reading. It is a low-level debugging binary that can produce very large output.

## Important JSON fields

`detect-pdf INPUT --json` returns fields including:

- `pdf_type`: `text_based`, `scanned`, `image_based`, or `mixed`
- `page_count`
- `pages_sampled`
- `pages_with_text`
- `confidence`: value from 0 to 1
- `title`
- `ocr_recommended`
- `pages_needing_ocr`: 1-indexed page numbers
- `detection_time_ms`

`detect-pdf INPUT --analyze --json` additionally focuses on layout routing:

- `is_complex`
- `pages_with_tables`
- `pages_with_columns`

`pdf2md INPUT --json` returns fields including:

- `pdf_type`, `page_count`, `processing_time_ms`
- `has_text`, `markdown_length`, `markdown`
- `pages_needing_ocr`
- `is_complex`, `pages_with_tables`, `pages_with_columns`
- `has_encoding_issues`

## Failure handling

- Exit code `2` from raw/full extraction means the PDF requires OCR.
- If classification succeeds but text is empty or garbled, route to OCR or visual inspection.
- Password-protected, malformed, or unsupported PDFs may fail parsing; preserve the original error and fall back to the `pdf` skill.
- Page selection is 1-indexed and accepts comma-separated numbers and inclusive ranges.
- Font-decoding warnings can appear on stderr even when extraction succeeds. Judge the JSON metadata and extracted text; use `RUST_LOG=error` for a quieter machine-readable pipeline when needed.
