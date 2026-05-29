#!/usr/bin/env bash
# setup.sh — Instalacao idempotente do opencode-config
# Copia configuracao e agentes para ~/.config/opencode/
# Uso: bash setup.sh [--symlink]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="${HOME}/.config/opencode"
USE_SYMLINK=false

if [[ "${1:-}" == "--symlink" ]]; then
  USE_SYMLINK=true
fi

green() { printf "\033[32m%s\033[0m\n" "$1"; }
yellow(){ printf "\033[33m%s\033[0m\n" "$1"; }
blue()  { printf "\033[34m%s\033[0m\n" "$1"; }

echo "============================================="
echo "  Instalacao opencode-config"
echo "  Modo: $(${USE_SYMLINK} && echo 'symlink' || echo 'copia')"
echo "============================================="
echo ""

# Criar diretorio de configuracao
mkdir -p "${CONFIG_DIR}/agents"

# Copiar/symlink opencode.json
blue "Instalando opencode.json..."
if [[ -f "${CONFIG_DIR}/opencode.json" ]]; then
  yellow "  ⚠ opencode.json ja existe em ${CONFIG_DIR}/ — pulando (use --force para sobrescrever)"
else
  if ${USE_SYMLINK}; then
    ln -s "${REPO_DIR}/opencode.json" "${CONFIG_DIR}/opencode.json"
    green "  ✓ opencode.json (symlink)"
  else
    cp "${REPO_DIR}/opencode.json" "${CONFIG_DIR}/opencode.json"
    green "  ✓ opencode.json (copia)"
  fi
fi

# Copiar/symlink agentes
blue "Instalando agentes..."
for agent in "${REPO_DIR}"/agents/*.md; do
  filename="$(basename "$agent")"
  if ${USE_SYMLINK}; then
    ln -sf "$agent" "${CONFIG_DIR}/agents/${filename}"
  else
    cp -u "$agent" "${CONFIG_DIR}/agents/${filename}"
  fi
  green "  ✓ ${filename}"
done

# Copiar template MCP (nao sobrescreve se ja existir)
blue "Configurando MCP servers..."
if [[ ! -f "${CONFIG_DIR}/opencode.jsonc" ]]; then
  cp "${REPO_DIR}/opencode.jsonc.example" "${CONFIG_DIR}/opencode.jsonc"
  green "  ✓ opencode.jsonc criado a partir do template"
  yellow "  ⚠ Edite ${CONFIG_DIR}/opencode.jsonc com suas chaves de API"
else
  yellow "  ⚠ opencode.jsonc ja existe — preservando (suas chaves estao seguras)"
fi

# Copiar .env.example (nao sobrescreve)
if [[ ! -f "${CONFIG_DIR}/.env" ]]; then
  if [[ -f "${REPO_DIR}/.env.example" ]]; then
    cp "${REPO_DIR}/.env.example" "${CONFIG_DIR}/.env"
    green "  ✓ .env criado a partir do template"
  fi
fi

echo ""
echo "============================================="
green "  Instalacao concluida!"
echo "============================================="
echo ""
echo "Proximos passos:"
echo "  1. Edite ${CONFIG_DIR}/opencode.jsonc com suas chaves de API"
echo "  2. Reinicie o OpenCode"
echo "  3. Teste com: @qa-engineer ola"
echo ""
