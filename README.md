# claude-issue-description

Agent skill that turns technical work into **ready-to-paste markdown** for task managers and dev teams.

**Tool-agnostic.** No APIs, no vendor-specific formatting. Works with Trello, Linear, Jira, GitHub Issues, Notion, Slack, email, or any text field.

## Command

One slash command, two types:

```
/issue                    # stakeholder summary (default)
/issue desc postmortem    # same, explicit type
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

`postmortem` (default), `incident`, `deploy`, `pr`, `commit`, `diff`

Sections: what happened, why, impact, how we fixed it, prevention.

### `tech` modes

`bug` (default), `task`, `pr`, `commit`, `diff`

Sections: summary, repro steps, expected vs actual, root cause, fix, developer notes, checklist.

## Language

**Automatic by default** — matches your session language.

**Override** with a language token:

```
/issue en desc postmortem
/issue tech pt
/issue desc --lang=es
```

Supported: `en`, `pt`, `pt-br`, `es`, `--lang=<code>`.

## Context sources

1. Current conversation
2. Git status + diff
3. Last commit
4. Open PR (`gh pr view` / `gh pr diff`)

## Install

### Option A — `npx skills add` (skill only)

```bash
npx skills add thadeu/claude-issue-description -g -a claude-code -a cursor -y
```

### Option B — `install.sh` (skill + `/issue` slash command)

```bash
git clone https://github.com/thadeu/claude-issue-description ~/code/claude-issue-description
~/code/claude-issue-description/install.sh
```

Symlinks:

- `~/.claude/skills/issue` → `skills/issue`
- `~/.claude/commands/issue.md` → `commands/issue.md`

Re-run `install.sh` after `git pull`.

## Layout

```
claude-issue-description/
├── skills/issue/SKILL.md
├── commands/issue.md
├── examples.md
├── install.sh
└── README.md
```

## License

MIT
