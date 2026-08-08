---
name: vault
description: Search and retrieve notes from Luiz Gustavo's Obsidian vault at `/Users/luizgustavo/git/vault`, using its current home page, inbox, study, career, and Leif structures. Use when the user wants to find notes, recover study material for concursos, inspect existing flashcards, review faculdade or TCC notes, pull context for curriculum writing, or load personal planning notes. Trigger on phrases like "check my notes", "what do I have on", "find in vault", "search notes", "load notes about", "bring me everything about", "briefing for", "o que eu tenho sobre", "meus flashcards", "anotações da faculdade", "currículo", and "concursos".
---

# Vault

Searches and retrieves notes from the Obsidian vault at `/Users/luizgustavo/git/vault`.

## Current vault map

Start broad navigation at `index.md`. Then prioritize these areas based on the user's intent:

- `inbox/`: uncategorized captures. Move or refine only when the user asks to organize them.
- `flashcards/`: spaced-repetition cards, including subjects like `portugues/`
- `concursos/`: the manual, canonical cadernos de erros. Each concurso has its own folder with an `index.md` and `caderno-de-erros/` subject files.
- `Leif/concursos/`: active Leif operational study plans. They use the plugin's Markdown schema and are separate from `concursos/`.
- `uni/`: faculdade notes, including TCC material
- `curriculo/`: master record, experience notes, skills, and editable CV sources in `curriculo/versoes/`. Never treat `curriculo/exports/` as source material.
- `vida/`: personal planning and operational notes
- `learning/til/`: short learning notes
- `projects/`, `blog/`, and `references/`: projects, writing, and reference material
- `templates/`: support material only when directly relevant

Use the real folder names exactly as they exist. They are lowercase in this vault.

## Exclusions and privacy

Never search, quote, summarize, link, edit, or index `credenciais/` unless the user explicitly names a file there and requests that action. It may contain secrets.

Ignore generated or application-maintenance paths: `curriculo/exports/`, `tmp/`, `Leif/.backups/`, `.obsidian/plugin-backups/`, `.qmd/`, `.obsidian/`, and `.git/`. Do not use their contents as note sources.

## Search workflow

### 1. Prefer qmd only when its collection is safe

Use qmd as the primary search tool when the `vault` collection already exists.

Search commands:

```bash
qmd query -c vault "search term"
qmd search -c vault "search term"
qmd vsearch -c vault "search term"
```

Use `--json` or `--files` when structured output helps. Use `-n 10` when the search is broad.

Use qmd only when the existing `vault` collection is known not to index `credenciais/` or generated paths. If that is not verified, use targeted `rg` searches instead. Do not create a root-level collection blindly, because it can index credentials.

### 2. Use snippets before reading whole files

qmd snippets are usually enough for quick lookup.

Read the full note only when:

- the user asks for the full note
- the snippet is cut off and misses the important part
- you are building a deeper synthesis

### 3. Fallback when qmd is unavailable or not initialized

If qmd cannot be used in the current session, fall back to targeted search with `rg` and `find`. Scope searches to the active content folders named above; never run an unfiltered full-vault search.

```bash
rg -l "exact phrase" /Users/luizgustavo/git/vault/flashcards --type md
rg -l "exact phrase" /Users/luizgustavo/git/vault/concursos --type md
rg -l "exact phrase" /Users/luizgustavo/git/vault/uni --type md
rg -l "exact phrase" /Users/luizgustavo/git/vault/curriculo --type md
rg -l "exact phrase" /Users/luizgustavo/git/vault/vida --type md
find /Users/luizgustavo/git/vault/{inbox,flashcards,concursos,Leif/concursos,uni,curriculo,vida,learning,projects,blog,references} -name "*slug*"
```

Do not run `rg` just to confirm what qmd already found.

## Area selection

Pick the likely area first, then widen only if needed.

- Concurso or revisão: check `concursos/{concurso}/index.md` first for edital info, then `concursos/{concurso}/caderno-de-erros/` for subject material. Also search `flashcards/` for existing cards on the topic.
- Active Leif cycle or status: read `Leif/concursos/{concurso}/concurso.md`, then the linked `materias/`, `recursos/`, and `assuntos/` notes. Do not use `Leif/.backups/` or migration receipts as sources.
- Faculdade, disciplina, TCC: search `uni/` first
- Currículo, experiência, estágio, projetos: search `curriculo/` first
- Organização pessoal, rotinas, pendências: search `vida/` first
- Broad recall or synthesis: search everything

### Concurso structure

The manual caderno structure is self-contained under `concursos/{concurso}/`:

```
concursos/
  {concurso}/
    index.md                       # edital info (prazos, vagas, salários, provas) + study index
    caderno-de-erros/
      {subject}.md                 # one file per subject with ### topic headings
```

The `index.md` holds everything needed to operate the concurso: deadlines, cargo details, how to enroll, and the full list of subject files to study. Subject files live inside `caderno-de-erros/` with `## Assuntos mapeados` and `###` topic headings. No cross-links between different concursos.

Do not merge or move manual cadernos and Leif plans unless the user explicitly requests a migration. If the user asks whether a topic already has a flashcard, inspect `flashcards/` before suggesting new material.

## Output modes

### Quick list

Default for broad searches. List the matching notes with one-line descriptions and ask which one to open further.

### Study retrieval

Use this when the user is revising for concursos or faculdade.

Return:

- the best matching notes
- existing flashcards on the topic, if any
- the main idea or rule already captured in the vault
- missing angles only when they are obvious from the material found

### Consolidated briefing

Use this when the user asks for "everything about", "briefing for", "consolidate", or clearly wants a synthesis to write, study, or reuse.

Structure the answer like this:

```markdown
## Briefing: {topic}

### Where this appears
- {flashcards, uni, curriculo, vida, etc.}

### Key points
- {main point}
- {main point}

### Existing material
- {flashcard or note already present}

### Gaps or open questions
- {what seems unresolved or missing}

### Sources
- `path/to/file.md`
- `path/to/file.md`
```

Keep the briefing useful. Do not dump raw note text without synthesis.

## Writing style

Follow the user's voice in the response. Keep it direct, informal, and without AI-speak.
