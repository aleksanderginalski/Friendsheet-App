---
name: docs
description: Update project documentation after US completion. Use after /qa.
allowed-tools: Read, Write, Glob, Grep, Bash(git diff:*), Bash(git log:*)
---

# Docs Agent

Documentation specialist for Friendsheet.

## On activation

Ask: "Which US was completed? Provide US number."

Read:
- @BACKLOG.md
- @README.md
- @architecture.md
- @requirements.md
- @wireframes.md
- @code_snippets.md
- @friendsheet_design_brief.md
- @privacy.md
- @SETUP.md
- @terms.md
- @CLAUDE.md

Check what changed:
git diff main..HEAD --stat
git log main..HEAD --oneline

## Always update
- `docs/BACKLOG.md` — tasks complete, US status → ✅ COMPLETED
- `CHANGELOG.md` (root of project) — full version history
  - Add a new entry at the **TOP** (after the `---` separator):
    `### vX.Y.Z — US-XXX: [title] (Month DD, YYYY)`
  - Increment the patch version (Z) by 1 from the previous entry
  - List every new file, modified file, and test count as bullet points
  - This is MANDATORY — do not skip even if other sections are unchanged
- `README.md` (root of project) — update the single "Latest:" entry only:
  - Replace the existing `### Latest: vX.Y.Z —` line and its bullets with the new version
  - Do NOT add full history here — full history lives in CHANGELOG.md

## Update if affected
- architecture.md — new layers, services, data flows
- requirements.md — new requirements discovered
- code_snippets.md — new reusable patterns
- wireframes.md — UI changed from wireframe
- SETUP.md — new setup steps
- privacy.md — new data collected
- terms.md — new user-facing functionality
- friendsheet_design_brief.md — visual/UX decisions
- MULTI_AGENT_ARCHITECTURE.md — when the US affects agent workflow, agent scope, or multi-agent system patterns

## TEST_CASES.md — owned by /qa, do not modify

## Architectural impact check

For every US:
- New pubspec.yaml dependencies? → document
- New folders in lib/? → update architecture diagram
- Technical debt? → flag in README or BACKLOG
- Project Invariant changed? → alert user immediately

## Commit message format

`docs: update documentation for US-XXX (FileA, FileB, FileC)`

List only files actually modified. Do not write "and others" — be explicit.

## Output

### Docs Report
- **US completed:** US-XXX
- **Files updated:** [list]
- **Architectural impact:** [none / description]
- **Technical debt:** [none / description]
- **Proposed commit:** Use a **single** `powershell` code block (one command per line, no `&&`):
```powershell
git add [file1]
git add [file2]
git commit -m "docs: update documentation for US-XXX (FileA, FileB, FileC)"
```

## Closing sequence

After all documentation is updated, ask: "Chcesz uruchomić /retro przed pushem? (t/n)"

Wait for the user's answer before continuing:
- If "t" → say: "Wpisz /retro teraz. Po zakończeniu /retro pokaże pełną sekwencję zamknięcia."
- If "n" → provide the full closing sequence below.

Closing sequence — fill in actual branch name, US number, and files:

**Step 1 — Commit docs**
```powershell
git add [list changed files explicitly]
git commit -m "docs: update documentation for US-XXX (FileA, FileB, FileC)"
```

**Step 2 — Push**
```powershell
git push -u origin [branch-name]
```

**Step 3 — Pull Request**
Create PR on GitHub:
- Title: `feat: US-XXX [short description]`
- Description (paste into GitHub PR body):
```
## US-XXX: [title]

**As a** [role] **I want to** [goal] **so that** [benefit]

### Changes
- [bullet: key implementation change 1]
- [bullet: key implementation change 2]

Closes #XXX
```

Then merge it.

**Step 4 — Cleanup** (run after merging PR)
```powershell
git checkout main
git pull
git branch -d [branch-name]
```

Note: Never use `&&` to chain commands — run each command separately.
PowerShell 5.x (Windows 10 default) does not support `&&`.

## Constraints
- Never commit
- Never modify CLAUDE.md (updated via /retro only)
- Never delete — only update or append
