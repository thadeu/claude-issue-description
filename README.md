# claude-issue-description

Agent skill that turns technical work into **ready-to-paste markdown** for task managers and dev teams.

**Tool-agnostic.** No APIs, no vendor-specific formatting. Works with Trello, Linear, Jira, GitHub Issues, Notion, Slack, email, or any text field.

## Commands

| Command | Audience | Output |
|---------|----------|--------|
| `/issue:desc` | Stakeholders (CTO, PM, ops) | Short plain-language summary |
| `/issue:description` | Same as `/issue:desc` | Alias |
| `/issue:tech` | Developers | Technical body with repro steps and checklist |

## Language

**Automatic by default** — output matches the language you use in the session.

**Override** by passing a language token in arguments:

```
/issue:desc en postmortem
/issue:tech pt
/issue:desc --lang=es
```

Supported shortcuts: `en`, `pt`, `pt-br`, `es`, or `--lang=<code>`.

## What it does

Pulls context from the current conversation and, when useful:

1. Git status + diff (uncommitted changes)
2. Last commit
3. Open PR (`gh pr view` / `gh pr diff`)

### `/issue:desc` — stakeholder summary

For non-technical readers. Typical sections:

- **What happened** — symptom in user/business terms
- **Why** — root cause in plain language
- **Impact** — who was affected
- **How we fixed it** — immediate + permanent fix
- **Prevention** — what stops recurrence

Modes: `postmortem` (default), `incident`, `deploy`, `pr`, `commit`, `diff`.

### `/issue:tech` — developer issue body

For engineers picking up the ticket. Includes:

- Summary
- Steps to reproduce
- Expected vs actual behavior
- Root cause (files, controllers, data state)
- Fix
- Developer notes
- Checklist

Modes: `bug` (default), `task`, `pr`, `commit`, `diff`.

## Install

### Option A — `npx skills add` (skill only)

```bash
npx skills add thadeu/claude-issue-description -g -a claude-code -a cursor -y
```

### Option B — `install.sh` (skill + slash commands)

```bash
git clone https://github.com/thadeu/claude-issue-description ~/code/claude-issue-description
~/code/claude-issue-description/install.sh
```

Symlinks:

- `~/.claude/skills/issue-description` → `skills/issue-description`
- `~/.claude/commands/issue` → `commands/`

Re-run `install.sh` after `git pull`.

## Usage

```
/issue:desc
/issue:desc postmortem
/issue:desc en incident
/issue:description deploy
/issue:tech
/issue:tech pr
/issue:tech pt bug
```

Natural language also works:

- "write an issue description for the card"
- "postmortem for the CTO"
- "technical issue body with repro steps"
- "slack summary of the fix"

## Layout

```
claude-issue-description/
├── skills/issue-description/SKILL.md
├── commands/
│   ├── desc.md          # /issue:desc
│   ├── description.md   # /issue:description (alias)
│   └── tech.md          # /issue:tech
├── examples.md
├── install.sh
└── README.md
```

## License

MIT
