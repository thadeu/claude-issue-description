---
description: issue:desc — short stakeholder summary (alias of issue:description)
---

Generate a short, non-technical summary ready to paste into any task manager or chat.

Follow the `/issue:desc` section in the `issue-description` skill (`~/.claude/skills/issue-description/SKILL.md`).

Arguments: `$ARGUMENTS` — optional language (`en`, `pt`, `es`, `--lang=xx`) then mode (`postmortem`, `incident`, `deploy`, `pr`, `commit`, `diff`).

Steps:

1. Use the current conversation as the primary source.
2. Resolve output language (auto from session, or override from arguments).
3. If in a git repo, load status, last commit, and diffs (see the skill).
4. If the user mentioned a PR or passed `pr`, load it with `gh pr view` / `gh pr diff`.
5. Return **only** the ready-to-paste markdown — no intro, no commentary.
