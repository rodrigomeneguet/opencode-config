---
name: backend-engineering
description: Praticas para APIs, servicos, persistencia, filas, integracoes, concorrencia, confiabilidade e desenho de backend com foco em manutencao e operacao.
compatibility: opencode
metadata:
  domain: backend
  audience: developer
---

## Quando usar

Carregue esta skill para APIs, bancos, filas, jobs, integracoes, servicos, autenticacao de backend, performance ou refatoracoes de dominio.

## Principios

- Entenda contratos existentes antes de mudar interfaces.
- Preserve compatibilidade quando ela fizer parte do requisito.
- Trate validacao, erros, timeouts, retries e idempotencia explicitamente.
- Evite transacoes longas e efeitos colaterais ocultos.
- Considere concorrencia, consistencia, indices e custo de consultas.
- Mantenha configuracao separada de codigo e segredos fora do repositorio.
- Adicione observabilidade em pontos que falham de maneira relevante.
- Prefira evolucao incremental a reescrita ampla sem necessidade.

## Entrega

Explique contratos alterados, migracoes de dados quando houver, comportamento de falha, testes, compatibilidade e impactos operacionais.
