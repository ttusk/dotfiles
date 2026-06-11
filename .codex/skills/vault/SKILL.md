---
name: vault
description: Search and retrieve notes from Luiz Gustavo's Obsidian vault at `/Users/luizgustavo/git/vault`. Use when the user wants to find notes, recover study material for concursos, inspect existing flashcards, review faculdade or TCC notes, pull context for curriculum writing, or load personal planning notes from the vault. Trigger on phrases like "check my notes", "what do I have on", "find in vault", "search notes", "load notes about", "bring me everything about", "briefing for", "o que eu tenho sobre", "meus flashcards", "anotações da faculdade", "currículo", and "concursos".
---

# Vault

Searches and retrieves notes from the Obsidian vault at `/Users/luizgustavo/git/vault`.

## What is in this vault

Prioritize these folders based on the user's intent:

- `flashcards/`: spaced-repetition cards, including subjects like `portugues/`
- `concursos/`: concurso prep material and study notes
- `uni/`: faculdade notes, including TCC material
- `curriculo/`: résumé, experience summaries, professional positioning
- `vida/`: personal planning and operational notes
- `templates/`: support material only when directly relevant

Use the real folder names exactly as they exist. They are lowercase in this vault.

## Search workflow

### 1. Prefer a vault-local qmd index

Use qmd as the primary search tool when the vault already has a local
`.qmd/index.yml` or `.qmd/index.yaml`.

The qmd CLI auto-detects a project-local `.qmd` by walking upward from the
current directory and, when found, keeps both config and SQLite index writes
inside that project. For this vault, prefer invoking qmd from the vault root:

```bash
vault_qmd() {
  (cd /Users/luizgustavo/git/vault && qmd "$@")
}
```

Use `vault_qmd` for all qmd commands when the vault has its own `.qmd`. This
gives every agent the same source of truth instead of creating per-workspace
SQLite indexes.

If the vault does not have a local `.qmd` yet, initialize one from the vault
root with `qmd init`, then configure the vault collection there.

Search commands:

```bash
vault_qmd query -c vault "search term"
vault_qmd search -c vault "search term"
vault_qmd vsearch -c vault "search term"
```

Use `--json` or `--files` when structured output helps. Use `-n 10` when the search is broad.

If the `vault` collection does not exist yet, initialize it first:

```bash
cd /Users/luizgustavo/git/vault
qmd init
qmd collection add . -n vault
qmd update -c vault
qmd embed -c vault 2>/dev/null
```

If the harness cannot rely on the vault-local `.qmd` yet and qmd reports
`SQLITE_CANTOPEN`, `unable to open database file`, or a misleading `sqlite-vec`
startup failure, wrap qmd with a workspace-local cache before falling back to `rg`:

```bash
qmd_local() {
  mkdir -p "$PWD/.qmd-cache/qmd"
  XDG_CACHE_HOME="$PWD/.qmd-cache" qmd "$@"
}
```

Use that only as a compatibility fallback. Prefer the vault-local `.qmd` when
available.

### 2. Use snippets before reading whole files

qmd snippets are usually enough for quick lookup.

Read the full note only when:

- the user asks for the full note
- the snippet is cut off and misses the important part
- you are building a deeper synthesis

### 3. Fallback when qmd is unavailable or not initialized

If qmd cannot be used in the current session, fall back to targeted search with `rg` and `find`.

```bash
rg -l "exact phrase" /Users/luizgustavo/git/vault/flashcards --type md
rg -l "exact phrase" /Users/luizgustavo/git/vault/concursos --type md
rg -l "exact phrase" /Users/luizgustavo/git/vault/uni --type md
rg -l "exact phrase" /Users/luizgustavo/git/vault/curriculo --type md
rg -l "exact phrase" /Users/luizgustavo/git/vault/vida --type md
find /Users/luizgustavo/git/vault -name "*slug*" -not -path "*/.obsidian/*"
```

Do not run `rg` just to confirm what qmd already found.

## Area selection

Pick the likely area first, then widen only if needed.

- Concurso or revisão: search `flashcards/` first, then `concursos/`
- Faculdade, disciplina, TCC: search `uni/` first
- Currículo, experiência, estágio, projetos: search `curriculo/` first
- Organização pessoal, rotinas, pendências: search `vida/` first
- Broad recall or synthesis: search everything

If the user asks whether a topic already has a flashcard, inspect `flashcards/` before suggesting new material.

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
