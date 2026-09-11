---
name: study-synthesis
description: "Transformar material estudado em notas condensadas, abstratas e úteis no vault de Luiz Gustavo, posicionando cada conceito no assunto certo e separando fonte, interpretação e aplicação. Use quando ele pedir para resumir uma leitura, extrair termos, organizar anotações de aula, artigo ou livro, melhorar uma nota de estudo, ou salvar o que aprendeu no lugar pertinente do vault. Não usar para captura genérica, flashcards isolados, mapeamento de edital ou redação de blog."
---

# Study synthesis

Ajude Luiz Gustavo a transformar leitura em conhecimento recuperável. O resultado não é uma transcrição nem um resumo escolar da fonte. É uma nota curta, abstrata e suficientemente precisa para ser reutilizada em uma revisão, questão, projeto ou explicação futura.

## Quando usar

Use esta skill quando houver material concreto para estudar e o pedido envolver uma ou mais destas ações:

- condensar um artigo, capítulo, aula, documentação, vídeo ou trecho fornecido;
- extrair e explicar termos, conceitos, relações, mecanismos, limites ou consequências;
- transformar rascunho, marcações ou transcrição em uma nota de estudo limpa;
- corrigir, expandir ou reposicionar conhecimento já existente no vault;
- salvar o que foi aprendido no assunto pertinente, em vez de criar uma captura solta.

Não use para:

- salvar uma ideia ou nota sem síntese, que pertence à skill `note`;
- atender mensagens cujo único resultado é criar ou editar um flashcard, mesmo que o tema seja acadêmico. Deixe a skill `note` cuidar desse formato;
- mapear edital, matérias ou prioridades de concurso, que pertencem a `concurso` ou `leif-concurso-import`;
- escrever ou revisar artigo de blog, que pertence a `ghostwriter`.

## Contrato de saída

1. Preserve a verdade da fonte. Não complete lacunas com memória ou invenção.
2. Separe explicitamente o que a fonte afirma, a interpretação feita e a aplicação ao projeto ou à prova quando essas camadas existirem.
3. Dê prioridade à nota canônica do assunto. Não crie um arquivo por termo se o conceito já tiver um lugar natural em uma nota existente.
4. Se o usuário pediu para salvar, edite o vault. Se pediu apenas ajuda para entender ou condensar, entregue um rascunho e indique o provável destino sem escrever por conta própria.
5. Se faltarem fonte, trecho ou contexto indispensável, diga exatamente o que falta. Não fabrique uma síntese plausível.

## Fluxo

### 1. Entender o material e a finalidade

Identifique, nesta ordem:

- qual é a fonte e qual parte foi realmente lida;
- qual é o objetivo: revisão, prova, faculdade, TCC, projeto ou vocabulário geral;
- quais conceitos merecem registro e quais são apenas contexto;
- se a saída deve ser rascunho, atualização de nota existente ou nova nota.

Não resuma parágrafo por parágrafo. Extraia somente o que muda a compreensão, a decisão ou a capacidade de resolver um problema.

### 2. Encontrar o lugar certo no vault

O vault fica em `/Users/luizgustavo/git/vault`. Para localizar contexto, use `qmd` somente quando a coleção `vault` estiver disponível e continuar limitada a Markdown seguro. Comece por `index.md`, pesquise o termo e seus sinônimos e leia a nota candidata antes de escolher o destino. Nunca use `credenciais/`, `curriculo/exports/`, `tmp/`, `.obsidian/`, `.qmd/` ou `.git/` como fonte.

A regra principal é o **escopo de utilidade**, não a data da leitura. O fato de ter aprendido algo hoje não cria um TIL. Nesta skill, não crie novas notas em `learning/til/`. Trate os arquivos que já existem ali como legado: leia-os quando ajudarem e só migre seu conteúdo quando o usuário pedir.

Prefira, nesta ordem:

1. identificar a pasta que representa o uso futuro do conhecimento;
2. ampliar a nota canônica desse escopo;
3. preencher a seção ou o heading já existente que corresponde ao conceito;
4. criar uma nota conceitual dentro desse mesmo escopo quando não houver lugar natural.

Exemplos:

- conceito de grafos estudado para o TCC: procurar primeiro em `uni/tcc/` e ampliar `uni/tcc/fundamentacao-teorica.md` ou outra nota conceitual já existente nessa pasta;
- conteúdo de uma disciplina: permanecer em `uni/{area}/`;
- decisão ou fundamento de um projeto: permanecer em `projects/{project}/`;
- regra de concurso: permanecer em `concursos/{concurso}/caderno-de-erros/`;
- referência geral sem projeto ou disciplina: usar `references/` somente se tiver valor duradouro;
- material ainda sem escopo identificável: usar `inbox/` como último recurso.

Quando o conceito aparecer em mais de um escopo, escolha uma casa principal conforme a utilidade imediata e use `[[wikilinks]]` nas aplicações relacionadas. Duplique apenas quando a mesma palavra representar modelos ou usos realmente diferentes.

Ao editar, preserve o frontmatter, a estrutura e o estilo do arquivo. Use Obsidian CLI para operações de vault quando isso for útil; caso contrário, edite diretamente com segurança.

### 3. Construir a abstração

Para cada conceito que sobreviver à triagem, responda mentalmente:

- **O que é?** Definição que separa o conceito dos vizinhos.
- **Como funciona ou se relaciona?** Mecanismo, condição, fórmula ou cadeia causal.
- **Quando se aplica?** Uso, consequência ou sinal que ajuda na recuperação.
- **Qual é o limite?** Exceção, hipótese, contraste ou confusão provável.
- **Qual exemplo mínimo fixa a ideia?** Só inclua exemplo que torne o abstrato verificável.

A unidade final deve ser uma ideia reutilizável, não a ordem em que a fonte a apresentou. Elimine repetições, detalhes ornamentais, introduções genéricas e exemplos que não acrescentem uma distinção.

### 4. Escrever no estilo do vault

- Português por padrão para explicações, opiniões e notas de estudo. Preserve nomes técnicos em inglês quando esse for o uso normal.
- Comece pela afirmação principal. Não use abertura vazia como “neste texto veremos”.
- Na primeira ocorrência, destaque o termo em **negrito**. Use headings `##` e `###` para conceitos que precisam ser recolhíveis.
- Organize o bloco como definição, relação ou mecanismo, limite ou contraste e exemplo ou aplicação, nesta ordem quando todos forem necessários.
- Use parágrafos curtos e listas somente para itens realmente paralelos. A nota deve parecer uma folha de estudo, não uma aula transcrita.
- Prefira verbos concretos e frases diretas. Não use em dash, slogans, frases de efeito, voz corporativa, enchimento ou prosa que pareça gerada por IA.
- Não empilhe sinônimos para parecer completo. Diga a mesma ideia uma vez, com o nível de precisão necessário.
- Use `$...$` para matemática inline e `$$...$$` somente para fórmulas em bloco. Preserve unidades, hipóteses e símbolos.
- Em leituras acadêmicas, registre URL, DOI e página ou seção quando a afirmação depender da fonte. Marque claramente decisões ou interpretações de Luiz Gustavo como tais.
- Adicione `[[wikilinks]]` para notas relacionadas já existentes. Não invente links só para decorar o texto.

### 5. Formatos por destino

**Nota conceitual ou TIL.** Uma definição forte, mecanismo, contraste relevante e um exemplo mínimo. Use o template existente quando criar arquivo novo, mantendo o frontmatter esperado.

**Nota de universidade ou TCC.** Preserve a hierarquia do documento. Na primeira ocorrência, defina o termo; depois registre a relação com o problema, método, métrica ou decisão. Separe “a fonte diz” de “no projeto, adotamos”.

**Caderno de erros.** Não registre o erro como diário. Sob o `###` do assunto, escreva somente a regra, condição, contraste ou macete que evita a repetição na próxima questão. Não crie datas, logs ou uma seção paralela de erros.

**Flashcard.** Só crie se for solicitado. Faça a síntese atômica, uma pergunta para uma regra ou contraste, e siga exatamente o formato Spaced Repetition já usado no vault. Se houver várias ideias, separe-as em cards.

## Critério de qualidade

Antes de salvar ou entregar, confira:

- o primeiro período permite reconhecer o conceito;
- a nota explica a relação ou consequência que torna o conceito útil;
- o limite ou contraste mais perigoso não foi perdido;
- o exemplo, se existe, testa a abstração em vez de repetir a definição;
- nenhuma afirmação importante foi inventada ou ficou sem fonte quando a fonte é necessária;
- o texto não repete uma nota já presente nem mistura níveis de abstração;
- o destino no vault é o assunto pertinente, com links e headings coerentes;
- um estudante consegue reler a nota rapidamente e reconstruir a ideia sem voltar à fonte inteira.

Depois de salvar, releia o trecho editado. Confirme o caminho, o heading usado, os links, a preservação do frontmatter e, em notas acadêmicas, as referências. Informe ao usuário o que foi sintetizado e onde ficou salvo.
