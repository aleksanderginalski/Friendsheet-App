# Task Instruction Template — [US-XXX]

## Context
[What this US implements and why. Include issue number.]

## Read
[List files that /dev must read before starting implementation.]

## Tasks
1. [First task — specific and actionable]
2. [Second task]
3. [Continue as needed]

## Constraints
- Follow CLAUDE.md standards (const constructors, single quotes, max 300 lines per file)
- Run `flutter analyze` after implementation
- Run `flutter test` after implementation
- Never commit firebase_options.dart or google-services.json

## After implementation
- flutter analyze — must pass with zero issues
- flutter test — must pass, report test count delta
- Manual verification steps:
  1. [Step 1]
  2. [Step 2]
