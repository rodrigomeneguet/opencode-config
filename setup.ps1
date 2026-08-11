[CmdletBinding()]
param(
    [switch]$Auto,
    [switch]$Merge,
    [switch]$Project
)

$ErrorActionPreference = 'Stop'

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$GlobalDir = Join-Path $HOME '.config\opencode'
$GlobalBackupDir = Join-Path $HOME '.config\opencode-backups'
$Script:LastBackupDir = $null

$ExpectedAgents = @(
    'luna-lead',
    'terra-planner',
    'deepseek-worker',
    'luna-worker',
    'luna-worker-xhigh',
    'terra-diagnostician',
    'strategic-advisor'
)

$ExpectedSkills = @(
    'infra-operations',
    'security-review',
    'software-testing',
    'backend-engineering',
    'frontend-engineering'
)

$LegacyAgents = @(
    'qa-engineer.md',
    'cybersecurity.md',
    'devops.md',
    'backend.md',
    'frontend.md',
    'luna-operator.md',
    'terra-lead.md'
)

function Write-Info([string]$Message) { Write-Host $Message -ForegroundColor Cyan }
function Write-Ok([string]$Message) { Write-Host $Message -ForegroundColor Green }
function Write-Warn([string]$Message) { Write-Host $Message -ForegroundColor Yellow }
function Write-Fail([string]$Message) { Write-Host $Message -ForegroundColor Red }

function Show-SourceVersion {
    Write-Info "Fonte da configuracao: $RepoDir"

    if (Get-Command git -ErrorAction SilentlyContinue) {
        try {
            $branch = (& git -C $RepoDir branch --show-current 2>$null).Trim()
            $commit = (& git -C $RepoDir rev-parse --short HEAD 2>$null).Trim()
            if ($branch) { Write-Host "  branch: $branch" }
            if ($commit) { Write-Host "  commit: $commit" }
        }
        catch {
            Write-Warn '  nao foi possivel identificar branch/commit local'
        }
    }
}

function Test-Source {
    $missing = 0
    Write-Info 'Preflight da v2.1'

    $configSource = Join-Path $RepoDir 'opencode.json'
    if (Test-Path -LiteralPath $configSource) {
        Write-Ok '  fonte OK: opencode.json'
    }
    else {
        Write-Fail '  fonte AUSENTE: opencode.json'
        $missing++
    }

    foreach ($name in $ExpectedAgents) {
        $path = Join-Path $RepoDir ".opencode\agents\$name.md"
        if (Test-Path -LiteralPath $path) {
            Write-Ok "  fonte OK: $name"
        }
        else {
            Write-Fail "  fonte AUSENTE: $name"
            $missing++
        }
    }

    foreach ($name in $ExpectedSkills) {
        $path = Join-Path $RepoDir ".opencode\skills\$name\SKILL.md"
        if (Test-Path -LiteralPath $path) {
            Write-Ok "  skill OK: $name"
        }
        else {
            Write-Fail "  skill AUSENTE: $name"
            $missing++
        }
    }

    if ($missing -gt 0) {
        Write-Host ''
        Write-Fail 'Seu clone local nao contem toda a topologia v2.1. Instalacao abortada.'
        Write-Host 'Atualize a branch e execute novamente:'
        Write-Host '  git fetch origin'
        Write-Host '  git checkout feat/orchestration-v2'
        Write-Host '  git pull --ff-only origin feat/orchestration-v2'
        Write-Host '  .\setup.ps1'
        exit 1
    }
}

function New-ConfigBackup {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][ValidateSet('global','project')][string]$Scope
    )

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupBase = if ($Scope -eq 'project') {
        Join-Path $Root '.opencode-backups'
    }
    else {
        $GlobalBackupDir
    }

    $backupDir = Join-Path $backupBase "$timestamp-$PID"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

    @(
        'opencode-config backup',
        "created_at=$([DateTime]::Now.ToString('o'))",
        "scope=$Scope",
        "source=$Root",
        "installer_repo=$RepoDir"
    ) | Set-Content -LiteralPath (Join-Path $backupDir 'BACKUP_INFO.txt') -Encoding UTF8

    $copied = $false

    if ($Scope -eq 'project') {
        foreach ($item in @('opencode.json', 'opencode.jsonc', 'AGENTS.md', '.opencode')) {
            $source = Join-Path $Root $item
            if (Test-Path -LiteralPath $source) {
                Copy-Item -LiteralPath $source -Destination $backupDir -Recurse -Force
                $copied = $true
            }
        }
    }
    else {
        if (Test-Path -LiteralPath $Root) {
            $configBackup = Join-Path $backupDir 'config'
            New-Item -ItemType Directory -Path $configBackup -Force | Out-Null

            Get-ChildItem -LiteralPath $Root -Force | ForEach-Object {
                Copy-Item -LiteralPath $_.FullName -Destination $configBackup -Recurse -Force
            }
            $copied = $true
        }
    }

    if (-not $copied) {
        Add-Content -LiteralPath (Join-Path $backupDir 'BACKUP_INFO.txt') -Value 'No previous OpenCode configuration was found.'
        Write-Warn 'Backup criado, mas nao havia configuracao anterior para copiar.'
    }
    else {
        Write-Ok "Backup obrigatorio criado: $backupDir"
    }

    $Script:LastBackupDir = $backupDir
}

function Should-Replace {
    param([Parameter(Mandatory = $true)][string]$Target)

    if (-not (Test-Path -LiteralPath $Target)) { return $true }
    if ($Auto) { return $true }
    if ($Merge) { return $false }

    $answer = Read-Host "Substituir $Target? [S/n]"
    return ($answer -notmatch '^[Nn]$')
}

function Install-File {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Target
    )

    $parent = Split-Path -Parent $Target
    New-Item -ItemType Directory -Path $parent -Force | Out-Null

    if (-not (Should-Replace -Target $Target)) {
        Write-Warn "  preservado: $Target"
        return
    }

    if (Test-Path -LiteralPath $Target) {
        Copy-Item -LiteralPath $Target -Destination "$Target.bak" -Force
    }

    Copy-Item -LiteralPath $Source -Destination $Target -Force
    Write-Ok "  instalado: $Target"
}

function Install-ManagedFiles {
    param(
        [Parameter(Mandatory = $true)][string]$AgentsDir,
        [Parameter(Mandatory = $true)][string]$SkillsDir
    )

    New-Item -ItemType Directory -Path $AgentsDir -Force | Out-Null
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null

    foreach ($name in $ExpectedAgents) {
        Install-File `
            -Source (Join-Path $RepoDir ".opencode\agents\$name.md") `
            -Target (Join-Path $AgentsDir "$name.md")
    }

    foreach ($name in $ExpectedSkills) {
        Install-File `
            -Source (Join-Path $RepoDir ".opencode\skills\$name\SKILL.md") `
            -Target (Join-Path $SkillsDir "$name\SKILL.md")
    }
}

function Remove-LegacyAgents {
    param([Parameter(Mandatory = $true)][string]$TargetDir)

    if (-not (Test-Path -LiteralPath $TargetDir)) { return }

    $removed = 0
    foreach ($file in $LegacyAgents) {
        $path = Join-Path $TargetDir $file
        if (Test-Path -LiteralPath $path) {
            Remove-Item -LiteralPath $path -Force
            Write-Warn "  removido agente legado: $path"
            $removed++
        }
    }

    if ($removed -gt 0) {
        Write-Ok "  limpeza concluida: $removed agente(s) legado(s) removido(s)"
    }
}

function Test-InstalledTopology {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$AgentsDir,
        [Parameter(Mandatory = $true)][string]$SkillsDir
    )

    $errors = 0
    Write-Host ''
    Write-Info 'Verificando instalacao efetiva'

    $config = Join-Path $Root 'opencode.json'
    if (-not (Test-Path -LiteralPath $config)) {
        Write-Fail "  AUSENTE: $config"
        $errors++
    }
    else {
        $content = Get-Content -LiteralPath $config -Raw
        if ($content -match '"default_agent"\s*:\s*"luna-lead"') {
            Write-Ok '  default_agent: luna-lead'
        }
        else {
            Write-Fail '  opencode.json instalado nao aponta para luna-lead'
            $errors++
        }
    }

    foreach ($name in $ExpectedAgents) {
        $path = Join-Path $AgentsDir "$name.md"
        if (Test-Path -LiteralPath $path) {
            Write-Ok "  agente instalado: $name"
        }
        else {
            Write-Fail "  agente AUSENTE no destino: $name"
            $errors++
        }
    }

    foreach ($name in $ExpectedSkills) {
        $path = Join-Path $SkillsDir "$name\SKILL.md"
        if (Test-Path -LiteralPath $path) {
            Write-Ok "  skill instalada: $name"
        }
        else {
            Write-Fail "  skill AUSENTE no destino: $name"
            $errors++
        }
    }

    if ($errors -gt 0) {
        Write-Host ''
        Write-Fail "Instalacao incompleta: $errors item(ns) esperado(s) ausente(s)."
        Write-Fail "Backup preservado em: $Script:LastBackupDir"
        exit 1
    }

    Write-Ok 'Topologia v2.1 instalada por completo.'
}

Show-SourceVersion
Test-Source
Write-Host ''

if ($Project) {
    $Root = (Get-Location).Path
    $AgentsDir = Join-Path $Root '.opencode\agents'
    $SkillsDir = Join-Path $Root '.opencode\skills'

    Write-Info "Instalacao project-level em $Root"

    # Backup sempre acontece antes de limpeza, merge ou prompt de sobrescrita.
    New-ConfigBackup -Root $Root -Scope 'project'

    Remove-LegacyAgents -TargetDir $AgentsDir
    Install-File -Source (Join-Path $RepoDir 'opencode.json') -Target (Join-Path $Root 'opencode.json')
    Install-ManagedFiles -AgentsDir $AgentsDir -SkillsDir $SkillsDir
    Test-InstalledTopology -Root $Root -AgentsDir $AgentsDir -SkillsDir $SkillsDir
}
else {
    $Root = $GlobalDir
    $AgentsDir = Join-Path $GlobalDir 'agents'
    $SkillsDir = Join-Path $GlobalDir 'skills'

    Write-Info "Instalacao global em $GlobalDir"

    # Backup sempre acontece antes de limpeza, merge ou prompt de sobrescrita.
    New-ConfigBackup -Root $Root -Scope 'global'

    New-Item -ItemType Directory -Path $GlobalDir -Force | Out-Null
    Remove-LegacyAgents -TargetDir (Join-Path $GlobalDir 'agents')
    Remove-LegacyAgents -TargetDir (Join-Path $GlobalDir '.opencode\agents')
    Install-File -Source (Join-Path $RepoDir 'opencode.json') -Target (Join-Path $GlobalDir 'opencode.json')
    Install-ManagedFiles -AgentsDir $AgentsDir -SkillsDir $SkillsDir
    Test-InstalledTopology -Root $Root -AgentsDir $AgentsDir -SkillsDir $SkillsDir
}

Write-Host ''
Write-Info 'MCPs opcionais:'
if ($env:BRAVE_API_KEY) { Write-Ok '  BRAVE_API_KEY encontrada' } else { Write-Warn '  BRAVE_API_KEY ausente' }
if ($env:GITHUB_PERSONAL_ACCESS_TOKEN) { Write-Ok '  GITHUB_PERSONAL_ACCESS_TOKEN encontrado' } else { Write-Warn '  GITHUB_PERSONAL_ACCESS_TOKEN ausente' }

Write-Host ''
Write-Ok "Backup pre-instalacao: $Script:LastBackupDir"
Write-Host 'Primarios esperados no seletor: luna-lead, terra-planner'
Write-Host 'Subagentes: deepseek-worker, luna-worker, terra-diagnostician, strategic-advisor'
Write-Host 'Oculto: luna-worker-xhigh'
