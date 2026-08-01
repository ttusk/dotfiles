---
name: cv-tailor
description: Tailor a CV from the master record for a specific job description. Use when the user provides a job posting (URL or pasted text) and asks to generate, optimize, montar currículo, adaptar CV, or audit a curriculum against a vaga. Reads the master record from the user's Obsidian vault and produces an ATS-optimized Typst `.typ` file via an iterative extract → assemble → audit loop.
---

# cv-tailor

Tailor a CV from a master record for a specific job description. Use when the user provides a job posting (URL or pasted text) and asks to generate, optimize, or audit a curriculum.

## Workflow

The skill runs in an iterative loop across 3 stages (max 3 iterations):

```
Job Description → Extract → Assemble → Audit
                      ↑          ↑         │
                 master record     │  score ≥ 80?
                                   │         │
                                   │    no   │ yes
                                   └─────────┘  ↓
                                          CV Final (.typ)
```

### Stage 1: Extract (agent: `agents/extract.md`)

Launch the extract agent with the job description. It returns a structured analysis:

- **Área predominante** (backend, dados, ML, fullstack, arquitetura)
- **Stack requerida** (ferramentas, frameworks, bancos)
- **Soft skills** mencionadas
- **Senioridade** inferida
- **Keywords obrigatórias** (termos que DEVEM aparecer)
- **Diferenciais** (nice-to-haves que pontuam bem)

### Stage 2: Assemble (agent: `agents/assemble.md`)

Launch the assemble agent with the extract output. It reads the master record from `/Users/luizgustavo/git/vault/curriculo/` and:

- Extrai dados pessoais do `index.md` (nome, email, telefone, links, formação, idiomas)
- Seleciona experiências relevantes conforme a área da vaga
- Escolhe e adapta bullets do master record por competência (mapa no `index.md`)
- Filtra `habilidades.md` para incluir só stack relevante
- Preenche o template Typst `basic-resume` com `#work()`, `#edu()` e bullets

### Stage 3: Audit (agent: `agents/audit.md`)

Launch the audit agent with the assembled Typst CV + original job description extract. It returns:

- **ATS Score** (estimativa 0-100)
- **Keyword coverage** (quais keywords aparecem e % de cobertura)
- **Gaps** (o que a vaga pede e não está no CV)
- **Warnings** (formatação, Typst, tamanho, seções faltantes)
- **Sugestões** de ajuste (2-3 ações concretas)

### Iterative loop

- If score ≥ 80: done, present the `.typ` file.
- If score 60–79: pass audit feedback back to Assemble for one revision pass. Re-audit.
- If score < 60 after 2 attempts: present the CV with warnings and let the user decide.
- Max 3 assemble → audit cycles total.

## After the loop

Present the final Typst CV in a code block, followed by the audit summary. Also show: `typst compile cv.typ`

## Master record

The master record lives at `/Users/luizgustavo/git/vault/curriculo/`. It contains all personal data, experiences, and skills. The assemble agent reads from it — nothing is hardcoded in the agents.

```
curriculo/
├── index.md                              ← Dados pessoais + mapa de áreas + guia de montagem
├── banco-do-brasil-solucoes-internas.md  ← BB (06/2025–atual)
├── elattes-pipeline-curriculos.md        ← eLattes/FAPDF (09/2025–atual)
├── ibict-classificacao-textual-nlp.md    ← IBICT (03/2025–11/2025)
└── habilidades.md                        ← Stack técnica por domínio
```

## Tone

- Português (vagas BR) ou inglês (vagas internacionais) — detectar automaticamente
- Verbos de ação no passado
- Sem pronomes pessoais nos bullets
- Sem jargão interno de empresa
