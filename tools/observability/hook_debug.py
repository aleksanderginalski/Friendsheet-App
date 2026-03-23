"""
hook_debug.py — temporary diagnostic hook.

Writes every PreToolUse event to an absolute path so we can confirm
hooks are firing and see what data Claude Code sends.
"""

import json
import os
import sys
from datetime import datetime

LOG_PATH = r'C:\Programowanie\Friendsheet-App\tools\observability\hook_debug.log'

try:
    raw = sys.stdin.read()
    timestamp = datetime.now().isoformat(timespec='seconds')

    try:
        data = json.loads(raw)
        tool_name = data.get('tool_name', data.get('tool', 'UNKNOWN'))
        session_id = data.get('session_id', 'UNKNOWN')
        line = f'{timestamp} | session={session_id} | tool={tool_name} | raw={raw[:200]}\n'
    except Exception as parse_err:
        line = f'{timestamp} | PARSE_ERROR={parse_err} | raw={raw[:200]}\n'

    with open(LOG_PATH, 'a', encoding='utf-8') as f:
        f.write(line)

except Exception as e:
    # Last resort — write error to a separate file
    try:
        with open(LOG_PATH + '.err', 'a') as f:
            f.write(f'{datetime.now().isoformat()} | {e}\n')
    except Exception:
        pass
