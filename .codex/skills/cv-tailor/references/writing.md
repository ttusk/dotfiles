# Grounded CV writing

## Voice and tense

- No first-person pronouns in bullets.
- Current recurring responsibility: present tense.
- Completed delivery or measured outcome: past tense.
- Portuguese vacancy: Portuguese CV unless the user requests English.
- English vacancy: natural English CV, not literal translation.

## Bullet shape

Prefer: action + scope/problem + technical mechanism + supported result.

Good:

> Desenvolvi API REST reativa em Java e Quarkus para o catálogo nacional de soluções de IA do setor público.

Bad:

> Responsável por várias tarefas importantes no backend.

Rules:

- 1–2 visual lines after rendering
- 2–4 bullets per selected experience
- 5–8 experience bullets total as a starting point, but actual PDF page count is the gate
- preserve real metrics exactly
- expand internal jargon into public language
- bold only relevant technologies, never entire clauses
- do not repeat the same keyword across summary, every bullet, and skills

## Titles and dates

- Preserve the canonical title from source material.
- A factual subtitle may clarify domain but cannot raise seniority.
- Never infer a missing start date.
- For unknown precision, use honest wording such as `Atual` or omit the start month rather than inventing one.
- Experience note dates override summary/index dates when they conflict.

## Summary and skills

- Summary is optional and limited to 2–3 lines.
- State the target domain only when supported by experience.
- Skills declared only in `habilidades.md` can appear in skills, but do not describe them as professional experience.
- Keep mandatory unsupported skills as gaps, not hidden keywords.

## Conservative Typst output

- Use `assets/resume.typ` as the structural base.
- Linear single-column content.
- A4 for Brazil/Europe; US Letter only for a clearly US-targeted application.
- Full HTTPS GitHub and LinkedIn URLs.
- No images, icons, charts, rating bars, page breaks, tables, grids, or multi-column layouts.
