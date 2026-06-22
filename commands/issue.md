---
description: issue — generate issue descriptions (desc for stakeholders, tech for devs)
argument-hint: "[desc|tech] [en|pt|es|--lang=xx] [postmortem|incident|deploy|bug|task|pr|commit|diff]"
---

Generate a ready-to-paste issue description from the current conversation (and git/PR context when useful).

Follow the `issue` skill (`~/.claude/skills/issue/SKILL.md`).

Arguments: `$ARGUMENTS`

## Parse arguments (in order)

1. **Type** — first token if it matches `desc`, `description`, `tech`, `dev` (default: `desc`)
2. **Language** — next token if it matches `en`, `pt`, `es`, `--lang=xx` (default: session language)
3. **Mode** — remaining tokens (default: infer from context; `postmortem` for desc, `bug` for tech)

## Examples

```
/issue
/issue tech
/issue desc postmortem
/issue desc en incident
/issue tech pt bug
/issue tech pr
```

## Steps

1. Use the current conversation as the primary source.
2. Resolve type → pick `desc` or `tech` template from the skill.
3. Resolve language (auto or override).
4. If in a git repo, load status, last commit, and diffs.
5. If mode is `pr` or user mentioned a PR, load `gh pr view` / `gh pr diff`.
6. Return **only** the ready-to-paste markdown — no intro, no commentary.
