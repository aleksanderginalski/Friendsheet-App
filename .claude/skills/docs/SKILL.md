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
- BACKLOG.md — tasks complete, US status → ✅ COMPLETED
- README.md — version history, feature status

## Update if affected
- architecture.md — new layers, services, data flows
- requirements.md — new requirements discovered
- code_snippets.md — new reusable patterns
- wireframes.md — UI changed from wireframe
- SETUP.md — new setup steps
- privacy.md — new data collected
- terms.md — new user-facing functionality
- friendsheet_design_brief.md — visual/UX decisions

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
- **Proposed commit:**
```powershell
git add [list changed files explicitly]
git commit -m "docs: update documentation for US-XXX (FileA, FileB, FileC)"
```

## Closing sequence

After all documentation is updated, ask: "Chcesz uruchomić /retro przed pushem? (t/n)"

Then provide the full closing sequence — fill in actual branch name, US number, and files:

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
```powershell
gh pr create --title "feat: US-XXX [short description]" --body "Closes #XXX"
```
Or create the PR manually on GitHub. Then merge it.

**Step 4 — Confirm merge**
Ask the user: "Czy zmergowałeś PR na GitHubie? Napisz 'tak' gdy gotowe."

Wait for confirmation before showing Step 5.

**Step 5 — Cleanup (after merge confirmation)**
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
