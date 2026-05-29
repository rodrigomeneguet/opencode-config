#!/usr/bin/env bash
# setup.sh — Instalacao idempotente do opencode-config
# Copia configuracao e agentes para ~/.config/opencode/.opencode/
# Uso: bash setup.sh [--symlink] [--project]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="${HOME}/.config/opencode"
USE_SYMLINK=false
PROJECT_MODE=false

for arg in "$@"; do
  case "$arg" in
    --symlink) USE_SYMLINK=true ;;
    --project) PROJECT_MODE=true ;;
  esac
done

green() { printf "\033[32m%s\033[0m\n" "$1"; }
yellow(){ printf "\033[33m%s\033[0m\n" "$1"; }
blue()  { printf "\033[34m%s\033[0m\n" "$1"; }

echo "============================================="
if ${PROJECT_MODE}; then
  echo "  Instalacao opencode-config (projeto-level)"
  echo "  Copiando para .opencode/ no diretorio atual"
else
  echo "  Instalacao opencode-config (global)"
  echo "  Modo: $(${USE_SYMLINK} && echo 'symlink' || echo 'copia')"
fi
echo "============================================="
echo ""

if ${PROJECT_MODE}; then
  # Modo projeto: copia para .opencode/ no CWD
  TARGET_DIR="$(pwd)/.opencode"
  mkdir -p "${TARGET_DIR}/agents"

  blue "Instalando agentes em ${TARGET_DIR}/agents/..."
  for agent in "${REPO_DIR}"/.opencode/agents/*.md; do
    filename="$(basename "$agent")"
    if ${USE_SYMLINK}; then
      ln -sf "$agent" "${TARGET_DIR}/agents/${filename}"
    else
      cp -u "$agent" "${TARGET_DIR}/agents/${filename}"
    fi
    green "  ✓ ${filename}"
  done

  # Copiar opencode.json para o CWD se nao existir
  if [[ ! -f "$(pwd)/opencode.json" ]]; then
    cp "${REPO_DIR}/opencode.json" "$(pwd)/opencode.json"
    green "  ✓ opencode.json copiado para o projeto"
  else
    yellow "  ⚠ opencode.json ja existe no projeto — pulando"
  fi

else
  # Modo global: copia para ~/.config/opencode/
  mkdir -p "${CONFIG_DIR}/.opencode/agents"

  # Copiar/symlink opencode.json
  blue "Instalando opencode.json..."
  if [[ -f "${CONFIG_DIR}/opencode.json" ]]; then
    yellow "  ⚠ opencode.json ja existe em ${CONFIG_DIR}/ — pulando"
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
  for agent in "${REPO_DIR}"/.opencode/agents/*.md; do
    filename="$(basename "$agent")"
    if ${USE_SYMLINK}; then
      ln -sf "$agent" "${CONFIG_DIR}/.opencode/agents/${filename}"
    else
      cp -u "$agent" "${CONFIG_DIR}/.opencode/agents/${filename}"
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
fi

echo ""
echo "============================================="
green "  Instalacao concluida!"
echo "============================================="
echo ""
if ${PROJECT_MODE}; then
  echo "Proximos passos:"
  echo "  1. Edite opencode.jsonc com suas chaves de API (se necessario)"
  echo "  2. Reinicie o OpenCode"
  echo "  3. Teste com: @qa-engineer ola"
else
  echo "Proximos passos:"
  echo "  1. Edite ${CONFIG_DIR}/opencode.jsonc com suas chaves de API"
  echo "  2. Reinicie o OpenCode"
  echo "  3. Teste com: @qa-engineer ola"
fi
echo ""
