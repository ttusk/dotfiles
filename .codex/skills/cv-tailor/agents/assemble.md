# Grounded Typst assembly for Codex

Build a selective, contextual one-column Typst CV from validated `master.json`, `requirements.json`, `application-context.json`, `cv-plan.json`, `evidence-matrix.json`, and `../assets/resume.typ`.

## Dynamic source selection

Never maintain or rely on a fixed experience filename list. Use the entries discovered by `discover_master.py`, including new notes added later.

Source priority:

1. experience/project note for its own title, organization, period, stack, bullets, and claims
2. `index.md` for profile/navigation
3. `habilidades.md` for declared skills only

When sources conflict, the dedicated experience note wins. Unknown dates remain unknown.

## Selection

- Follow every `decision` in `cv-plan.json`; an omitted optional section must not be restored to fill the page.
- Rank experiences and facts by requirement coverage, professional evidence, responsibility alignment, recency, supported impact, and narrative diversity.
- Do not select an experience solely to repeat a keyword. Prefer a concrete proof point over a generic credential list.
- Keep professional experience, projects, and education distinct. Include a project only when it closes a relevant requirement that professional evidence does not cover.
- Use a page budget. Prefer fewer readable bullets over a complete inventory. One page is preferred only when it remains readable; use an additional page rather than shrinking the body text or duplicating content.

## Writing

Read `../references/writing.md` completely.

- Preserve canonical employer, institution, title, dates, technologies, and metrics.
- Never promote seniority or rename a role to imitate the vacancy.
- A source-backed descriptive subtitle is allowed, but the canonical title must remain visible.
- Use present tense for current recurring work and past tense for completed outcomes.
- Remove first-person pronouns and internal jargon.
- Match the vacancy language naturally without copying its entire vocabulary.
- Keep unsupported mandatory requirements in the gap report. Do not inject them.
- Never repeat an optional fact in multiple sections merely to increase keyword coverage.

## Typst

- Use `../assets/resume.typ` as the base; it is a thin wrapper around the pinned `@preview/basic-resume:0.2.9` package. Preserve the package import and `resume.with` wrapper.
- For `basic-resume` contact fields, pass `github.com/<username>` and `linkedin.com/in/<username>` so the package creates HTTPS targets; never pass a bare username, and verify the embedded PDF links.
- Use the package's `#work`, `#edu`, and `dates-helper` primitives instead of recreating spacing or alignment.
- Replace every `REPLACE_*` placeholder, including the four section visibility flags.
- Render only sections whose `cv-plan.json` decision is `include`; resolve `conditional` sections from evidence before rendering.
- Use A4 for Brazil/Europe and US Letter only for an explicitly US-targeted role.
- Keep a single linear column. No tables, grids, columns, images, icons, rating bars, charts, or forced page breaks.
- Do not add manual `#set par`, `#set list`, heading-margin, or block-spacing overrides on top of `basic-resume`; its defaults are the spacing baseline.
- If the content is cramped or overflows, first remove the weakest optional bullets/sections or accept a second page. Never tighten package spacing or body text to force one page.
- Inspect the rendered preview for clear separation between section headings, work headers, metadata, bullet groups, skills, and education. A valid page count does not prove readable spacing.
- Keep body text readable. Do not force one page by reducing typography below the template's readable baseline.
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
