# Instalacao e backup

Este repositorio possui instaladores para ambientes Unix/WSL e Windows nativo.

## Principio de seguranca

**Toda execucao do instalador cria um backup antes de qualquer alteracao.**

O backup acontece antes de:

- remover agentes legados conhecidos;
- copiar o novo `opencode.json`;
- instalar agentes ou skills;
- perguntar se um arquivo existente pode ser sobrescrito;
- aplicar `--merge` / `-Merge`.

Nao existe opcao para desativar esse backup no instalador.

Isso significa que ate uma execucao em que o usuario responda **Nao** para todas as sobrescritas deixa um snapshot do estado anterior.

## O que e preservado

### Instalacao global

O snapshot inclui toda a arvore existente de:

```text
~/.config/opencode/
```

Linux, macOS e WSL salvam em:

```text
~/.config/opencode-backups/YYYYMMDD-HHMMSS-PID/
```

PowerShell nativo usa o equivalente dentro de `$HOME`:

```text
$HOME\.config\opencode-backups\YYYYMMDD-HHMMSS-PID\
```

Cada snapshot contem `BACKUP_INFO.txt` com timestamp, escopo e origem.

### Instalacao em projeto

No modo project-level o instalador preserva, se existirem:

```text
opencode.json
opencode.jsonc
AGENTS.md
.opencode/
```

O snapshot fica em:

```text
<projeto>/.opencode-backups/YYYYMMDD-HHMMSS-PID/
```

`.opencode-backups/` e ignorado pelo Git para evitar versionamento acidental.

## Linux / macOS / WSL

O OpenCode recomenda WSL para a melhor experiencia no Windows. Nesse caso use o instalador Bash normalmente.

```bash
git clone https://github.com/rodrigomeneguet/opencode-config.git
cd opencode-config
git checkout feat/orchestration-v2
bash setup.sh
```

Modos:

```bash
bash setup.sh              # global interativo
bash setup.sh --auto       # global sem perguntas
bash setup.sh --merge      # preserva arquivos existentes
bash setup.sh --symlink    # usa symlinks na instalacao global
bash setup.sh --project    # instala no projeto atual
```

O backup e criado em todos os modos.

## Windows PowerShell nativo

Abra PowerShell no clone do repositorio e execute:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\setup.ps1
```

Modos:

```powershell
.\setup.ps1               # global interativo
.\setup.ps1 -Auto         # global sem perguntas
.\setup.ps1 -Merge        # preserva arquivos existentes
.\setup.ps1 -Project      # instala no projeto atual
```

O instalador usa o caminho global documentado pelo OpenCode, equivalente a:

```text
~/.config/opencode/
```

em `$HOME`.

## Garantias dos dois instaladores

Ambos realizam:

1. preflight do inventario esperado;
2. backup obrigatorio do estado atual;
3. limpeza apenas dos agentes legados conhecidos deste repositorio;
4. instalacao explicita dos agentes e skills gerenciados;
5. verificacao de `default_agent: luna-lead`;
6. verificacao de todos os 7 agentes;
7. verificacao das 5 skills;
8. exibicao do caminho do backup ao final.

## Agentes esperados

```text
luna-lead
terra-planner
deepseek-worker
luna-worker
luna-worker-xhigh
terra-diagnostician
strategic-advisor
```

`luna-worker-xhigh` permanece oculto no seletor do OpenCode, mas deve existir no filesystem.

## Restauracao manual

O instalador nao restaura automaticamente para evitar substituir configuracoes sem intencao explicita.

Para restaurar, feche o OpenCode e copie o conteudo do snapshot desejado de volta para o local original.

Em uma instalacao global Unix/WSL, por exemplo:

```bash
rm -rf ~/.config/opencode
cp -a ~/.config/opencode-backups/<snapshot>/config ~/.config/opencode
```

Em Windows, use `Copy-Item -Recurse -Force` a partir do snapshot equivalente.

Antes de restaurar, e recomendavel criar mais um backup do estado corrente.
