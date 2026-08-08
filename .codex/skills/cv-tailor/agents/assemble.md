# Grounded Typst assembly for Codex

Build a tailored one-column Typst CV from validated artifacts. The authoritative inputs are `master.json`, `requirements.json`, `evidence-matrix.json`, and `../assets/resume.typ`.

## Dynamic source selection

Never maintain or rely on a fixed experience filename list. Use the entries discovered by `discover_master.py`, including new notes added later.

Source priority:

1. experience/project note for its own title, organization, period, stack, bullets, and claims
2. `index.md` for profile/navigation
3. `habilidades.md` for declared skills only

When sources conflict, the dedicated experience note wins. Unknown dates remain unknown.

## Selection

- Rank experiences by professional evidence for must-haves, responsibility alignment, recency, and supported impact.
- Do not select an experience solely to repeat a keyword.
- Start with 2–4 bullets per experience and 5–8 total. The compiled page count, not a bullet heuristic, is the final length gate.
- Projects may be included when they add missing relevant evidence and are clearly labeled as projects.

## Writing

Read `../references/writing.md` completely.

- Preserve canonical employer, institution, title, dates, technologies, and metrics.
- Never promote seniority or rename a role to imitate the vacancy.
- A source-backed descriptive subtitle is allowed, but the canonical title must remain visible.
- Use present tense for current recurring work and past tense for completed outcomes.
- Remove first-person pronouns and internal jargon.
- Match the vacancy language naturally.
- Keep unsupported mandatory requirements in the gap report. Do not inject them.

## Typst

- Use `../assets/resume.typ` as the base; do not recreate layout ad hoc.
- Replace every `REPLACE_*` placeholder.
- Use A4 for Brazil/Europe and US Letter only for an explicitly US-targeted role.
- Use full URLs: `https://github.com/{username}` and `https://www.linkedin.com/in/{username}`.
- Keep a single linear column. No tables, grids, columns, images, icons, rating bars, charts, or forced page breaks.
- Save editable output at `curriculo/versoes/cv-{company}-{role}.typ`.

## Provenance

Write `provenance.json` using `../references/contracts.md` at the same time as the CV.

For each rendered experience bullet record:

- exact generated text
- current source path and SHA-256 from `master.json`
- tight source line range
- factual claims
- transformations
- preserved metrics

Cover work header fields in `work_entries` with the same current hashes and tight line excerpts. Provide `field_claims` separately for `company`, `canonical_title`, and `dates`; every claim must appear both in the displayed field and in the cited source. Every final experience bullet must have exactly one matching provenance entry. Re-run `validate_provenance.py` after every content edit.
