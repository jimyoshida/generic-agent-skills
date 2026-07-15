# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A **source/distribution** repository for reusable AI-assistant skills. The skills
authored here are meant to be *installed* into user-level scopes — they do **not**
run from this repo. Consequently:

- Skill sources live under `.agents/skills/<name>/`, **not** `.claude/skills/`.
  Putting a skill in `.claude/skills/` here would make Claude Code load it as a
  project skill (wrong for this repo) — author new skills under `.agents/skills/`.
- `.agents/` is deliberate: `Install-Skill.ps1` reads from `.agents/skills/` and
  the shared install target for Copilot is `~/.agents/skills`.

## Install pipeline

`Install-Skill.ps1` (PowerShell 7+) copies every skill directory from
`.agents/skills/` into user-level scopes. A "skill" is any immediate subdirectory
of `.agents/skills/` that contains a `SKILL.md`. Targets:

- Claude Code → `~/.claude/skills`
- GitHub Copilot → `~/.copilot/skills` **and** `~/.agents/skills`

```powershell
./Install-Skill.ps1                       # install to both (default)
./Install-Skill.ps1 -Target ClaudeCode    # Claude Code only
./Install-Skill.ps1 -Force                # overwrite existing (default is skip)
./Install-Skill.ps1 -WhatIf               # dry run, no changes
```

By default existing skills are **skipped**, not overwritten — use `-Force` to sync
edits to already-installed copies.

## Authoring a skill

Each skill is a directory with a `SKILL.md` whose YAML frontmatter drives
discovery. Convention observed across existing skills:

- `name` (required, kebab-case) and `description` (required) — the `description`
  is trigger-heavy: it lists the exact user phrases/keywords that should activate
  the skill, since that string is what the assistant matches on.
- Optional: `version`, `allowed-tools` (restrict tool access).

Bundled helper scripts go in the skill's own `scripts/` directory. Reference them
**relative to the skill directory** (e.g. `<this-skill-dir>/scripts/foo.py`), not
via a hardcoded `~/.claude/...` path — the same source installs to three different
locations, so a hardcoded scope path breaks under Copilot/shared targets.

## Testing a skill

There is no build/lint/test framework. To test, install the skill (`-Force`) and
invoke it in an assistant session, or run its helper script directly, e.g.:

```bash
python .agents/skills/wikitext-fetcher/scripts/get_wikitext.py "<url>"
```
