# claude-issue-description

Agent skill that turns technical work into **ready-to-paste markdown** for task managers and dev teams.

**Tool-agnostic.** No APIs, no vendor-specific formatting. Works with Trello, Linear, Jira, GitHub Issues, Notion, Slack, email, or any text field.

## Command

One slash command, two types:

```
/issue                    # stakeholder incident (default)
/issue desc               # same — CTO / Trello update
/issue desc postmortem    # critical failure — client-facing report
/issue tech               # developer issue body
/issue tech bug           # technical bug report
/issue desc en incident   # English stakeholder incident
/issue tech pt pr         # Portuguese PR technical summary
```

| Type | Aliases | Audience |
|------|---------|----------|
| `desc` | `description` | Stakeholders (CTO, PM, ops) |
| `tech` | `dev` | Developers |

### `desc` modes

`incident` (default), `postmortem`, `deploy`, `pr`, `commit`, `diff`

Use `postmortem` only for critical production failures that require formal communication to customers.

Sections: what happened, why, impact, how we fixed it, prevention.

### `tech` modes

`bug` (default), `task`, `pr`, `commit`, `diff`

Sections: summary, repro steps, expected vs actual, root cause, fix, developer notes, checklist.

## Language

**Automatic by default** — matches your session language.

**Override** with a language token:

```
/issue desc pt
/issue desc postmortem
/issue tech pt
/issue desc --lang=es
```

Supported: `en`, `pt`, `pt-br`, `es`, `--lang=<code>`.

## Output

By default, `/issue` **always writes** to `tmp/issue-<slug>.md` (or `tmp/pr-<slug>.md` for PR content) in the current project and replies with the file path only — optimized for copy-paste into Trello, GitHub, Linear, etc.

Opt out only when explicitly requested (e.g. "no tmp", "show in chat").

## Context sources

1. Current conversation
2. Git status + diff
3. Last commit
4. Open PR (`gh pr view` / `gh pr diff`)

## Install

**This repo is the single source of truth.** Do not edit `~/.claude/skills/issue` by hand — install or refresh from here.

```bash
git clone https://github.com/thadeu/claude-issue-description ~/code/claude-issue-description
~/code/claude-issue-description/install.sh
```

Symlinks:

- `~/.claude/skills/issue` → `skills/issue`
- `~/.claude/commands/issue.md` → `commands/issue.md`

### Verify install

```bash
~/code/claude-issue-description/install.sh check
```

Exits `0` when symlinks point at this repo; exits `1` with fix instructions when out of sync (copied files, wrong symlink target, or missing install).

After `git pull`, run `install.sh` again (or `install.sh check` first).

### Alternative — `npx skills add` (skill only, no `/issue` command)

```bash
npx skills add thadeu/claude-issue-description -g -a claude-code -a cursor -y
```

Prefer `install.sh` when you want the `/issue` slash command and a explicit sync check against this repo.

## Layout

```
claude-issue-description/
├── skills/issue/SKILL.md   # source of truth
├── commands/issue.md
├── examples.md
├── install.sh              # install | check | help
└── README.md
```

## License

MIT
