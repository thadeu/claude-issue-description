#!/usr/bin/env bash
# claude-issue-description — installer
#
# Symlinks:
#   ~/.claude/skills/issue        → skills/issue
#   ~/.claude/commands/issue.md   → commands/issue.md  (/issue slash command)
#
# Re-run safely: existing symlinks are replaced.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SKILL_DIR="$CLAUDE_DIR/skills/issue"
COMMAND_FILE="$CLAUDE_DIR/commands/issue.md"

GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
NC=$'\033[0m'

log()  { printf '%s[issue]%s %s\n' "$GREEN" "$NC" "$*"; }
warn() { printf '%s[issue]%s %s\n' "$YELLOW" "$NC" "$*"; }
err()  { printf '%s[issue]%s %s\n' "$RED" "$NC" "$*" >&2; }

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

cleanup_legacy() {
  rm -f "$CLAUDE_DIR/commands/issue/desc.md" \
        "$CLAUDE_DIR/commands/issue/description.md" \
        "$CLAUDE_DIR/commands/issue/tech.md" 2>/dev/null || true
  rmdir "$CLAUDE_DIR/commands/issue" 2>/dev/null || true
  rm -f "$CLAUDE_DIR/skills/issue-description" 2>/dev/null || true
  rm -rf "$CLAUDE_DIR/skills/issue-description" 2>/dev/null || true
}

log "installing from $REPO_DIR"
cleanup_legacy
link "$REPO_DIR/skills/issue"       "$SKILL_DIR"
link "$REPO_DIR/commands/issue.md"  "$COMMAND_FILE"

cat <<EOF

${GREEN}Done.${NC}

Try:
  /issue
  /issue desc postmortem
  /issue tech
  /issue tech en bug
EOF
