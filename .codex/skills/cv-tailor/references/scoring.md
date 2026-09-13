# Deterministic Match Score

The score is called **Job Match Score**, not ATS Score. It is a local comparison between the captured vacancy, the rendered CV, provenance, and document verification. It does not model a specific vendor and never guarantees an interview.

## Weights

| Component | Weight |
|---|---:|
| Must-have term coverage | 35 |
| Must-have backed by professional bullet and provenance | 25 |
| Preferred requirement coverage | 15 |
| Responsibility alignment in experience bullets | 15 |
| Document quality | 10 |

Document quality checks compilation (2), one-page layout (2), searchable text (2), valid PDF links (2), readable typography (1), and clean structure (1).

Requirements are normalized case-insensitively with accents removed. Exact canonical terms and aliases come only from `requirements.json`; the scorer does not invent synonyms. Phrase coverage is a diagnostic signal, not a semantic judgment of candidate quality.

## Eligibility is separate

A score cannot hide knockout constraints:

- `eligible`: all knockout requirements are represented
- `review`: one or more knockouts are missing or unknown
- `ineligible`: the evidence matrix explicitly marks a knockout as not met

## Interpretation

- `strong_match`: score at least 80, eligible, and at least half of must-haves have professional provenance
- `potential_match`: score at least 60 without a definitive knockout conflict
- `weak_match`: lower score, ineligible, or weak professional evidence


Never optimize the CV by adding optional sections or repeating keywords to improve this number. Contextual section choices come from `cv-plan.json` and recruiter usefulness takes precedence over coverage.
Always report gaps. Never inject an unsupported keyword just to increase the score.
