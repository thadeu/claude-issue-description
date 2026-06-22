# claude-trello

Agent skill that turns technical work into **short, plain-language updates** for stakeholders.

**Tool-agnostic.** The output is plain markdown — paste it into Trello, Linear, Jira, GitHub Issues, Notion, Slack, email, or any card description field. The `/trello:` namespace is just the slash-command name; nothing is Trello-specific.

## What it does

Given the current conversation (and optionally git diff, last commit, or open PR), it writes a ready-to-paste summary for a **non-technical audience** — CTO, PM, ops lead.

Typical use cases:

- Postmortem after a production incident
- Card description for a bug or task
- Slack thread summary
- Deploy note for leadership

## Install

### Option A — `npx skills add` (skill only)

```bash
npx skills add thadeu/claude-trello -g -a claude-code -a cursor -y
```

### Option B — `install.sh` (skill + `/trello:description` slash command)

```bash
git clone https://github.com/thadeu/claude-trello ~/code/claude-trello
~/code/claude-trello/install.sh
```

Symlinks:

- `~/.claude/skills/trello` → `skills/trello`
- `~/.claude/commands/trello` → `commands/`

Re-run `install.sh` after `git pull` to pick up slash-command changes.

## Usage

```
/trello:description
/trello:description postmortem
/trello:description incident
/trello:description deploy
/trello:description pr
/trello:description commit
/trello:description diff
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
claude-trello/
├── skills/trello/SKILL.md   # main skill (npx skills add entrypoint)
├── commands/description.md  # /trello:description slash command
├── examples.md              # reference outputs
├── install.sh               # symlink installer for slash commands
└── README.md
```

## License

MIT
