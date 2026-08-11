# Routing

## Regra principal

O roteamento nao deve seguir uma escada cega de "mais dificil = modelo maior".

A pergunta correta e:

> **Qual e o gargalo desta tarefa?**

## Tabela de decisao

| Gargalo | Rota |
| --- | --- |
| Volume, paralelismo, leitura ou tarefa validavel | DeepSeek Worker |
| Execucao importante e bem definida | Luna Worker High |
| Problema bem definido, mas High ficou raso | Luna Worker XHigh |
| Problema mal enquadrado, varias hipoteses/camadas | Terra Diagnostician Low |
| Projeto amplo precisa de plano ou replanejamento | Terra Planner Low |
| Arquitetura, risco, seguranca, rollback, trade-offs | Strategic Advisor Terra Medium |
| Revisao excepcionalmente critica | promover Advisor para Sol manualmente |

## Fluxo padrao

```text
Luna Lead Medium
   │
   ├─ simples/pequeno ───────────────→ resolve diretamente
   │
   ├─ barato/validavel ──────────────→ DeepSeek Free
   │
   ├─ execucao premium ──────────────→ Luna High
   │                                      │
   │                                      └─ falta profundidade
   │                                             ↓
   │                                          Luna XHigh
   │
   ├─ enquadramento ruim/multi-camada ──→ Terra Diagnostician Low
   │
   ├─ plano ficou insuficiente ─────────→ Terra Planner Low
   │
   └─ arquitetura/risco ────────────────→ Strategic Advisor Terra Medium
```

## DeepSeek vs Luna

Use DeepSeek quando a saida puder ser validada de maneira objetiva e o risco for baixo.

Use Luna quando:

- estiver no caminho critico;
- a integracao for forte;
- a fidelidade ao contexto for importante;
- houver maior sensibilidade de dados;
- a qualidade do DeepSeek tiver sido insuficiente.

## Luna High vs Luna XHigh

Use High como worker premium normal.

Use XHigh somente se:

1. o problema estiver bem delimitado;
2. High ja tiver sido insuficiente ou demonstrar baixa confianca;
3. o gargalo parecer profundidade adicional de raciocinio.

Nao use XHigh para compensar um problema mal definido.

## Luna XHigh vs Terra Low

```text
Mesmo enquadramento, precisa aprofundar → Luna XHigh
Enquadramento duvidoso, varias camadas → Terra Low
```

Essa e uma das decisoes mais importantes da arquitetura.

## Terra Planner

Pode ser usado de duas formas:

### Manual

O usuario seleciona `terra-planner`, pede planejamento e depois volta para `luna-lead` para execucao.

### Automatico

O Luna Lead percebe que o plano precisa ser revisto e chama `terra-planner` como subagente. Terra devolve um plano atualizado e o Luna continua a entrega.

O Terra Planner nao deve virar gerente permanente.

## Checkpoints recomendados

Chame Terra Planner ou Strategic Advisor quando ocorrer:

- mudanca estrutural de escopo;
- nova dependencia relevante;
- premissa importante invalidada;
- risco operacional maior que o previsto;
- mudanca dificil de reverter;
- fase critica antes de producao;
- necessidade de reavaliar arquitetura.

## Pacote de evidencia

Antes de escalar para Terra, o Luna Lead deve condensar:

```text
Objetivo
Ambiente/topologia
Sintoma
Linha do tempo
Evidencias essenciais
Mudancas recentes
Hipoteses
Testes executados
Resultados
Restricoes
Risco
Rollback
Recomendacao preliminar
```

Isso reduz contexto caro e melhora a qualidade da consulta.
