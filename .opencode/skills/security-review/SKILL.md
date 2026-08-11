---
name: security-review
description: Revisao de seguranca para configuracoes, infraestrutura e software, cobrindo identidade, segredos, superficie de ataque, dependencia, hardening e risco operacional.
compatibility: opencode
metadata:
  domain: security
  audience: reviewer
---

## Quando usar

Carregue esta skill quando a tarefa envolver autenticacao, autorizacao, segredos, exposicao de rede, hardening, dependencias, dados sensiveis, configuracao de seguranca ou revisao antes de producao.

## Checklist

- Identidade e menor privilegio.
- Segredos fora de codigo, logs e repositorio.
- Exposicao de portas, endpoints e interfaces administrativas.
- Validacao de entrada e limites de confianca.
- Criptografia em transito e repouso quando aplicavel.
- Dependencias e imagens com procedencia conhecida.
- Politicas de backup, recuperacao e rollback.
- Logging suficiente sem vazamento de dados sensiveis.
- Configuracoes default inseguras ou permissivas.
- Separacao entre ambientes e credenciais.
- Risco de supply chain e automacoes com privilegios excessivos.

## Saida

Classifique achados por severidade, evidencia, impacto, explorabilidade, recomendacao e validacao. Nao trate suspeita como vulnerabilidade confirmada.
