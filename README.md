# claude-issue-description

Agent skill that turns technical work into **short, plain-language updates** for stakeholders.

**Tool-agnostic.** The output is plain markdown — paste it into Trello, Linear, Jira, GitHub Issues, Notion, Slack, email, or any card description field.

## What it does

Given the current conversation (and optionally git diff, last commit, or open PR), it writes a ready-to-paste summary for a **non-technical audience** — CTO, PM, ops lead.

Typical use cases:

- Postmortem after a production incident
- Card / issue description for a bug or task
- Slack thread summary
- Deploy note for leadership

## Install

### Option A — `npx skills add` (skill only)

```bash
npx skills add thadeu/claude-issue-description -g -a claude-code -a cursor -y
```

### Option B — `install.sh` (skill + `/issue:description` slash command)

```bash
git clone https://github.com/thadeu/claude-issue-description ~/code/claude-issue-description
~/code/claude-issue-description/install.sh
```

Symlinks:

- `~/.claude/skills/issue-description` → `skills/issue-description`
- `~/.claude/commands/issue` → `commands/`

Re-run `install.sh` after `git pull` to pick up slash-command changes.

## Usage

```
/issue:description
/issue:description postmortem
/issue:description incident
/issue:description deploy
/issue:description pr
/issue:description commit
/issue:description diff
```

Natural language also works:

- "gera uma description pro card"
- "postmortem pro CTO do que aconteceu"
- "resumo pro Slack do fix"
- "issue description for Linear"

## Context sources

The agent uses, in order:

1. Current conversation
2. Git status + diff (uncommitted changes)
3. Last commit
4. Open PR (`gh pr view` / `gh pr diff`) when relevant

## Output

Plain markdown. No API calls, no tool-specific formatting. Works anywhere that accepts text.

Default sections (postmortem):

- **O que aconteceu** — symptom in user/business terms
- **Por quê** — root cause in plain language
- **Impacto** — who was affected
- **Como resolvemos** — immediate fix + permanent fix
- **Prevenção** — what stops recurrence

Shorter variant available for Slack or one-liner updates.

## Layout

```
claude-issue-description/
├── skills/issue-description/SKILL.md
├── commands/description.md       # /issue:description
├── examples.md
├── install.sh
└── README.md
```

## License

MIT
