# Politica de Roteamento

## Regra principal

Tudo comeca no `luna-operator`.

O objetivo e economizar quota OpenAI sem sacrificar controle. Por isso, `deepseek-worker` deve ser usado agressivamente como primeira opcao de worker sempre que a tarefa puder ser revisada ou validada depois.

## DeepSeek Worker

Use amplamente para:

- exploracao de codebase;
- leitura e correlacao de logs;
- revisao de configuracoes;
- testes;
- documentacao;
- debugging;
- refatoracoes delimitadas;
- implementacoes isoladas;
- revisao de diff;
- scripts e IaC;
- investigacoes paralelas;
- segunda opiniao.

Repositorios privados, codigo privado, logs reais e configuracoes internas NAO sao automaticamente motivos para evitar o DeepSeek.

Se houver credenciais ou segredos evidentes, prefira remover ou mascarar somente os valores sensiveis e continuar delegando o restante do material.

O usuario pode sempre substituir essa regra e pedir explicitamente para uma tarefa, projeto ou ambiente preferir `luna-worker`.

## Luna Worker XHigh

Use como worker premium quando:

- o usuario pedir explicitamente;
- a tarefa estiver no caminho critico;
- houver alta integracao entre componentes;
- a validacao objetiva for dificil;
- o impacto de erro for alto;
- o DeepSeek ja tiver falhado ou entregue resultado insuficiente.

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

O papel e desacoplado do modelo. Terra Medium e o default atual; promova para Sol quando necessario.

## Terra Lead

Selecione manualmente quando a tarefa deixa de ser uma intervencao e vira um projeto:

- varias frentes dependentes;
- varios componentes/repositorios;
- migracao em fases;
- integracao entre backend, frontend, banco, automacao e observabilidade;
- incidente complexo com coordenacao de varias linhas de investigacao.

O Terra Lead deve mandar uma parcela grande do trabalho paralelo e verificavel para DeepSeek e reservar Luna XHigh para caminho critico, integracoes delicadas, falha do DeepSeek ou preferencia explicita do usuario.

## Anti-padroes

- Chamar advisor para tarefa mecanica.
- Deixar dois workers editarem a mesma area sem coordenacao.
- Criar workers com escopo vago.
- Insistir indefinidamente no modelo barato quando a evidencia aponta para escalonamento.
- Tratar automaticamente todo codigo privado ou log real como proibido para DeepSeek.

## Principio operacional

Otimize por **trabalho correto por unidade de quota**, nao por prestigio do modelo.
