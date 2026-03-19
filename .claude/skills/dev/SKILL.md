---
name: dev
description: Implementation agent. Reads CLAUDE.md for full instructions. Use after /planning generates a Task instruction.
---

# Dev Agent

This agent's instructions live in **CLAUDE.md** — the project's primary instruction file for /dev.

## How to use

1. `/planning` saves the Task instruction to `.claude/current_task.md`
2. Open `.claude/current_task.md`
3. Paste the full Task instruction as your next message

Claude Code will then run as the /dev agent using CLAUDE.md as its instruction set.
