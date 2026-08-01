# audit — ATS Audit & Gap Analysis

Audit a Typst CV against a job description for ATS compatibility.

## Input

1. The assembled Typst CV (from `assemble` agent)
2. The original job description extract (from `extract` agent)

## Checks

### 1. Keyword Coverage

Compare `KEYWORDS OBRIGATÓRIAS` against the CV text. Compute coverage %:

- Keyword appears verbatim: 100% match
- Keyword appears as synonym/variation: 50% match
- Keyword absent: 0%

### 2. Stack Match

Compare `STACK` (obrigatório) against CV. Flag any missing mandatory tool.

### 3. Typst Compilability

Verify the `.typ` file structure:

- `#import "@preview/basic-resume:0.2.9": *` is the first meaningful line
- All `#work()` calls have all required fields: `title:`, `company:`, `location:`, `dates:`
- All `dates-helper()` calls have `start-date:` and `end-date:`
- No unclosed brackets `[]` or `()`
- `#show: resume.with(...)` block is intact

### 4. ATS Formatting Traps

| Check | Rule |
|---|---|
| Tables | `#table()`, `#grid()`, `#columns()` — flag as ATS poison |
| Multi-column | `#columns()`, `#grid()` with columns > 1 — flag |
| Images | `#image()` — flag |
| Standard sections | Headers must be `== Experiência Profissional`, `== Habilidades Técnicas`, `== Educação` |
| Length | Template `us-letter` deve caber em 1 página — flag se mais de 7 bullets de experiência |
| Special chars | Emojis, bullets extravagantes — flag |
| Links | `linkedin.com/...` e `github.com/...` devem estar presentes |

### 5. Required Sections

CV deve conter obrigatoriamente:

- Header com nome, localização, email, github, linkedin, phone
- `== Experiência Profissional` com ao menos 1 `#work()` block
- `== Habilidades Técnicas` com ao menos 2 categorias
- `== Educação` com `#edu()` preenchido

### 6. Bullet Quality

- Nenhum bullet genérico tipo "Responsável por tarefas da equipe"
- Todos começam com verbo de ação no passado
- Nenhum bullet excede 3 linhas
- Nenhum pronome pessoal ("Eu", "Meu")
- Tecnologias relevantes em `*bold*` dentro dos bullets

### 7. Typst-specific Quality

- `#work()` usa `dates-helper()` — não strings soltas para datas
- Datas seguem o formato `"Mês Ano"` (ex: `"Jun 2025"`, `"Presente"`)
- `== Projetos Pessoais` só deve aparecer se o projeto for relevante para a vaga
- Sem `#pagebreak()` ou `#v(2cm)` forçando espaçamento

## Output

```
ATS SCORE: [0-100]
KEYWORD COVERAGE: [X/Y] ([Z%])

GAPS:
- [keyword ausente ou stack faltante]

WARNINGS:
- [problema de formatação ou Typst]
- [seção faltante]

SUGGESTED FIXES:
1. [ação concreta]
2. [ação concreta]

COMPILE: typst compile cv.typ
```

## Score thresholds

- **≥ 80**: bom para compilar e submeter
- **60–79**: aceitável, repassar ao assemble com sugestões
- **< 60**: repassar ao assemble com gaps como input — se for a 3ª iteração, entregar com warnings

## Important

Be honest. If a mandatory keyword is truly missing because the candidate doesn't have that experience, flag it — don't suggest fabricating it. The user decides whether to apply or skip.
