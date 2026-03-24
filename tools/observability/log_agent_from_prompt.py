"""
log_agent_from_prompt.py — Claude Code UserPromptSubmit hook.

Appends an agent_start entry to the session JSONL log whenever the user
invokes a skill directly via slash command (e.g. /pm, /planning, /dev).

This complements log_agent.py (PreToolUse[Skill]) which only fires when
Claude itself calls the Skill tool. Together they cover both invocation paths.

Must never crash or the Claude Code session will be interrupted.
"""

import json
import os
import re
import sys
from datetime import datetime

# All known skill names in this project.
_KNOWN_SKILLS = {
    'pm', 'discover', 'planning', 'dev', 'qa', 'debug', 'docs', 'retro',
}


def _extract_skill(prompt: str) -> tuple[str, str] | None:
    """Return (skill_name, args) if the prompt starts with a known /skill command.

    Checks the first non-empty line only — handles leading whitespace and
    multi-line prompts where the command is on the first line.
    Returns None if the prompt is not a skill invocation.
    """
    first_line = prompt.lstrip().split('\n')[0].strip()
    match = re.match(r'^/(\w[\w-]*)(?:\s+(.*))?$', first_line, re.DOTALL)
    if not match:
        return None

    skill = match.group(1).lower()
    args = (match.group(2) or '').strip()

    if skill not in _KNOWN_SKILLS:
        return None

    return skill, args


def main() -> None:
    try:
        raw = sys.stdin.read()
        data = json.loads(raw)

        prompt = data.get('prompt', '')
        result = _extract_skill(prompt)
        if result is None:
            return  # Not a skill invocation — nothing to log.

        skill, args = result
        session_id = data.get('session_id', 'unknown')
        timestamp = datetime.now().isoformat(timespec='seconds')

        script_dir = os.path.dirname(os.path.abspath(__file__))
        logs_dir = os.path.join(script_dir, 'logs')
        os.makedirs(logs_dir, exist_ok=True)

        log_path = os.path.join(logs_dir, f'{session_id}.jsonl')
        entry = {
            'type': 'agent_start',
            'session_id': session_id,
            'skill': skill,
            'args': args,
            'timestamp': timestamp,
        }

        with open(log_path, 'a', encoding='utf-8') as f:
            f.write(json.dumps(entry) + '\n')

    except Exception:
        # Never raise — a hook crash interrupts the Claude Code session.
        pass


if __name__ == '__main__':
    main()
