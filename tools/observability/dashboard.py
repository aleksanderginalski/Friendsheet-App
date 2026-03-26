"""
dashboard.py — Generate a multi-session agent observability dashboard.

Usage:
    python tools/observability/dashboard.py

Output:
    tools/observability/reports/dashboard.html  — opened in default browser.
"""

import json
import os
import webbrowser
from datetime import datetime

from dashboard_html import build_html

LOGS_DIR = os.path.join('tools', 'observability', 'logs')
REPORTS_DIR = os.path.join('tools', 'observability', 'reports')


def _parse_ts(ts_str: str) -> datetime:
    return datetime.fromisoformat(ts_str)


_IMPL_AGENTS = {'dev', 'dev-ai', 'debug'}


def _compute_timeline(entries: list[dict]) -> list[dict]:
    """Build ordered agent segments with durations (mirrors report.py logic).

    Injects a synthetic dev-ai segment when planning is immediately followed
    by a non-implementation agent (continuation session pattern).
    """
    agents = [e for e in entries if e.get('type') == 'agent_start']
    session_ends = sorted(
        [e for e in entries if e.get('type') == 'session_end' and 'timestamp' in e],
        key=lambda e: _parse_ts(e['timestamp']),
    )

    if not agents:
        return []

    end_ts = datetime.now()
    if session_ends:
        try:
            end_ts = _parse_ts(session_ends[-1]['timestamp'])
        except (KeyError, ValueError):
            pass

    raw = []
    for i, agent in enumerate(agents):
        start = _parse_ts(agent['timestamp'])
        end = _parse_ts(agents[i + 1]['timestamp']) if i + 1 < len(agents) else end_ts
        raw.append({
            'skill': agent.get('skill', 'unknown'),
            'args': agent.get('args', ''),
            'start': start,
            'end': end,
        })

    segments = []
    for i, seg in enumerate(raw):
        is_planning_gap = (
            seg['skill'].lower() == 'planning'
            and i + 1 < len(raw)
            and raw[i + 1]['skill'].lower() not in _IMPL_AGENTS
        )
        if is_planning_gap:
            planning_actual_end = None
            for se in session_ends:
                if _parse_ts(se['timestamp']) > seg['start']:
                    planning_actual_end = _parse_ts(se['timestamp'])
                    break
            if planning_actual_end and planning_actual_end < seg['end']:
                segments.append({
                    'skill': seg['skill'],
                    'args': seg['args'],
                    'duration_sec': max(0.0, (planning_actual_end - seg['start']).total_seconds()),
                })
                segments.append({
                    'skill': 'dev-ai',
                    'args': '[estimated]',
                    'duration_sec': max(0.0, (seg['end'] - planning_actual_end).total_seconds()),
                })
            else:
                segments.append({
                    'skill': seg['skill'],
                    'args': seg['args'],
                    'duration_sec': max(0.0, (seg['end'] - seg['start']).total_seconds()),
                })
        else:
            segments.append({
                'skill': seg['skill'],
                'args': seg['args'],
                'duration_sec': max(0.0, (seg['end'] - seg['start']).total_seconds()),
            })
    return segments


def _load_session(path: str) -> dict:
    """Parse a JSONL log file into a session summary dict."""
    entries = []
    with open(path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entries.append(json.loads(line))
            except json.JSONDecodeError:
                continue

    session_id = os.path.splitext(os.path.basename(path))[0]

    # Total tokens from last session_end entry (cumulative — last is highest)
    session_ends = [e for e in entries if e.get('type') == 'session_end']
    total_tokens = session_ends[-1].get('total_tokens') if session_ends else None

    # Metadata written by report.bat (us, sp, notes)
    meta = next((e for e in entries if e.get('type') == 'metadata'), None)

    # Date from first timestamp found in any entry
    first_ts = next((e.get('timestamp') for e in entries if e.get('timestamp')), None)
    date_str = first_ts[:16].replace('T', ' ') if first_ts else '—'

    # US: metadata wins; fallback to planning agent args
    us = meta.get('us', '—') if meta else '—'
    if us == '—':
        plan = next(
            (e for e in entries
             if e.get('type') == 'agent_start' and e.get('skill') == 'planning'),
            None,
        )
        if plan and plan.get('args'):
            us = plan['args']

    return {
        'session_id': session_id,
        'date': date_str,
        'total_tokens': total_tokens,
        'us': us,
        'sp': meta.get('sp') if meta else None,
        'notes': meta.get('notes', '') if meta else '',
        'planning_count': sum(
            1 for e in entries
            if e.get('type') == 'agent_start' and e.get('skill') == 'planning'
        ),
        'dev_count': sum(
            1 for e in entries
            if e.get('type') == 'agent_start' and e.get('skill') == 'dev'
        ),
        'segments': _compute_timeline(entries),
    }


def load_all_sessions() -> list[dict]:
    """Load all JSONL sessions from LOGS_DIR, sorted newest first."""
    if not os.path.isdir(LOGS_DIR):
        return []
    sessions = []
    for fname in os.listdir(LOGS_DIR):
        if not fname.endswith('.jsonl'):
            continue
        try:
            sessions.append(_load_session(os.path.join(LOGS_DIR, fname)))
        except Exception:
            continue
    sessions.sort(key=lambda s: s['date'], reverse=True)
    return sessions


def main() -> None:
    sessions = load_all_sessions()
    html = build_html(sessions)
    os.makedirs(REPORTS_DIR, exist_ok=True)
    out_path = os.path.join(REPORTS_DIR, 'dashboard.html')
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(html)
    abs_path = os.path.abspath(out_path)
    print(f'Dashboard generated: {abs_path}')
    webbrowser.open(f'file:///{abs_path}')


if __name__ == '__main__':
    main()
