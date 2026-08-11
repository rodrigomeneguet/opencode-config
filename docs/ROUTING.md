# Politica de Roteamento

## Regra principal

Tudo comeca no `luna-operator`.

Escalar nao e premio por dificuldade percebida. Escale quando houver evidencia de que outro papel reduz risco, tentativas ou custo total.

## DeepSeek Worker

Use quando todas as condicoes abaixo forem verdadeiras:

- tarefa independente;
- baixo risco;
- resultado objetivamente validavel;
- dados nao sensiveis ou sanitizados;
- erro do worker nao compromete producao ou caminho critico.

Exemplos: documentacao, testes, exploracao de codigo publico/pessoal nao sensivel, busca de padroes, revisao independente, pequenas implementacoes isoladas.

## Luna Worker XHigh

Use para:

- caminho critico;
- codigo privado;
- infraestrutura sensivel;
- implementacoes integradas;
- tarefas com alto custo de retrabalho;
- subtarefas que precisam seguir o plano com muita fidelidade.

## Terra Diagnostician

Use quando:

- existem varias hipoteses plausiveis;
- logs e sintomas atravessam componentes;
- duas tentativas razoaveis falharam;
- o problema e intermitente;
- cronologia, topologia e dependencias precisam ser correlacionadas;
- a causa raiz ainda nao esta demonstrada.

## Strategic Advisor

Use quando:

- ha decisao arquitetural;
- seguranca ou identidade estao em jogo;
- existe risco de perda de dados ou indisponibilidade ampla;
- a mudanca e dificil de reverter;
- backup, recuperacao ou rollback precisam ser validados;
- ha trade-off de longo prazo;
- Terra e Luna continuam incertos.

## Terra Lead

Selecione manualmente quando a tarefa deixa de ser uma intervencao e vira um projeto:

- varias frentes dependentes;
- varios componentes/repositorios;
- migracao em fases;
- integracao entre backend, frontend, banco, automacao e observabilidade;
- incidente complexo com coordenacao de varias linhas de investigacao.

## Anti-padroes

- Chamar advisor para tarefa mecanica.
- Mandar logs inteiros para modelos mais caros sem filtragem inicial.
- Usar DeepSeek Free com informacao confidencial.
- Criar workers com escopo vago.
- Deixar dois workers editarem a mesma area sem coordenacao.
- Insistir indefinidamente no modelo barato quando a evidencia aponta para escalonamento.
