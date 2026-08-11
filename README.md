# opencode-config

Configuracao pessoal de orquestracao para OpenCode, otimizada para infraestrutura, troubleshooting e projetos de software com foco em qualidade por unidade de quota.

## Arquitetura

### Fluxo padrao

```text
Luna Operator (Medium)
├── DeepSeek Worker (Free)    -> capacidade elastica para alto volume
├── Luna Worker (XHigh)       -> worker premium / caminho critico
├── Terra Diagnostician       -> RCA e correlacao entre camadas
└── Strategic Advisor (Terra) -> arquitetura, seguranca, risco e rollback
```

### Projeto grande

```text
Terra Lead (Medium)
├── DeepSeek Worker (Free)
├── Luna Worker (XHigh)
└── Strategic Advisor (Terra Medium; promovivel a Sol)
```

A regra principal e simples: **comece no Luna, use DeepSeek agressivamente para absorver volume e escale para Luna/Terra quando criticidade, integracao ou qualidade justificarem**.

## Agentes

| Agente | Modelo | Papel |
| --- | --- | --- |
| `luna-operator` | GPT-5.6 Luna Medium | Primario padrao para infra e codigo |
| `deepseek-worker` | DeepSeek V4 Flash Free | Capacidade elastica gratuita para exploracao, implementacao, logs, testes e revisao |
| `luna-worker` | GPT-5.6 Luna XHigh | Worker premium para caminho critico e alta integracao |
| `terra-diagnostician` | GPT-5.6 Terra Medium | RCA, logs e diagnostico multi-camada |
| `terra-lead` | GPT-5.6 Terra Medium | Primario opcional para projetos grandes |
| `strategic-advisor` | GPT-5.6 Terra Medium | Advisor somente leitura para arquitetura e risco |

O advisor tem nome de papel, nao de modelo. Quando a criticidade justificar, altere apenas o frontmatter de `strategic-advisor.md` para `openai/gpt-5.6-sol` e ajuste o `reasoningEffort`.

## DeepSeek Free: politica permissiva

O `deepseek-worker` deve ser usado de forma agressiva para reduzir consumo da quota OpenAI.

Repositorios privados, codigo privado, logs reais e configuracoes internas **nao sao automaticamente excluidos** do DeepSeek.

Se aparecerem credenciais ou segredos evidentes, a preferencia e mascarar ou remover somente os valores sensiveis e continuar usando o worker gratuito no restante da tarefa quando possivel.

Exemplos de bons usos:

- exploracao de codebase;
- debugging;
- leitura e correlacao de logs;
- revisao de configuracoes;
- testes;
- documentacao;
- refatoracoes delimitadas;
- implementacoes isoladas;
- revisao de diff;
- Terraform, Ansible, Docker, Kubernetes e scripts;
- investigacoes paralelas e segunda opiniao.

Para uma tarefa, projeto ou ambiente em que voce prefira manter o trabalho no ecossistema OpenAI, basta instruir `luna-operator` ou `terra-lead` a **preferir `luna-worker`**. Essa preferencia manual tem prioridade sobre o roteamento economico.

## Skills sob demanda

Os antigos agentes de papel fixo foram removidos. Em vez de manter `devops`, `backend`, `frontend`, `qa` e `cybersecurity` como agentes permanentes, o conhecimento especializado fica em skills carregadas quando necessario:

- `infra-operations`
- `security-review`
- `software-testing`
- `backend-engineering`
- `frontend-engineering`

Isso reduz poluicao no menu de agentes e separa **responsabilidade de orquestracao** de **especialidade de dominio**.

## Estrutura

```text
opencode-config/
├── opencode.json
├── setup.sh
├── .env.example
├── .opencode/
│   ├── agents/
│   │   ├── luna-operator.md
│   │   ├── deepseek-worker.md
│   │   ├── luna-worker.md
│   │   ├── terra-diagnostician.md
│   │   ├── terra-lead.md
│   │   └── strategic-advisor.md
│   └── skills/
│       ├── infra-operations/SKILL.md
│       ├── security-review/SKILL.md
│       ├── software-testing/SKILL.md
│       ├── backend-engineering/SKILL.md
│       └── frontend-engineering/SKILL.md
├── docs/
│   ├── ARCHITECTURE.md
│   ├── ROUTING.md
│   └── COST-STRATEGY.md
└── scripts/
    └── validate.sh
```

## Pre-requisitos

- OpenCode atualizado;
- Node.js/npm para os MCPs locais;
- acesso/autenticacao aos provedores OpenAI e OpenCode Zen;
- Git para sincronizar a configuracao.

Confirme os modelos disponiveis:

```bash
opencode models
```

Modelos esperados nesta configuracao:

```text
openai/gpt-5.6-luna
openai/gpt-5.6-terra
opencode/deepseek-v4-flash-free
```

## Instalacao

```bash
git clone https://github.com/rodrigomeneguet/opencode-config.git
cd opencode-config
bash setup.sh
```

Modos:

```bash
bash setup.sh              # global, interativo
bash setup.sh --auto       # global, sem perguntas
bash setup.sh --merge      # instala apenas o que estiver ausente
bash setup.sh --symlink    # global com symlinks para facilitar git pull
bash setup.sh --project    # instala no projeto atual
```

A instalacao global usa:

```text
~/.config/opencode/opencode.json
~/.config/opencode/agents/
~/.config/opencode/skills/
```

O modo `--project` usa:

```text
./opencode.json
./.opencode/agents/
./.opencode/skills/
```

## MCPs e segredos

Brave Search, GitHub, Git History e Memory Graph ficam no mesmo `opencode.json` principal. As credenciais sao referenciadas por variaveis de ambiente e nao ficam gravadas no repositorio:

```bash
export BRAVE_API_KEY="..."
export GITHUB_PERSONAL_ACCESS_TOKEN="..."
```

O OpenCode substitui `{env:VARIAVEL}` em tempo de execucao.

## Politica de roteamento

1. Luna Operator mantem o contexto principal e resolve tarefas pequenas.
2. DeepSeek recebe agressivamente trabalho tecnico delegavel e validavel.
3. Luna Worker XHigh recebe caminho critico, alta integracao, fallback de qualidade ou preferencia explicita.
4. Terra Diagnostician entra quando a causa nao e clara ou atravessa camadas.
5. Strategic Advisor entra nos portoes de arquitetura, seguranca, blast radius e rollback.
6. Terra Lead e selecionado manualmente quando o trabalho vira um projeto multi-frente.

Detalhes em [`docs/ROUTING.md`](docs/ROUTING.md).

## Validacao

```bash
bash scripts/validate.sh
```

O script valida JSON, agentes, skills, roteamento, ausencia de RT Mind legado, referencias de segredos via ambiente e sintaxe do setup.

## Filosofia

O objetivo nao e usar sempre o modelo mais forte. O objetivo e usar **o arranjo que conclui mais trabalho correto por unidade de quota**, aproveitando a capacidade gratuita do Zen sempre que ela puder ser validada e escalando apenas quando fizer sentido.
