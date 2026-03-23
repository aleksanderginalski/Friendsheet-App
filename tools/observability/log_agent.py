"""
log_agent.py — Claude Code PreToolUse hook for Skill tool.

Appends an agent_start entry to the session JSONL log whenever a skill is invoked.
Called automatically by Claude Code hooks; receives event data on stdin as JSON.
Must never crash or the Claude Code session will be interrupted.
"""

import json
import os
import sys
from datetime import datetime


def main() -> None:
    try:
        raw = sys.stdin.read()
        data = json.loads(raw)

        session_id = data.get('session_id', 'unknown')
        tool_input = data.get('tool_input', {})
        skill = tool_input.get('skill', 'unknown')
        args = tool_input.get('args', '')
        timestamp = datetime.now().isoformat(timespec='seconds')

        # Use absolute path so the hook works regardless of working directory.
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
