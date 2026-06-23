#!/usr/bin/env bash
# claude-issue-description — installer
#
# Symlinks:
#   ~/.claude/skills/issue        → skills/issue
#   ~/.claude/commands/issue.md   → commands/issue.md  (/issue slash command)
#
# Usage:
#   ./install.sh          # install or refresh symlinks
#   ./install.sh check    # verify install matches this repo

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SKILL_DIR="$CLAUDE_DIR/skills/issue"
COMMAND_FILE="$CLAUDE_DIR/commands/issue.md"
SKILL_SRC="$REPO_DIR/skills/issue"
COMMAND_SRC="$REPO_DIR/commands/issue.md"

GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
NC=$'\033[0m'

log()  { printf '%s[issue]%s %s\n' "$GREEN" "$NC" "$*"; }
warn() { printf '%s[issue]%s %s\n' "$YELLOW" "$NC" "$*"; }
err()  { printf '%s[issue]%s %s\n' "$RED" "$NC" "$*" >&2; }

resolve_path() {
  local link="$1"
  local target

  if [[ ! -L "$link" ]]; then
    echo ""
    return 1
  fi

  target="$(readlink "$link")"

  if [[ "$target" != /* ]]; then
    target="$(cd "$(dirname "$link")" && cd "$target" && pwd)"
  fi

  if [[ -L "$target" ]]; then
    resolve_path "$target"
    return
  fi

  if [[ -f "$target" ]]; then
    echo "$(cd "$(dirname "$target")" && pwd)/$(basename "$target")"
  elif [[ -d "$target" ]]; then
    echo "$(cd "$target" && pwd)"
  else
    echo "$target"
  fi
}

repo_revision() {
  git -C "$REPO_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown"
}

check_symlink() {
  local label="$1"
  local dst="$2"
  local expected_src="$3"
  local status=0

  if [[ ! -e "$dst" && ! -L "$dst" ]]; then
    err "$label not installed: $dst"
    return 1
  fi

  if [[ -L "$dst" ]]; then
    local resolved expected
    resolved="$(resolve_path "$dst")"
    expected="$(cd "$(dirname "$expected_src")" && pwd)/$(basename "$expected_src")"

    if [[ "$resolved" == "$expected" ]]; then
      log "OK $label → $expected_src"
      return 0
    fi

    err "$label out of sync"
    err "  installed: $dst → $(readlink "$dst")"
    err "  expected:  $dst → $expected_src"
    return 1
  fi

  if [[ -f "$dst" ]] && diff -q "$expected_src" "$dst" >/dev/null 2>&1; then
    warn "$label is a regular file (content matches repo, but not symlinked)"
    warn "  run ./install.sh to link $dst → $expected_src"
    return 1
  fi

  if [[ -d "$dst" ]] && diff -q "$expected_src/SKILL.md" "$dst/SKILL.md" >/dev/null 2>&1; then
    warn "$label is a copied directory (content matches repo, but not symlinked)"
    warn "  run ./install.sh to link $dst → $expected_src"
    return 1
  fi

  err "$label exists but does not match repo: $dst"
  err "  run ./install.sh to link → $expected_src"
  return 1
}

cmd_check() {
  local failed=0
  local rev
  rev="$(repo_revision)"

  log "checking install against repo $REPO_DIR @ $rev"

  check_symlink "skill"   "$SKILL_DIR"    "$SKILL_SRC"    || failed=1
  check_symlink "command" "$COMMAND_FILE" "$COMMAND_SRC"  || failed=1

  if [[ "$failed" -eq 0 ]]; then
    log "install is up to date"
    exit 0
  fi

  err "install is out of date — run: $REPO_DIR/install.sh"
  exit 1
}

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

cmd_install() {
  log "installing from $REPO_DIR @ $(repo_revision)"
  cleanup_legacy
  link "$SKILL_SRC"   "$SKILL_DIR"
  link "$COMMAND_SRC" "$COMMAND_FILE"

  cat <<EOF

${GREEN}Done.${NC}

Verify anytime:
  $REPO_DIR/install.sh check

Try:
  /issue
  /issue desc
  /issue desc postmortem
  /issue tech
  /issue tech en bug
EOF
}

case "${1:-install}" in
  check)
    cmd_check
    ;;
  install|--install|"")
    cmd_install
    ;;
  -h|--help|help)
    cat <<EOF
Usage: install.sh [command]

Commands:
  install   Link skill and /issue command to this repo (default)
  check     Verify ~/.claude install matches this repo
  help      Show this help
EOF
    ;;
  *)
    err "unknown command: $1 (try: install, check, help)"
    exit 1
    ;;
esac
