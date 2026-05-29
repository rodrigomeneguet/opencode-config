# 🤖 opencode-config

Configuration template for [OpenCode](https://opencode.ai) — the open source AI coding agent.

> Setup in under 2 minutes. Sync across machines via Git.

---

## 📋 Overview

| Component | Details |
| --- | --- |
| **MCP Servers** | Brave Search, GitHub, Git History, Memory Graph |
| **Custom Agents** | QA Engineer, Cybersecurity, DevOps, Backend, Frontend |
| **LLM Provider** | RT Mind (vLLM) — Qwen 3.5 & 3.6 |

---

## 🚀 Quick Start

```bash
# Clone this repo
git clone https://github.com/rodrigomeneguet/opencode-config.git
cd opencode-config

# Copy config files to OpenCode directory
cp opencode.json ~/.config/opencode/
cp -r agents/ ~/.config/opencode/

# Setup MCP servers with your API keys
cp opencode.jsonc.example ~/.config/opencode/opencode.jsonc

# Edit and replace placeholders with your real keys
#  - Brave Search API key → BRAVE_API_KEY
#  - GitHub PAT           → GITHUB_PERSONAL_ACCESS_TOKEN

# Restart OpenCode
# Done! All MCPs and agents are ready.
```

---

## 📁 File Structure

```
~/.config/opencode/
├── opencode.json              ← Provider + model configuration
├── opencode.jsonc             ← MCP servers (copy from .example + your keys)
├── .env                       ← (optional) environment variables
└── agents/                    ← Custom agents (@mention to invoke)
    ├── qa-engineer.md               → Test strategy & automation
    ├── cybersecurity.md             → Vulnerability assessment & OWASP
    ├── devops.md                    → CI/CD, containers, IaC
    ├── backend.md                   → API design, DB, microservices
    └── frontend.md                  → React/Vue, CSS, a11y, performance
```

---

## 🔧 MCP Servers

| Server | Package | Purpose | Keys Needed |
| --- | --- | --- | --- |
| **Brave Search** | `@brave/brave-search-mcp-server` | Web, image, video, news search | Brave API Key ([api-dashboard.search.brave.com](https://api-dashboard.search.brave.com)) |
| **GitHub** | `@modelcontextprotocol/server-github` | Issues, PRs, repos, file management | GitHub PAT ([github.com/settings/tokens](https://github.com/settings/tokens)) |
| **Git History** | `@cyanheads/git-mcp-server` | Local commits, diffs, blame (28 tools) | None |
| **Memory Graph** | `@modelcontextprotocol/server-memory` | Persistent state across sessions | None |

---

## 🤖 Custom Agents

Invoke with `@` mention in your OpenCode session:

| Agent | Example Usage | Permissions |
| --- | --- | --- |
| `@qa-engineer` | `@qa-engineer sugira testes para o modulo X` | Edit ✅, Bash ✅ |
| `@cybersecurity` | `@cybersecurity audite o arquivo config.py` | Edit ❌, Bash (read-only) |
| `@devops` | `@devops crie um pipeline CI/CD para o projeto` | Edit ✅, Bash ✅ |
| `@backend` | `@backend avalie a arquitetura de microservicos` | Edit ✅, Bash ✅ |
| `@frontend` | `@frontend revise os componentes de UI` | Edit ✅, Bash ✅ |

### Run agents in parallel

Multiple agents can work on the same task from different angles:

```
@cybersecurity audite as vulnerabilidades do projeto
@qa-engineer analise a cobertura de testes
@devops sugira uma estrategia de CI/CD
```

All three run simultaneously and return independent reports.

---

## 🔑 Getting Your API Keys

### Brave Search

1. Go to [api-dashboard.search.brave.com](https://api-dashboard.search.brave.com)
2. Sign up / sign in
3. Create a new API key
4. Paste into `opencode.jsonc` → `BRAVE_API_KEY`

### GitHub Personal Access Token

1. Go to [github.com/settings/tokens](https://github.com/settings/tokens)
2. Generate a new token with `repo` scope (or `public_repo` for public repos only)
3. Paste into `opencode.jsonc` → `GITHUB_PERSONAL_ACCESS_TOKEN`

---

## 🔄 Syncing Updates

To update your configuration from this repo:

```bash
# Clone or update
git clone https://github.com/rodrigomeneguet/opencode-config.git
# or, if already cloned:
cd opencode-config && git pull origin main

# Re-copy files (preserves your opencode.jsonc with real keys)
cp opencode.json ~/.config/opencode/
cp -r agents/ ~/.config/opencode/
```

---

## 📝 Adding New Agents

Create a markdown file in `agents/`:

```markdown
---
description: Your agent description here
mode: subagent
permission:
  edit: allow       # or deny
  bash: allow       # or deny, or granular rules
---

You are a [role]. Focus on [specialty]...
```

Then restart OpenCode. The agent will be available via `@agent-name`.

---

## 🛡️ Security Notes

- **Never commit `opencode.jsonc` with real keys** — use the `.example` template
- The `.gitignore` is configured to block `opencode.jsonc` and `.env`
- Rotate your API keys periodically
- GitHub PAT: use the minimum scopes needed for your workflow

---

## 📚 References

- [OpenCode Docs](https://opencode.ai/docs/)
- [MCP Servers](https://opencode.ai/docs/mcp-servers/)
- [Agents Configuration](https://opencode.ai/docs/agents/)
- [Permissions](https://opencode.ai/docs/permissions/)
