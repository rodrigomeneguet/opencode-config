# opencode-config

Configuracao pessoal de orquestracao para OpenCode, otimizada para infraestrutura, troubleshooting e projetos de software com foco em qualidade por unidade de quota.

## Arquitetura

### Fluxo padrao

```text
Luna Operator (Medium)
├── DeepSeek Worker (Free)    -> tarefas nao sensiveis e facilmente validaveis
├── Luna Worker (XHigh)       -> caminho critico, codigo privado e infra sensivel
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

A regra principal e simples: **comece no Luna e escale apenas quando a incerteza, o risco ou o tamanho da coordenacao justificar**.

## Agentes

| Agente | Modelo | Papel |
| --- | --- | --- |
| `luna-operator` | GPT-5.6 Luna Medium | Primario padrao para infra e codigo |
| `deepseek-worker` | DeepSeek V4 Flash Free | Capacidade elastica gratuita para tarefas nao sensiveis |
| `luna-worker` | GPT-5.6 Luna XHigh | Worker de alta fidelidade para caminho critico |
| `terra-diagnostician` | GPT-5.6 Terra Medium | RCA, logs e diagnostico multi-camada |
| `terra-lead` | GPT-5.6 Terra Medium | Primario opcional para projetos grandes |
| `strategic-advisor` | GPT-5.6 Terra Medium | Advisor somente leitura para arquitetura e risco |

O advisor tem nome de papel, nao de modelo. Quando a criticidade justificar, altere apenas o frontmatter de `strategic-advisor.md` para `openai/gpt-5.6-sol` e ajuste o `reasoningEffort`.

## DeepSeek Free: regra de privacidade

O DeepSeek V4 Flash Free e usado somente como worker opcional. Durante a oferta gratuita, o provedor informa que dados podem ser coletados para feedback/melhoria do modelo.

**Nao envie ao `deepseek-worker`:**

- tokens, senhas, chaves ou segredos;
- dados pessoais ou de clientes;
- logs de producao nao sanitizados;
- configuracoes corporativas confidenciais;
- codigo privado sensivel ou propriedade intelectual que nao deva sair do fluxo confiavel.

Na duvida, use `luna-worker`.

## Skills sob demanda

Os antigos agentes de papel fixo foram removidos. Em vez de manter `devops`, `backend`, `frontend`, `qa` e `cybersecurity` como agentes permanentes, o conhecimento especializado fica em skills carregadas apenas quando necessario:

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
├── opencode.jsonc.example
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

A instalacao global usa os caminhos oficiais:

```text
~/.config/opencode/opencode.json
~/.config/opencode/opencode.jsonc
~/.config/opencode/agents/
~/.config/opencode/skills/
```

O modo `--project` usa:

```text
./opencode.json
./opencode.jsonc
./.opencode/agents/
./.opencode/skills/
```

## MCPs

O template inclui:

- Brave Search;
- GitHub;
- Git History;
- Memory Graph.

As credenciais nao sao gravadas no repositorio. `opencode.jsonc.example` referencia variaveis de ambiente:

```bash
export BRAVE_API_KEY="..."
export GITHUB_PERSONAL_ACCESS_TOKEN="..."
```

Sem a variavel correspondente, o `setup.sh` desabilita o MCP dependente de chave na configuracao gerada.

## Politica de roteamento

Use o fluxo padrao para a maioria das tarefas:

1. Luna Operator investiga e tenta resolver.
2. DeepSeek recebe apenas trabalho nao sensivel e objetivamente validavel.
3. Luna Worker XHigh recebe caminho critico e material sensivel.
4. Terra Diagnostician entra quando a causa nao e clara ou atravessa camadas.
5. Strategic Advisor entra nos portoes de arquitetura, seguranca, blast radius e rollback.
6. Terra Lead e selecionado manualmente quando o trabalho vira um projeto multi-frente.

Detalhes em [`docs/ROUTING.md`](docs/ROUTING.md).

## Validacao

```bash
bash scripts/validate.sh
```

O script valida JSON, agentes, skills, roteamento, ausencia de RT Mind legado, guardrails do DeepSeek, referencias de segredos via ambiente e sintaxe do setup.

## Filosofia

O objetivo nao e usar sempre o modelo mais forte. O objetivo e usar **o menor modelo que conclui a tarefa com confiabilidade**, escalando quando o custo de uma tentativa ruim passa a ser maior que o custo de um modelo melhor.
