#!/usr/bin/env bash
#
# Installs this repository's skills into user-level AI coding assistant scopes.
#
# Copies every skill directory found under <repo>/.agents/skills into the
# user-level skills directories for Claude Code and/or GitHub Copilot.
# Each skill is a folder that contains a SKILL.md file.
#
# Target locations:
#   - Claude Code:    ~/.claude/skills
#   - GitHub Copilot: ~/.copilot/skills and ~/.agents/skills
#
# Usage:
#   ./install-skill.sh [-t|--target ClaudeCode|GitHubCopilot|Both] [-f|--force] [-n|--dry-run] [-h|--help]
#
# Examples:
#   ./install-skill.sh
#   ./install-skill.sh --target ClaudeCode --force
#   ./install-skill.sh --target GitHubCopilot

set -euo pipefail

TARGET='Both'
FORCE=0
DRY_RUN=0

usage() {
    cat <<'EOF'
Usage: install-skill.sh [-t|--target ClaudeCode|GitHubCopilot|Both] [-f|--force] [-n|--dry-run] [-h|--help]

Options:
  -t, --target <name>   Which AI coding assistant(s) to install skills for.
                         Valid values: ClaudeCode, GitHubCopilot, Both (default).
  -f, --force            Overwrite skills that already exist in the destination.
  -n, --dry-run          Show what would be copied without making any changes.
  -h, --help             Show this help message.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--target)
            TARGET="${2:-}"
            shift 2
            ;;
        -f|--force)
            FORCE=1
            shift
            ;;
        -n|--dry-run|--WhatIf)
            DRY_RUN=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

case "$TARGET" in
    ClaudeCode|GitHubCopilot|Both) ;;
    *)
        echo "Invalid -t/--target value: $TARGET (expected ClaudeCode, GitHubCopilot, or Both)" >&2
        exit 1
        ;;
esac

# Colors (disabled if not a terminal)
if [[ -t 1 ]]; then
    C_MAGENTA=$'\033[35m'
    C_CYAN=$'\033[36m'
    C_YELLOW=$'\033[33m'
    C_GREEN=$'\033[32m'
    C_RESET=$'\033[0m'
else
    C_MAGENTA=''; C_CYAN=''; C_YELLOW=''; C_GREEN=''; C_RESET=''
fi

# Source: .agents/skills relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/.agents/skills"

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Source skills directory not found: $SOURCE_DIR" >&2
    exit 1
fi

# Destination directories based on target
dest_names=()
dest_paths=()
if [[ "$TARGET" == 'ClaudeCode' || "$TARGET" == 'Both' ]]; then
    dest_names+=('Claude Code')
    dest_paths+=("$HOME/.claude/skills")
fi
if [[ "$TARGET" == 'GitHubCopilot' || "$TARGET" == 'Both' ]]; then
    dest_names+=('GitHub Copilot (primary)')
    dest_paths+=("$HOME/.copilot/skills")
    dest_names+=('GitHub Copilot (shared)')
    dest_paths+=("$HOME/.agents/skills")
fi

# A skill is any immediate subdirectory of the source that contains a SKILL.md.
skills=()
for dir in "$SOURCE_DIR"/*/; do
    [[ -d "$dir" ]] || continue
    if [[ -f "${dir}SKILL.md" ]]; then
        skills+=("$(basename "$dir")")
    fi
done

if [[ ${#skills[@]} -eq 0 ]]; then
    echo "Warning: No skills (directories containing SKILL.md) found in $SOURCE_DIR" >&2
    exit 0
fi

total_installed=0
total_skipped=0

for i in "${!dest_paths[@]}"; do
    dest_dir="${dest_paths[$i]}"
    dest_name="${dest_names[$i]}"

    if [[ ! -d "$dest_dir" ]]; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "What if: Performing the operation \"Create directory\" on target \"$dest_dir\"."
        else
            mkdir -p "$dest_dir"
        fi
    fi

    echo ""
    echo "${C_MAGENTA}Target: $dest_name${C_RESET}"
    echo "${C_CYAN}Installing ${#skills[@]} skill(s) to $dest_dir${C_RESET}"

    installed=0
    skipped=0

    for skill in "${skills[@]}"; do
        src_path="$SOURCE_DIR/$skill"
        target_path="$dest_dir/$skill"

        if [[ -e "$target_path" && "$FORCE" -ne 1 ]]; then
            echo "${C_YELLOW}  [skip] $skill (already exists; use --force to overwrite)${C_RESET}"
            skipped=$((skipped + 1))
            continue
        fi

        if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "What if: Performing the operation \"Copy skill '$skill' to $dest_name\" on target \"$target_path\"."
            installed=$((installed + 1))
            continue
        fi

        if [[ -e "$target_path" ]]; then
            rm -rf "$target_path"
        fi
        cp -R "$src_path" "$target_path"
        echo "${C_GREEN}  [ok]   $skill${C_RESET}"
        installed=$((installed + 1))
    done

    total_installed=$((total_installed + installed))
    total_skipped=$((total_skipped + skipped))
done

echo ""
echo "${C_CYAN}Done. Total installed: $total_installed, Total skipped: $total_skipped${C_RESET}"
