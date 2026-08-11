# Estrategia de Custo e Qualidade

## Objetivo

Otimizar custo por tarefa concluida, nao apenas custo por token.

## Ordem economica

1. DeepSeek V4 Flash Free para tarefas apropriadas e nao sensiveis.
2. Luna como default para quase todo trabalho cotidiano.
3. Luna XHigh antes de escalar problemas delimitados que merecem mais raciocinio.
4. Terra para diagnostico multi-camada, coordenacao e decisoes de maior ambiguidade.
5. Sol apenas quando a qualidade adicional justificar o custo relativo.

## Por que Luna continua sendo o ponto de entrada

Luna tem custo muito baixo para sua capacidade, portanto vale deixa-lo investigar, filtrar contexto, executar mudancas comuns e construir um pacote de evidencias antes de gastar modelos superiores.

## Quando o barato fica caro

Escalone quando ocorrer um dos seguintes sinais:

- duas tentativas razoaveis sem progresso;
- raciocinio circular;
- necessidade de reprocessar contexto grande repetidamente;
- incerteza arquitetural;
- risco operacional elevado;
- retrabalho potencial maior que o custo de uma chamada Terra.

## Advisor em Terra por padrao

O `strategic-advisor` usa Terra Medium como configuracao economica. Promova para Sol quando houver revisao arquitetural excepcionalmente complexa, seguranca critica, decisao irreversivel ou quando a discordancia entre agentes continuar material.

## DeepSeek Free e custo de privacidade

Gratis nao significa sem custo de governanca. O worker gratuito deve receber apenas material que possa ser enviado ao provedor sem problema. Sanitizar logs e remover segredos faz parte do custo operacional e precisa ser considerado antes de delegar.

## Medicao sugerida

Compare configuracoes pela entrega, nao pela sensacao:

- numero de intervencoes humanas;
- tentativas por tarefa;
- qualidade do diff;
- testes concluidos;
- tempo ate validacao;
- consumo de quota OpenAI;
- percentual de tarefas absorvidas pelo DeepSeek sem retrabalho;
- quantidade de escalonamentos Luna -> Terra -> Sol.
