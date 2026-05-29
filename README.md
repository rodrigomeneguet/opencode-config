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
- Diretorio `~/.config/opencode/` (criado automaticamente na primeira execucao do OpenCode)
- Conta no [Brave Search API](https://api-dashboard.search.brave.com) (para busca web)
- [GitHub Personal Access Token](https://github.com/settings/tokens) (para integracao com GitHub)

---

## Inicio Rapido (~5 minutos)

1. Clone este repositorio:
   ```bash
   git clone https://github.com/rodrigomeneguet/opencode-config.git
   cd opencode-config
   ```

2. Copie a configuracao e agentes para o OpenCode:
   ```bash
   mkdir -p ~/.config/opencode
   cp opencode.json ~/.config/opencode/
   cp -r agents/ ~/.config/opencode/
   ```

3. Copie o template de configuracao MCP:
   ```bash
   cp opencode.jsonc.example ~/.config/opencode/opencode.jsonc
   ```

4. Edite `~/.config/opencode/opencode.jsonc` e substitua os placeholders:
   - `{YOUR_BRAVE_API_KEY}` → sua chave de API do Brave Search
   - `{YOUR_GITHUB_TOKEN}` → seu token de acesso pessoal do GitHub

5. Reinicie o OpenCode. Verifique com: `@qa-engineer ola`

---

## Estrutura de Arquivos

```
~/.config/opencode/
├── opencode.json              ← Configuracao de provedor e modelos
├── opencode.jsonc             ← Servidores MCP (copie do .example + suas chaves)
├── .env                       ← (opcional) variaveis de ambiente
└── agents/                    ← Agentes customizados (invocaveis com @)
    ├── qa-engineer.md         → Estrategia e automacao de testes
    ├── cybersecurity.md       → Avaliacao de vulnerabilidades e OWASP
    ├── devops.md              → CI/CD, containers, IaC
    ├── backend.md             → Design de APIs, banco de dados, microservicos
    └── frontend.md            → React/Vue, CSS, acessibilidade, performance
```

> **Importante:** `opencode.json` configura provedores e modelos. `opencode.jsonc` configura servidores MCP. Ambos sao carregados pelo OpenCode.

---

## Servidores MCP

| Servidor | Pacote | Finalidade | Chaves Necessarias |
| --- | --- | --- | --- |
| **Brave Search** | `@brave/brave-search-mcp-server` | Busca web, imagens, videos, noticias | Chave Brave API ([api-dashboard.search.brave.com](https://api-dashboard.search.brave.com)) |
| **GitHub** | `@modelcontextprotocol/server-github` | Issues, PRs, repos, gestao de arquivos | GitHub PAT ([github.com/settings/tokens](https://github.com/settings/tokens)) |
| **Git History** | `@cyanheads/git-mcp-server` | Commits locais, diffs, blame (28 ferramentas) | Nenhuma |
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

### Brave Search

1. Acesse [api-dashboard.search.brave.com](https://api-dashboard.search.brave.com)
2. Faca login ou crie uma conta
3. Gere uma nova chave de API
4. Cole em `opencode.jsonc` → `BRAVE_API_KEY`

### GitHub Personal Access Token

1. Acesse [github.com/settings/tokens](https://github.com/settings/tokens)
2. Gere um novo token com escopo `repo` (ou `public_repo` apenas para repos publicos)
3. Cole em `opencode.jsonc` → `GITHUB_PERSONAL_ACCESS_TOKEN`

> **Dica:** Use o escopo minimo necessario. Para muitos casos, `public_repo` e suficiente.

---

## Sincronizando Atualizacoes

Para atualizar sua configuracao deste repositorio:

```bash
# Clone ou atualize
git clone https://github.com/rodrigomeneguet/opencode-config.git
# ou, se ja clonado:
cd opencode-config && git pull origin master

# Recopie os arquivos (preserva seu opencode.jsonc com chaves reais)
cp opencode.json ~/.config/opencode/
cp -r agents/ ~/.config/opencode/
```

> Seus arquivos `opencode.jsonc` e `.env` estao protegidos pelo `.gitignore` e nao serao sobrescritos. Agentes podem sobrescrever customizacoes — considere usar branches para modifications locais.

---

## Adicionando Novos Agentes

Crie um arquivo markdown em `agents/`:

```markdown
---
description: Descricao do seu agente aqui
mode: subagent
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

- **Nunca faca commit de `opencode.jsonc` com chaves reais** — use o template `.example`
- O `.gitignore` bloqueia `opencode.jsonc`, `opencode.json` e `.env`
- Rotacione suas chaves de API periodicamente
- GitHub PAT: use os escopos minimos necessarios para seu fluxo de trabalho
- O vLLM endpoint esta configurado para uso interno — nao compartilhe a URL publicamente

---

## Solucao de Problemas

### Agentes nao aparecem apos copiar os arquivos

- Verifique se o frontmatter dos arquivos em `agents/` esta formatado corretamente (cada campo em uma linha separada)
- Confirme que copiou todo o diretorio `agents/` para `~/.config/opencode/agents/`
- Reinicie o OpenCode completamente

### Servidor MCP nao inicia

- Verifique se o Node.js 18+ esta instalado: `node --version`
- Teste manualmente: `npx -y @brave/brave-search-mcp-server --help`
- Verifique se as chaves de API estao corretas em `opencode.jsonc`

### Erro de conexao com o modelo

- Confirme que o endpoint vLLM esta acessivel: `curl https://api-vllm.regionaltelhas.com.br/v1/models`
- Verifique sua conexao com a internet
- Confirme que o modelo esta configurado corretamente em `opencode.json`

### Configuracao nao e detectada

- Certifique-se de que os arquivos estao em `~/.config/opencode/` (nao em outro diretorio)
- Verifique se nao ha erros de formatacao JSON nos arquivos de configuracao
- Reinicie o OpenCode apos qualquer alteracao

---

## Referencias

- [Documentacao do OpenCode](https://opencode.ai/docs/)
- [Servidores MCP](https://opencode.ai/docs/mcp-servers/)
- [Configuracao de Agentes](https://opencode.ai/docs/agents/)
- [Permissoes](https://opencode.ai/docs/permissions/)
