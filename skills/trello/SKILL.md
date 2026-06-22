---
name: trello
description: >-
  Generate short, non-technical summaries ready to paste into any task manager
  or chat (Trello, Linear, Jira, GitHub Issues, Notion, Slack, email, CTO
  updates). Use when the user types /trello:description, asks for a card
  description, issue description, postmortem, incident summary, or wants to
  explain a fix to a non-technical leader. Tool-agnostic — outputs plain
  markdown only. Pulls context from the current conversation, git diff, last
  commit, or open PR.
disable-model-invocation: true
argument-hint: "[postmortem|incident|deploy|pr|commit|diff]"
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git rev-parse:*), Bash(gh pr view:*), Bash(gh pr diff:*)
---

# trello — summaries for non-technical audiences

Turn technical work into a short update a CTO or PM can read in under a minute.

**Tool-agnostic.** Output is plain markdown — paste into Trello, Linear, Jira, GitHub Issues, Notion, Slack, email, or any card description field. No tool-specific syntax or API.

The slash command `/trello:description` is optional sugar. If it is not installed, run the same flow from natural-language triggers in the description above.

## Audience

Write for a **technical leader who is not in the weeds** — CTO, head of product, ops lead.

- Plain language. No jargon unless unavoidable; define it in one line when needed.
- Short sentences. No code blocks unless the user explicitly asks.
- Focus on **what happened**, **who was affected**, **why**, and **how we fixed it**.
- Portuguese by default when the user writes in Portuguese; English when they write in English.

## Context sources (use all that apply)

Priority order:

1. **Current conversation** — the main source. What was investigated, found, and changed.
2. **Git working tree** — uncommitted/staged changes when the work is not committed yet.
3. **Last commit** — when the fix is already committed.
4. **Open PR** — when the user mentions a PR or `$ARGUMENTS` contains `pr`.

Do not invent facts. If something is unclear, say what is known and mark the gap briefly.

### Git context (run when in a git repo)

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
git status --short 2>/dev/null
git log -1 --format='%h %s%n%b' 2>/dev/null
git diff --stat 2>/dev/null
git diff --staged --stat 2>/dev/null
```

### PR context (only when relevant)

```bash
gh pr view --json title,body,url,commits 2>/dev/null
gh pr diff 2>/dev/null
```

## Mode selection

Use `$ARGUMENTS` or infer from the conversation:

| Mode | When | Title prefix |
|------|------|--------------|
| `postmortem` | default — bug/incident already fixed or mitigated | Postmortem |
| `incident` | ongoing or just resolved production issue | Incidente |
| `deploy` | shipping a fix or feature, no incident framing | Deploy |
| `pr` | summarize an open/merged PR | PR |
| `commit` | summarize only the last commit | — |
| `diff` | summarize only uncommitted changes | — |

## Output format

Return **only** the ready-to-paste text. No preamble like "here is your description".

Default template (`postmortem` / `incident`):

```markdown
## [Postmortem|Incidente|Deploy] — <short title>

**O que aconteceu**
<1–3 sentences — symptom in user/business terms>

**Por quê**
<1–3 sentences — root cause in plain language, no stack traces>

**Impacto**
<who/what was affected; severity; duration if known>

**Como resolvemos**
1. **Imediato:** <hotfix, manual DB change, rollback, etc.>
2. **Definitivo:** <code change, deploy, process fix>

**Prevenção**
<what stops this from recurring — deploy pending, test added, monitoring, etc.>
```

Shorter variant when the user asks for "poucas palavras" or Slack:

```markdown
**Resumo:** <one line>

**Causa:** <one line>

**Fix:** <one line>

**Status:** <resolved | mitigated | deploy pending>
```

## Writing rules

- **O que aconteceu** = what the user/customer saw, not which controller failed.
- **Por quê** = the conflicting rules, missing check, or bad assumption — not line numbers.
- **Imediato vs Definitivo** = separate band-aid from permanent fix when both exist.
- Do not include secrets, customer PII, or internal URLs unless the user provided them.
- Keep the whole postmortem under ~150 words unless the user asks for more detail.
- Never add tool-specific fields (Trello labels, Jira custom fields, Linear project IDs).

## Examples

See [examples.md](../../examples.md) for a full reference postmortem.

## Workflow

1. Read the conversation and `$ARGUMENTS`.
2. Gather git/PR context if in a repo and it adds facts not already in the chat.
3. Pick the mode and template.
4. Write the summary once, paste-ready.
5. Do not ask follow-up questions unless critical facts are missing (e.g. impact unknown).
