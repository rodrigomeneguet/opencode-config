#!/usr/bin/env bash
# setup.sh — Instalacao interativa do opencode-config
# Detecta config existente, mescla, configura chaves interativamente
# Uso: bash setup.sh [--auto|--project|--symlink|--merge]
set -euo pipefail

# ═══════════════════════════════════════════════════════════
# Configuracao
# ═══════════════════════════════════════════════════════════
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="${HOME}/.config/opencode"
MODE="interactive"  # interactive|auto|project|merge
USE_SYMLINK=false

for arg in "$@"; do
  case "$arg" in
    --auto)     MODE="auto" ;;
    --project)  MODE="project" ;;
    --symlink)  USE_SYMLINK=true ;;
    --merge)    MODE="merge" ;;
    --help|-h)
      echo "Uso: bash setup.sh [OPCOES]"
      echo ""
      echo "Opcoes:"
      echo "  (nenhum)    Modo interativo (default)"
      echo "  --auto      Modo automatico (usa .env ou valores existentes)"
      echo "  --project   Copia para .opencode/ no diretorio atual"
      echo "  --symlink   Usa symlinks em vez de copias (global)"
      echo "  --merge     Apenas merge (nao sobrescreve nada)"
      echo "  --help      Mostra esta ajuda"
      exit 0
      ;;
  esac
done

# ═══════════════════════════════════════════════════════════
# Cores e helpers
# ═══════════════════════════════════════════════════════════
green()  { printf "\033[32m%s\033[0m\n" "$1"; }
yellow() { printf "\033[33m%s\033[0m\n" "$1"; }
red()    { printf "\033[31m%s\033[0m\n" "$1"; }
blue()   { printf "\033[34m%s\033[0m\n" "$1"; }
bold()   { printf "\033[1m%s\033[0m\n" "$1"; }

ask_yes_no() {
  local prompt="$1"
  local default="${2:-y}"
  local yn
  if [[ "$MODE" == "auto" ]]; then
    return 0
  fi
  if [[ "$default" == "y" ]]; then
    read -rp "$prompt [S/n]: " yn
    yn="${yn:-S}"
  else
    read -rp "$prompt [s/N]: " yn
    yn="${yn:-N}"
  fi
  [[ "$yn" =~ ^[Ss]$ ]]
}

ask_value() {
  local prompt="$1"
  local var_name="$2"
  local silent="${3:-false}"
  if [[ "$MODE" == "auto" ]]; then
    return 1
  fi
  if [[ "$silent" == "true" ]]; then
    read -rsp "$prompt: " value
    echo ""
  else
    read -rp "$prompt: " value
  fi
  if [[ -n "$value" ]]; then
    eval "$var_name='$value'"
    return 0
  fi
  return 1
}

# ═══════════════════════════════════════════════════════════
# Carregar .env existente
# ═══════════════════════════════════════════════════════════
load_env() {
  local env_file="$1"
  if [[ -f "$env_file" ]]; then
    while IFS= read -r line; do
      if [[ "$line" =~ ^[A-Z_]+=.+$ ]]; then
        local key="${line%%=*}"
        local val="${line#*=}"
        export "$key"="$val" 2>/dev/null || true
      fi
    done < "$env_file"
  fi
}

# ═══════════════════════════════════════════════════════════
# Header
# ═══════════════════════════════════════════════════════════
echo ""
bold "╔═══════════════════════════════════════════════════╗"
bold "║        opencode-config — Instalacao              ║"
bold "╚═══════════════════════════════════════════════════╝"
echo ""
blue "Modo: ${MODE}"
echo ""

# ═══════════════════════════════════════════════════════════
# FASE 1: Detectar instalacao existente
# ═══════════════════════════════════════════════════════════
bold "── Fase 1: Detectando configuracao existente ──"

EXISTING_PROVIDER=""
EXISTING_MCPS=""
EXISTING_ENV=""

if [[ -f "${CONFIG_DIR}/opencode.json" ]]; then
  green "  ✓ opencode.json encontrado em ${CONFIG_DIR}/"
  EXISTING_PROVIDER=$(cat "${CONFIG_DIR}/opencode.json" 2>/dev/null || echo "")
fi

if [[ -f "${CONFIG_DIR}/opencode.jsonc" ]]; then
  green "  ✓ opencode.jsonc encontrado em ${CONFIG_DIR}/"
  EXISTING_MCPS=$(cat "${CONFIG_DIR}/opencode.jsonc" 2>/dev/null || echo "")
fi

if [[ -f "${CONFIG_DIR}/.env" ]]; then
  green "  ✓ .env encontrado em ${CONFIG_DIR}/"
  EXISTING_ENV="exists"
  load_env "${CONFIG_DIR}/.env"
fi

if [[ -z "$EXISTING_PROVIDER" && -z "$EXISTING_MCPS" && -z "$EXISTING_ENV" ]]; then
  yellow "  ⚠ Nenhuma configuracao existente encontrada — instalacao limpa"
fi
echo ""

# ═══════════════════════════════════════════════════════════
# FASE 2: Merge de configuracao
# ═══════════════════════════════════════════════════════════
bold "── Fase 2: Merge de configuracao ──"

if [[ "$MODE" == "project" ]]; then
  blue "  Modo projeto: copiando para .opencode/ no CWD"
  TARGET_DIR="$(pwd)/.opencode"
  mkdir -p "${TARGET_DIR}/agents"

  for agent in "${REPO_DIR}"/.opencode/agents/*.md; do
    filename="$(basename "$agent")"
    if ${USE_SYMLINK}; then
      ln -sf "$agent" "${TARGET_DIR}/agents/${filename}"
    else
      cp -u "$agent" "${TARGET_DIR}/agents/${filename}"
    fi
    green "  ✓ ${filename}"
  done

  if [[ ! -f "$(pwd)/opencode.json" ]]; then
    cp "${REPO_DIR}/opencode.json" "$(pwd)/opencode.json"
    green "  ✓ opencode.json copiado"
  else
    yellow "  ⚠ opencode.json ja existe no projeto"
  fi

  # Copiar MCP config se nao existir
  if [[ ! -f "$(pwd)/opencode.jsonc" ]]; then
    cp "${REPO_DIR}/opencode.jsonc.example" "$(pwd)/opencode.jsonc"
    green "  ✓ opencode.jsonc criado (edite com suas chaves)"
  fi

  echo ""
  green "  Instalacao de projeto concluida!"
  echo ""
  exit 0
fi

# Modo global: merge provider
if [[ -n "$EXISTING_PROVIDER" ]]; then
  yellow "  Configuracao de provider existente detectada"
  if ask_yes_no "  Deseja substituir pelo provider do repo (rt-vllm/Qwen)?"; then
    mkdir -p "${CONFIG_DIR}"
    if ${USE_SYMLINK}; then
      ln -sf "${REPO_DIR}/opencode.json" "${CONFIG_DIR}/opencode.json"
    else
      cp "${REPO_DIR}/opencode.json" "${CONFIG_DIR}/opencode.json"
    fi
    green "  ✓ Provider atualizado"
  else
    yellow "  → Provider existente preservado"
  fi
else
  mkdir -p "${CONFIG_DIR}"
  if ${USE_SYMLINK}; then
    ln -sf "${REPO_DIR}/opencode.json" "${CONFIG_DIR}/opencode.json"
  else
    cp "${REPO_DIR}/opencode.json" "${CONFIG_DIR}/opencode.json"
  fi
  green "  ✓ opencode.json instalado"
fi

# Merge agentes
blue "  Instalando agentes..."
mkdir -p "${CONFIG_DIR}/.opencode/agents"
for agent in "${REPO_DIR}"/.opencode/agents/*.md; do
  filename="$(basename "$agent")"
  if ${USE_SYMLINK}; then
    ln -sf "$agent" "${CONFIG_DIR}/.opencode/agents/${filename}"
  else
    cp -u "$agent" "${CONFIG_DIR}/.opencode/agents/${filename}"
  fi
  green "  ✓ ${filename}"
done
echo ""

# ═══════════════════════════════════════════════════════════
# FASE 3: Configuracao de chaves
# ═══════════════════════════════════════════════════════════
bold "── Fase 3: Configuracao de chaves de API ──"

# Variaveis obrigatorias
declare -A REQUIRED_KEYS=(
  ["BRAVE_API_KEY"]="obrigatoria"
)

# Variaveis opcionais
declare -A OPTIONAL_KEYS=(
  ["GITHUB_PERSONAL_ACCESS_TOKEN"]="recomendada (para GitHub MCP)"
)

configure_key() {
  local key="$1"
  local desc="$2"
  local current_value="${!key:-}"

  # Ja tem valor?
  if [[ -n "$current_value" ]]; then
    local masked="${current_value:0:4}****${current_value: -4}"
    green "  ✓ ${key}: ${masked}"
    if [[ "$MODE" != "auto" ]]; then
      if ask_yes_no "    Deseja alterar ${key}?"; then
        if ask_value "    Novo valor para ${key}" "new_val" true; then
          export "$key"="$new_val"
          green "    → ${key} atualizada"
        fi
      fi
    fi
    return 0
  fi

  # Nao tem valor — perguntar
  yellow "  ⚠ ${key} nao configurada"
  if [[ "$desc" == "obrigatoria" ]]; then
    blue "    (${desc}: necessaria para Brave Search MCP)"
  else
    blue "    (${desc})"
  fi

  if [[ "$MODE" == "auto" ]]; then
    red "    ✗ ${key} ausente — modo auto nao pode configurar"
    return 1
  fi

  if ask_yes_no "    Deseja configurar ${key} agora?"; then
    if ask_value "    Digite o valor de ${key}" "new_val" true; then
      export "$key"="$new_val"
      green "    → ${key} configurada"
      return 0
    else
      red "    ✗ Valor vazio — ${key} nao configurada"
      return 1
    fi
  else
    yellow "    → ${key} pulada"
    return 1
  fi
}

MISSING_KEYS=0

for key in "${!REQUIRED_KEYS[@]}"; do
  if ! configure_key "$key" "${REQUIRED_KEYS[$key]}"; then
    ((MISSING_KEYS++))
  fi
done

for key in "${!OPTIONAL_KEYS[@]}"; do
  configure_key "$key" "${OPTIONAL_KEYS[$key]}" || true
done
echo ""

# ═══════════════════════════════════════════════════════════
# FASE 4: Gerar arquivos
# ═══════════════════════════════════════════════════════════
bold "── Fase 4: Gerando arquivos de configuracao ──"

# Gerar opencode.jsonc
blue "  Gerando opencode.jsonc..."
if [[ -f "${CONFIG_DIR}/opencode.jsonc" ]]; then
  cp "${CONFIG_DIR}/opencode.jsonc" "${CONFIG_DIR}/opencode.jsonc.bak"
  yellow "  → Backup: opencode.jsonc.bak"
fi

# Copiar template e substituir placeholders
cp "${REPO_DIR}/opencode.jsonc.example" "${CONFIG_DIR}/opencode.jsonc"

if [[ -n "${BRAVE_API_KEY:-}" ]]; then
  sed -i "s/{YOUR_BRAVE_API_KEY}/${BRAVE_API_KEY}/g" "${CONFIG_DIR}/opencode.jsonc"
fi

if [[ -n "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]]; then
  sed -i "s/{YOUR_GITHUB_TOKEN}/${GITHUB_PERSONAL_ACCESS_TOKEN}/g" "${CONFIG_DIR}/opencode.jsonc"
fi

green "  ✓ opencode.jsonc gerado"

# Gerar .env
blue "  Gerando .env..."
cat > "${CONFIG_DIR}/.env" << EOF
# Variaveis de ambiente para opencode-config
# Gerado por setup.sh em $(date '+%Y-%m-%d %H:%M:%S')

BRAVE_API_KEY=${BRAVE_API_KEY:-}
GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_PERSONAL_ACCESS_TOKEN:-}
EOF
green "  ✓ .env gerado"
echo ""

# ═══════════════════════════════════════════════════════════
# FASE 5: Verificacao final
# ═══════════════════════════════════════════════════════════
bold "── Fase 5: Verificacao final ──"

ERRORS=0

# Verificar opencode.json
if [[ -f "${CONFIG_DIR}/opencode.json" ]]; then
  if node -e "JSON.parse(require('fs').readFileSync('${CONFIG_DIR}/opencode.json','utf8'))" 2>/dev/null; then
    green "  ✓ opencode.json: valido"
  else
    red "  ✗ opencode.json: JSON invalido"
    ((ERRORS++))
  fi
else
  red "  ✗ opencode.json: nao encontrado"
  ((ERRORS++))
fi

# Verificar opencode.jsonc
if [[ -f "${CONFIG_DIR}/opencode.jsonc" ]]; then
  if node -e "JSON.parse(require('fs').readFileSync('${CONFIG_DIR}/opencode.jsonc','utf8'))" 2>/dev/null; then
    green "  ✓ opencode.jsonc: valido"
  else
    red "  ✗ opencode.jsonc: JSON invalido"
    ((ERRORS++))
  fi
else
  red "  ✗ opencode.jsonc: nao encontrado"
  ((ERRORS++))
fi

# Verificar chaves
for key in "${!REQUIRED_KEYS[@]}"; do
  if [[ -n "${!key:-}" ]]; then
    green "  ✓ ${key}: configurada"
  else
    red "  ✗ ${key}: AUSENTE"
    ((ERRORS++))
  fi
done

for key in "${!OPTIONAL_KEYS[@]}"; do
  if [[ -n "${!key:-}" ]]; then
    green "  ✓ ${key}: configurada"
  else
    yellow "  ⚠ ${key}: nao configurada (opcional)"
  fi
done

# Verificar agentes
AGENT_COUNT=$(ls -1 "${CONFIG_DIR}/.opencode/agents/"*.md 2>/dev/null | wc -l)
if [[ "$AGENT_COUNT" -gt 0 ]]; then
  green "  ✓ ${AGENT_COUNT} agente(s) instalado(s)"
else
  red "  ✗ Nenhum agente encontrado"
  ((ERRORS++))
fi

echo ""

# ═══════════════════════════════════════════════════════════
# Resumo
# ═══════════════════════════════════════════════════════════
if [[ $ERRORS -eq 0 ]]; then
  bold "╔═══════════════════════════════════════════════════╗"
  green "║       ✓ Instalacao concluida com sucesso!       ║"
  bold "╚═══════════════════════════════════════════════════╝"
  echo ""
  echo "  Arquivos instalados em: ${CONFIG_DIR}/"
  echo ""
  echo "  Proximos passos:"
  echo "    1. Reinicie o OpenCode"
  echo "    2. Teste: @qa-engineer ola"
  echo ""
else
  bold "╔═══════════════════════════════════════════════════╗"
  red "║    ✗ Instalacao com erros (${ERRORS} erro(s))           ║"
  bold "╚═══════════════════════════════════════════════════╝"
  echo ""
  echo "  Corrija os erros acima e execute novamente."
  echo ""
  exit 1
fi
