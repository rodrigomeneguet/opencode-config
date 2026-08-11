# Arquitetura de Orquestracao

## Objetivo

Maximizar trabalho concluido por unidade de quota sem perder qualidade em tarefas de infraestrutura e desenvolvimento.

## Camadas

### Luna Operator

Ponto de entrada padrao. Deve resolver diretamente a maior parte do trabalho cotidiano e decidir se a tarefa realmente merece escalonamento.

### Workers

- `deepseek-worker`: capacidade gratuita para tarefas nao sensiveis, isoladas e facilmente validaveis.
- `luna-worker`: executor de alta fidelidade, configurado em XHigh para caminho critico, codigo privado e infraestrutura sensivel.

### Diagnostico

`terra-diagnostician` atua somente em leitura. Seu papel e reduzir incerteza, correlacionar camadas, produzir hipoteses concorrentes e sugerir testes discriminadores.

### Coordenacao de projeto

`terra-lead` e um segundo agente primario. Ele nao deve ser usado por padrao. Selecione-o quando houver varias frentes dependentes, integracao complexa ou necessidade real de coordenar workers.

### Advisor

`strategic-advisor` e um papel, nao um modelo. O motor padrao e Terra Medium. Pode ser promovido para Sol em revisoes excepcionais sem mudar o contrato operacional do agente.

## Por que os antigos agentes de funcao foram removidos

DevOps, QA, Backend, Frontend e Cybersecurity misturavam duas dimensoes diferentes:

1. quem coordena ou executa;
2. qual conhecimento de dominio e necessario.

Na v2, os agentes representam responsabilidades na cadeia de decisao. Especialidades de dominio foram movidas para skills carregadas sob demanda.

## Profundidade de subagentes

`subagent_depth` permanece em `1`: agentes primarios podem chamar subagentes; subagentes nao criam outros subagentes. Isso reduz cascatas de custo e mantem responsabilidade clara.
