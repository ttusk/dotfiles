---
name: commit
description: "Git commit with conventional commits, mandatory decision-focused bodies, optional draft PRs, and small human-written messages. Use when the user asks to commit, save changes, stage and commit, or create/open/update a PR."
---

# Commit

Create small, incremental git commits following Conventional Commits. Optionally open or update a draft PR.

## Usage

- `/commit` — commit staged changes
- `/commit detailed` — propose a multi-paragraph commit message for approval
- `/commit --pr` — commit pending changes and open or update a draft PR

## Commit format

```text
<type>(<scope>): <short description>

<body: the decisions behind this commit>
```

Types: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`

The scope is optional and names the module or area, such as `auth`.

## Commit message rules

1. The subject is concise, lowercase after the prefix, and uses the imperative mood.
2. Every commit has a body. Explain why the change was made this way, not what the diff already shows.
3. The body states decisions, constraints, non-obvious consequences, or meaningful rejected alternatives.
4. Use two to five body lines for ordinary commits; one line is acceptable only when it captures the complete decision.
5. Wrap lines at 72 columns.
6. Never mention AI, agents, Codex, OpenCode, Claude, Copilot, or assistants.
7. Never add a `Co-Authored-By` trailer.
8. Never use emojis.
9. Keep one logical change per commit. During TDD, commit after each RED-GREEN-REFACTOR cycle.

Do not use file lists, changelogs, implementation walkthroughs, or hedging in the body.

## Modes

### Quick (default)

Inspect the work, stage only the intended files, and commit directly with a subject and short decision-focused body.

### Detailed

For milestone features, architectural changes, or non-obvious fixes, propose the complete multi-paragraph message as plain text. Do not run `git commit` until the user approves it.

## Luiz's dotfiles repo

For Luiz Gustavo's dotfiles setup:

- the dotfiles repo is a bare repo at `$HOME/.dotfiles.git` with `$HOME` as the work tree
- use the `dots` alias instead of plain `git` when operating on that repo
- prefer commands like `dots status`, `dots diff`, `dots add`, `dots commit`, and `dots push`
- if files are ignored but intentionally versioned in the dotfiles repo, use `dots add -f <files>`

## Before committing

1. Inspect both unstaged and staged diffs:

   ```bash
   git diff
   git diff --staged
   ```

2. Run the project's relevant test suite or verification command.
3. Stage explicitly with `git add <files>`; never use `git add -A` or `git add .`.
4. Review the staged diff again.
5. Commit with a body.

## Draft PR (`--pr`)

When the user requests a PR:

1. Check the current branch with `git branch --show-current`.
2. Never commit to `main` or `master` unless explicitly requested. Create a feature branch when needed, using `feat/`, `fix/`, `refactor/`, `test/`, `chore/`, or `docs/`.
3. Commit pending changes before creating or updating the PR.
4. Gather commits and the branch diff relative to `main` or `master`.
5. Check whether a PR already exists with `gh pr view --json number,title,body`.
6. Propose the PR title and body, then wait for user approval before creating or editing it.
7. Push the branch when needed, then use `gh pr create --draft` for a new PR or `gh pr edit` for an existing one.
8. Report the resulting PR URL.

### PR title

```text
<type>: <short description>
```

Use lowercase, imperative wording, and fewer than 70 characters. If a Linear ID is available, prefix it as `TEAM-123 -`.

### PR body

Use only these sections:

```markdown
<issue URL, if one exists>

### Background

1-2 paragraphs explaining the problem and high-level approach.

### Key Decisions

1. **Decision title**: brief statement of the choice.
2. **Another decision**: brief statement of the choice.
```

Omit the issue URL when none exists. Omit `Key Decisions` when there are no meaningful decisions. Do not include checklists, file lists, templates, changelogs, or `Closes` keywords.

## PR style

- Write fluid, natural prose.
- State key decisions as facts, without implementation walkthroughs.
- Never mention AI, agents, Claude, Copilot, or assistance.
- Do not use em dashes, en dashes, or double dashes.
