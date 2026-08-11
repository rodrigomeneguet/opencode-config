# Architecture

## Principio central

O sistema roteia trabalho por **custo, risco e tipo de incerteza**.

O `luna-lead` e o dono da execucao continua. Terra entra de forma episodica quando sua capacidade adicional realmente agrega valor.

## Execucao padrao

```text
                         ┌─ DeepSeek Free
                         │
                         ├─ Luna High
Luna Lead Medium ────────┼─ Luna XHigh
   execucao continua     │
                         ├─ Terra Diagnostician Low
                         │
                         ├─ Terra Planner Low
                         │
                         └─ Strategic Advisor Terra Medium
```

### Luna Lead

Responsavel por:

- entender a demanda;
- manter plano e TODO;
- decidir o que resolve sozinho;
- escolher e orientar workers;
- integrar resultados;
- validar diffs, testes e comportamento;
- decidir quando escalar;
- entregar o resultado final.

## Projeto grande

```text
Terra Planner Low
       │
       │ cria plano / checkpoint
       ▼
Luna Lead Medium
       │
       ├─ DeepSeek Free
       ├─ Luna High
       ├─ Luna XHigh
       ├─ Terra Diagnostician Low
       └─ Strategic Advisor Terra Medium
```

O Terra Planner nao acompanha cada worker. Ele participa no inicio e em checkpoints semanticos:

- arquitetura inicial;
- mudanca relevante de escopo;
- descoberta que invalida premissas;
- reorganizacao de fases;
- antes de uma etapa estrutural critica.

Depois do checkpoint, a execucao volta ao Luna Lead.

## Escalonamento automatico pelo Luna

O Luna Lead pode chamar diretamente:

```text
DeepSeek Worker
Luna Worker High
Luna Worker XHigh
Terra Diagnostician Low
Terra Planner Low
Strategic Advisor Terra Medium
```

O usuario tambem pode selecionar `terra-planner` manualmente porque ele usa `mode: all`.

## Diferenca entre XHigh e Terra

Esses dois caminhos nao sao equivalentes.

```text
Problema bem enquadrado
+ precisa pensar mais
        ↓
Luna XHigh
```

```text
Problema mal enquadrado
+ hipoteses/camadas conflitantes
        ↓
Terra Diagnostician
```

Aumentar o effort do mesmo modelo e trocar de modelo resolvem gargalos diferentes.

## Papel do Strategic Advisor

O advisor continua somente leitura e focado em:

- arquitetura;
- seguranca;
- blast radius;
- rollback e recuperacao;
- trade-offs duradouros;
- revisao critica.

O motor padrao e Terra Medium. Sol fica reservado para promocao manual em revisoes excepcionais.
