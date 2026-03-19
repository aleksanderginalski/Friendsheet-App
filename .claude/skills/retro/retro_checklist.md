# Retro Checklist

## Reactive questions (ask one at a time)
a) Which agents did you use this session?
b) Did any agent produce output you had to manually correct?
c) Was there a moment when you didn't know what to do next?
d) Did any agent miss something it should have caught?
e) What worked well?

## Proactive check (every 3 US)
Review MULTI_AGENT_ARCHITECTURE.md and ask:
"Is there anything in the system that could work better, even if it's not causing problems now?"

Areas to check:
- Agent that does too much → split?
- Repetitive task without a dedicated agent?
- Agent ordering in the daily flow?
- Helper files that would benefit any agent?

## Proposal format (for each issue found)
1. Name the file: `.claude/skills/X/SKILL.md` or `CLAUDE.md`
2. Show exact text to add
3. Write: "Proposing change in [file]. Do you want to know why?"
4. Wait for "t" (accept) or "n" (reject) before next proposal
