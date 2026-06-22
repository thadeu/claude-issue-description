---
description: trello:description — short postmortem or card description for any task manager
---

Generate a short, non-technical summary ready to paste into Trello, Linear, Jira, GitHub Issues, Notion, Slack, or email.

Follow the `trello` skill (`~/.claude/skills/trello/SKILL.md`).

Optional mode from the user: `$ARGUMENTS` — one of `postmortem`, `incident`, `deploy`, `pr`, `commit`, `diff`.

Steps:

1. Use the current conversation as the primary source.
2. If in a git repo, load status, last commit, and diffs (see the skill).
3. If the user mentioned a PR or passed `pr`, load it with `gh pr view` / `gh pr diff`.
4. Pick the output template from the skill (default: postmortem).
5. Return **only** the ready-to-paste markdown — no intro, no commentary.

Write in the same language the user used in this session.
