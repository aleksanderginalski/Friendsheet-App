"""
report.py — Generate a per-session HTML observability report.

Usage:
    python tools/observability/report.py --us US-INF-010 --sp 5 [--notes "text"] [--session SESSION_ID]

Arguments:
    --us        User Story number (e.g. US-INF-010). Written to session log.
    --sp        Story Points (integer). Written to session log.
    --notes     Optional free-text notes about the session.
    --session   Explicit session ID. If omitted, uses the most recently modified log.

Output:
    tools/observability/reports/{session_id}.html  — opened in default browser.
"""

import argparse
import json
import os
import sys
import webbrowser
from datetime import datetime, timezone


COST_PER_TOKEN = 0.000006  # rough estimate in USD
LOGS_DIR = os.path.join('tools', 'observability', 'logs')
REPORTS_DIR = os.path.join('tools', 'observability', 'reports')


# ---------------------------------------------------------------------------
# Log file helpers
# ---------------------------------------------------------------------------

def _find_latest_log() -> str | None:
    """Return path to the most recently modified JSONL file in LOGS_DIR."""
    if not os.path.isdir(LOGS_DIR):
        return None
    files = [
        os.path.join(LOGS_DIR, f)
        for f in os.listdir(LOGS_DIR)
        if f.endswith('.jsonl')
    ]
    if not files:
        return None
    return max(files, key=os.path.getmtime)


def _load_entries(log_path: str) -> list[dict]:
    """Read all JSONL entries from the session log file."""
    entries = []
    with open(log_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entries.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    return entries


def _write_metadata(log_path: str, us: str, sp: int, notes: str) -> None:
    """Append a metadata entry to the session log (consumed by US-INF-011)."""
    entry = {
        'type': 'metadata',
        'us': us,
        'sp': sp,
        'notes': notes,
        'timestamp': datetime.now().isoformat(timespec='seconds'),
    }
    with open(log_path, 'a', encoding='utf-8') as f:
        f.write(json.dumps(entry) + '\n')


# ---------------------------------------------------------------------------
# Timeline computation
# ---------------------------------------------------------------------------

def _parse_ts(ts_str: str) -> datetime:
    return datetime.fromisoformat(ts_str)


def _fmt_duration(seconds: float) -> str:
    m, s = divmod(int(seconds), 60)
    return f'{m}m {s:02d}s'


_IMPL_AGENTS = {'dev', 'dev-ai', 'debug'}


def _compute_timeline(entries: list[dict]) -> list[dict]:
    """
    Build an ordered list of agent segments with durations and token deltas.

    Each segment: {skill, args, start, end, duration_sec, token_delta, synthetic}

    When a planning segment is immediately followed by a non-implementation agent
    (qa, docs, retro) with no dev/dev-ai/debug in between — a synthetic dev-ai
    segment is injected to represent implementation work done in a continuation
    session (where the Skill hook does not re-fire).

    Token deltas are computed from cumulative session_end entries rather than
    time-proportional approximation.
    """
    agents = [e for e in entries if e.get('type') == 'agent_start']
    session_ends = sorted(
        [
            e for e in entries
            if e.get('type') == 'session_end'
            and 'timestamp' in e
            and e.get('total_tokens') is not None
        ],
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

    # Build raw agent boundaries
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

    # Inject synthetic dev-ai when planning → non-impl agent detected
    expanded = []
    for i, seg in enumerate(raw):
        is_planning_gap = (
            seg['skill'].lower() == 'planning'
            and i + 1 < len(raw)
            and raw[i + 1]['skill'].lower() not in _IMPL_AGENTS
        )
        if is_planning_gap:
            # Find the first session_end after planning's start = planning's actual end
            planning_actual_end = None
            for se in session_ends:
                se_ts = _parse_ts(se['timestamp'])
                if se_ts > seg['start']:
                    planning_actual_end = se_ts
                    break
            if planning_actual_end and planning_actual_end < seg['end']:
                expanded.append({**seg, 'end': planning_actual_end, 'synthetic': False})
                expanded.append({
                    'skill': 'dev-ai',
                    'args': '[estimated]',
                    'start': planning_actual_end,
                    'end': seg['end'],
                    'synthetic': True,
                })
            else:
                expanded.append({**seg, 'synthetic': False})
        else:
            expanded.append({**seg, 'synthetic': False})

    # Compute duration and actual token deltas using session_end cumulative data
    def _tokens_at(ts: datetime) -> int | None:
        result = None
        for se in session_ends:
            if _parse_ts(se['timestamp']) <= ts:
                result = se.get('total_tokens')
            else:
                break
        return result

    segments = []
    for seg in expanded:
        duration_sec = max(0.0, (seg['end'] - seg['start']).total_seconds())
        tok_start = _tokens_at(seg['start'])
        tok_end = _tokens_at(seg['end'])
        token_delta = max(0, tok_end - tok_start) if (tok_start is not None and tok_end is not None) else None
        segments.append({
            'skill': seg['skill'],
            'args': seg['args'],
            'start': seg['start'],
            'end': seg['end'],
            'duration_sec': duration_sec,
            'token_delta': token_delta,
            'synthetic': seg['synthetic'],
        })
    return segments


# ---------------------------------------------------------------------------
# HTML generation
# ---------------------------------------------------------------------------

_SKILL_COLORS = {
    'pm':       '#4CAF50',
    'planning': '#2196F3',
    'dev':      '#FF9800',
    'dev-ai':   '#E91E63',
    'qa':       '#9C27B0',
    'debug':    '#F44336',
    'docs':     '#00BCD4',
    'retro':    '#795548',
    'discover': '#607D8B',
}
_DEFAULT_COLOR = '#9E9E9E'


def _color(skill: str) -> str:
    return _SKILL_COLORS.get(skill.lower(), _DEFAULT_COLOR)


def _build_svg_bars(segments: list[dict], total_sec: float) -> str:
    """Build an inline SVG horizontal bar chart."""
    bar_height = 28
    gap = 6
    label_width = 100
    chart_width = 420
    svg_height = max(1, len(segments)) * (bar_height + gap) + 10

    lines = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{label_width + chart_width + 60}" '
        f'height="{svg_height}" style="font-family:monospace;font-size:12px;">',
    ]

    for i, seg in enumerate(segments):
        y = i * (bar_height + gap) + 4
        pct = (seg['duration_sec'] / total_sec) if total_sec > 0 else 0
        bar_w = max(4, int(pct * chart_width))
        color = _color(seg['skill'])
        label = f'/{seg["skill"]}'

        lines.append(
            f'<text x="{label_width - 6}" y="{y + bar_height // 2 + 4}" '
            f'text-anchor="end" fill="#333">{label}</text>'
        )
        lines.append(
            f'<rect x="{label_width}" y="{y}" width="{bar_w}" height="{bar_height}" '
            f'fill="{color}" rx="3"/>'
        )
        dur_label = _fmt_duration(seg['duration_sec'])
        lines.append(
            f'<text x="{label_width + bar_w + 6}" y="{y + bar_height // 2 + 4}" '
            f'fill="#555">{dur_label}</text>'
        )

    lines.append('</svg>')
    return '\n'.join(lines)


def _build_html(
    session_id: str,
    segments: list[dict],
    entries: list[dict],
    us: str,
    sp: int,
    notes: str,
) -> str:
    """Render the full self-contained HTML report."""

    # Metadata
    meta = next((e for e in entries if e.get('type') == 'metadata'), {})
    session_end_list = [e for e in entries if e.get('type') == 'session_end']
    end_entry = session_end_list[-1] if session_end_list else {}
    total_tokens = end_entry.get('total_tokens')
    session_date = segments[0]['start'].strftime('%Y-%m-%d %H:%M') if segments else '—'
    total_sec = sum(s['duration_sec'] for s in segments)

    planning_count = sum(1 for s in segments if s['skill'].lower() == 'planning')
    dev_count = sum(1 for s in segments if s['skill'].lower() == 'dev')
    dev_ai_count = sum(1 for s in segments if s['skill'].lower() == 'dev-ai' and not s.get('synthetic'))

    cost_str = '—'
    if total_tokens is not None:
        cost_str = f'${total_tokens * COST_PER_TOKEN:.4f}'

    token_str = f'{total_tokens:,}' if total_tokens is not None else 'N/A'

    svg = _build_svg_bars(segments, total_sec)

    # Timeline table rows
    has_synthetic = any(s.get('synthetic') for s in segments)
    rows = []
    for seg in segments:
        delta = seg.get('token_delta')
        if delta is not None:
            tok = f'{delta:,}'
            pct = f'{delta / total_tokens * 100:.1f}%' if total_tokens else '—'
        elif total_tokens is not None and total_sec > 0:
            est = int(total_tokens * (seg['duration_sec'] / total_sec))
            tok = f'~{est:,}'
            pct = f'{seg["duration_sec"] / total_sec * 100:.1f}%'
        else:
            tok = '—'
            pct = '—'
        label = f'/{seg["skill"]}'
        if seg.get('synthetic'):
            label += ' *'
        rows.append(
            f'<tr>'
            f'<td style="color:{_color(seg["skill"])};font-weight:bold">{label}</td>'
            f'<td>{seg["start"].strftime("%H:%M:%S")}</td>'
            f'<td>{_fmt_duration(seg["duration_sec"])}</td>'
            f'<td>{tok}</td>'
            f'<td>{pct}</td>'
            f'</tr>'
        )
    rows_html = '\n'.join(rows) if rows else '<tr><td colspan="5">No agent invocations recorded.</td></tr>'

    notes_display = notes or meta.get('notes') or '—'

    html = f'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Session Report — {us}</title>
<style>
  body {{ font-family: 'Segoe UI', sans-serif; background: #f5f5f5; margin: 0; padding: 24px; color: #222; }}
  .card {{ background: #fff; border-radius: 8px; padding: 24px; margin-bottom: 20px;
           box-shadow: 0 1px 4px rgba(0,0,0,.12); }}
  h1 {{ margin: 0 0 4px; font-size: 1.5rem; }}
  .subtitle {{ color: #666; font-size: 0.9rem; margin-bottom: 20px; }}
  table {{ border-collapse: collapse; width: 100%; }}
  th {{ background: #f0f0f0; padding: 8px 12px; text-align: left; font-size: 0.85rem; color: #555; }}
  td {{ padding: 8px 12px; border-bottom: 1px solid #eee; font-size: 0.9rem; }}
  tr:last-child td {{ border-bottom: none; }}
  .footer-grid {{ display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }}
  .metric {{ text-align: center; }}
  .metric .value {{ font-size: 1.6rem; font-weight: bold; color: #1976D2; }}
  .metric .label {{ font-size: 0.8rem; color: #888; margin-top: 2px; }}
  .changes-row {{ display: flex; gap: 24px; align-items: flex-start; flex-wrap: wrap; }}
  .change-chip {{ background: #EEF2FF; border-radius: 20px; padding: 4px 14px;
                  font-size: 0.85rem; color: #3949AB; }}
  .disclaimer {{ font-size: 0.75rem; color: #aaa; margin-top: 8px; }}
  h2 {{ font-size: 1rem; color: #444; margin: 0 0 16px; }}
</style>
</head>
<body>

<div class="card">
  <h1>Session Report — {us}</h1>
  <div class="subtitle">{session_date} &nbsp;|&nbsp; Story Points: {sp} &nbsp;|&nbsp; Session: {session_id[:16]}…</div>

  <div class="footer-grid">
    <div class="metric">
      <div class="value">{_fmt_duration(total_sec)}</div>
      <div class="label">Total Duration</div>
    </div>
    <div class="metric">
      <div class="value">{token_str}</div>
      <div class="label">Total Tokens</div>
    </div>
    <div class="metric">
      <div class="value">{cost_str}</div>
      <div class="label">Est. Cost (USD)</div>
    </div>
  </div>
</div>

<div class="card">
  <h2>Agent Timeline</h2>
  {svg}
  <br>
  <table>
    <thead>
      <tr>
        <th>Agent</th><th>Start</th><th>Duration</th><th>Est. Tokens</th><th>% of session</th>
      </tr>
    </thead>
    <tbody>
      {rows_html}
    </tbody>
  </table>
  <div class="disclaimer">Tokens per agent computed from cumulative session_end entries at segment boundaries.<br>
  * = synthetic /dev-ai segment (no agent_start recorded — continuation session; estimated from session_end data).<br>
  ~ = time-proportion fallback (used when session_end data is unavailable).</div>
</div>

<div class="card">
  <h2>Design Changes</h2>
  <div class="changes-row">
    <div class="change-chip">/planning invocations: {planning_count}</div>
    <div class="change-chip">/dev invocations: {dev_count}</div>
    <div class="change-chip">/dev-ai invocations: {dev_ai_count}</div>
  </div>
  <p style="margin-top:12px;font-size:0.9rem;color:#444;">Notes: {notes_display}</p>
</div>

</body>
</html>'''
    return html


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description='Generate per-session observability report.')
    parser.add_argument('--us', required=True, help='User Story number, e.g. US-INF-010')
    parser.add_argument('--sp', required=True, type=int, help='Story Points')
    parser.add_argument('--notes', default='', help='Optional session notes')
    parser.add_argument('--session', default='', help='Session ID (omit to use latest log)')
    args = parser.parse_args()

    # Resolve log file
    if args.session:
        log_path = os.path.join(LOGS_DIR, f'{args.session}.jsonl')
    else:
        log_path = _find_latest_log()

    if not log_path or not os.path.isfile(log_path):
        print('No session log found. Make sure at least one agent was invoked with hooks active.')
        sys.exit(1)

    session_id = os.path.splitext(os.path.basename(log_path))[0]

    # Write metadata entry (consumed by US-INF-011 dashboard)
    _write_metadata(log_path, args.us, args.sp, args.notes)

    # Load all entries (including the metadata we just wrote)
    entries = _load_entries(log_path)

    # Build timeline
    segments = _compute_timeline(entries)

    # Generate HTML
    html = _build_html(session_id, segments, entries, args.us, args.sp, args.notes)

    # Write report
    os.makedirs(REPORTS_DIR, exist_ok=True)
    report_path = os.path.join(REPORTS_DIR, f'{session_id}.html')
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write(html)

    abs_path = os.path.abspath(report_path)
    print(f'Report generated: {abs_path}')
    webbrowser.open(f'file:///{abs_path}')


if __name__ == '__main__':
    main()
