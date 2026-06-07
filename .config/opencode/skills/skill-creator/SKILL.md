---
name: skill-creator
description: Create new skills, modify and improve existing skills, and measure skill performance for Codex and OpenCode. Use when users want to create a skill from scratch, edit or optimize an existing skill, structure skill resources, define trigger descriptions, or run a practical review loop for a skill in these harnesses.
---

# Skill Creator

A skill for creating new skills and iteratively improving them in `Codex` and `OpenCode`.

This adaptation is for your current harnesses. The upstream version came from a Claude-oriented workflow. Some bundled scripts still exist as imported artifacts, but this skill's instructions should follow the realities of `Codex` and `OpenCode`, not Claude-specific behavior.

## Goal

Help the user:

- create a new skill
- improve an existing skill
- tighten a skill's trigger description
- organize scripts, references, and assets
- review whether the skill behaves well in realistic prompts

## Working model

At a high level:

1. understand what the skill should do
2. inspect the current skill or draft one from scratch
3. define realistic trigger situations
4. shape `SKILL.md` and any bundled resources
5. validate the skill with practical prompts
6. iterate until the result is solid

If the user already has a draft, jump directly to review and improvement.

If the user wants a lightweight flow, skip formal evaluation and work conversationally.

## Important harness note

The bundled scripts in this imported `skill-creator` directory are not fully ported to `Codex` or `OpenCode`.

Treat them like this:

- `scripts/package_skill.py`, `scripts/quick_validate.py`, `scripts/aggregate_benchmark.py`, and the reference material may still be useful
- `scripts/run_eval.py` and `scripts/improve_description.py` are upstream Claude-specific utilities and should not be assumed to work in your current harnesses
- when in doubt, prefer inline validation using the current harness rather than depending on those scripts

Do not present Claude-specific commands as if they were valid for Codex or OpenCode.

## Communicating with the user

Assume a mixed audience. Some users are very technical. Some are not.

In the default case:

- `evaluation` and `benchmark` are fine
- explain terms like `JSON`, `assertion`, or `frontmatter` when the user may not know them
- keep explanations short and practical

## Creating or updating a skill

### 1. Capture intent

Start from the current conversation whenever possible.

Extract:

1. what the skill should enable the harness to do
2. when the skill should trigger
3. what output shape or behavior is expected
4. whether the user wants a formal validation loop or a lighter pass

### 2. Interview and research

Ask only the questions needed to remove ambiguity:

- edge cases
- input and output formats
- example prompts
- dependencies
- success criteria

If the harness supports subagents and they would help, use them. Otherwise research inline.

### 3. Write or revise `SKILL.md`

Focus on:

- `name`
- `description`
- the workflow or rules the skill should follow
- references to bundled resources when relevant

The `description` is the primary trigger surface. It must say both:

- what the skill does
- when to use it

Descriptions should be a bit assertive so the harness does not underuse the skill.

## Skill writing guide

### Anatomy of a skill

```text
skill-name/
├── SKILL.md
├── scripts/
├── references/
└── assets/
```

### Progressive disclosure

Use three levels:

1. metadata in frontmatter
2. the main `SKILL.md` body
3. references, scripts, and assets loaded only when needed

Keep `SKILL.md` lean. Move bulk material into `references/` or scripts.

### What good skills contain

Include:

- trigger guidance
- workflow guidance
- constraints that matter
- concrete examples when they help
- references to helper files

Do not add random extra docs like `README.md`, `CHANGELOG.md`, or process diaries unless the skill truly needs them.

## Validation loop for Codex and OpenCode

Use this practical loop instead of assuming Claude-specific automation:

### Step 1: Draft realistic prompts

Write 2 to 5 prompts that a real user of Codex or OpenCode would actually type.

Make them:

- concrete
- slightly messy when realistic
- varied in scope
- representative of true trigger situations

### Step 2: Review the prompts with the user

Show the prompts and let the user approve, reject, or add more.

### Step 3: Run the prompts in a practical way

Choose the best available method:

- manual harness review in the current conversation
- subagent-based comparison when available
- side-by-side reasoning with and without the skill's guidance

When comparing versions:

- compare the current skill vs no skill, or
- compare the new skill vs the previous draft

### Step 4: Evaluate output quality

Look at:

- whether the skill triggered when it should
- whether it stayed out of the way when it should not trigger
- whether the workflow was followed
- whether the outputs were more accurate, structured, or useful
- whether the skill is too broad, too narrow, or too verbose

### Step 5: Revise

Improve:

- the trigger description
- workflow clarity
- references and examples
- structure and resource layout

Then run another pass.

## What to do with the bundled upstream scripts

Because this imported package came from a Claude-oriented repo:

- do not assume `run_eval.py` works here
- do not assume `improve_description.py` works here
- if the user wants those scripts ported for Codex or OpenCode, treat that as a separate engineering task

If needed, say plainly that they are upstream artifacts and not yet harness-native.

## Description tuning guidance

When improving a description, optimize for:

- recognizable trigger phrases
- clarity about what the skill is for
- clear boundaries for when not to use it
- distinctiveness from other installed skills

Bad description:

```text
Helps with dashboards.
```

Better description:

```text
Create and refine dashboard specs, metrics layouts, and stakeholder-facing reporting flows. Use whenever the user asks to plan, scope, or specify a dashboard, analytics panel, KPI view, or executive metrics feature.
```

## Packaging and structure

If the user wants a clean installable skill:

- ensure the folder name matches the skill name
- ensure `SKILL.md` exists
- keep references and scripts organized
- remove clutter that does not help the harness perform the task

Use the helper scripts only when they are actually compatible with the current harness and task.

## Default stance

Prefer practical adaptation over clever automation.

For Codex and OpenCode:

- inline validation is acceptable
- subagent validation is good when available
- imported Claude-only automation should be treated as optional legacy baggage until explicitly ported
