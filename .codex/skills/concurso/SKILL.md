---
name: concurso
description: Bootstrap a new concurso structure in the Obsidian vault by extracting the edital syllabus, deduplicating overlapping topics across disciplines into atomic non-redundant subject files, and creating a clean index.md with all metadata. Use when the user provides an edital (PDF, text, or URL) and wants to set up a new concurso, or when they want to reorganize an existing concurso to eliminate cross-discipline topic overlap. Trigger on phrases like "criar concurso", "mapear edital", "estruturar concurso", "organizar estudos para", "bootstrap concurso", "novo edital", and "extrair assuntos".
---

# Concurso

Bootstraps the manual caderno structure in the Obsidian vault at `/Users/luizgustavo/git/vault`. Extracts the full syllabus from the edital, deduplicates overlapping topics, and produces orthogonal (non-redundant) subject files.

## Vault boundary

This skill writes only to `concursos/{concurso}/`. That folder is the manual, canonical caderno de erros. It must not move, rewrite, or merge the active Leif plans under `Leif/concursos/`; use `leif-concurso-import` when the user explicitly wants a Leif plan.

Do not place material in `credenciais/`, generated paths, plugin backups, or `.obsidian/`.

## Core principle: zero topic overlap

The edital often lists the same concept under multiple disciplines (e.g., Docker appears in both "Computação em Nuvem" and "Automação", LGPD appears in both "Legislação" and "Segurança da Informação"). This redundancy wastes study time.

Every atomic topic must live in **exactly one** subject file. No exceptions. Cross-references are noted as comments inside the file, not as separate entries.

## Workflow

### Step 1: Extract the syllabus

Read the edital (PDF, text, or URL). Extract the full conteúdo programático for the chosen cargo/perfil. Preserve the raw hierarchy: Module > Discipline > Topic > Subtopic.

If the edital is a PDF, use `python3 -c "import pdfplumber..."` to extract text. Prioritize the Anexo that lists the programmatic content.

Also extract edital metadata: cargo, perfil, vagas, lotação, salário, banca, datas, estrutura da prova.

### Step 2: Map topics to a flat list

Flatten the hierarchy into a list of leaf topics. Each leaf gets:

- `topic`: the exact text from the edital
- `discipline`: the discipline/section it came from (e.g., "REDES DE COMPUTADORES")
- `module`: "Gerais" or "Específicos"
- `lineage`: the full path from module > discipline > ... > topic

Keep the list as a structured reference. Do not skip subtopics.

### Step 3: Detect overlaps

Walk the flat topic list and flag semantic overlaps. An overlap means the same concept, technology, law, or knowledge area appears in more than one discipline.

Overlap signals (check all of these):

1. **Same named entity**: Docker, Kubernetes, LGPD, Lei 13.709, VMware, Python, Java, Git, Ansible, Puppet, NIST, COBIT, ITIL, Scrum, etc.
2. **Same concept expressed differently**: "Infrastructure as Code" = "IaC" = "infraestrutura como código". "Segurança de redes" ≈ "segurança em redes de computadores". "Backup" ≈ "rotinas de Backup e Recuperação".
3. **Same law/standard cited**: Lei 13.709/2018, NBR ISO 27001, etc.
4. **Same technology stack**: Java EE + Jboss + Weblogic appearing in multiple files
5. **Nested containment**: "Segurança na nuvem" belongs to both Cloud and Segurança. Default resolution: keep in the more specific discipline.

When any of these signals fire, flag the overlap. Present the conflict to the user as:

```markdown
## Overlaps detected

| Topic | Found in | Suggested home |
|---|---|---|
| Docker e Kubernetes | Computação em Nuvem, Automação | Computação em Nuvem |
| LGPD (Lei 13.709) | Leg. Segurança, Segurança da Informação, Plataforma Básica | Leg. Segurança (Módulo Gerais) |
| Python | Automação, Aplicações, Ferramentas Analytics | Linguagens e Frameworks |
...
```

### Step 4: Resolve overlaps

Resolution rules, applied in order:

1. **Module priority**: If a topic appears in both Módulo I (Gerais) and Módulo II (Específicos), keep the detailed version in Específicos. In Gerais, keep only a cross-reference note pointing to the Específicos file.
2. **Specificity wins**: If a topic is the core business of one discipline and a side mention in another, keep it in the core discipline. "Python" lives in Linguagens, not in Automação. "LGPD" lives in Legislação, not in Segurança.
3. **First occurrence tiebreaker**: If two disciplines have equal claim, keep it in the first file alphabetically.
4. **Always ask the user**: The resolution rules are defaults. Present the proposed resolution and let the user override. The user knows their study strategy best.

After resolving, produce a **normalized topic map**: each discipline file gets a unique, non-overlapping set of topics. Every topic from the original edital is covered exactly once.

### Step 5: Create subject files

For each normalized discipline, create `concursos/{concurso}/caderno-de-erros/{subject}.md`.

Each subject file:

```markdown
# {Discipline Name}

## Assuntos mapeados

### {Topic 1}

### {Topic 2}
```

Rules:
- `###` headings are the atomic, deduplicated topics
- If a topic was relocated here from another discipline, add a brief note in the heading: `### Tópico (realocado de {source})`
- If this file lost topics to another file, note at the top: `<!-- Tópicos de {topic} movidos para [[{other-file}]] -->`
- Leave topics empty. The user fills in macetes later.
- No `## Erros registrados` section. Macetes go under `###` headings directly.
- Filename is lowercase kebab-case: `redes-computadores.md`, `legislacao-seguranca-dados.md`

### Step 6: Create index.md

Create `concursos/{concurso}/index.md`:

```markdown
---
tags: [concurso, {concurso}]
created: YYYY-MM-DD
---

# {Nome do Concurso}

{Perfil} — **{Perfil Name}**. Lotação: {cidade}. Banca: **{banca}**.

- **Vagas:** ...
- **Salário:** ...
- **Portal:** {link}
- **Validade:** ...

## Prazos

| Evento | Data |
| --- | --- |
| Inscrições | ... |
| Prova | ... |

## Prova

{table with módulo, disciplina, questões, peso, máx}

**Desempate:** ...

## Caderno de erros

### Gerais (qtd q, peso X)

- [[concursos/{concurso}/caderno-de-erros/{subject}|{Subject Name}]]

### Específicas (qtd q, peso X)

- [[concursos/{concurso}/caderno-de-erros/{subject}|{Subject Name}]]

## Pendências

- [ ] Efetivar inscrição
- [ ] Pagar boleto
```

## Slugs

Generate lowercase kebab-case slugs from discipline names. Strip diacritics. Examples:

- "Redes de Computadores" → `redes-computadores`
- "Legislação Acerca de Segurança da Informação e Proteção de Dados" → `legislacao-seguranca-dados`
- "Computação em Nuvem e Virtualização" → `computacao-nuvem`

## Handling multiple profiles

If the user wants to compare profiles or hasn't decided yet, run Steps 1-3 for all IT-relevant profiles, show the overlap analysis per profile, and let the user pick before proceeding to Steps 5-6.

## Reorganizing an existing concurso

If the user asks to reorganize ("quero reorganizar", "tem overlap demais", etc.):

1. Read all existing subject files
2. Run Step 3-4 across them to find overlaps
3. Present the deduplication plan
4. After approval, rewrite files with clean non-overlapping topics
5. Update index.md links if filenames changed

Do not delete old files until the user approves the new structure.

## Constraints

- Never create overlapping topics across files. One concept = one file.
- Do not fabricate topics not present in the edital.
- When the edital is vague ("Noções de...", "Conceitos de..."), extract the topic as-is. The user can refine later.
- Module I (Conhecimentos Gerais) is the same for all profiles of a concurso. Reuse the same files if multiple profiles share the same concurso.
- Keep the output concise. The index.md should be scannable. Subject files should be skeletons.
