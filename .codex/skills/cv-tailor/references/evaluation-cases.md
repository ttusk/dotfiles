# Codex evaluation cases

Use these prompts after material changes to the skill. They are realistic Codex prompts, not synthetic API calls.

## 1. Portuguese Java backend vacancy

Prompt:

> Adapte meu currículo para esta vaga de backend Java/Quarkus. Ela pede APIs REST, Kubernetes e testes automatizados: [pasted vacancy]

Assertions:

- BBSIA is dynamically discovered
- Java/Quarkus appears with professional provenance
- PDF compiles to one page with correct email/GitHub/LinkedIn links
- Kubernetes is not upgraded to a personal achievement unless its cited source supports it
- the rendered preview uses the pinned `@preview/basic-resume:0.2.9` base; no manual compressed spacing overrides are introduced


## 1a. Local Portuguese vacancy with no language signal

Prompt:

> Adapte meu currículo para uma vaga de backend em Brasília. A descrição está em português e não menciona idiomas: [pasted vacancy]

Assertions:

- `application-context.json` records a Brazilian Portuguese context without an explicit language signal
- `cv-plan.json` sets `languages.decision` to `omit`
- the generated CV has no `Idiomas` heading and does not repeat English in the summary or skills
- relevant experience or readable whitespace is preferred over a generic credential line

## 1b. Same market, explicit language relevance

Prompt:

> Adapte meu currículo para uma empresa multinacional no Brasil. A vaga pede colaboração diária com equipes nos Estados Unidos e inglês avançado: [pasted vacancy]

Assertions:

- the context records international interaction and an explicit language requirement
- `cv-plan.json` includes languages with `required` priority
- the language appears once in an appropriate location, not in every section
- an unsupported language level remains an honest gap

## 2. English data engineering vacancy

Prompt:

> Tailor my resume for this Data Engineer role. Keep it honest and in English: [pasted vacancy]

Assertions:

- eLattes evidence is prioritized
- English is natural
- all bullets have provenance
- PT-only section headings do not remain

## 3. Clear mismatch

Prompt:

> Monte um currículo para uma vaga sênior .NET/Azure que exige 8 anos e inglês fluente.

Assertions:

- no C#, .NET, Azure, senior title, or years are invented
- eligibility/match gaps are explicit
- recommendation is `reconsider` or `apply_with_caveats`, not a fabricated high score

## 4. Interactive or blocked URL

Prompt:

> Use esta vaga do LinkedIn para adaptar meu currículo: [URL]

Assertions:

- Codex browses the URL
- if login blocks content, Codex asks for pasted text
- no resume or personal data is uploaded to the page

## 5. Audit only

Prompt:

> Audite este currículo contra a vaga, mas não altere nenhum arquivo.

Assertions:

- read-only behavior is respected
- deterministic report distinguishes document quality from job fit
- no output files or external actions are created

## Trigger boundary

Positive triggers: montar/adaptar/otimizar/auditar currículo para uma vaga, resume tailoring, job match, CV para URL de vaga.

Negative prompt:

> Estou pensando em mudar de carreira. O que você acha?

Expected: do not trigger cv-tailor unless the user asks for CV work or supplies a vacancy for comparison.
