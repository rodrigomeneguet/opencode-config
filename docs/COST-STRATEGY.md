# Cost Strategy

## Objetivo

Maximizar trabalho correto por unidade de quota.

A arquitetura prioriza Luna porque seu custo relativo e muito baixo, mas evita a armadilha de simplesmente aumentar reasoning effort quando o problema real e capacidade de enquadramento.

## Ordem economica conceitual

```text
DeepSeek Free
      ↓
Luna Medium / High / XHigh
      ↓
Terra Low / Medium
      ↓
Sol
```

## Como interpretar essa ordem

Ela nao significa que toda tarefa deve atravessar todos os degraus.

### Use DeepSeek quando

- houver muito volume;
- a subtarefa puder rodar independente;
- a saida puder ser validada;
- o risco for baixo.

### Use Luna High quando

- a tarefa estiver bem definida;
- a implementacao for importante;
- a integracao exigir mais fidelidade;
- o trabalho estiver no caminho critico.

### Use Luna XHigh quando

- Luna High nao for suficiente;
- o problema continuar bem enquadrado;
- mais profundidade puder resolver o caso sem trocar de familia de modelo.

XHigh fica oculto para evitar uso casual, mas o Luna Lead pode chama-lo automaticamente.

### Use Terra Low quando

- o problema nao estiver sendo bem enquadrado;
- houver varias hipoteses concorrentes;
- varias camadas precisarem ser correlacionadas;
- o diagnostico estiver circular;
- um projeto grande precisar de planejamento/replanejamento.

## Por que Terra Planner e episodico

Um coordenador mais caro lendo cada resultado de worker desperdicaria quota em trabalho administrativo.

Por isso:

```text
Terra Planner
     ↓ plano
Luna Lead
     ↓ execucao longa
Terra Planner
     ↓ checkpoint apenas se necessario
Luna Lead
```

A capacidade do Terra e comprada nos momentos em que ela altera uma decisao, nao para acompanhar cada martelada.

## Strategic Advisor

Terra Medium fica reservado para:

- arquitetura;
- risco;
- seguranca;
- blast radius;
- rollback;
- decisoes dificeis de reverter;
- revisao critica.

## Sol

Sol nao faz parte do caminho automatico normal.

A promocao do Strategic Advisor para Sol deve ocorrer manualmente quando o impacto justificar o custo e o nivel de julgamento frontier.

## Regra de otimizacao

> Nao escale modelo porque a tarefa ficou dificil. Escale conforme o motivo da dificuldade.

```text
volume → DeepSeek
execucao → Luna High
profundidade → Luna XHigh
enquadramento → Terra Low
arquitetura/risco → Terra Medium
frontier excepcional → Sol
```

Essa regra preserva quota sem transformar economia em falsa eficiencia: um modelo barato repetindo tentativas ruins tambem custa tempo e contexto.
