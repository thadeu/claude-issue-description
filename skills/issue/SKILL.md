---
name: issue
description: >-
  Generate issue descriptions from conversation, git diff, commits, or PRs.
  Use /issue with type desc (stakeholder summary) or tech (developer body with
  repro steps and checklist). Tool-agnostic markdown for Trello, Linear, Jira,
  GitHub Issues, Notion, Slack, or email. Language follows the session by
  default; override with en, pt, es, or --lang=xx.
disable-model-invocation: true
argument-hint: "[desc|tech] [en|pt|es|--lang=xx] [postmortem|incident|deploy|bug|task|pr|commit|diff]"
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git rev-parse:*), Bash(gh pr view:*), Bash(gh pr diff:*)
---

# issue

Turn technical work into ready-to-paste markdown for task managers or dev teams.

**Tool-agnostic.** No APIs, no vendor-specific fields. Paste anywhere that accepts text.

**Source of truth:** this file lives in [claude-issue-description](https://github.com/thadeu/claude-issue-description). Install with `install.sh`; run `install.sh check` if the agent reads a stale copy.

## Command

Single entry point: **`/issue`**

```
/issue                          # desc, auto language, inferred mode
/issue tech                     # developer issue body
/issue desc postmortem          # stakeholder postmortem
/issue desc en incident         # English incident summary
/issue tech pt bug              # Portuguese technical bug report
/issue tech pr                  # PR-focused technical summary
```

### Types

| Type | Aliases | Audience | Default mode |
|------|---------|----------|--------------|
| `desc` | `description` | Stakeholders (CTO, PM, ops) | `postmortem` |
| `tech` | `dev`, `developer` | Engineers | `bug` |

If no type is given, use `desc`.

### Modes by type

**`desc` modes:**

| Mode | When | Title prefix |
|------|------|--------------|
| `postmortem` | default — fixed or mitigated bug/incident | Postmortem |
| `incident` | ongoing or just resolved production issue | Incident |
| `deploy` | shipping a fix or feature | Deploy |
| `pr` | summarize an open/merged PR | PR |
| `commit` | last commit only | — |
| `diff` | uncommitted changes only | — |

**`tech` modes:**

| Mode | When |
|------|------|
| `bug` | default for incidents and regressions |
| `task` | feature work, refactor, chore |
| `pr` | summarize PR for reviewers |
| `commit` | last commit only |
| `diff` | uncommitted changes only |

## Language

**Default: automatic.** Match the language the user writes in during the session.

**Override:** pass a language token after the type:

| Argument | Language |
|----------|----------|
| `en`, `english` | English |
| `pt`, `pt-br`, `portuguese` | Portuguese |
| `es`, `spanish` | Spanish |
| `--lang=en`, `--lang=pt` | Explicit flag |

Section headings and body text must both use the selected language.

## Context sources

Priority order:

1. **Current conversation**
2. **Git working tree** — uncommitted/staged changes
3. **Last commit**
4. **Open PR** — when mode is `pr` or user mentions a PR

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

## Type `desc` — stakeholder summary

### Audience

Technical leader who is **not** in the weeds — CTO, head of product, ops lead.

- Plain language. Minimal jargon.
- No code blocks unless the user asks.
- Focus on what happened, who was affected, why, and how it was fixed.
- Keep under ~150 words unless the user asks for more.

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

Same structure: **O que aconteceu**, **Por quê**, **Impacto**, **Como resolvemos** (Imediato / Definitivo), **Prevenção**.

### Short variant (Slack)

```markdown
**Summary:** <one line>
**Cause:** <one line>
**Fix:** <one line>
**Status:** <resolved | mitigated | deploy pending>
```

---

## Type `tech` — developer issue body

### Audience

Engineers picking up the ticket — needs enough detail to reproduce, debug, review, or ship.

- Technical and precise. File paths, classes, endpoints, env vars, SQL, flags — when known.
- Code snippets only when they clarify the fix or repro (keep short).
- Label guesses as **hypothesis**.

### Template (English)

```markdown
## [Bug|Task] — <short title>

### Summary
<2–4 sentences — technical overview>

### Steps to reproduce
1. <step>
2. <step>
3. <observed result>

_If N/A, explain why._

### Expected vs actual
- **Expected:** <behavior>
- **Actual:** <behavior>

### Root cause
<controllers, filters, race conditions, config, data state, etc.>

### Fix
<files, migrations, flags, manual ops>

### Developer notes
- <edge cases, rollout order, monitoring>

### Checklist
- [ ] Root cause documented
- [ ] Fix implemented / deployed
- [ ] Regression test added (or reason skipped)
- [ ] Affected users/data verified
- [ ] Rollback plan clear (if production change)
```

### Template (Portuguese)

Same sections: **Resumo**, **Passos para reproduzir**, **Esperado vs atual**, **Causa raiz**, **Correção**, **Notas para devs**, **Checklist**.

---

## Workflow

1. Parse `$ARGUMENTS`: type → language → mode.
2. Gather git/PR context if useful.
3. Pick template for type.
4. Return **only** ready-to-paste markdown — no preamble.
5. Ask follow-up questions only when critical facts are missing.
6. **After generating the content**, ask whether to save it to a file under `tmp/` in the current project (e.g. `tmp/issue-<slug>.md` or `tmp/pr-<slug>.md`). If the user confirms, write the markdown there and reply with the file path only — do not repeat the full body in chat.

### Optional file output

When the user accepts the `tmp/` file:

- Use a short, kebab-case slug derived from the title (e.g. `profile-email-reconfirmation`).
- Prefer `tmp/pr-<slug>.md` when mode is `pr` or the content is clearly a PR description; otherwise `tmp/issue-<slug>.md`.
- Create `tmp/` if it does not exist.
- Do not commit the file unless the user asks.

Example prompt after output:

> Want me to save this to `tmp/pr-profile-email-reconfirmation.md` for easy copy-paste?

## Examples

See [examples.md](../../examples.md).
