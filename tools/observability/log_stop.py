"""
log_stop.py — Claude Code Stop hook.

Appends a session_end entry to the session JSONL log when Claude Code stops.
Attempts to extract total token usage from the transcript file.
Must never crash or the Claude Code session will be interrupted.
"""

import json
import os
import sys
from datetime import datetime


def _extract_tokens(transcript_path: str) -> int | None:
    """Parse the transcript file and sum all token usage fields found.

    The transcript is JSONL; each line is a conversation entry that may contain
    usage data under various field paths depending on Claude Code version.
    Returns the summed token count, or None if no usage data was found.
    """
    if not transcript_path or not os.path.isfile(transcript_path):
        return None

    total_input = 0
    total_output = 0
    found_any = False

    try:
        with open(transcript_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue

                # Try known field paths used by Claude Code transcript format.
                usage = None
                if isinstance(entry, dict):
                    # Path 1: top-level 'usage'
                    usage = entry.get('usage')
                    # Path 2: nested inside 'message'
                    if usage is None:
                        msg = entry.get('message', {})
                        if isinstance(msg, dict):
                            usage = msg.get('usage')

                if isinstance(usage, dict):
                    inp = usage.get('input_tokens', 0) or 0
                    out = usage.get('output_tokens', 0) or 0
                    if inp or out:
                        total_input += inp
                        total_output += out
                        found_any = True
    except Exception:
        return None

    return (total_input + total_output) if found_any else None


def main() -> None:
    try:
        raw = sys.stdin.read()
        data = json.loads(raw)

        session_id = data.get('session_id', 'unknown')
        transcript_path = data.get('transcript_path', '')
        timestamp = datetime.now().isoformat(timespec='seconds')

        total_tokens = _extract_tokens(transcript_path)

        logs_dir = os.path.join('tools', 'observability', 'logs')
        os.makedirs(logs_dir, exist_ok=True)

        log_path = os.path.join(logs_dir, f'{session_id}.jsonl')
        entry = {
            'type': 'session_end',
            'session_id': session_id,
            'total_tokens': total_tokens,
            'total_cost': None,
            'transcript_path': transcript_path,
            'timestamp': timestamp,
        }

        with open(log_path, 'a', encoding='utf-8') as f:
            f.write(json.dumps(entry) + '\n')

    except Exception:
        # Never raise — a hook crash interrupts the Claude Code session.
        pass


if __name__ == '__main__':
    main()
