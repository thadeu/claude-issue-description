---
name: issue-description
description: >-
  Generate issue descriptions from conversation, git diff, commits, or PRs.
  /issue:desc (or /issue:description) writes plain-language summaries for
  stakeholders. /issue:tech writes technical notes for developers (repro steps,
  root cause, checklist). Tool-agnostic markdown for Trello, Linear, Jira,
  GitHub Issues, Notion, Slack, or email. Language follows the session by
  default; override with en, pt, es, or --lang=xx in arguments.
disable-model-invocation: true
argument-hint: "[en|pt|es|--lang=xx] [postmortem|incident|deploy|pr|commit|diff]"
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git rev-parse:*), Bash(gh pr view:*), Bash(gh pr diff:*)
---

# issue-description

Turn technical work into ready-to-paste markdown for task managers or dev teams.

**Tool-agnostic.** No APIs, no vendor-specific fields. Paste anywhere that accepts text.

## Commands

| Command | Audience | Output |
|---------|----------|--------|
| `/issue:desc` | Stakeholders (CTO, PM, ops) | Short plain-language summary |
| `/issue:description` | Same as `/issue:desc` | Alias |
| `/issue:tech` | Developers | Technical issue body with repro steps and checklist |

If slash commands are not installed, natural-language triggers in the skill description still work.

## Language

**Default: automatic.** Match the language the user writes in during the session.

**Override:** pass a language as the first argument (before the mode):

| Argument | Language |
|----------|----------|
| `en`, `english` | English |
| `pt`, `pt-br`, `portuguese` | Portuguese |
| `es`, `spanish` | Spanish |
| `--lang=en`, `--lang=pt` | Explicit flag (any ISO-style code) |

Examples:

```
/issue:desc pt postmortem
/issue:tech en
/issue:desc --lang=es incident
```

Section headings and body text must both use the selected language.

## Context sources

Priority order:

1. **Current conversation**
2. **Git working tree** — uncommitted/staged changes
3. **Last commit**
4. **Open PR** — when the user mentions a PR or mode is `pr`

Do not invent facts. Mark unknowns briefly.

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

---

## `/issue:desc` — stakeholder summary

### Audience

Technical leader who is **not** in the weeds — CTO, head of product, ops lead.

- Plain language. Minimal jargon.
- No code blocks unless the user asks.
- Focus on what happened, who was affected, why, and how it was fixed.
- Keep under ~150 words unless the user asks for more.

### Modes

Use `$ARGUMENTS` (after stripping the language token) or infer from context:

| Mode | When | Title prefix |
|------|------|--------------|
| `postmortem` | default — fixed or mitigated bug/incident | Postmortem |
| `incident` | ongoing or just resolved production issue | Incident |
| `deploy` | shipping a fix or feature | Deploy |
| `pr` | summarize an open/merged PR | PR |
| `commit` | last commit only | — |
| `diff` | uncommitted changes only | — |

### Template (English)

```markdown
## [Postmortem|Incident|Deploy] — <short title>

**What happened**
<1–3 sentences — symptom in user/business terms>

**Why**
<1–3 sentences — root cause in plain language, no stack traces>

**Impact**
<who/what was affected; severity; duration if known>

**How we fixed it**
1. **Immediate:** <hotfix, manual DB change, rollback, etc.>
2. **Permanent:** <code change, deploy, process fix>

**Prevention**
<what stops recurrence — deploy pending, test added, monitoring, etc.>
```

### Template (Portuguese)

Use the same structure with headings: **O que aconteceu**, **Por quê**, **Impacto**, **Como resolvemos** (Imediato / Definitivo), **Prevenção**.

### Short variant (Slack / one-liner)

```markdown
**Summary:** <one line>
**Cause:** <one line>
**Fix:** <one line>
**Status:** <resolved | mitigated | deploy pending>
```

### Writing rules

- Describe what the user saw, not which controller failed.
- Separate immediate fix from permanent fix when both exist.
- No secrets, PII, or internal URLs unless the user provided them.
- No tool-specific fields (labels, custom fields, project IDs).

---

## `/issue:tech` — developer issue body

### Audience

Engineers picking up the ticket — needs enough detail to reproduce, debug, review, or ship.

- Technical and precise. File paths, classes, endpoints, env vars, SQL, flags — when known.
- Code snippets only when they clarify the fix or repro (keep short).
- Separate facts from assumptions. Label guesses as **hypothesis**.

### Modes

Same mode tokens as `/issue:desc`. Default: infer `bug` vs `task` from context.

| Mode | When |
|------|------|
| `bug` | default for incidents and regressions |
| `task` | feature work, refactor, chore |
| `pr` | summarize PR for reviewers |
| `commit` | last commit only |
| `diff` | uncommitted changes only |

### Template (English)

```markdown
## [Bug|Task] — <short title>

### Summary
<2–4 sentences — technical overview of the problem or change>

### Steps to reproduce
1. <step>
2. <step>
3. <observed result>

_If not reproducible or N/A (e.g. deploy note), write "N/A" and explain why._

### Expected vs actual
- **Expected:** <behavior>
- **Actual:** <behavior>

### Root cause
<technical explanation — controllers, filters, race conditions, config, data state, etc.>

### Fix
<what changed or will change — files, migrations, flags, manual ops>

### Developer notes
- <edge cases, rollout order, backwards compatibility, monitoring>
- <links to logs, traces, PRs — no secrets>

### Checklist
- [ ] Root cause documented
- [ ] Fix implemented / deployed
- [ ] Regression test added (or reason skipped)
- [ ] Affected users/data verified
- [ ] Rollback plan clear (if production change)
```

### Template (Portuguese)

Same sections: **Resumo**, **Passos para reproduzir**, **Esperado vs atual**, **Causa raiz**, **Correção**, **Notas para devs**, **Checklist**.

### Writing rules

- Repro steps must be actionable — another dev should follow them without asking.
- Checklist items must reflect what actually applies; remove irrelevant rows.
- Include SQL/console one-liners for hotfixes when the conversation mentions them.
- Do not include secrets. Redact tokens and PII.

---

## Workflow

1. Detect command: `desc` / `description` → stakeholder; `tech` → developer.
2. Resolve language (auto or override from `$ARGUMENTS`).
3. Gather git/PR context if useful and not already in the chat.
4. Pick mode and template.
5. Return **only** the ready-to-paste markdown — no preamble.
6. Ask follow-up questions only when critical facts are missing (e.g. impact unknown for a postmortem).

## Examples

See [examples.md](../../examples.md).
