#!/usr/bin/env bash
# scripts/validate.sh — Validacao completa da configuracao do opencode-config
# Executa no sandbox (repo clonado), sem tocar na config real do usuario.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0
WARNINGS=0

green() { printf "\033[32m%s\033[0m\n" "$1"; }
red()   { printf "\033[31m%s\033[0m\n" "$1"; }
yellow(){ printf "\033[33m%s\033[0m\n" "$1"; }
blue()  { printf "\033[34m%s\033[0m\n" "$1"; }

echo "============================================="
echo "  Validacao de Configuracao opencode-config"
echo "  Diretorio: ${REPO_DIR}"
echo "============================================="
echo ""

# ─── 1. Validar JSON do opencode.json ───
blue "[1/8] Validando opencode.json..."
if command -v node &>/dev/null; then
  if node -e "JSON.parse(require('fs').readFileSync('${REPO_DIR}/opencode.json','utf8'))" 2>/dev/null; then
    green "  ✓ opencode.json: JSON valido"
  else
    red "  ✗ opencode.json: JSON invalido"
    ((ERRORS++))
  fi
else
  yellow "  ⚠ node nao encontrado, pulando validacao JSON"
  ((WARNINGS++))
fi

# ─── 2. Validar JSON do opencode.jsonc.example ───
blue "[2/8] Validando opencode.jsonc.example..."
if command -v node &>/dev/null; then
  if node -e "JSON.parse(require('fs').readFileSync('${REPO_DIR}/opencode.jsonc.example','utf8'))" 2>/dev/null; then
    green "  ✓ opencode.jsonc.example: JSON valido"
  else
    red "  ✗ opencode.jsonc.example: JSON invalido"
    ((ERRORS++))
  fi
else
  yellow "  ⚠ node nao encontrado, pulando"
  ((WARNINGS++))
fi

# ─── 3. Validar frontmatter dos agentes ───
blue "[3/8] Validando frontmatter dos agentes..."
for agent_file in "${REPO_DIR}"/.opencode/agents/*.md; do
  filename="$(basename "$agent_file")"
  line1="$(head -1 "$agent_file")"
  if [[ "$line1" == "---" ]]; then
    if grep -q "^description:" "$agent_file" && grep -q "^mode:" "$agent_file"; then
      green "  ✓ ${filename}: frontmatter valido"
    else
      red "  ✗ ${filename}: frontmatter sem description/mode"
      ((ERRORS++))
    fi
  else
    red "  ✗ ${filename}: linha 1 deve ser apenas '---' (encontrado: '${line1}')"
    ((ERRORS++))
  fi
done

# ─── 4. Verificar .gitignore ───
blue "[4/8] Verificando .gitignore..."
GITIGNORE="${REPO_DIR}/.gitignore"
for entry in "opencode.jsonc" "opencode.json" ".env"; do
  if grep -q "^${entry}$" "$GITIGNORE"; then
    green "  ✓ '${entry}' esta no .gitignore"
  else
    red "  ✗ '${entry}' NAO esta no .gitignore"
    ((ERRORS++))
  fi
done

# ─── 5. Verificar MCP packages no npm ───
blue "[5/8] Verificando disponibilidade dos pacotes MCP no npm..."
MCP_PACKAGES=(
  "@brave/brave-search-mcp-server"
  "@modelcontextprotocol/server-github"
  "@cyanheads/git-mcp-server"
  "@modelcontextprotocol/server-memory"
)
for pkg in "${MCP_PACKAGES[@]}"; do
  if command -v npm &>/dev/null; then
    if npm view "$pkg" version &>/dev/null; then
      version="$(npm view "$pkg" version 2>/dev/null)"
      green "  ✓ ${pkg}@${version}"
    else
      red "  ✗ ${pkg}: NAO encontrado no npm"
      ((ERRORS++))
    fi
  else
    yellow "  ⚠ npm nao encontrado, pulando verificacao de pacotes"
    ((WARNINGS++))
    break
  fi
done

# ─── 6. Validar setup.sh ───
blue "[6/8] Validando setup.sh..."
SETUP="${REPO_DIR}/setup.sh"
if [[ -f "$SETUP" ]]; then
  if bash -n "$SETUP" 2>/dev/null; then
    green "  ✓ setup.sh: sintaxe valida"
  else
    red "  ✗ setup.sh: erro de sintaxe"
    ((ERRORS++))
  fi
  if [[ -x "$SETUP" ]]; then
    green "  ✓ setup.sh: executavel"
  else
    yellow "  ⚠ setup.sh: nao e executavel (chmod +x)"
    ((WARNINGS++))
  fi
else
  red "  ✗ setup.sh: nao encontrado"
  ((ERRORS++))
fi

# ─── 7. Verificar .env.example ───
blue "[7/8] Verificando .env.example..."
if [[ -f "${REPO_DIR}/.env.example" ]]; then
  green "  ✓ .env.example existe"
  # Verificar se tem as variaveis obrigatorias
  if grep -q "^BRAVE_API_KEY=" "${REPO_DIR}/.env.example"; then
    green "  ✓ BRAVE_API_KEY documentada"
  else
    red "  ✗ BRAVE_API_KEY nao documentada no .env.example"
    ((ERRORS++))
  fi
else
  red "  ✗ .env.example: nao encontrado"
  ((ERRORS++))
fi

# ─── 8. Testar endpoint vLLM ───
blue "[8/8] Testando conectividade do endpoint vLLM..."
VLLM_URL="$(node -e "console.log(JSON.parse(require('fs').readFileSync('${REPO_DIR}/opencode.json','utf8')).provider['rt-vllm'].options.baseURL)" 2>/dev/null || echo "")"
if [[ -n "$VLLM_URL" ]]; then
  if curl -sf --max-time 5 "${VLLM_URL}/models" >/dev/null 2>&1; then
    green "  ✓ Endpoint vLLM acessivel: ${VLLM_URL}"
  else
    yellow "  ⚠ Endpoint vLLM inacessivel (timeout ou offline): ${VLLM_URL}"
    ((WARNINGS++))
  fi
else
  yellow "  ⚠ Nao foi possivel extrair URL do vLLM"
  ((WARNINGS++))
fi

# ─── Resumo ───
echo ""
echo "============================================="
echo "  Resumo da Validacao"
echo "============================================="
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
  green "  ✓ Todas as validacoes passaram!"
elif [[ $ERRORS -eq 0 ]]; then
  yellow "  ⚠ ${WARNINGS} aviso(s), 0 erro(s)"
else
  red "  ✗ ${ERRORS} erro(s), ${WARNINGS} aviso(s)"
fi
echo ""
exit $ERRORS
