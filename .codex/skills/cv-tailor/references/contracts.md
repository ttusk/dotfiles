# Artifact contracts

All JSON files use UTF-8, `schema_version: 1`, sorted stable requirement IDs, and no comments.

## requirements.json

```json
{
  "schema_version": 1,
  "source": {
    "kind": "url",
    "url": "https://example.com/job",
    "sha256": "64 lowercase hex characters",
    "captured_at": "2026-08-04T12:00:00-03:00"
  },
  "language": "pt",
  "role": "Backend Engineer",
  "seniority": {
    "value": "junior",
    "confidence": 0.8,
    "evidence": ["trecho exato da vaga"]
  },
  "requirements": [
    {
      "id": "req-generated-by-validator",
      "priority": "must",
      "category": "technology",
      "text": "Experiência com Java",
      "canonical_term": "Java",
      "aliases": ["Java 21", "Java 25"],
      "expected_evidence": "experience",
      "job_evidence": "trecho exato da vaga",
      "knockout": false
    }
  ]
}
```

Categories: `technology`, `responsibility`, `experience`, `education`, `language`, `location`, `authorization`, `soft_skill`, `other`.

Priorities: `must`, `preferred`.

Evidence types: `experience`, `skill`, `education`, `profile`.

Do not decide requirement IDs manually. Write the draft with an empty ID and let `validate_requirements.py --canonical-output` assign a content-derived ID.

## application-context.json

This file captures the vacancy context that determines what belongs in the CV. It is not a candidate fact source.

```json
{
  "schema_version": 1,
  "document_language": "pt",
  "market": "brazil",
  "company_scope": "local",
  "international_interaction": "unknown",
  "explicit_language_signal": "absent",
  "role": "Backend Engineer",
  "evidence": ["exact vacancy phrase supporting the context"]
}
```

Allowed values:

- `document_language`: `pt` or `en`
- `market`: `brazil`, `international`, or `unknown`
- `company_scope`: `local`, `national`, `multinational`, `international`, or `unknown`
- `international_interaction`: `yes`, `no`, or `unknown`
- `explicit_language_signal`: `absent`, `preferred`, `required`, or `knockout`

The context must be inferred from the vacancy and user preferences, never from missing candidate evidence. If context is ambiguous, use `unknown` and prefer omission of optional sections.

## preferences.json

User preferences may override optional presentation decisions without changing the master record or hiding a required vacancy fact:

```json
{
  "schema_version": 1,
  "language_policy": "contextual"
}
```

`language_policy` is `contextual`, `always`, or `never`. Required language requirements always remain visible in the CV or in the honest gap report.

## cv-plan.json

`plan_sections.py` produces the contextual section policy before assembly:

```json
{
  "schema_version": 1,
  "application_context": {},
  "section_policy": {
    "languages": {
      "decision": "omit",
      "priority": "optional",
      "reason": "local Portuguese application has no language signal"
    }
  },
  "included_sections": ["summary", "experience", "skills", "education"]
}
```

Decisions are `include`, `omit`, or `conditional`. `conditional` sections are included only when the evidence-selection phase proves they close a relevant requirement. The renderer must not emit a section whose decision is `omit`.


## master-preflight.json

Produced by `preflight_master.py`. It reports `present`, `partial`, or `missing` for personal data, professional experience, education, technical skills, verified metric achievements, contact, and languages. It is diagnostic: it must never fabricate or infer absent personal facts. `ready_for_tailoring: false` means an essential category is entirely absent and verified user input is required before generation.

## evidence-matrix.json

```json
{
  "schema_version": 1,
  "requirements": [
    {
      "requirement_id": "req-...",
      "status": "supported",
      "strength": "professional_experience",
      "source_ids": ["bbsia-backend-java-quarkus.md:L17"],
      "notes": "Java and Quarkus appear in an active backend role"
    }
  ],
  "eligibility": "eligible",
  "recommendation": "apply"
}
```

Statuses: `supported`, `partial`, `missing`, `contradicted`, `unknown`.

Strength: `professional_experience`, `project`, `declared_skill`, `education`, `profile`.

Use `none` only when the status is `missing` or `unknown` and there is no candidate evidence. `supported`, `partial`, and `contradicted` entries must cite at least one source ID discovered in `master.json`; a `supported` citation must also contain the canonical term or a validated alias. Every requirement ID must appear exactly once. Validate the file with `validate_evidence_matrix.py`; do not proceed on failure.

Recommendations:

- `apply`: must-haves have strong support and no knockout conflict
- `apply_with_caveats`: plausible fit with visible gaps or unknown knockouts
- `reconsider`: explicit knockout conflict or very weak must-have evidence

## provenance.json

Every rendered experience bullet needs one entry:

```json
{
  "schema_version": 1,
  "bullets": [
    {
      "generated_text": "Desenvolvi uma API REST reativa com Java e Quarkus.",
      "sources": [
        {
          "path": "bbsia-backend-java-quarkus.md",
          "sha256": "current source hash from master.json",
          "line_start": 17,
          "line_end": 17,
          "excerpt": "exact text from the cited source lines"
        }
      ],
      "claims": ["API REST reativa", "Java", "Quarkus"],
      "transformations": ["compressed"],
      "metrics_preserved": []
    }
  ],
  "work_entries": [
    {
      "company": "BBSIA",
      "canonical_title": "Programador backend",
      "dates": "Atual. Início não informado",
      "sources": [
        {
          "path": "bbsia-backend-java-quarkus.md",
          "sha256": "current source hash from master.json",
          "line_start": 8,
          "line_end": 11,
          "excerpt": "exact text from the cited source lines"
        }
      ],
      "field_claims": {
        "company": ["BBSIA"],
        "canonical_title": ["Programador backend"],
        "dates": ["Atual"]
      }
    }
  ]
}
```

Allowed transformations: `selected`, `compressed`, `reordered`, `translated`, `internal_jargon_expanded`, `tense_adjusted`.

Never add a metric, technology, employer, title, date, scale, or result that is absent from the cited source lines.

For `work_entries`, each displayed field must include its corresponding source-backed `field_claims`. Explanatory wording such as “Início não informado” is allowed only when it preserves an unknown value rather than guessing one.

## verification.json

Produced only by `verify_cv.py`. It is authoritative for:

- Typst compiler exit code
- page count
- extracted searchable text
- hyperlinks embedded in the PDF
- placeholders and conservative-layout violations
- hashes of the validated source and PDF
- rendered preview paths

## match-report.json

Produced only by `score_cv.py`. Do not edit it manually. It contains:

- Job Match Score
- weighted components
- evidence coverage
- eligibility
- decision
- structured gaps
- explicit non-guarantee disclaimer

The scorer consumes both `provenance-validation.json` and `evidence-matrix-validation.json`. Invalid inputs receive no trusted experience-evidence credit and force `reconsider`.
