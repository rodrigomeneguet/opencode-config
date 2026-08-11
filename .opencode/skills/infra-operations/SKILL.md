---
name: infra-operations
description: Praticas de infraestrutura, Linux, redes, Kubernetes, cloud, observabilidade, automacao, CI/CD, IaC e troubleshooting orientado a evidencia.
compatibility: opencode
metadata:
  domain: infrastructure
  audience: operator
---

## Quando usar

Carregue esta skill para troubleshooting, operacao, mudancas de infraestrutura, redes, Linux, containers, Kubernetes, cloud, CI/CD, Terraform, Ansible, observabilidade ou incidentes.

## Principios

- Descubra o estado atual antes de mudar qualquer coisa.
- Reconstrua linha do tempo e mudancas recentes.
- Separe sintoma, causa, fator contribuinte e evidencia.
- Comece por testes reversiveis e de baixo impacto.
- Preserve configuracao anterior, backup, snapshot ou rollback quando aplicavel.
- Em producao, explicite blast radius e criterio de abortar.
- Prefira comandos de leitura antes de comandos de escrita.
- Correlacione logs, metricas, eventos, rede, DNS, identidade e dependencias.
- Nao confunda ausencia de erro com sucesso: valide o servico do ponto de vista do consumidor.

## Entrega recomendada

1. estado observado;
2. hipotese principal e alternativas;
3. testes executados;
4. mudanca proposta ou aplicada;
5. validacao;
6. rollback;
7. riscos restantes.
