# Concurso study prioritization

Use this reference when mapping a concurso edital into Leif, especially before deciding Tec caderno granularity.

The goal is not to map everything with equal depth. The goal is to maximize expected score gain per hour while preserving edital coverage.

## Core idea

Create a study attack plan before creating cadernos:

```text
priority = expected_score_gain / study_cost
```

Where:

- `expected_score_gain` depends on subject weight, question count, user's current accuracy, and how learnable the topic is in the remaining time;
- `study_cost` is the estimated time to reach useful coverage, not mastery;
- `confidence` is the user's current likelihood of getting questions right without more study;
- `caderno granularity` should follow the study strategy, not the other way around.

When the user has no measured accuracy yet, estimate conservatively and mark the estimate as an assumption.

## Inputs to estimate

Use whatever evidence is available:

- edital question count and weights;
- banca;
- exam date / days remaining;
- user's available hours per week;
- existing Leif sessions and accuracy if present;
- Tec question volume by filter;
- whether the topic is broad, recurring, named, legal, framework-based, or taxonomy-poor;
- user's stated preferences, such as "Portuguese via provas" or "I already know this".

Do not fabricate precise hours. Use ranges when uncertain.

## Output shape

For each matéria, produce a concise table:

| Matéria | Peso/questões | Custo | Confiança | Ganho esperado | Estratégia | Caderno |
|---|---:|---:|---:|---:|---|---|

Suggested scales:

- `Peso/questões`: exact from edital when available, otherwise low/medium/high.
- `Custo`: low/medium/high, optionally estimated hours.
- `Confiança`: low/medium/high or a percent if the user has data.
- `Ganho esperado`: low/medium/high.
- `Estratégia`: `practice broad`, `targeted`, `law/framework exact`, `skim/monitor`.
- `Caderno`: broad, clustered, exact, fallback, or skip.

## Strategy classes

### practice broad

Use when the best study path is exposure to many banca-style questions/provas and error review, not fine taxonomy.

Typical subjects:

- Portuguese;
- English;
- broad reasoning/math/statistics;
- sometimes broad/introductory TI when the edital is generic and the user needs pattern recognition.

Default caderno:

- broad Tec matéria or broad cluster + banca;
- optionally use full provas/simulados;
- avoid spending time building dozens of tiny cadernos.

Study action:

- solve prova/questions first;
- review errors;
- only open theory for repeated misses.

### targeted

Use when the subject has medium/high payoff and can be grouped into useful clusters.

Typical subjects:

- software engineering;
- databases;
- systems and networks;
- cloud/infrastructure;
- data analysis;
- governance/management when not dominated by named laws.

Default caderno:

- one subject-level or cluster caderno with several narrow Tec assunto filters;
- avoid full Tec matéria if the edital is narrower.

Study action:

- compact theory or summary;
- focused questions;
- revisit weak clusters.

### law/framework exact

Use when named laws, decrees, frameworks, standards, or methods are directly listed in the edital.

Typical subjects:

- LGPD and related articles;
- Lei Anticorrupção / LAI / Lei 9.613;
- ITIL, COBIT, PMBOK;
- ISO/NIST/OWASP;
- constitutional/administrative law topics when specific.

Default caderno:

- exact leaf filters or narrow parent filters;
- if Tec lacks exact filters, use closest valid filters and mark `gap-noted`.

Study action:

- read the source/framework summary;
- drill exact filters;
- make quick notes on repeated articles/concepts.

### skim/monitor

Use when the topic is low-weight, very broad, modern/taxonomy-poor, or expensive relative to expected score gain.

Typical subjects:

- ESG/ASG modern terms where Tec coverage is incomplete;
- very niche named institutions with few/no questions;
- topics unlikely to be decisive unless the edital weights them heavily.

Default caderno:

- approximate/fallback caderno only if useful;
- otherwise skip special caderno and record the gap.

Study action:

- short edital-driven summary;
- monitor occasional questions;
- do not sink hours into perfect taxonomy.

## Domain heuristics

### Portuguese and English

Often high value but best learned through practice, not over-filtering.

Prefer:

- broad banca caderno;
- full provas from the banca;
- error review by pattern.

Only create fine filters when the edital is unusually narrow or the user has a repeated weakness.

### Reasoning/math/statistics

Use broad practice when the edital is generic. Split into clusters only if the user has weak spots or the edital has high weight.

Typical clusters:

- propositional logic / argumentation;
- quantitative reasoning;
- probability/statistics;
- graphs/tables.

### TI

Do not treat all TI as one strategy.

- broad/introductory TI: often `practice broad` or `targeted`;
- named tools/frameworks/protocols: `targeted` or `law/framework exact`;
- low-incidence modern tools with poor Tec coverage: `skim/monitor`.

### Law, governance, compliance

Named laws and frameworks can have very high ROI because a small amount of source reading can buy questions.

Prefer exact filters and short source-driven summaries.

### Economy, finance, public budget

Use clusters based on the edital. Counts can be large because the domains are broad; this is acceptable if the filters are still edital-aligned.

Prioritize by expected exam weight and user weakness.

### ESG/sustainability/diversity

Often taxonomy-poor in Tec. Use edital-driven summaries and approximate filters when helpful. Report gaps openly.

Do not force false exactness.

## Decision rules for caderno granularity

Use caderno granularity that supports the strategy:

1. If `practice broad`, prefer broad caderno + banca/provas.
2. If `targeted`, prefer clustered caderno with narrow filters.
3. If `law/framework exact`, prefer exact filters; mark gaps.
4. If `skim/monitor`, create only a lightweight fallback caderno or skip.

Do not build a fine caderno merely because Tec allows it. Do not build a broad caderno merely because it is easy. The caderno is a tool for the study plan.

## Reporting

Always state:

- which subjects are high ROI;
- which subjects should be practiced broadly;
- which subjects need exact filters/source reading;
- which subjects are low ROI or taxonomy-poor;
- what assumptions were used.
