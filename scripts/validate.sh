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

EXPECTED_AGENTS=(luna-operator luna-worker deepseek-worker terra-diagnostician terra-lead strategic-advisor)
EXPECTED_SKILLS=(infra-operations security-review software-testing backend-engineering frontend-engineering)

echo "============================================="
echo "  opencode-config v2 - validacao"
echo "============================================="

blue "[1/8] JSON"
if node -e "JSON.parse(require('fs').readFileSync('${REPO_DIR}/opencode.json','utf8'))" 2>/dev/null; then
  pass "opencode.json valido"
else
  fail "opencode.json invalido"
fi

blue "[2/8] Configuracao de modelos e MCP"
if grep -q 'openai/gpt-5.6-luna' "${REPO_DIR}/opencode.json"; then pass "Luna configurado"; else fail "Luna ausente"; fi
if grep -q '"default_agent": "luna-operator"' "${REPO_DIR}/opencode.json"; then pass "luna-operator e o default"; else fail "default_agent incorreto"; fi
if grep -q 'rt-vllm\|Qwen3\.5\|Qwen3\.6' "${REPO_DIR}/opencode.json"; then fail "RT Mind/Qwen legado ainda presente"; else pass "RT Mind removido"; fi
if grep -q '{env:BRAVE_API_KEY}' "${REPO_DIR}/opencode.json"; then pass "Brave usa env"; else fail "Brave nao usa env"; fi
if grep -q '{env:GITHUB_PERSONAL_ACCESS_TOKEN}' "${REPO_DIR}/opencode.json"; then pass "GitHub usa env"; else fail "GitHub nao usa env"; fi

blue "[3/8] Agentes"
for name in "${EXPECTED_AGENTS[@]}"; do
  file="${REPO_DIR}/.opencode/agents/${name}.md"
  if [[ ! -f "$file" ]]; then fail "agente ausente: $name"; continue; fi
  [[ "$(head -1 "$file")" == "---" ]] || fail "$name sem frontmatter"
  grep -q '^description:' "$file" || fail "$name sem description"
  grep -q '^mode:' "$file" || fail "$name sem mode"
  grep -q '^model:' "$file" || fail "$name sem model"
  pass "$name"
done

blue "[4/8] Skills"
for name in "${EXPECTED_SKILLS[@]}"; do
  file="${REPO_DIR}/.opencode/skills/${name}/SKILL.md"
  if [[ ! -f "$file" ]]; then fail "skill ausente: $name"; continue; fi
  grep -q "^name: ${name}$" "$file" || fail "$name com name invalido"
  grep -q '^description:' "$file" || fail "$name sem description"
  pass "$name"
done

blue "[5/8] Roteamento e privacidade"
if grep -q 'opencode/deepseek-v4-flash-free' "${REPO_DIR}/.opencode/agents/deepseek-worker.md"; then pass "DeepSeek Free configurado"; else fail "DeepSeek Free ausente"; fi
if grep -qi 'nao processe segredos' "${REPO_DIR}/.opencode/agents/deepseek-worker.md"; then pass "guardrail de privacidade do DeepSeek presente"; else fail "guardrail de privacidade do DeepSeek ausente"; fi
if grep -q 'reasoningEffort: xhigh' "${REPO_DIR}/.opencode/agents/luna-worker.md"; then pass "Luna worker em xhigh"; else warn "Luna worker nao esta em xhigh"; fi
if grep -q 'model: openai/gpt-5.6-terra' "${REPO_DIR}/.opencode/agents/strategic-advisor.md"; then pass "advisor em Terra"; else warn "advisor usa outro motor"; fi

blue "[6/8] Segredos"
if grep -RIEq '(ghp_[A-Za-z0-9]{20,}|BSA[A-Za-z0-9]{20,})' "${REPO_DIR}" --exclude-dir=.git; then fail "possivel credencial literal encontrada"; else pass "nenhuma credencial conhecida encontrada"; fi

blue "[7/8] setup.sh"
if bash -n "${REPO_DIR}/setup.sh"; then pass "sintaxe valida"; else fail "erro de sintaxe"; fi

blue "[8/8] MCP packages"
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
