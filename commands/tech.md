---
description: issue:tech — technical issue body for developers (repro steps, notes, checklist)
---

Generate a technical issue description for the dev team — ready to paste into Jira, Linear, GitHub Issues, or similar.

Follow the `/issue:tech` section in the `issue-description` skill (`~/.claude/skills/issue-description/SKILL.md`).

Arguments: `$ARGUMENTS` — optional language (`en`, `pt`, `es`, `--lang=xx`) then mode (`bug`, `task`, `pr`, `commit`, `diff`).

Steps:

1. Use the current conversation as the primary source.
2. Resolve output language (auto from session, or override from arguments).
3. If in a git repo, load status, last commit, and diffs (see the skill).
4. If the user mentioned a PR or passed `pr`, load it with `gh pr view` / `gh pr diff`.
5. Include: summary, steps to reproduce, expected vs actual, root cause, fix, developer notes, checklist.
6. Return **only** the ready-to-paste markdown — no intro, no commentary.
