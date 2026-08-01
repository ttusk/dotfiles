---
name: leif-concurso-import
description: Map a Brazilian concurso edital into Leif by extracting the syllabus, separating matérias, deduplicating assuntos, estimating item/topic structure, prioritizing study by cost-benefit/ROI, optionally creating matching Tec Concursos cadernos, and importing the result into Leif's Obsidian plugin data.json. Use when the user provides an edital PDF/text/URL and asks to map, structure, bootstrap, import, load a concurso into Leif, plan study priorities, or create Tec cadernos for the mapped assuntos.
---

# Leif Concurso Import

Turns an edital into Leif data: concurso → matérias → recursos/items → edital assuntos/topics.

Use this skill when the user wants to map an edital and import the result into the Leif Obsidian plugin. If the task is only to create Obsidian notes/caderno-de-erros, use the existing `concurso` skill instead.

## Inputs

Accept any of:

- edital PDF path
- pasted edital text
- edital URL
- previously extracted syllabus

Before importing, identify the target Leif data file. Default: current repo `sample-vault/.obsidian/plugins/leif/data.json` when working inside the Leif repo; otherwise ask for the vault path.

## Workflow

1. Extract edital content.
   - For PDFs, extract text with `pdfplumber` or another available PDF tool.
   - Focus on cargo/perfil, banca, prova date, conteúdo programático, subjects/disciplines, question counts, weights, and links.

2. Produce a concise mapping plan.
   - Contest metadata: name, board, exam date, notice/exam links if known.
   - Matérias: discipline name, order, planned minutes if inferable.
   - Items: larger study blocks under each matéria. Prefer edital sections/subsections.
   - Topics: atomic assuntos. Preserve edital wording.

3. Produce a study ROI plan.
   - Read `references/study-prioritization.md`.
   - Estimate each matéria's payoff using available evidence: question count/weight, breadth, user's known strengths/weaknesses, expected current accuracy, expected gain, and study time cost.
   - Classify the study strategy before deciding caderno granularity:
     - `practice broad`: learn mostly through full/broad FCC-style questions or provas;
     - `targeted`: study concise theory plus edital-aligned questions;
     - `law/framework exact`: read the named source/framework and drill exact filters;
     - `skim/monitor`: low ROI or taxonomy-poor topics where a compact summary plus occasional questions is better than over-mapping.
   - Use this plan to decide whether a broad caderno, a precise caderno, multiple clusters, or no special caderno is worth the effort.

4. Deduplicate assuntos.
   - One concept should live under one matéria/topic home.
   - Detect overlaps by same law/standard, named entity, technology, or same concept in different words.
   - Present overlap decisions before import if more than trivial.

5. Ask before writing when judgment matters.
   - If cargo/perfil is ambiguous, stop and ask.
   - If overlap resolution changes where topics live, show a short table and ask for approval.
   - If the target data file has existing contests, ask whether to append, replace an existing contest, or create a new one unless the user already specified.

6. Create an import JSON.
   - Use `references/import-schema.md` for the accepted shape.
   - Keep IDs stable and kebab-case. Prefix IDs with the contest slug.
   - Do not include study sessions; import structure only.

7. Optional: create Tec Concursos cadernos.
   - Only do this when the user explicitly asks for Tec cadernos.
   - Read `references/tec-concursos.md`.
   - Treat Tec as browser-assisted automation unless the user provides an official API/export mechanism.
   - Ask the user to log in manually; never store credentials.
   - Before creating cadernos, build a Tec filter plan from the edital topics and the ROI plan, not just from Leif subject names. Inspect the Tec filter tree deeply enough to choose exact assuntos where doing so improves study payoff.
   - Classify each matéria before filtering:
     - general/classic disciplines can use a broad Tec matéria + banca when the edital really covers the usual broad content (for example Portuguese, English, broad reasoning/math/statistics);
     - specific disciplines, legislation, standards, frameworks, tools, protocols, and named laws must use edital-aligned filters, not a whole Tec matéria.
   - Do not overfit cadernos when broad practice has better cost-benefit than fine filtering. For example, Portuguese and English often work better as broad banca/prova practice with error review than as dozens of grammar subtópicos.
   - Validate every created caderno in Tec's `Configurações` tab before writing its URL back to Leif. The settings rows, not the caderno title or creation success alone, are the authority.
   - Record Tec taxonomy gaps honestly. If a law/tool/standard has no usable filter or has zero questions with the banca filter, keep the closest valid filter only when it is useful and report the limitation.

8. Merge into Leif.
   - Run `scripts/import_leif_concurso.py --data <data.json> --import <mapped.json>`.
   - Use `--replace` only when the user explicitly wants to replace an existing contest with the same ID.
   - Validate the resulting JSON has coherent links: contest.subjectIds, subject.itemIds, subject.topicIds, and contestStates.
   - When syncing Tec cadernos into an existing Leif contest, audit every topic in the target contest: no topic should be left without a `questionNotebook.url` unless deliberately skipped and reported.

9. Report the result.
   - Summarize contest name, number of matérias, items, topics, and target data file.
   - Include the study attack plan: high ROI priorities, broad-practice subjects, exact-filter subjects, low-ROI/skim subjects, and assumptions.
   - If Tec cadernos were created, include caderno names/URLs and any failures.
   - Mention any assumptions, broad/fallback cadernos, Tec filters that had no questions, and unresolved edital ambiguity.

## Import rules

- Preserve existing Leif data unless replacing is explicitly requested.
- Never overwrite a contest with the same ID without permission.
- Use `activeContestId` only if the user asks to make the imported concurso active.
- Keep imports conservative: no fabricated question counts, pages, notebooks, or materials unless they appear in the edital or user provides them.
- Prefer a clean first import over a perfect taxonomy. The user can refine in Leif.
