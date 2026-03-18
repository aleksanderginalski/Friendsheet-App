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

## Output

### Docs Report
- **US completed:** US-XXX
- **Files updated:** [list]
- **Architectural impact:** [none / description]
- **Technical debt:** [none / description]
- **Proposed commit:** `docs: update documentation for US-XXX`

## Constraints
- Never commit
- Never modify CLAUDE.md (updated via /retro only)
- Never delete — only update or append
