# generic-agent-skills

A collection of reusable skills for AI coding assistants (Claude Code, GitHub Copilot).

Skills are modular capabilities that extend AI coding assistants with specialized knowledge and workflows. This repository provides a curated set of skills that can be installed into your user-level configuration.

## Installation

Use the [Install-Skill.ps1](Install-Skill.ps1) script to copy skills from this repository into your AI coding assistant's configuration:

```powershell
# Install to both Claude Code and GitHub Copilot (default)
./Install-Skill.ps1

# Install to Claude Code only
./Install-Skill.ps1 -Target ClaudeCode

# Install to GitHub Copilot only
./Install-Skill.ps1 -Target GitHubCopilot

# Force overwrite existing skills
./Install-Skill.ps1 -Force

# Preview what would be installed
./Install-Skill.ps1 -WhatIf
```

### Requirements

- PowerShell 7.0 or later
- Windows, macOS, or Linux

### Installation Locations

The script installs skills to the following user-level directories:

- **Claude Code**: `~/.claude/skills`
- **GitHub Copilot**: `~/.copilot/skills` and `~/.agents/skills`

## Available Skills

Skills are located in [.agents/skills/](.agents/skills/). Each skill is a directory containing a `SKILL.md` file with the skill definition.

## Skill Structure

Each skill follows this structure:

```text
.agents/skills/
└── skill-name/
    ├── SKILL.md          # Skill definition and instructions
    └── [other files]     # Optional: examples, templates, etc.
```

## Development

To add a new skill to this repository:

1. Create a directory under `.agents/skills/` with your skill name
2. Add a `SKILL.md` file with skill metadata and instructions
3. Test the skill locally before committing
4. Use `./Install-Skill.ps1` to install it to your user configuration

## License

See individual skill directories for licensing information.
