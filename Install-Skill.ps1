#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Installs this repository's skills into user-level AI coding assistant scopes.

.DESCRIPTION
    Copies every skill directory found under <repo>/.agents/skills into the
    user-level skills directories for Claude Code and/or GitHub Copilot.
    Each skill is a folder that contains a SKILL.md file.

    Target locations:
    - Claude Code: ~/.claude/skills
    - GitHub Copilot: ~/.copilot/skills and ~/.agents/skills

.PARAMETER Target
    Which AI coding assistant(s) to install skills for.
    Valid values: 'ClaudeCode', 'GitHubCopilot', 'Both' (default).

.PARAMETER Force
    Overwrite skills that already exist in the destination without prompting.

.PARAMETER WhatIf
    Show what would be copied without making any changes.

.EXAMPLE
    ./Install-Skill.ps1

.EXAMPLE
    ./Install-Skill.ps1 -Target ClaudeCode -Force

.EXAMPLE
    ./Install-Skill.ps1 -Target GitHubCopilot
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet('ClaudeCode', 'GitHubCopilot', 'Both')]
    [string]$Target = 'Both',

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Source: .agents/skills relative to this script
$SourceDir = Join-Path $PSScriptRoot '.agents/skills'

# Destination directories based on target
$DestDirs = @()
if ($Target -in 'ClaudeCode', 'Both') {
    $DestDirs += @{
        Name = 'Claude Code'
        Path = Join-Path $HOME '.claude/skills'
    }
}
if ($Target -in 'GitHubCopilot', 'Both') {
    $DestDirs += @{
        Name = 'GitHub Copilot (primary)'
        Path = Join-Path $HOME '.copilot/skills'
    }
    $DestDirs += @{
        Name = 'GitHub Copilot (shared)'
        Path = Join-Path $HOME '.agents/skills'
    }
}

if (-not (Test-Path -LiteralPath $SourceDir)) {
    throw "Source skills directory not found: $SourceDir"
}

# A skill is any immediate subdirectory of the source that contains a SKILL.md.
$skills = Get-ChildItem -LiteralPath $SourceDir -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') }

if (-not $skills) {
    Write-Warning "No skills (directories containing SKILL.md) found in $SourceDir"
    return
}

$totalInstalled = 0
$totalSkipped   = 0

foreach ($destInfo in $DestDirs) {
    $destDir = $destInfo.Path
    $destName = $destInfo.Name

    if (-not (Test-Path -LiteralPath $destDir)) {
        if ($PSCmdlet.ShouldProcess($destDir, 'Create directory')) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
    }

    Write-Host "`nTarget: $destName" -ForegroundColor Magenta
    Write-Host "Installing $($skills.Count) skill(s) to $destDir" -ForegroundColor Cyan

    $installed = 0
    $skipped   = 0

    foreach ($skill in $skills) {
        $targetPath = Join-Path $destDir $skill.Name

        if ((Test-Path -LiteralPath $targetPath) -and -not $Force) {
            Write-Host "  [skip] $($skill.Name) (already exists; use -Force to overwrite)" -ForegroundColor Yellow
            $skipped++
            continue
        }

        if ($PSCmdlet.ShouldProcess($targetPath, "Copy skill '$($skill.Name)' to $destName")) {
            if (Test-Path -LiteralPath $targetPath) {
                Remove-Item -LiteralPath $targetPath -Recurse -Force
            }
            Copy-Item -LiteralPath $skill.FullName -Destination $targetPath -Recurse -Force
            Write-Host "  [ok]   $($skill.Name)" -ForegroundColor Green
            $installed++
        }
    }

    $totalInstalled += $installed
    $totalSkipped   += $skipped
}

Write-Host "`nDone. Total installed: $totalInstalled, Total skipped: $totalSkipped" -ForegroundColor Cyan
