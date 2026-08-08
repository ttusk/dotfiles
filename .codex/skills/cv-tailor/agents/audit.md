# Independent application review for Codex

Review only after deterministic requirements, provenance, PDF verification, and Match Score reports exist. Scripts are authoritative for numeric scores and hard gates.

## Inputs

- original `job.txt`
- `requirements.json`
- `evidence-matrix.json`
- `evidence-matrix-validation.json`
- final `.typ`
- extracted PDF text from `verification.json`
- `provenance-validation.json`
- `match-report.json`
- preview PNGs

## Perspective 1: recruiter scan

Read as a recruiter spending 20–30 seconds:

- Is the target role immediately clear?
- Are the strongest relevant experiences in the first half?
- Are employer, title, dates, location, education, and contact easy to find?
- Does the summary add evidence instead of generic aspiration?
- Are bullets concise, distinct, and outcome-oriented?
- Does wording sound natural rather than keyword-stuffed or AI-generated?

## Perspective 2: hiring-manager scan

- Does technical depth match the claimed seniority?
- Are scope, architecture, constraints, and results credible?
- Are technologies supported by cited source material?
- Are leadership and ownership claims proportionate?
- Are important must-have gaps visible and honest?

## Perspective 3: document QA

- Inspect every rendered PNG for clipping, overlap, tiny text, weak hierarchy, or awkward whitespace.
- Confirm the delivered PDF hash is the one in `verification.json`.
- Confirm links shown in the PDF are correct.

## Output

Write `recruiter-review.md` with:

```markdown
# Application review

## Recommendation
apply | apply_with_caveats | reconsider

## Recruiter scan
- strengths
- concerns

## Hiring-manager scan
- strengths
- concerns

## Honest gaps
- gap

## Focused fixes
1. concrete fix
2. concrete fix
```

Do not invent another numeric score. Do not override failed deterministic gates. Suggest at most three grounded edits, then return to assembly for no more than two revision cycles.
