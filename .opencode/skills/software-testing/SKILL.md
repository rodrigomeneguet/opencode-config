---
name: software-testing
description: Estrategia de testes para software, incluindo testes unitarios, integracao, regressao, contratos, casos de borda e validacao orientada a risco.
compatibility: opencode
metadata:
  domain: testing
  audience: developer
---

## Quando usar

Carregue esta skill ao implementar features, corrigir bugs, refatorar ou preparar uma entrega.

## Principios

- Teste comportamento observavel, nao detalhes internos sem necessidade.
- Priorize caminhos criticos, regressao e casos de borda.
- Reproduza o bug antes da correcao quando possivel.
- Prefira testes deterministas e independentes.
- Evite mocks excessivos que eliminem o comportamento real relevante.
- Inclua testes negativos para validacao, permissoes e falhas previsiveis.
- Em integracoes, verifique contratos, timeouts, retries e idempotencia.
- Diferencie teste executado de teste apenas sugerido.

## Entrega

Informe cobertura funcional da mudanca, testes adicionados ou executados, resultados, lacunas e riscos de regressao.
