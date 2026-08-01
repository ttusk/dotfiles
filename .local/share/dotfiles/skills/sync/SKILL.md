---
name: sync
description: Scout the current project and update its project-level guidance so it matches the real stack, commands, tests, and conventions. Adapted for Codex and OpenCode. Use when the user wants to sync, bootstrap, tune, initialize, or refresh project instructions.
---

# Sync

Scout the project and sync its project-level guidance with reality.

Prefer a shared `AGENTS.md` as the primary project instruction file. If the project already has harness-specific docs, update them too. Do not create or maintain Claude-specific `.claude/rules` unless the project explicitly still depends on them.

## Usage

- `/sync` -> full sync
- `/sync agents` -> only update `AGENTS.md`
- `/sync harness` -> only update existing harness-specific docs

## Phase 1: Scout

If the harness supports subagents, launch a scout-style subagent. Otherwise scout inline.

Report:

- stack and versions
- test, lint, build, and format commands
- test structure
- naming and error-handling conventions
- existing docs such as `AGENTS.md`, `README.md`, `.codex/*`, `.opencode/*`, and legacy files

## Phase 2: Diff

Compare the scout findings against:

- `AGENTS.md`
- existing harness-specific docs
- other project docs that describe commands or conventions

Check:

- is `AGENTS.md` missing or outdated
- do documented commands match reality
- do docs describe the current architecture and conventions

## Phase 3: Propose

Present a sync plan with:

- files to create
- files to update
- files that look stale but should not be auto-deleted

Wait for approval before applying.

## Phase 4: Apply

- show diffs before writing
- preserve custom sections
- never delete existing guidance automatically
- prefer updating shared guidance in `AGENTS.md` over duplicating the same text in multiple harness folders

## Phase 5: Report

Summarize:

- created
- updated
- flagged for manual review
