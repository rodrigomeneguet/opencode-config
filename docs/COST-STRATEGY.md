# Estrategia de Custo e Qualidade

## Objetivo

Otimizar trabalho correto por unidade de quota OpenAI, nao apenas custo por token.

## Ordem economica

1. DeepSeek V4 Flash Free para o maximo de trabalho tecnico delegavel e validavel.
2. Luna Operator Medium como controlador e executor direto de tarefas pequenas.
3. Luna Worker XHigh como worker premium para caminho critico, alta integracao, fallback de qualidade ou preferencia explicita.
4. Terra Diagnostician Medium para reduzir incerteza em problemas dificeis.
5. Terra Lead Medium para coordenar projetos grandes.
6. Strategic Advisor em Terra Medium por padrao, promovido para Sol apenas quando necessario.

## DeepSeek como capacidade elastica

A cota gratuita do Zen deve ser tratada como capacidade disponivel e usada agressivamente.

Nao desperdice quota OpenAI apenas porque o repositorio e privado, o log e de ambiente real ou a configuracao e interna. Esses fatores, isoladamente, nao devem mudar o roteamento.

Quando houver segredos evidentes, prefira mascarar apenas senhas, tokens, API keys, cookies, private keys ou credenciais embutidas e continuar a tarefa com o restante do contexto.

Se o usuario quiser manter determinado projeto, ambiente ou tarefa no ecossistema OpenAI, ele pode simplesmente pedir ao Luna Operator ou Terra Lead para preferir `luna-worker`.

## Quando pagar Luna XHigh

Use quando a economia do DeepSeek deixar de compensar:

- caminho critico;
- mudanca fortemente integrada;
- validacao dificil;
- impacto operacional alto;
- continuidade de contexto importante;
- falha ou baixa qualidade do DeepSeek;
- preferencia explicita do usuario.

## Quando escalar para Terra

Escalone quando houver multiplas hipoteses, correlacao entre camadas, raciocinio circular, projeto multi-frente ou quando o custo de retrabalho superar o custo de uma chamada Terra.

## Advisor em Terra por padrao

O `strategic-advisor` usa Terra Medium como configuracao economica. Promova para Sol quando houver revisao arquitetural excepcionalmente complexa, seguranca critica, decisao irreversivel ou quando a discordancia entre agentes continuar material.

## Medicao sugerida

Compare configuracoes pela entrega:

- numero de intervencoes humanas;
- tentativas por tarefa;
- qualidade do diff;
- testes concluidos;
- tempo ate validacao;
- consumo de quota OpenAI;
- percentual de tarefas absorvidas pelo DeepSeek sem retrabalho;
- quantidade de escalonamentos Luna -> Terra -> Sol.

## Principio

O modelo mais caro nao deve receber trabalho apenas por ser mais forte. Escale quando a probabilidade de retrabalho, erro ou risco justificar o custo adicional.
