#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0
WARNINGS=0

green()  { printf '\033[32m%s\033[0m\n' "$1"; }
red()    { printf '\033[31m%s\033[0m\n' "$1"; }
yellow() { printf '\033[33m%s\033[0m\n' "$1"; }
blue()   { printf '\033[34m%s\033[0m\n' "$1"; }

fail() { red "  ✗ $1"; ERRORS=$((ERRORS + 1)); }
warn() { yellow "  ⚠ $1"; WARNINGS=$((WARNINGS + 1)); }
pass() { green "  ✓ $1"; }

EXPECTED_AGENTS=(luna-lead terra-planner luna-worker luna-worker-xhigh deepseek-worker terra-diagnostician strategic-advisor)
EXPECTED_SKILLS=(infra-operations security-review software-testing backend-engineering frontend-engineering)
LEGACY_AGENTS=(luna-operator terra-lead qa-engineer cybersecurity devops backend frontend)

echo "============================================="
echo "  opencode-config v2.1 - validacao"
echo "============================================="

blue "[1/10] JSON"
if node -e "JSON.parse(require('fs').readFileSync('${REPO_DIR}/opencode.json','utf8'))" 2>/dev/null; then
  pass "opencode.json valido"
else
  fail "opencode.json invalido"
fi

blue "[2/10] Configuracao global"
if grep -q 'openai/gpt-5.6-luna' "${REPO_DIR}/opencode.json"; then pass "Luna configurado"; else fail "Luna ausente"; fi
if grep -q '"default_agent": "luna-lead"' "${REPO_DIR}/opencode.json"; then pass "luna-lead e o default"; else fail "default_agent incorreto"; fi
if grep -q 'rt-vllm\|Qwen3\.5\|Qwen3\.6' "${REPO_DIR}/opencode.json"; then fail "RT Mind/Qwen legado ainda presente"; else pass "RT Mind removido"; fi
if grep -q '{env:BRAVE_API_KEY}' "${REPO_DIR}/opencode.json"; then pass "Brave usa env"; else fail "Brave nao usa env"; fi
if grep -q '{env:GITHUB_PERSONAL_ACCESS_TOKEN}' "${REPO_DIR}/opencode.json"; then pass "GitHub usa env"; else fail "GitHub nao usa env"; fi

blue "[3/10] Agentes"
for name in "${EXPECTED_AGENTS[@]}"; do
  file="${REPO_DIR}/.opencode/agents/${name}.md"
  if [[ ! -f "$file" ]]; then fail "agente ausente: $name"; continue; fi
  [[ "$(head -1 "$file")" == "---" ]] || fail "$name sem frontmatter"
  grep -q '^description:' "$file" || fail "$name sem description"
  grep -q '^mode:' "$file" || fail "$name sem mode"
  grep -q '^model:' "$file" || fail "$name sem model"
  pass "$name"
done

blue "[4/10] Agentes legados"
legacy_found=0
for name in "${LEGACY_AGENTS[@]}"; do
  if [[ -f "${REPO_DIR}/.opencode/agents/${name}.md" ]]; then
    fail "agente legado ainda no repo: $name"
    legacy_found=1
  fi
done
[[ $legacy_found -eq 0 ]] && pass "nenhum agente legado no repo"

blue "[5/10] Skills"
for name in "${EXPECTED_SKILLS[@]}"; do
  file="${REPO_DIR}/.opencode/skills/${name}/SKILL.md"
  if [[ ! -f "$file" ]]; then fail "skill ausente: $name"; continue; fi
  grep -q "^name: ${name}$" "$file" || fail "$name com name invalido"
  grep -q '^description:' "$file" || fail "$name sem description"
  pass "$name"
done

blue "[6/10] Roteamento de modelos"
grep -q 'reasoningEffort: medium' "${REPO_DIR}/.opencode/agents/luna-lead.md" && pass "Luna Lead em Medium" || fail "Luna Lead nao esta em Medium"
grep -q 'reasoningEffort: high' "${REPO_DIR}/.opencode/agents/luna-worker.md" && pass "Luna Worker em High" || fail "Luna Worker nao esta em High"
grep -q 'reasoningEffort: xhigh' "${REPO_DIR}/.opencode/agents/luna-worker-xhigh.md" && pass "Luna XHigh configurado" || fail "Luna XHigh ausente"
grep -q '^hidden: true' "${REPO_DIR}/.opencode/agents/luna-worker-xhigh.md" && pass "Luna XHigh oculto" || warn "Luna XHigh nao esta oculto"
grep -q 'reasoningEffort: low' "${REPO_DIR}/.opencode/agents/terra-diagnostician.md" && pass "Terra Diagnostician em Low" || fail "Terra Diagnostician nao esta em Low"
grep -q 'reasoningEffort: low' "${REPO_DIR}/.opencode/agents/terra-planner.md" && pass "Terra Planner em Low" || fail "Terra Planner nao esta em Low"
grep -q 'reasoningEffort: medium' "${REPO_DIR}/.opencode/agents/strategic-advisor.md" && pass "Strategic Advisor em Medium" || warn "Strategic Advisor nao esta em Medium"
grep -q 'opencode/deepseek-v4-flash-free' "${REPO_DIR}/.opencode/agents/deepseek-worker.md" && pass "DeepSeek Free configurado" || fail "DeepSeek Free ausente"

blue "[7/10] Roteamento do Luna Lead"
for target in deepseek-worker luna-worker luna-worker-xhigh terra-diagnostician terra-planner strategic-advisor; do
  if grep -q "\"${target}\": allow" "${REPO_DIR}/.opencode/agents/luna-lead.md"; then
    pass "Luna Lead pode chamar ${target}"
  else
    fail "Luna Lead nao pode chamar ${target}"
  fi
done

blue "[8/10] Instaladores e backups"
if bash -n "${REPO_DIR}/setup.sh"; then pass "setup.sh com sintaxe valida"; else fail "setup.sh com erro de sintaxe"; fi
[[ -f "${REPO_DIR}/setup.ps1" ]] && pass "setup.ps1 presente" || fail "setup.ps1 ausente"

grep -q 'backup_current_config' "${REPO_DIR}/setup.sh" && pass "Unix cria snapshot pre-instalacao" || fail "backup obrigatorio ausente no setup.sh"
grep -q 'opencode-backups' "${REPO_DIR}/setup.sh" && pass "Unix usa diretorio de backups dedicado" || fail "diretorio de backup Unix ausente"
grep -q 'New-ConfigBackup' "${REPO_DIR}/setup.ps1" && pass "Windows cria snapshot pre-instalacao" || fail "backup obrigatorio ausente no setup.ps1"
grep -q 'opencode-backups' "${REPO_DIR}/setup.ps1" && pass "Windows usa diretorio de backups dedicado" || fail "diretorio de backup Windows ausente"

grep -q 'luna-operator.md' "${REPO_DIR}/setup.sh" && grep -q 'terra-lead.md' "${REPO_DIR}/setup.sh" && pass "setup.sh limpa nomes v2 antigos" || warn "setup.sh pode deixar nomes v2 antigos"
grep -q "'luna-operator.md'" "${REPO_DIR}/setup.ps1" && grep -q "'terra-lead.md'" "${REPO_DIR}/setup.ps1" && pass "setup.ps1 limpa nomes v2 antigos" || warn "setup.ps1 pode deixar nomes v2 antigos"

if command -v pwsh >/dev/null 2>&1; then
  if pwsh -NoProfile -Command '$tokens=$null; $errors=$null; [System.Management.Automation.Language.Parser]::ParseFile($args[0],[ref]$tokens,[ref]$errors) | Out-Null; if ($errors.Count -gt 0) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }' "${REPO_DIR}/setup.ps1" >/dev/null 2>&1; then
    pass "setup.ps1 com sintaxe valida"
  else
    fail "setup.ps1 com erro de sintaxe"
  fi
else
  warn "pwsh ausente; parser do setup.ps1 nao executado neste host"
fi

blue "[9/10] Segredos"
if grep -RIEq '(ghp_[A-Za-z0-9]{20,}|BSA[A-Za-z0-9]{20,})' "${REPO_DIR}" --exclude-dir=.git; then fail "possivel credencial literal encontrada"; else pass "nenhuma credencial conhecida encontrada"; fi

blue "[10/10] MCP packages"
MCP_PACKAGES=('@brave/brave-search-mcp-server' '@modelcontextprotocol/server-github' '@cyanheads/git-mcp-server' '@modelcontextprotocol/server-memory')
if command -v npm >/dev/null 2>&1; then
  for pkg in "${MCP_PACKAGES[@]}"; do
    if npm view "$pkg" version >/dev/null 2>&1; then pass "$pkg disponivel"; else warn "$pkg nao verificado no npm"; fi
  done
else
  warn "npm ausente; verificacao de MCPs ignorada"
fi

echo ""
echo "============================================="
echo "  Resultado: ${ERRORS} erro(s), ${WARNINGS} aviso(s)"
echo "============================================="
[[ "$ERRORS" -eq 0 ]]
