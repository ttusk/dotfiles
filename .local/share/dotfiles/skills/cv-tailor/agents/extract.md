# extract — Keyword & Relevance Analysis

Extract structured requirements from a job description.

## Input

Job description text or URL. If URL, fetch the content first. If the URL is behind a login wall, ask the user to paste the text instead.

## Output

Return a JSON-like structure in plain text:

```
ÁREA: [backend | dados | ml | fullstack | arquitetura | devops]
SENIORIDADE: [junior | pleno | senior | staff | não especificada]

STACK:
- ferramenta1 (obrigatório)
- ferramenta2 (diferencial)

SOFT SKILLS:
- skill1
- skill2

KEYWORDS OBRIGATÓRIAS:
- termo que deve aparecer no CV
- termo que deve aparecer no CV

DIFERENCIAIS:
- algo que pontua bem se tiver
- algo que pontua bem se tiver

IDIOMA DA VAGA: [pt | en]
```

## Rules

1. **Stack**: diferencie obrigatório de diferencial. Se a vaga diz "experiência com X", é obrigatório. Se diz "conhecimento em X" ou "desejável X", é diferencial.

2. **Keywords obrigatórias**: extraia termos exatos que o ATS vai buscar. Ex: se a vaga pede "ETL pipelines", inclua "ETL" e "pipelines" como keywords separadas. Inclua variações relevantes.

3. **Senioridade**: infira por sinais — "lidere", "arquitetar", "ownership" → senior/staff; "experiência com", "conhecimento em" → pleno; "apoio", "aprender", "vaga de entrada" → junior.

4. **Idioma**: detecte pelo texto da vaga. Se misto, priorize o idioma da maioria do texto.

5. Se a vaga pedir uma stack que o usuário claramente não domina (ex: pede C# e o master record só tem Python), avise como GAP no final da análise.
