#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Installs this repository's skills into the user-level Claude Code scope.

.DESCRIPTION
    Copies every skill directory found under <repo>/.agents/skills into the
    user-level skills directory (~/.claude/skills). Each skill is a folder that
    contains a SKILL.md file.

.PARAMETER Force
    Overwrite skills that already exist in the destination without prompting.

.PARAMETER WhatIf
    Show what would be copied without making any changes.

.EXAMPLE
    ./install-skills.ps1

.EXAMPLE
    ./install-skills.ps1 -Force
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Source: .agents/skills relative to this script. Destination: user-level scope.
$SourceDir = Join-Path $PSScriptRoot '.agents/skills'
$DestDir   = Join-Path $HOME '.claude/skills'

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

if (-not (Test-Path -LiteralPath $DestDir)) {
    if ($PSCmdlet.ShouldProcess($DestDir, 'Create directory')) {
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }
}

Write-Host "Installing $($skills.Count) skill(s) to $DestDir" -ForegroundColor Cyan

$installed = 0
$skipped   = 0

foreach ($skill in $skills) {
    $target = Join-Path $DestDir $skill.Name

    if ((Test-Path -LiteralPath $target) -and -not $Force) {
        Write-Host "  [skip] $($skill.Name) (already exists; use -Force to overwrite)" -ForegroundColor Yellow
        $skipped++
        continue
    }

    if ($PSCmdlet.ShouldProcess($target, "Copy skill '$($skill.Name)'")) {
        if (Test-Path -LiteralPath $target) {
            Remove-Item -LiteralPath $target -Recurse -Force
        }
        Copy-Item -LiteralPath $skill.FullName -Destination $target -Recurse -Force
        Write-Host "  [ok]   $($skill.Name)" -ForegroundColor Green
        $installed++
    }
}

Write-Host ""
Write-Host "Done. Installed: $installed, Skipped: $skipped" -ForegroundColor Cyan
