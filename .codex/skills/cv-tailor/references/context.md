# Contextual application tailoring

The master record is complete by design. An application CV is selective by design. Never copy every master field into every CV.

## Application context

Before selecting content, create `application-context.json` from the vacancy and explicit user preferences. Record:

- language in which the CV will be written
- hiring market
- local, national, multinational, or international company context
- whether the role involves international teams, clients, or documentation
- explicit language signals from the vacancy
- exact vacancy phrases that support the context

Use `unknown` when the vacancy does not establish a context. Do not infer international work merely because a company name or technology is familiar.

## Section policy

Run `scripts/plan_sections.py` before assembling Typst. The output is the authoritative decision for optional sections.

- `experience` is the primary section when supported experience exists.
- `summary` appears only as targeted positioning for the vacancy, never as a generic stack inventory.
- `skills` contains a compact, selected subset relevant to the vacancy.
- `projects` is conditional: include it only when project evidence closes a relevant requirement that professional experience does not cover, and label it clearly.
- `education` is prominent when required or useful for junior/intern hiring; otherwise keep it compact or omit it when space is constrained.
- `languages` is contextual:
  - include when the vacancy explicitly requires or prefers a language;
  - include for international roles, international collaboration, or an English-language application when it adds signal;
  - omit for a local Portuguese-language application with no language signal;
  - never include merely because the master record contains a language.

A required vacancy language remains visible in the CV or in the honest gap report, regardless of optional-section preferences.

## Decision priority

Apply decisions in this order:

1. explicit user preference for this application;
2. hard vacancy requirements;
3. direct relevance to the role;
4. strength and type of candidate evidence;
5. readability and available page space.

An optional section must earn its space. If two sections compete, prefer a concrete, role-relevant proof point over a generic credential list.

## User overrides

Preferences such as `language_policy: contextual`, `always`, or `never` affect presentation only. They do not modify the master record, change evidence strength, or justify hiding an explicit vacancy requirement.

When the context is genuinely ambiguous and the decision would materially change the CV, ask one focused question. Otherwise use the conservative choice: omit low-signal optional content and explain the omission in `cv-plan.json`.

## Review questions

Before rendering, confirm:

- Does the first half of the CV communicate the target role and strongest proof?
- Is each included section useful for this vacancy?
- Are professional experience, projects, and education clearly distinguished?
- Is any language, skill, title, or summary phrase present only because the template had a slot for it?
- Would removing an optional section make the CV clearer or stronger?
