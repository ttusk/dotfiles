# Tec Concursos caderno automation

Use this reference only when the user asks to create or sync Tec Concursos cadernos from the mapped edital.

## Safety and limits

- Prefer an official Tec import/export/API if the user has one.
- Otherwise use browser-assisted automation with the user already logged in.
- Never ask for or store the user's Tec password.
- Stop and ask if Tec shows CAPTCHA, 2FA, payment walls, destructive confirmations, or a changed layout.
- Respect Tec's terms and rate limits; keep actions human-paced.
- Do not scrape question content. The goal is to create/search/filter cadernos and store links, not copy proprietary material.

## Mapping model

Create Tec cadernos at the same granularity as Leif topics or at a coarser per-subject level, depending on user preference.

Before choosing Tec granularity, read `study-prioritization.md` and use the study ROI plan. Tec cadernos are not the final objective; they are study instruments. The right caderno is the one that improves score per hour:

- `practice broad` subjects usually get broad banca/prova cadernos;
- `targeted` subjects usually get clustered edital-aligned cadernos;
- `law/framework exact` subjects usually get exact filters plus source reading;
- `skim/monitor` subjects get approximate/lightweight cadernos or no special caderno.

Default recommendation:

- one Tec caderno per Leif topic when the edital topic is precise and likely searchable;
- one Tec caderno per edital cluster when several edital topics naturally share a Tec filter family;
- one Tec caderno per subject only when the edital genuinely covers most of that Tec subject or when the user explicitly chooses a broad review caderno.

Before choosing granularity, classify each Leif matéria:

- `general broad`: classic disciplines where the edital is intentionally broad and Tec's whole matéria is a good study surface, usually with the banca filter. Examples: Língua Portuguesa, Língua Inglesa, Raciocínio Lógico/Matemática/Estatística when the edital lists the usual broad program.
- `specific clustered`: disciplines with several precise edital bullets that fit one Tec family. Create one caderno for the matéria, but select many narrow assunto filters inside it. Examples: Engenharia de Software, Banco de Dados, Segurança, Redes, Gestão de TI.
- `legislation/framework`: named laws, decrees, standards, methods, institutions, controls, or frameworks. Search exact terms first and use only matching leaves or narrow parents. Do not select a full matéria just because the exact law is hard to find.
- `taxonomy gap`: edital terms that Tec does not expose cleanly as filters, or exposes with zero questions after applying banca. Record the gap and use the closest useful filter only when it still helps the candidate.

Also classify the study strategy from the ROI plan:

- `practice broad`: broad question/prova practice has better cost-benefit than fine filtering.
- `targeted`: clustered filters help concentrate effort.
- `law/framework exact`: exact filters and source reading are high ROI.
- `skim/monitor`: mapping too deeply is likely not worth the time.

Before creating cadernos, present a table:

| Leif matéria | Edital assunto(s) | Tec filter(s) selected | Caderno name | Expected breadth |
|---|---|---|---|---|

Ask for approval if more than 10 cadernos will be created, if search terms are uncertain, or if any planned caderno uses a full Tec subject instead of narrower edital-aligned filters.

When the user has already approved a strategy in conversation, preserve it explicitly. For example: if the user says Portuguese can use the whole content but legislation and specific TI must be filtered deeply, apply that rule consistently without asking again for each subject.

If the user says they usually solve Portuguese/English by provas, reflect that in the plan: broad cadernos + error review, not granular grammar/reading filters unless the data shows a repeated weakness.

## Filter precision workflow

The Tec tree is not the edital. Do not assume a Leif matéria maps cleanly to a whole Tec matéria.

For each Leif subject/topic cluster:

1. Convert the edital wording into 2-5 Tec search probes.
   - Include exact named entities: laws, frameworks, protocols, tools, standards, acronyms, and named methods.
   - Include broader synonyms only after checking the exact terms.
   - Examples: `OAuth2`, `OIDC`, `JWT`, `OWASP Top 10`, `ITIL v4`, `COBIT 2019`, `Docker`, `Kubernetes`, `SQL ANSI`.
   - For legislation, probe both the law/decree number and the common name: `Lei 12.846`, `Lei Anticorrupção`, `Decreto 11.129`.
   - For tools and cloud/data terms, probe both exact tool names and family names: `Zabbix`, `Grafana`, `observabilidade`, `LLM`, `IA generativa`, `Machine Learning`.
   - For finance/public policy topics, probe institutional names and domain terms separately: `CMN`, `BACEN`, `CVM`, `Basileia`, `seguros`, `garantias`.
2. Search Tec's `Matéria e assunto` tree and inspect nested results.
   - Prefer exact leaf assuntos matching the edital.
   - Prefer a narrow parent assunto when it exactly groups several edital bullets.
   - Use the full Tec subject only when narrower leaves would miss a large part of the edital or create a brittle/excessive caderno set.
   - Ignore unrelated results caused by page noise, logged-in account text, or unrelated órgãos/cargos. In practice Tec searches can return unrelated labels such as an órgão name; do not treat those as subject matches.
   - A visible summary like `Assuntos contendo "X"` is not enough. Select the actual clickable/filterable assunto row and later verify it in `Configurações`.
3. Add the exam banca filter when appropriate.
   - For edital-based preparation, the default is to add the banca from the edital when the user wants targeted practice.
   - If the banca filter leaves too few questions, create a separate broader fallback caderno rather than silently widening the main caderno.
   - Apply the banca deliberately after the subject filters and record the post-banca count.
4. Measure breadth before creation.
   - Record the question count shown by Tec after selecting filters.
   - Classify each planned caderno:
     - `exact`: selected filters closely match the edital topics.
     - `clustered`: selected filters group related edital topics with acceptable extra coverage.
     - `broad`: uses a whole Tec subject or includes clear extra coverage.
     - `fallback`: intentionally broader because exact filters have too few questions or do not exist.
     - `gap-noted`: contains useful selected filters but some edital terms were unavailable or zero-count in Tec.
5. Review broad filters.
   - Pause and ask before creating a broad caderno when a narrower mapping appears possible.
   - Do not create "ocean" cadernos just because the UI allows it. Large counts are acceptable only when the selected scope is intentionally broad.
   - Large counts can be legitimate when the selected filters really are broad edital topics, such as micro/macro/AFO/SFN/seguros. Do not shrink a caderno just to make the count look small if the edital scope is broad.

Bad default:

- Leif matéria: `Língua Portuguesa`
- Tec filter: full `Língua Portuguesa (Português)`
- Reason: easy to create

Better:

- Start from edital bullets: interpretação, ortografia, coesão, morfossintaxe, reescrita, redação oficial.
- Select matching Tec assuntos or a documented cluster.
- Use full `Língua Portuguesa (Português)` only if the user wants a broad FCC Portuguese caderno or if the edital coverage is deliberately general.

## Granularity decision rules

Prefer this order:

1. Exact Tec leaf assunto for a precise edital bullet.
2. Narrow Tec parent assunto that covers multiple edital bullets.
3. Cluster caderno combining several exact/narrow filters under one Leif subject.
4. Full Tec subject as an explicit broad/fallback choice.

When a Leif subject has many tiny edital bullets:

- avoid creating dozens of tiny cadernos without approval;
- build 3-8 cluster cadernos if it improves precision materially;
- if creating one caderno for the Leif subject, still select narrow filters inside it rather than the whole Tec subject when feasible.

When the Tec taxonomy lacks the edital topic:

- record the closest available Tec filter;
- mark it `approximate` or `fallback`;
- do not pretend it is exact;
- if no acceptable filter exists, skip the caderno and report why.

## Lessons from robust ABGF-style mapping

Use these practical heuristics when mapping a modern edital with mixed general subjects, TI, legislation, governance, ESG, finance, and data topics.

### Domain strategy matrix

Use this as the default starting point, then adjust with the user's accuracy and edital weights:

| Domain | Default study strategy | Default Tec caderno | Main reason |
|---|---|---|---|
| Portuguese | `practice broad` | broad matéria/provas + banca | high transfer from banca-style practice; fine grammar filters often have lower ROI |
| English | `practice broad` | broad matéria/provas + banca | reading comprehension improves through exposure and error review |
| Reasoning/math/statistics | `practice broad` or `targeted` | broad cluster, split only for weak spots | patterns matter; split when weight or weakness justifies it |
| Broad/intro TI | `practice broad` or `targeted` | broad or family clusters | many topics are recurring concepts, not named sources |
| Specific TI/tools/protocols | `targeted` | clustered exact leaves | filters help avoid wasting time outside edital scope |
| Laws/frameworks/standards | `law/framework exact` | exact leaves/narrow parents | small source-reading cost can produce direct gains |
| Governance/compliance | `targeted` or `law/framework exact` | exact where possible, clustered otherwise | taxonomy is uneven; named items matter |
| Economy/finance/AFO | `targeted` | broad-but-edital-aligned clusters | broad domains can be high count but still edital-aligned |
| ESG/sustainability/diversity | `skim/monitor` or `targeted` | approximate/lightweight clusters | Tec coverage is often incomplete; avoid false exactness |
| Data/ML/IA | `targeted` | clusters by data/BI/ML/IA | exact modern terms may be missing; use useful families |

### General subjects

Broad Tec matérias are acceptable when the edital itself is broad and classic:

- Portuguese: whole `Língua Portuguesa (Português)` + banca can be acceptable if the edital covers interpretation, grammar, cohesion, rewrite, official writing, and similar language topics.
- English: whole `Língua Inglesa (Inglês)` + banca can be acceptable for broad reading, comprehension, grammar, and vocabulary programs.
- Reasoning/math/statistics: whole or clustered `Raciocínio Lógico`, `Matemática`, and `Estatística` + banca can be acceptable when the edital has a broad reasoning program.

Do not carry this broad-subject rule into specific subjects.

### Specific TI subjects

For TI, prefer clusters of exact leaves. Examples of useful Tec probes and filter families:

- security: `OWASP`, `OAuth`, `JWT`, `SAML`, `criptografia`, `certificado digital`, `IDS`, `IPS`, `firewall`, `SIEM`, `LGPD`, `NIST`, `ISO 27001`;
- data protection/security governance: `LGPD`, `ANPD`, `incidente de segurança`, `boas práticas`, `segurança e sigilo`;
- databases/data engineering: `SQL`, `DDL`, `DML`, `normalização`, `SGBD`, `NoSQL`, `Data Warehouse`, `ETL`, `Data Lake`, `Big Data`, `transações`;
- software engineering: `requisitos`, `testes`, `microsserviços`, `APIs`, `Swagger`, `OpenAPI`, `DDD`, `padrões de projeto`, `métricas`, `qualidade`, and programming languages named in the edital;
- cloud/infrastructure: `Cloud Computing`, `Docker`, `Kubernetes`, `virtualização`, `Windows Server`, `Active Directory`, `Linux`, `LDAP`, `NFS`, `RAID`, `backup`, `Zabbix`, `Grafana`, `alta disponibilidade`, `armazenamento`;
- DevOps: `DevOps`, `IaC`, `integração contínua`, `entrega contínua`, `Git`, `GitHub`, `GitLab`, `Jenkins`, `Ansible`, shell/PowerShell scripting;
- Gestão de TI: `ITIL v4`, `COBIT 2019`, `PMBOK`, `Scrum`, `Kanban`, `Planejamento Estratégico de TI`.

When Tec lacks exact leaves such as `Terraform`, `MLOps`, `SonarQube`, or a specific cloud product, record the gap and use a family filter only if it still represents the edital topic.

### Governance, compliance, finance, and ESG

These areas often have incomplete or uneven Tec taxonomy. Use named probes, then approximate carefully:

- compliance/governance: `COSO`, `controle interno`, `governança corporativa`, `empresas estatais`, `Lei Anticorrupção`, `Decreto 11.129`, `Lei 9.613`, `COAF`, `LAI`, `dados abertos`;
- finance: `microeconomia`, `elasticidades`, `falhas de mercado`, `macroeconomia`, `inflação`, `política monetária`, `política fiscal`, `PPA`, `LDO`, `LOA`, `LRF`, `SFN`, `CMN`, `BACEN`, `CVM`, `Basileia`, `seguros`, `resseguros`, `garantias`;
- ESG/sustainability: `Agenda 2030`, `ODS`, `Acordo de Paris`, `Política Nacional sobre Mudança do Clima`, `bioeconomia`, `biodiversidade`, `responsabilidade social`, `direitos humanos`, `diversidade`, `desigualdade`.

Common gaps to report instead of pretending exact coverage: `FCPA`, `UK Bribery Act`, `KYC`, `PEP`, `FGE`, `ABGF`, `Seguro de Crédito à Exportação`, `PRSAC`, `CMN 4.557`, `CMN 4.945`, and many modern ASG/finanças sustentáveis terms.

## Naming

Use stable names:

`{CONCURSO} · {MATÉRIA} · {ASSUNTO}`

Examples:

- `TCE-SP Auditor 2026 · Português · Interpretação de textos`
- `TRT-2 Analista 2026 · Direito Constitucional · Direitos fundamentais`

## Browser workflow

1. Open Tec Concursos in the browser.
2. Confirm the user is logged in.
3. Navigate to cadernos/question notebooks area.
4. For each approved row:
   - search/filter questions using the mapped edital terms;
   - inspect nested Tec filters before selecting broad parent filters;
   - add banca/other relevant filters when intentionally targeting the edital;
   - record the resulting question count and precision classification;
   - create a caderno with the planned name;
   - save the caderno URL or identifier;
   - record whether the result is exact, approximate, or failed.
5. Validate the created caderno in the `Configurações` tab before updating Leif:
   - confirm the URL is a real caderno URL such as `/questoes/cadernos/<id>`;
   - read the `Filtros utilizados neste caderno` table;
   - record the group question count;
   - confirm the selected `Assunto` rows and the `Banca`;
   - inspect any Tec note like `combinação de filtros utilizada não permitiu localizar questões...`;
   - record selected filters that Tec reports as zero-count under the current combination.
6. Update the Leif import JSON before importing:
   - add `questionNotebook` to the matching topic when a caderno URL is known:

```json
{
  "id": "topic-id",
  "name": "Topic name",
  "questionNotebook": {
    "id": "topic-id-tec",
    "name": "Tec · Topic name",
    "url": "https://...",
    "solvedQuestions": 0,
    "correctAnswers": 0
  }
}
```

When syncing an already-imported concurso, update every affected topic in the target subject or topic cluster. If one subject-level caderno is used for a matéria, all Leif topics in that matéria should usually point to that same caderno. Preserve existing user progress only when the caderno identity is unchanged; for a newly created caderno, initialize `solvedQuestions` and `correctAnswers` as `0`.

## Tec UI automation edge cases

Tec is not a stable API. Treat the browser UI as fallible and verify after each important action.

- Always clear active filters before starting a new caderno.
- Search in `Matéria e assunto`; do not select banca/órgão/ano results by accident.
- A search may show many unrelated items; filter candidates by title/path and visible text.
- Some exact-looking terms may exist in the tree but become zero-question filters after applying the banca. Keep them only if they document edital coverage and do not distort the caderno; report the zero-question note.
- Some filters may fail to click even when the text appears. Retry only after re-reading visible state; if still failing, mark the filter as failed and continue with the usable subset.
- Uncheck `Gerar cadernos em série` if Tec has it enabled; otherwise Tec may create unintended multiple cadernos.
- Do not trust the caderno name as proof. The name can be correct while filters are wrong.
- Do not trust the pre-generation count alone. Always validate the saved caderno in `Configurações`.
- Do not scrape or copy question statements, alternatives, explanations, or comments. Counts, filter names, and caderno URLs are enough.
- Keep automation human-paced. If Tec shows CAPTCHA, 2FA, a payment wall, a destructive confirmation, or a materially changed layout, stop and ask.

## Completion audit

Before reporting the Tec sync as complete:

1. Count all Leif subjects and topics for the target contest.
2. Verify every target topic has a `questionNotebook.url`, unless explicitly skipped.
3. Verify each distinct caderno URL was validated in Tec `Configurações`.
4. For each caderno, classify it as `exact`, `clustered`, `broad`, `fallback`, or `gap-noted`.
5. Confirm broad cadernos are intentional and limited to genuinely broad/general edital subjects.
6. List gaps where Tec lacks exact filters or where selected filters have zero questions with the banca.
7. Save a concise status log if the run is long, so a later continuation can resume without guessing.

## Reporting

Report:

- created cadernos count;
- precision summary: exact / clustered / broad / fallback / failed;
- which broad cadernos were intentional general-subject cadernos;
- which cadernos have Tec taxonomy gaps or zero-question selected filters;
- skipped/failed cadernos with reason;
- caderno URLs added to Leif;
- any broad cadernos that should later be refined into narrower edital-specific cadernos;
- any manual steps still needed.
