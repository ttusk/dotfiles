---
name: commit
description: Git commit with conventional commits, optional draft PR, and small human-written messages. Use when the user asks to commit, save changes, stage and commit, or create a PR.
---

# Commit

Create small, incremental git commits. Optionally open or update a draft PR.

## Commit format

```text
<type>(<scope>): <short description>
```

Types: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`

## Rules

1. stage explicitly with `git add <files>`
2. keep the message concise
3. use lowercase after the prefix
4. never mention AI, agents, Codex, OpenCode, or assistants
5. never add `Co-Authored-By`
6. no emoji
7. one logical change per commit

## Before committing

Inspect the diff:

```bash
git diff
git diff --staged
```

Run the relevant tests before committing.

## Draft PR

When the user also wants a PR:

1. make sure the current branch is not `main` or `master`
2. push the branch if needed
3. gather the branch diff and recent commits
4. draft a PR title and body
5. show them for approval before creating or editing the PR

## PR style

- natural prose
- short background
- key decisions as facts
- no changelog dump
- no AI mentions
