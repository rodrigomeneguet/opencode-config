#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
GLOBAL_DIR="${HOME}/.config/opencode"
GLOBAL_BACKUP_DIR="${HOME}/.config/opencode-backups"
MODE="interactive"
USE_SYMLINK=false
LAST_BACKUP_DIR=""

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
      cat <<'HELP'
Uso: bash setup.sh [opcao]

  sem opcao    instalacao global interativa
  --auto       instalacao global sem perguntas
  --merge      instala apenas arquivos ausentes
  --project    instala no projeto atual
  --symlink    usa symlinks na instalacao global
  --help       mostra esta ajuda

Todo modo cria um backup timestampado ANTES de limpar, mesclar ou perguntar
sobre sobrescrita. O backup nao pode ser desativado pelo instalador.
HELP
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

  [[ -f "${REPO_DIR}/opencode.json" ]] || { red "  fonte AUSENTE: opencode.json"; missing=$((missing + 1)); }

  for name in "${EXPECTED_AGENTS[@]}"; do
    if [[ -f "${REPO_DIR}/.opencode/agents/${name}.md" ]]; then
      green "  fonte OK: ${name}"
    else
      red "  fonte AUSENTE: ${name}"
      missing=$((missing + 1))
    fi
  done

  for name in "${EXPECTED_SKILLS[@]}"; do
    if [[ -f "${REPO_DIR}/.opencode/skills/${name}/SKILL.md" ]]; then
      green "  skill OK: ${name}"
    else
      red "  skill AUSENTE: ${name}"
      missing=$((missing + 1))
    fi
  done

  if [[ "$missing" -gt 0 ]]; then
    echo ""
    red "Seu clone local nao contem toda a topologia v2.1. Instalacao abortada."
    echo "  git fetch origin"
    echo "  git checkout feat/orchestration-v2"
    echo "  git pull --ff-only origin feat/orchestration-v2"
    echo "  bash setup.sh"
    exit 1
  fi
}

backup_current_config() {
  local root="$1"
  local scope="$2"
  local timestamp backup_base backup_dir copied=0

  timestamp="$(date '+%Y%m%d-%H%M%S')-$$"

  if [[ "$scope" == "project" ]]; then
    backup_base="${root}/.opencode-backups"
  else
    backup_base="$GLOBAL_BACKUP_DIR"
  fi

  backup_dir="${backup_base}/${timestamp}"
  mkdir -p "$backup_dir"

  {
    echo "opencode-config backup"
    echo "created_at=$(date -Iseconds 2>/dev/null || date)"
    echo "scope=${scope}"
    echo "source=${root}"
    echo "installer_repo=${REPO_DIR}"
  } > "${backup_dir}/BACKUP_INFO.txt"

  if [[ "$scope" == "project" ]]; then
    for item in opencode.json opencode.jsonc AGENTS.md .opencode; do
      if [[ -e "${root}/${item}" || -L "${root}/${item}" ]]; then
        cp -a "${root}/${item}" "$backup_dir/"
        copied=$((copied + 1))
      fi
    done
  else
    if [[ -d "$root" ]]; then
      mkdir -p "${backup_dir}/config"
      cp -a "${root}/." "${backup_dir}/config/"
      copied=1
    fi
  fi

  if [[ "$copied" -eq 0 ]]; then
    echo "No previous OpenCode configuration was found." >> "${backup_dir}/BACKUP_INFO.txt"
    yellow "Backup criado, mas nao havia configuracao anterior para copiar."
  else
    green "Backup obrigatorio criado: ${backup_dir}"
  fi

  LAST_BACKUP_DIR="$backup_dir"
}

ask_replace() {
  local target="$1"
  [[ ! -e "$target" && ! -L "$target" ]] && return 0
  [[ "$MODE" == "auto" ]] && return 0
  [[ "$MODE" == "merge" ]] && return 1

  local answer
  read -rp "Substituir ${target}? [S/n]: " answer </dev/tty
  [[ ! "${answer:-S}" =~ ^[Nn]$ ]]
}

install_file() {
  local src="$1" target="$2"
  mkdir -p "$(dirname "$target")"

  if ! ask_replace "$target"; then
    yellow "  preservado: $target"
    return 0
  fi

  # Mantem tambem o .bak imediato por conveniencia, alem do snapshot completo.
  if [[ -e "$target" && ! -L "$target" ]]; then
    cp -a "$target" "${target}.bak"
  fi

  if $USE_SYMLINK && [[ "$MODE" != "project" ]]; then
    ln -sfn "$src" "$target"
  else
    cp -a "$src" "$target"
  fi

  green "  instalado: $target"
}

install_managed_files() {
  local agents_dir="$1"
  local skills_dir="$2"
  local name

  mkdir -p "$agents_dir" "$skills_dir"

  # Instalacao orientada pelo inventario esperado. Evita loops dependentes de stdin.
  for name in "${EXPECTED_AGENTS[@]}"; do
    install_file "${REPO_DIR}/.opencode/agents/${name}.md" "${agents_dir}/${name}.md"
  done

  for name in "${EXPECTED_SKILLS[@]}"; do
    install_file "${REPO_DIR}/.opencode/skills/${name}/SKILL.md" "${skills_dir}/${name}/SKILL.md"
  done
}

cleanup_legacy_agents() {
  local target_dir="$1"
  local removed=0
  local filename
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
  local name

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
    red "Backup preservado em: ${LAST_BACKUP_DIR}"
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

  # O backup acontece antes de qualquer limpeza ou pergunta de sobrescrita.
  backup_current_config "$ROOT" "project"

  cleanup_legacy_agents "$AGENTS_DIR"
  install_file "${REPO_DIR}/opencode.json" "${ROOT}/opencode.json"
  install_managed_files "$AGENTS_DIR" "$SKILLS_DIR"
  verify_installation "$ROOT" "$AGENTS_DIR" "$SKILLS_DIR"
else
  ROOT="$GLOBAL_DIR"
  AGENTS_DIR="${GLOBAL_DIR}/agents"
  SKILLS_DIR="${GLOBAL_DIR}/skills"

  blue "Instalacao global em ${GLOBAL_DIR}"

  # O backup acontece antes de mkdir/cleanup/install e independe da escolha do usuario.
  backup_current_config "$ROOT" "global"

  mkdir -p "$GLOBAL_DIR"
  cleanup_legacy_agents "${GLOBAL_DIR}/agents"
  cleanup_legacy_agents "${GLOBAL_DIR}/.opencode/agents"
  install_file "${REPO_DIR}/opencode.json" "${GLOBAL_DIR}/opencode.json"
  install_managed_files "$AGENTS_DIR" "$SKILLS_DIR"
  verify_installation "$ROOT" "$AGENTS_DIR" "$SKILLS_DIR"
fi

echo ""
blue "MCPs opcionais:"
[[ -n "${BRAVE_API_KEY:-}" ]] && green "  BRAVE_API_KEY encontrada" || yellow "  BRAVE_API_KEY ausente"
[[ -n "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]] && green "  GITHUB_PERSONAL_ACCESS_TOKEN encontrado" || yellow "  GITHUB_PERSONAL_ACCESS_TOKEN ausente"

echo ""
blue "Validando repositorio..."
if bash "${REPO_DIR}/scripts/validate.sh"; then
  green "Configuracao instalada e validada."
else
  red "A validacao encontrou problemas."
  red "Backup preservado em: ${LAST_BACKUP_DIR}"
  exit 1
fi

echo ""
green "Backup pre-instalacao: ${LAST_BACKUP_DIR}"
echo "Primarios esperados no seletor: luna-lead, terra-planner"
echo "Subagentes: deepseek-worker, luna-worker, terra-diagnostician, strategic-advisor"
echo "Oculto: luna-worker-xhigh"
