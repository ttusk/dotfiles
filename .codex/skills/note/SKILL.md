---
name: note
description: Capture an insight, idea, study note, flashcard, or reference into Luiz Gustavo's Obsidian vault at `/Users/luizgustavo/git/vault`. Use when the user wants to save something for later, jot down an idea, record a TIL, start a blog draft, create a flashcard, save concurso material, save faculdade notes, store curriculum material, or add anything to the vault. Trigger on phrases like "save this", "note this down", "I had an idea", "TIL", "remember this", "add to vault", "create a flashcard", "salva isso", and "anota isso".
---

# Note

Saves a note to the Obsidian vault at `/Users/luizgustavo/git/vault`.

## Tool choice

Use the right tool for the job:

- Use `qmd` to search the vault for related notes and existing context.
- Use `Obsidian CLI` when you need vault-aware note operations such as create, append, prepend, move, rename, open, or template-based creation.
- Use direct file editing only as a fallback when `Obsidian CLI` is unavailable or when the task is simpler to perform directly.

`Obsidian CLI` is especially useful when:

- creating a note from a template
- appending or prepending content to an existing note
- moving or renaming a note while keeping the operation inside Obsidian's vault model
- opening the note after creation

Relevant commands from the official CLI:

```bash
obsidian vault="vault" create path="folder/note.md" content="..."
obsidian vault="vault" create path="folder/note.md" template="note" open
obsidian vault="vault" append path="folder/note.md" content="..."
obsidian vault="vault" prepend path="folder/note.md" content="..."
obsidian vault="vault" move path="folder/note.md" to="folder/new-name.md"
obsidian vault="vault" open path="folder/note.md"
```

## Writing style

All notes must follow the user's voice. Write like a human, not like an AI.

- Informal, conversational, direct. No corporate speak, no filler
- Never use em dashes. Use periods to separate ideas
- Short sentences. Punchy. Get to the point
- First person when expressing opinion. "We" when exploring together
- Portuguese for opinions, ideas, study notes, and process
- English for technical or code-heavy notes when that fits the source material
- No excessive formatting. Bold only for key terms on first mention
- No emoji in prose

## How to decide where it goes

Based on the content, pick the right location:

| Content | Path | Template |
|---------|------|----------|
| Quick thought, unsorted | `inbox/{slug}.md` | note |
| Blog post idea (one-liner) | Append to `blog/ideas.md` under `## Backlog` | - |
| Blog draft (outline ready) | `blog/drafts/{slug}.md` | blog-draft |
| Something learned today | `learning/til/{slug}.md` | til |
| Project-specific note | `projects/{project}/{slug}.md` | note |
| Useful link or tool | `references/{slug}.md` | note |
| Flashcard | `flashcards/{subject}/{slug}.md` | flashcard |
| Concurso study note | `concursos/{slug}.md` | note |
| Concurso error log by subject | `concursos/caderno-de-erros/{subject}.md` | caderno-de-erros |
| Faculdade note | `uni/{area}/{slug}.md` | note |
| Currículo or career material | `curriculo/{slug}.md` | note |
| Personal planning or life admin | `vida/{slug}.md` | note |

If ambiguous, ask the user. Default to `inbox/`.

## Slug

Generate a lowercase kebab-case slug from the title. Example: "Ruby GC tuning" becomes `ruby-gc-tuning`.

## Frontmatter

Every normal note should have YAML frontmatter:

```yaml
---
tags: [relevant, tags]
created: YYYY-MM-DD
---
```

For blog drafts, add `status: draft`. For project notes, add `project: {name}`.

Flashcards are an exception. Follow the Obsidian Spaced Repetition format already used in this vault instead of forcing YAML frontmatter.

## Links

If the note relates to existing notes, add `[[links]]` to connect them. Search with `qmd search -c vault "topic"` first when the vault collection is configured.

## Caderno de erros

Use this format when the user wants to save mistakes from questões, simulados, revisões, or weak spots by subject.

Rules:

1. Prefer appending to the subject file in `concursos/caderno-de-erros/` instead of creating scattered notes
2. Inside each subject file, keep the syllabus under `## Assuntos mapeados`
3. Each mapped topic should be a `###` heading so it can be collapsed in Obsidian
4. When logging a new mistake, append it under the matching `###` topic heading whenever possible
5. If the correct topic heading does not exist yet, create it as a new `###` heading under `## Assuntos mapeados`
6. Keep one error per entry
7. Record the practical cause of the mistake, not just the topic name
8. End each entry with a short correction or recall cue that helps avoid repeating the mistake

Suggested subject note shape:

```md
# Materia

## Assuntos mapeados

### Assunto 1

#### YYYY-MM-DD - erro curto
- Questao ou fonte:
- Onde eu errei:
- Correcao:
- Sinal de alerta para a proxima:

### Assunto 2
```

If the user sends only a raw syllabus or topic list, create just the `###` topic headings first and leave them empty until real errors are added.

Suggested error entry shape:

```md
#### YYYY-MM-DD - erro curto
- Questao ou fonte:
- Onde eu errei:
- Correcao:
- Sinal de alerta para a proxima:
```

## Flashcards

Before creating a flashcard:

1. Check whether the vault already has a flashcard on that topic
2. Reuse the existing pattern and file location from `flashcards/`
3. Keep the card atomic. One rule, one concept, one exception, one prazo, one competência, or one contrast per card
4. Prefer concurso-oriented cards. Ask about literal rule, distinction, pegadinha, exception, condition, or consequence
5. Keep the answer lean. No intro, no motivational explanation, no historical context, no extra example unless the user asked for it
6. If the material contains multiple points, split it into multiple cards instead of writing a long answer
7. Use a hierarchical flashcard tag for the deck, based on the subject

Convert the subject to lowercase kebab-case when using it in the tag.

Examples:

- `#flashcards/portugues`
- `#flashcards/direito-constitucional`
- `#flashcards/matematica/raciocinio-logico`

Use the current vault format for spaced repetition:

```md
#flashcards/{subject}

Pergunta
?
Resposta
<!--SR:!2026-06-09,1,230-->
```

For multiline answers (paragraphs, bullet lists, any answer spanning more than one line):

```md
#flashcards/{subject}

Pergunta
?
Primeiro paragrafo da resposta.

Segundo paragrafo da resposta.
<!--SR:!2026-06-09,1,230-->
+++
<!--SR:!2026-06-09,1,230-->
```

Flashcard contract:

- `?` is the separator for a normal flashcard
- `??` is for multiline reversed flashcards, not for ordinary multiline answers
- if the card depends on a table, matrix, diagram, code snippet, or other visual context, that context must appear before `?` so it is visible on the front of the card
- a single-line answer must end directly in one `<!--SR:!...-->` tag
- for multiline answers, place one `<!--SR:!...-->` line immediately after the answer text and immediately before `+++`
- in this vault, reviewed multiline cards may also keep a trailing `<!--SR:!...-->` line right after `+++`
- `+++` must stay immediately after the metadata line that comes after the answer
- when editing an existing multiline card, preserve the `<!--SR:...-->` line above `+++`. Do not remove it just to force a one-tag layout
- if the card already has a trailing `<!--SR:...-->` line after `+++`, preserve it unless the user asks to normalize the file

Avoid these failure modes:

- long lecture-style answers instead of a direct concurso answer
- putting the table, matrix, or diagram only in the answer when the user must inspect it before responding
- missing `<!--SR:...-->` immediately above `+++` in a multiline card
- multiline answer without `+++`
- extra `<!--SR:...-->` lines scattered inside the answer body instead of right above `+++`
- using `??` when the user did not ask for a reversed card

## Steps

1. Understand what the user wants to capture
2. Pick the right folder based on content type
3. Search the vault for related notes with `qmd search -c vault "topic"` when available
4. If `Obsidian CLI` is available and the task benefits from vault-aware operations, use it to create, append, prepend, move, rename, or open the note
5. Otherwise write the note directly with frontmatter, content, and links to related notes
6. If it is a flashcard, use the vault's flashcard format with `#flashcards/{subject}` instead of YAML frontmatter
7. Update the qmd index: `qmd update -c vault && qmd embed -c vault 2>/dev/null`
8. **Flashcard verification**: after creating or editing flashcards, always re-read the file and verify:
   - The question is atomic and concurso-oriented, not a broad essay prompt
   - The answer contains only the fact set needed to recall the point
   - A single-line answer ends with `<!--SR:!...-->`
   - A multiline answer ends with `<!--SR:!...-->` on the line above `+++`
   - If there is already a trailing `<!--SR:!...-->` line right after `+++`, keep it
   - There is no stray `<!--SR:!...-->` floating in the middle of the answer body, and no accidental `??`
9. Confirm to the user what was saved and where
