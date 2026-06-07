---
name: note
description: Capture an insight, idea, study note, flashcard, or reference into Luiz Gustavo's Obsidian vault at `/Users/luizgustavo/git/vault`. Use when the user wants to save something for later, jot down an idea, record a TIL, start a blog draft, create a flashcard, save concurso material, save faculdade notes, store curriculum material, or add anything to the vault. Trigger on phrases like "save this", "note this down", "I had an idea", "TIL", "remember this", "add to vault", "create a flashcard", "salva isso", and "anota isso".
---

# Note

Saves a note to the Obsidian vault at `/Users/luizgustavo/git/vault`.

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

## Flashcards

Before creating a flashcard:

1. Check whether the vault already has a flashcard on that topic
2. Reuse the existing pattern from `flashcards/`
3. Keep the card atomic. One rule, one concept, or one contrast per card
4. Use a hierarchical flashcard tag for the deck, based on the subject

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
```

## Steps

1. Understand what the user wants to capture
2. Pick the right folder based on content type
3. Search the vault for related notes with `qmd search -c vault "topic"` when available
4. Write the note with frontmatter, content, and links to related notes
5. If it is a flashcard, use the vault's flashcard format with `#flashcards/{subject}` instead of YAML frontmatter
6. Update the qmd index: `qmd update -c vault && qmd embed -c vault 2>/dev/null`
7. Confirm to the user what was saved and where
