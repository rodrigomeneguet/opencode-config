# opencode-config

Template de configuracao para o [OpenCode](https://opencode.ai) — o agente de IA open source para programacao.

> Configuracao rapida. Sincronize entre maquinas via Git.

---

## Visao Geral

| Componente | Detalhes |
| --- | --- |
| **Servidores MCP** | Brave Search, GitHub, Git History, Memory Graph |
| **Agentes Customizados** | QA Engineer, Cybersecurity, DevOps, Backend, Frontend |
| **Provedor LLM** | RT Mind (vLLM) — Qwen 3.5 & 3.6 |

---

## Pre-requisitos

- [Node.js](https://nodejs.org/) 18+ (necessario para `npx`)
- [OpenCode](https://opencode.ai) instalado

---

## Inicio Rapido

1. Clone e execute o instalador:
   ```bash
   git clone https://github.com/rodrigomeneguet/opencode-config.git
   cd opencode-config
   bash setup.sh
   ```

2. O instalador vai:
   - Detectar configuracao existente e perguntar sobre merge
   - Solicitar chaves de API ausentes (Brave Search obrigatoria)
   - Gerar arquivos de configuracao automaticamente
   - Validar tudo ao final

3. Reinicie o OpenCode. Teste com: `@qa-engineer ola`

### Modos de instalacao

```bash
bash setup.sh              # Interativo (default) — pergunta tudo
bash setup.sh --auto       # Automatico — usa .env ou valores existentes
bash setup.sh --symlink    # Global com symlinks — atualiza com git pull
bash setup.sh --project    # Projeto-level — copia para .opencode/ no CWD
bash setup.sh --merge      # Apenas merge — nao sobrescreve nada
```

---

## Estrutura de Arquivos

```
~/.config/opencode/
├── opencode.json              ← Configuracao de provedor e modelos
├── opencode.jsonc             ← Servidores MCP (gerado pelo setup)
├── .env                       ← Chaves de API (gerado pelo setup)
└── .opencode/
    └── agents/                ← Agentes customizados (invocaveis com @)
        ├── qa-engineer.md     → Estrategia e automacao de testes
        ├── cybersecurity.md   → Avaliacao de vulnerabilidades e OWASP
        ├── devops.md          → CI/CD, containers, IaC
        ├── backend.md         → Design de APIs, banco de dados, microservicos
        └── frontend.md        → React/Vue, CSS, acessibilidade, performance
```

> **Importante:** `opencode.json` configura provedores e modelos. `opencode.jsonc` configura servidores MCP. Agentes ficam em `.opencode/agents/`. Todos sao carregados pelo OpenCode.

### Uso como projeto

Ao clonar e rodar opencode deste diretorio, os agentes ja estao disponiveis em `.opencode/agents/` (projeto-level). Nenhuma copia global necessaria.

---

## Servidores MCP

| Servidor | Pacote | Finalidade | Chaves Necessarias |
| --- | --- | --- | --- |
| **Brave Search** | `@brave/brave-search-mcp-server` | Busca web, imagens, videos, noticias | `BRAVE_API_KEY` (obrigatoria) |
| **GitHub** | `@modelcontextprotocol/server-github` | Issues, PRs, repos, gestao de arquivos | `GITHUB_PERSONAL_ACCESS_TOKEN` (opcional) |
| **Git History** | `@cyanheads/git-mcp-server` | Commits locais, diffs, blame | Nenhuma |
| **Memory Graph** | `@modelcontextprotocol/server-memory` | Estado persistente entre sessoes | Nenhuma |

---

## Agentes Customizados

Invocaveis com mencao `@` na sua sessao OpenCode:

| Agente | Exemplo de Uso | Permissoes |
| --- | --- | --- |
| `@qa-engineer` | `@qa-engineer sugira testes para o modulo X` | Edicao (sim), Bash restrito |
| `@cybersecurity` | `@cybersecurity audite o arquivo config.py` | Edicao (nao), Bash (somente leitura) |
| `@devops` | `@devops crie um pipeline CI/CD para o projeto` | Edicao (sim), Bash restrito |
| `@backend` | `@backend avalie a arquitetura de microservicos` | Edicao (sim), Bash restrito |
| `@frontend` | `@frontend revise os componentes de UI` | Edicao (sim), Bash restrito |

### Executar agentes em paralelo

Varios agentes podem trabalhar na mesma tarefa de angulos diferentes:

```
@cybersecurity audite as vulnerabilidades do projeto
@qa-engineer analise a cobertura de testes
@devops sugira uma estrategia de CI/CD
```

Os tres executam simultaneamente e retornam relatorios independentes.

---

## Obtendo suas Chaves de API

### Brave Search (obrigatoria)

1. Acesse [api-dashboard.search.brave.com](https://api-dashboard.search.brave.com)
2. Faca login ou crie uma conta
3. Gere uma nova chave de API

O setup vai pedir a chave automaticamente. voce tambem pode configurar manualmente:

```bash
# No .env
BRAVE_API_KEY=sua_chave_aqui
```

### GitHub Personal Access Token (opcional)

1. Acesse [github.com/settings/tokens](https://github.com/settings/tokens)
2. Gere um novo token com escopo `repo` (ou `public_repo` apenas para repos publicos)

```bash
# No .env
GITHUB_PERSONAL_ACCESS_TOKEN=seu_token_aqui
```

> **Dica:** Use o escopo minimo necessario. Para muitos casos, `public_repo` e suficiente.

---

## Sincronizando Atualizacoes

Para atualizar sua configuracao deste repositorio:

```bash
cd opencode-config
git pull origin master
bash setup.sh --merge
```

O modo `--merge` vai:
- Detectar configuracoes existentes
- Perguntar antes de substituir qualquer coisa
- Preservar suas chaves de API

> Seus arquivos `opencode.jsonc` e `.env` estao protegidos pelo `.gitignore` e nao serao sobrescritos pelo git pull.

---

## Adicionando Novos Agentes

Crie um arquivo markdown em `.opencode/agents/`:

```markdown
---
description: Descricao do seu agente aqui
mode: all
permission:
  edit: allow
  bash:
    "comando *": "allow"
---

Voce e um [papel]. Foco em [especialidade]...
```

Em seguida, reinicie o OpenCode. O estara disponivel via `@nome-do-agente`.

---

## Seguranca

- **Nunca faca commit de `.env` ou `opencode.jsonc`** — estao no `.gitignore`
- O `.gitignore` bloqueia: `opencode.jsonc`, `.env`, `opencode.json`
- Rotacione suas chaves de API periodicamente
- GitHub PAT: use os escopos minimos necessarios para seu fluxo de trabalho
- O vLLM endpoint esta configurado para uso interno — nao compartilhe a URL publicamente

---

## Solucao de Problemas

### Agentes nao aparecem

- Verifique se o frontmatter dos arquivos em `.opencode/agents/` esta formatado corretamente (cada campo em uma linha separada)
- Reinicie o OpenCode completamente

### Servidor MCP nao inicia

- Verifique se o Node.js 18+ esta instalado: `node --version`
- Teste manualmente: `npx -y @brave/brave-search-mcp-server --help`
- Verifique se as chaves estao corretas no `.env`

### Erro de conexao com o modelo

- Confirme que o endpoint vLLM esta acessivel: `curl https://api-vllm.regionaltelhas.com.br/v1/models`
- Verifique sua conexao com a internet

### Configuracao nao e detectada

- Certifique-se de que os arquivos estao em `~/.config/opencode/`
- Reinicie o OpenCode apos qualquer alteracao

### Reconfigurar chaves

Execute novamente o setup:
```bash
cd opencode-config
bash setup.sh
```

Ou edite diretamente:
```bash
nano ~/.config/opencode/.env
```

---

## Referencias

- [Documentacao do OpenCode](https://opencode.ai/docs/)
- [Servidores MCP](https://opencode.ai/docs/mcp-servers/)
- [Configuracao de Agentes](https://opencode.ai/docs/agents/)
- [Permissoes](https://opencode.ai/docs/permissions/)
