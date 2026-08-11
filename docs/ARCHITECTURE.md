# Arquitetura de Orquestracao

## Objetivo

Maximizar trabalho concluido por unidade de quota sem perder qualidade em tarefas de infraestrutura e desenvolvimento.

## Camadas

### Luna Operator

Ponto de entrada padrao e controlador da sessao. Resolve tarefas pequenas diretamente, mantem o contexto principal e decide quando delegar.

### Workers

- `deepseek-worker`: capacidade gratuita e elastica. Deve absorver agressivamente exploracao, logs, configuracoes, testes, debugging, refatoracoes, revisoes e implementacoes delimitadas sempre que a saida puder ser validada.
- `luna-worker`: executor premium em XHigh para caminho critico, alta integracao, falha do DeepSeek ou preferencia explicita do usuario.

Repositorio privado, codigo privado, log real e configuracao interna nao sao tratados automaticamente como material proibido para DeepSeek. Segredos evidentes devem ser mascarados ou removidos quando possivel sem inutilizar toda a tarefa.

### Diagnostico

`terra-diagnostician` atua somente em leitura. Seu papel e reduzir incerteza, correlacionar camadas, produzir hipoteses concorrentes e sugerir testes discriminadores.

### Coordenacao de projeto

`terra-lead` e um segundo agente primario. Selecione-o quando houver varias frentes dependentes, integracao complexa ou necessidade real de coordenar workers.

Em projetos grandes, Terra Lead deve usar bastante DeepSeek para trabalho paralelo e verificavel e reservar Luna XHigh para trechos mais criticos ou quando o usuario pedir.

### Advisor

`strategic-advisor` e um papel, nao um modelo. O motor padrao e Terra Medium. Pode ser promovido para Sol em revisoes excepcionais sem mudar o contrato operacional do agente.

## Por que os antigos agentes de funcao foram removidos

DevOps, QA, Backend, Frontend e Cybersecurity misturavam duas dimensoes diferentes:

1. quem coordena ou executa;
2. qual conhecimento de dominio e necessario.

Na v2, os agentes representam responsabilidades na cadeia de decisao. Especialidades de dominio foram movidas para skills carregadas sob demanda.

## Profundidade de subagentes

`subagent_depth` permanece em `1`: agentes primarios podem chamar subagentes; subagentes nao criam outros subagentes. Isso reduz cascatas de custo e mantem responsabilidade clara.

## Preferencia manual

Para uma tarefa, projeto ou ambiente mais serio, o usuario pode simplesmente instruir `luna-operator` ou `terra-lead` a preferir `luna-worker`. Essa preferencia tem prioridade sobre o roteamento economico padrao.
