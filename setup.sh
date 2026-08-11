#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
GLOBAL_DIR="${HOME}/.config/opencode"
MODE="interactive"
USE_SYMLINK=false

for arg in "$@"; do
  case "$arg" in
    --auto) MODE="auto" ;;
    --project) MODE="project" ;;
    --merge) MODE="merge" ;;
    --symlink) USE_SYMLINK=true ;;
    --help|-h)
      cat <<'EOF'
Uso: bash setup.sh [opcao]

  sem opcao    instalacao global interativa
  --auto       instalacao global sem perguntas
  --merge      instala apenas arquivos ausentes
  --project    instala no projeto atual
  --symlink    usa symlinks na instalacao global
  --help       mostra esta ajuda
EOF
      exit 0
      ;;
    *) echo "Opcao desconhecida: $arg" >&2; exit 2 ;;
  esac
done

green()  { printf '\033[32m%s\033[0m\n' "$1"; }
yellow() { printf '\033[33m%s\033[0m\n' "$1"; }
red()    { printf '\033[31m%s\033[0m\n' "$1"; }
blue()   { printf '\033[34m%s\033[0m\n' "$1"; }

ask_replace() {
  local target="$1"
  [[ ! -e "$target" ]] && return 0
  [[ "$MODE" == "auto" ]] && return 0
  [[ "$MODE" == "merge" ]] && return 1
  read -rp "Substituir ${target}? [s/N]: " answer
  [[ "${answer:-N}" =~ ^[Ss]$ ]]
}

install_file() {
  local src="$1" target="$2"
  mkdir -p "$(dirname "$target")"
  if ! ask_replace "$target"; then
    yellow "  preservado: $target"
    return 0
  fi
  if [[ -e "$target" && ! -L "$target" ]]; then
    cp "$target" "${target}.bak"
  fi
  if $USE_SYMLINK && [[ "$MODE" != "project" ]]; then
    ln -sfn "$src" "$target"
  else
    cp "$src" "$target"
  fi
  green "  instalado: $target"
}

install_tree() {
  local src_dir="$1" target_dir="$2"
  mkdir -p "$target_dir"
  while IFS= read -r -d '' src; do
    local rel="${src#${src_dir}/}"
    install_file "$src" "${target_dir}/${rel}"
  done < <(find "$src_dir" -type f -print0)
}

if [[ "$MODE" == "project" ]]; then
  ROOT="$(pwd)"
  blue "Instalacao project-level em ${ROOT}"
  install_file "${REPO_DIR}/opencode.json" "${ROOT}/opencode.json"
  install_tree "${REPO_DIR}/.opencode/agents" "${ROOT}/.opencode/agents"
  install_tree "${REPO_DIR}/.opencode/skills" "${ROOT}/.opencode/skills"
else
  blue "Instalacao global em ${GLOBAL_DIR}"
  mkdir -p "$GLOBAL_DIR"
  install_file "${REPO_DIR}/opencode.json" "${GLOBAL_DIR}/opencode.json"
  install_tree "${REPO_DIR}/.opencode/agents" "${GLOBAL_DIR}/agents"
  install_tree "${REPO_DIR}/.opencode/skills" "${GLOBAL_DIR}/skills"
fi

echo ""
blue "MCPs opcionais:"
if [[ -n "${BRAVE_API_KEY:-}" ]]; then
  green "  BRAVE_API_KEY encontrada"
else
  yellow "  BRAVE_API_KEY ausente: brave-search podera falhar ate a variavel ser exportada"
fi
if [[ -n "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]]; then
  green "  GITHUB_PERSONAL_ACCESS_TOKEN encontrado"
else
  yellow "  GITHUB_PERSONAL_ACCESS_TOKEN ausente: GitHub MCP podera falhar ate a variavel ser exportada"
fi

echo ""
blue "Validando repositorio..."
if bash "${REPO_DIR}/scripts/validate.sh"; then
  green "Configuracao instalada e validada."
else
  red "A validacao encontrou problemas. Revise a saida acima."
  exit 1
fi

echo ""
echo "Modelos esperados:"
echo "  openai/gpt-5.6-luna"
echo "  openai/gpt-5.6-terra"
echo "  opencode/deepseek-v4-flash-free"
echo ""
echo "Confirme com: opencode models"
echo "Autenticacao: use 'opencode auth login' para OpenAI/OpenCode Zen quando necessario."
