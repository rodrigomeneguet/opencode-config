#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
GLOBAL_DIR="${HOME}/.config/opencode"
MODE="interactive"
USE_SYMLINK=false

EXPECTED_AGENTS=(
  "luna-lead"
  "terra-planner"
  "deepseek-worker"
  "luna-worker"
  "luna-worker-xhigh"
  "terra-diagnostician"
  "strategic-advisor"
)

EXPECTED_SKILLS=(
  "infra-operations"
  "security-review"
  "software-testing"
  "backend-engineering"
  "frontend-engineering"
)

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

show_source_version() {
  blue "Fonte da configuracao: ${REPO_DIR}"
  if command -v git >/dev/null 2>&1 && git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local branch commit
    branch="$(git -C "$REPO_DIR" branch --show-current 2>/dev/null || true)"
    commit="$(git -C "$REPO_DIR" rev-parse --short HEAD 2>/dev/null || true)"
    echo "  branch: ${branch:-detached}"
    echo "  commit: ${commit:-desconhecido}"
  fi
}

preflight_source() {
  local missing=0

  blue "Preflight da v2.1"
  for name in "${EXPECTED_AGENTS[@]}"; do
    if [[ -f "${REPO_DIR}/.opencode/agents/${name}.md" ]]; then
      green "  fonte OK: ${name}"
    else
      red "  fonte AUSENTE: ${name}"
      missing=$((missing + 1))
    fi
  done

  if [[ "$missing" -gt 0 ]]; then
    echo ""
    red "Seu clone local nao contem todos os agentes da v2.1. Instalacao abortada para evitar uma configuracao parcial."
    echo ""
    echo "Atualize a branch e tente novamente:"
    echo "  git fetch origin"
    echo "  git checkout feat/orchestration-v2"
    echo "  git pull --ff-only origin feat/orchestration-v2"
    echo "  bash setup.sh"
    exit 1
  fi
}

ask_replace() {
  local target="$1"
  [[ ! -e "$target" ]] && return 0
  [[ "$MODE" == "auto" ]] && return 0
  [[ "$MODE" == "merge" ]] && return 1

  local answer
  read -rp "Substituir ${target}? [S/n]: " answer
  [[ ! "${answer:-S}" =~ ^[Nn]$ ]]
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

cleanup_legacy_agents() {
  local target_dir="$1"
  local removed=0
  local legacy_agents=(
    "qa-engineer.md"
    "cybersecurity.md"
    "devops.md"
    "backend.md"
    "frontend.md"
    "luna-operator.md"
    "terra-lead.md"
  )

  [[ -d "$target_dir" ]] || return 0

  for filename in "${legacy_agents[@]}"; do
    if [[ -e "${target_dir}/${filename}" || -L "${target_dir}/${filename}" ]]; then
      rm -f "${target_dir}/${filename}"
      yellow "  removido agente legado: ${target_dir}/${filename}"
      removed=$((removed + 1))
    fi
  done

  if [[ "$removed" -gt 0 ]]; then
    green "  limpeza concluida: ${removed} agente(s) legado(s) removido(s)"
  fi
}

verify_installation() {
  local root="$1"
  local agents_dir="$2"
  local skills_dir="$3"
  local errors=0

  echo ""
  blue "Verificando instalacao efetiva"

  if [[ ! -f "${root}/opencode.json" ]]; then
    red "  AUSENTE: ${root}/opencode.json"
    errors=$((errors + 1))
  elif ! grep -q '"default_agent"[[:space:]]*:[[:space:]]*"luna-lead"' "${root}/opencode.json"; then
    red "  opencode.json instalado nao aponta para luna-lead"
    errors=$((errors + 1))
  else
    green "  default_agent: luna-lead"
  fi

  for name in "${EXPECTED_AGENTS[@]}"; do
    if [[ -f "${agents_dir}/${name}.md" || -L "${agents_dir}/${name}.md" ]]; then
      green "  agente instalado: ${name}"
    else
      red "  agente AUSENTE no destino: ${name}"
      errors=$((errors + 1))
    fi
  done

  for name in "${EXPECTED_SKILLS[@]}"; do
    if [[ -f "${skills_dir}/${name}/SKILL.md" || -L "${skills_dir}/${name}/SKILL.md" ]]; then
      green "  skill instalada: ${name}"
    else
      red "  skill AUSENTE no destino: ${name}"
      errors=$((errors + 1))
    fi
  done

  if [[ "$errors" -gt 0 ]]; then
    echo ""
    red "Instalacao incompleta: ${errors} item(ns) esperado(s) ausente(s)."
    red "O setup nao vai reportar sucesso enquanto a topologia v2.1 nao estiver completa."
    exit 1
  fi

  green "Topologia v2.1 instalada por completo."
}

show_source_version
preflight_source

echo ""

if [[ "$MODE" == "project" ]]; then
  ROOT="$(pwd)"
  AGENTS_DIR="${ROOT}/.opencode/agents"
  SKILLS_DIR="${ROOT}/.opencode/skills"

  blue "Instalacao project-level em ${ROOT}"
  cleanup_legacy_agents "$AGENTS_DIR"
  install_file "${REPO_DIR}/opencode.json" "${ROOT}/opencode.json"
  install_tree "${REPO_DIR}/.opencode/agents" "$AGENTS_DIR"
  install_tree "${REPO_DIR}/.opencode/skills" "$SKILLS_DIR"
  verify_installation "$ROOT" "$AGENTS_DIR" "$SKILLS_DIR"
else
  ROOT="$GLOBAL_DIR"
  AGENTS_DIR="${GLOBAL_DIR}/agents"
  SKILLS_DIR="${GLOBAL_DIR}/skills"

  blue "Instalacao global em ${GLOBAL_DIR}"
  mkdir -p "$GLOBAL_DIR"

  cleanup_legacy_agents "${GLOBAL_DIR}/agents"
  cleanup_legacy_agents "${GLOBAL_DIR}/.opencode/agents"

  install_file "${REPO_DIR}/opencode.json" "${GLOBAL_DIR}/opencode.json"
  install_tree "${REPO_DIR}/.opencode/agents" "$AGENTS_DIR"
  install_tree "${REPO_DIR}/.opencode/skills" "$SKILLS_DIR"
  verify_installation "$ROOT" "$AGENTS_DIR" "$SKILLS_DIR"
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
echo "Primarios esperados no seletor:"
echo "  luna-lead"
echo "  terra-planner"
echo ""
echo "Subagentes esperados:"
echo "  deepseek-worker"
echo "  luna-worker"
echo "  terra-diagnostician"
echo "  strategic-advisor"
echo ""
echo "Subagente oculto esperado:"
echo "  luna-worker-xhigh"
echo ""
echo "Confirme modelos com: opencode models"
echo "Autenticacao: use 'opencode auth login' para OpenAI/OpenCode Zen quando necessario."
