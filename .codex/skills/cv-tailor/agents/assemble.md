# assemble — Typst CV Assembly from Master Record

Build a tailored Typst CV by reading the candidate's master record from their vault and filling a `basic-resume` template with selected, adapted bullets.

## Input

The structured output from the `extract` agent. On iteration 2+, also receives audit feedback (gaps, warnings).

## Data source

Read everything from the vault's `curriculo/` directory (`/Users/luizgustavo/git/vault/curriculo/`):

| File | What to extract |
|---|---|
| `index.md` | Perfil (nome, localização, email, telefone, github, linkedin, site, formação, idiomas) + mapa de áreas + guia de montagem |
| `banco-do-brasil-solucoes-internas.md` | Experiência, bullets, stack, período |
| `elattes-pipeline-curriculos.md` | Experiência, bullets, stack, período |
| `ibict-classificacao-textual-nlp.md` | Experiência, bullets, stack, período |
| `habilidades.md` | Stack técnica por categoria |

**Nada de dados pessoais está chumbado neste agente.** Tudo é lido do vault.

## Template Typst

O CV usa o pacote `basic-resume` (`@preview/basic-resume:0.2.9`). Estrutura:

### Bloco fixo — preencher com dados do `index.md`

```typst
#import "@preview/basic-resume:0.2.9": *

#let name = "[NOME]"
#let location = "[LOCALIZAÇÃO]"
#let email = "[EMAIL]"
#let github = "[GITHUB — apenas username]"
#let linkedin = "[LINKEDIN — apenas username]"
#let phone = "[TELEFONE]"
#let personal-site = "[SITE — apenas domínio]"

#show: resume.with(
  author: name,
  location: location,
  email: email,
  github: github,
  linkedin: linkedin,
  phone: phone,
  personal-site: personal-site,
  accent-color: "#101010",
  font: "New Computer Modern",
  paper: "us-letter",
  author-position: left,
  personal-info-position: left,
)

== Educação

#edu(
  institution: "[NOME DA INSTITUIÇÃO — extrair da formação]",
  location: "[LOCALIZAÇÃO]",
  dates: dates-helper(start-date: "[INÍCIO]", end-date: "Presente"),
  degree: "[CURSO]",
)
```

### Bloco dinâmico — experiências

Cada experiência do vault vira um `#work()` block. Título do cargo adaptado ao tom da vaga:

```typst
== Experiência Profissional

#work(
  title: "[Título do cargo]",
  location: "[Localização ou Remoto]",
  company: "[Empresa/Instituição — do header da experiência]",
  dates: dates-helper(start-date: "[Mês Ano]", end-date: "[Mês Ano ou Presente]"),
)
- Bullet adaptado com *Tecnologia* em bold.
```

### Bloco dinâmico — habilidades

Filtrado do `habilidades.md`: só categorias com match na stack da vaga.

```typst
== Habilidades Técnicas

- *Categoria*: ferramenta1, ferramenta2.
```

### Bloco opcional — idiomas

```typst
== Idiomas

- Inglês C2 · Português nativo.
```

Só incluir se o `index.md` tiver dados de idiomas.

## Passo a passo

### 1. Selecionar experiências

Use o mapa de áreas do `index.md`. Priorize experiências com bullets na área da vaga. Ordem: cronológica reversa.

### 2. Adaptar bullets

- **Escolher** — use o índice de áreas do `index.md` para puxar bullets da competência certa.
- **Enxugar** — reduza de 3-4 linhas (master record) para 1-2 linhas (CV): verbo de ação + resultado + tecnologia.
- **Métrica** — preserve se existe. Não invente se não existe.
- **Jargão** — traduza termos internos ("Genera" → "hub interno de LLMs").
- **Bold** — destaque tecnologias com `*asteriscos*`.
- **Limite** — 3-5 bullets por experiência.

### 3. Filtrar habilidades

Do `habilidades.md`, mantenha só categorias com match na `STACK` da vaga.

### 4. Injetar keywords do extract

Garanta que as `KEYWORDS OBRIGATÓRIAS` apareçam naturalmente nos bullets ou nas habilidades. Priorize encaixar sem forçar — se uma keyword não tem lastro real, não invente.

## Regras

- **Não invente** — sem lastro no vault, não entra.
- **Não minta** — tecnologia que você não usou não aparece.
- **Não repita** — dois bullets similares? Escolha o melhor.
- **Header intocável** — nunca altere `#show: resume.with(...)`, os `#let`, ou `== Educação`.
- **Verbos de ação**: "Desenvolvi", "Implementei", "Projetei", "Liderei", "Reduzi".
- **Sem "eu"**: "Desenvolvi uma API..." ✓, "Eu desenvolvi..." ✗.
- **Typst**: bold com `*texto*`, datas com `dates-helper()`, sem `#table()`/`#grid()`/`#columns()`.
- **Máximo 1 página** — template `us-letter`, mantenha conciso.
