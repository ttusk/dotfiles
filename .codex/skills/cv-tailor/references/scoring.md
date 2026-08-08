# Deterministic Match Score

The score is called **Job Match Score**, not ATS Score. It is a local comparison between the captured vacancy, the rendered CV, provenance, and document verification. It does not model a specific vendor and never guarantees an interview.

## Weights

| Component | Weight |
|---|---:|
| Must-have term coverage | 35 |
| Must-have backed by professional bullet and provenance | 25 |
| Preferred requirement coverage | 15 |
| Responsibility alignment in experience bullets | 15 |
| Compiled document quality | 10 |

Document quality has five two-point gates: compilation, one page, searchable text, valid PDF links, and no placeholders/forbidden constructs.

Requirements are normalized case-insensitively with accents removed. Exact canonical terms and aliases come only from `requirements.json`; the scorer does not invent synonyms.

## Eligibility is separate

A score cannot hide knockout constraints:

- `eligible`: all knockout requirements are represented
- `review`: one or more knockouts are missing or unknown
- `ineligible`: the evidence matrix explicitly marks a knockout as not met

## Interpretation

- `strong_match`: score at least 80, eligible, and at least half of must-haves have professional provenance
- `potential_match`: score at least 60 without a definitive knockout conflict
- `weak_match`: lower score, ineligible, or weak professional evidence

Always report gaps. Never inject an unsupported keyword just to increase the score.
