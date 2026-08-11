# opencode-orchestrator

Configuracao pessoal do OpenCode orientada a **otimizacao de quota**, com roteamento por **custo, risco, privacidade e tipo de dificuldade**.

> Route work to the right model, at the right reasoning level, for the right cost.

A ideia central e simples:

> Quase tudo comeca no Luna. O Luna Lead continua dono da execucao e escala apenas quando o motivo da dificuldade justificar.

## Arquitetura v2.1

### Execucao padrao

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

O `luna-lead` e o default. Ele acompanha plano, tarefas, workers, integracao, testes e entrega final.

Ele nao escala simplesmente porque algo ficou "dificil". Ele escala conforme **por que** ficou dificil:

| Situacao | Rota |
| --- | --- |
| Trabalho independente, paralelo e validavel | `deepseek-worker` |
| Execucao importante e bem definida | `luna-worker` High |
| Problema bem definido, mas High nao foi suficiente | `luna-worker-xhigh` |
| Problema mal enquadrado, multi-camada ou circular | `terra-diagnostician` Low |
| Projeto amplo precisa de plano/replanejamento | `terra-planner` Low |
| Arquitetura, risco, seguranca ou trade-offs | `strategic-advisor` Terra Medium |

### Projeto grande

O Terra nao precisa ficar sentado em todas as rodadas da execucao.

```text
Terra Planner Low
       │
       │ plano / checkpoint
       ▼
Luna Lead Medium
       │
       ├─ DeepSeek Free
       ├─ Luna High
       ├─ Luna XHigh
       ├─ Terra Diagnostician Low
       └─ Strategic Advisor Terra Medium
```

Fluxo recomendado:

1. use `terra-planner` quando o projeto ainda estiver nebuloso;
2. Terra cria arquitetura, fases, dependencias, validacao e rollback;
3. Luna Lead assume a execucao;
4. Luna delega e integra as entregas;
5. se o plano deixar de fazer sentido, Luna pode chamar `terra-planner` novamente;
6. Terra devolve o plano revisado e Luna continua a execucao.

O usuario tambem pode selecionar `terra-planner` manualmente. Ele usa `mode: all`, portanto funciona como agente selecionavel e como subagente do Luna Lead.

## Agentes

### `luna-lead`

- **modelo:** GPT-5.6 Luna
- **reasoning:** Medium
- **papel:** lider de execucao
- **status:** default

E o dono operacional da sessao. Resolve o que for simples, escolhe workers, valida entregas e decide quando escalar.

### `deepseek-worker`

- **modelo:** DeepSeek V4 Flash Free
- **papel:** capacidade elastica gratuita

Bom para exploracao, leitura, testes, documentacao, inventario, revisao independente, busca de padroes e tarefas objetivamente validaveis.

Nao envie credenciais literais ou segredos desnecessariamente.

### `luna-worker`

- **modelo:** GPT-5.6 Luna
- **reasoning:** High
- **papel:** worker premium normal

Caminho padrao para implementacoes importantes, integracao e troubleshooting bem enquadrado.

### `luna-worker-xhigh`

- **modelo:** GPT-5.6 Luna
- **reasoning:** XHigh
- **hidden:** true

Nao aparece no seletor normal. O Luna Lead pode chama-lo quando o problema ja estiver bem definido, mas Luna High nao tiver profundidade suficiente.

A ideia e espremer o Luna antes de pagar Terra quando o gargalo for profundidade, nao capacidade de enquadramento.

### `terra-diagnostician`

- **modelo:** GPT-5.6 Terra
- **reasoning:** Low
- **papel:** RCA e diagnostico multi-camada

Primeiro salto de capacidade quando o problema envolve varias hipoteses, cronologia, varias camadas ou diagnostico circular.

### `terra-planner`

- **modelo:** GPT-5.6 Terra
- **reasoning:** Low
- **mode:** all
- **papel:** planejamento e checkpoints

Planeja projetos grandes e replaneja quando o contexto muda. Nao deve gerenciar a execucao rotineira.

### `strategic-advisor`

- **modelo:** GPT-5.6 Terra
- **reasoning:** Medium
- **papel:** arquitetura, seguranca, risco e revisao critica

O papel e desacoplado do motor. Para uma revisao excepcionalmente importante, ele pode ser promovido temporariamente para Sol sem alterar a arquitetura.

## Escada de capacidade

```text
DeepSeek Free
      │
      ├─ volume e paralelismo
      ▼
Luna High
      │
      ├─ problema bem definido, precisa de mais profundidade
      ▼
Luna XHigh
      │
      ├─ problema esta mal enquadrado / multi-camada
      ▼
Terra Low
      │
      ├─ arquitetura / risco / julgamento
      ▼
Terra Medium
      │
      └─ excepcionalmente: Sol
```

Essa escada **nao e totalmente linear**. Luna XHigh e Terra Low resolvem problemas diferentes:

- XHigh: mais profundidade no mesmo enquadramento;
- Terra: salto de capacidade quando o enquadramento ou julgamento e o gargalo.

## Skills

As antigas personas fixas de Backend, Frontend, DevOps, QA e Cybersecurity foram removidas. O conhecimento util foi preservado como skills sob demanda:

- `infra-operations`
- `security-review`
- `software-testing`
- `backend-engineering`
- `frontend-engineering`

Isso reduz poluicao no seletor de agentes.

## Estrutura

```text
.opencode/
├── agents/
│   ├── luna-lead.md
│   ├── terra-planner.md
│   ├── deepseek-worker.md
│   ├── luna-worker.md
│   ├── luna-worker-xhigh.md
│   ├── terra-diagnostician.md
│   └── strategic-advisor.md
└── skills/
    ├── infra-operations/
    ├── security-review/
    ├── software-testing/
    ├── backend-engineering/
    └── frontend-engineering/

docs/
├── ARCHITECTURE.md
├── ROUTING.md
├── COST-STRATEGY.md
└── INSTALLATION.md

opencode.json
setup.sh
setup.ps1
scripts/validate.sh
.env.example
```

## Backup automatico obrigatorio

**Todo uso de `setup.sh` ou `setup.ps1` cria um snapshot antes de qualquer alteracao**, inclusive antes de perguntar se o usuario deseja sobrescrever arquivos.

Isso vale tambem para `--merge` / `-Merge` e para instalacao project-level.

### Global

O snapshot preserva toda a configuracao existente de:

```text
~/.config/opencode/
```

Linux/macOS/WSL:

```text
~/.config/opencode-backups/YYYYMMDD-HHMMSS-PID/
```

Windows PowerShell:

```text
$HOME\.config\opencode-backups\YYYYMMDD-HHMMSS-PID\
```

### Project-level

Preserva, quando existirem:

```text
opencode.json
opencode.jsonc
AGENTS.md
.opencode/
```

em:

```text
<projeto>/.opencode-backups/YYYYMMDD-HHMMSS-PID/
```

O backup nao pode ser desativado pelo instalador. Detalhes e restauracao manual em [`docs/INSTALLATION.md`](docs/INSTALLATION.md).

## Instalacao Linux / macOS / WSL

```bash
git clone https://github.com/rodrigomeneguet/opencode-orchestrator.git
cd opencode-orchestrator
git checkout feat/orchestration-v2
bash setup.sh
```

Modos:

```bash
bash setup.sh              # global interativo
bash setup.sh --auto       # global automatico
bash setup.sh --merge      # preserva arquivos existentes
bash setup.sh --symlink    # global usando symlinks
bash setup.sh --project    # instala no projeto atual
```

## Instalacao Windows PowerShell

No PowerShell, dentro do clone:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\setup.ps1
```

Modos:

```powershell
.\setup.ps1               # global interativo
.\setup.ps1 -Auto         # global automatico
.\setup.ps1 -Merge        # preserva arquivos existentes
.\setup.ps1 -Project      # instala no projeto atual
```

Para Windows com WSL, use `setup.sh` dentro da distribuicao Linux.

## Limpeza de agentes legados

Os instaladores removem apenas nomes legados gerenciados por este repositorio:

```text
backend
frontend
devops
qa-engineer
cybersecurity
luna-operator
terra-lead
```

Eles nao removem agentes customizados desconhecidos.

Como o backup ocorre antes da limpeza, os arquivos removidos continuam disponiveis no snapshot daquela execucao.

## Variaveis de ambiente

Bash:

```bash
export BRAVE_API_KEY="..."
export GITHUB_PERSONAL_ACCESS_TOKEN="..."
```

PowerShell:

```powershell
$env:BRAVE_API_KEY="..."
$env:GITHUB_PERSONAL_ACCESS_TOKEN="..."
```

Nunca versione credenciais.

## Validacao

Linux/macOS/WSL:

```bash
bash scripts/validate.sh
opencode models
```

Depois abra o OpenCode e valide:

1. `luna-lead` aparece como default;
2. `terra-planner` aparece no seletor;
3. `luna-worker-xhigh` nao aparece no seletor, mas pode ser chamado pelo Luna Lead;
4. Luna Lead consegue delegar para DeepSeek, Luna High, Terra Diagnostician, Terra Planner e Strategic Advisor;
5. os agentes antigos nao aparecem mais.

## Documentacao detalhada

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/ROUTING.md`](docs/ROUTING.md)
- [`docs/COST-STRATEGY.md`](docs/COST-STRATEGY.md)
- [`docs/INSTALLATION.md`](docs/INSTALLATION.md)
