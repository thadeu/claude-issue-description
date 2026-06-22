#!/usr/bin/env bash
# claude-issue-description — installer
#
# Symlinks this repo into Claude Code discovery paths:
#   ~/.claude/skills/issue-description  → skills/issue-description
#   ~/.claude/commands/issue            → commands/  (/issue:* slash commands)
#
# Re-run safely: existing symlinks are replaced.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SKILL_DIR="$CLAUDE_DIR/skills/issue-description"
COMMANDS_DIR="$CLAUDE_DIR/commands/issue"

GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
NC=$'\033[0m'

log()  { printf '%s[issue-description]%s %s\n' "$GREEN" "$NC" "$*"; }
warn() { printf '%s[issue-description]%s %s\n' "$YELLOW" "$NC" "$*"; }
err()  { printf '%s[issue-description]%s %s\n' "$RED" "$NC" "$*" >&2; }

link() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    local existing
    existing="$(readlink "$dst")"
    if [[ "$existing" == "$src" ]]; then
      log "already linked: $dst"
      return 0
    fi
    warn "replacing symlink: $dst (was → $existing)"
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    err "$dst already exists and is not a symlink. Move it aside and re-run."
    exit 1
  fi

  ln -s "$src" "$dst"
  log "linked $dst → $src"
}

log "installing from $REPO_DIR"
link "$REPO_DIR/skills/issue-description" "$SKILL_DIR"
link "$REPO_DIR/commands"              "$COMMANDS_DIR"

cat <<EOF

${GREEN}Done.${NC}

Try in Claude Code or Cursor:
  /issue:description
  /issue:description postmortem
  /issue:description deploy

Or ask: "gera uma description pro card do que fizemos"
EOF
