"""
dashboard_html.py — HTML/SVG generation helpers for dashboard.py.
"""

import json
import math
from datetime import datetime

COST_PER_TOKEN = 0.000006

_SKILL_COLORS = {
    'pm': '#4CAF50', 'planning': '#2196F3', 'dev': '#FF9800',
    'qa': '#9C27B0', 'debug': '#F44336', 'docs': '#00BCD4',
    'retro': '#795548', 'discover': '#607D8B',
}
_DEFAULT_COLOR = '#9E9E9E'

_CSS = '''
body{font-family:'Segoe UI',sans-serif;background:#f5f5f5;margin:0;padding:24px;color:#222}
.card{background:#fff;border-radius:8px;padding:24px;margin-bottom:20px;box-shadow:0 1px 4px rgba(0,0,0,.12)}
h1{margin:0 0 4px;font-size:1.5rem}
h2{font-size:1rem;color:#444;margin:0 0 16px}
.subtitle{color:#666;font-size:.9rem;margin-bottom:4px}
table{border-collapse:collapse;width:100%}
th{background:#f0f0f0;padding:8px 12px;text-align:left;font-size:.85rem;color:#555}
td{padding:8px 12px;border-bottom:1px solid #eee;font-size:.9rem}
tr:last-child td{border-bottom:none}
.hist-row{display:flex;flex-wrap:wrap;gap:24px;align-items:flex-end}
.hist-block{display:flex;flex-direction:column;align-items:center}
.hist-title{font-size:.85rem;color:#555;margin-bottom:8px;font-weight:bold}
.compare-controls{display:flex;gap:24px;margin-bottom:16px}
.compare-controls label{font-size:.85rem;color:#555}
.compare-controls select{margin-top:4px;padding:6px 10px;border:1px solid #ddd;border-radius:4px;font-size:.9rem}
.compare-panels{display:flex;gap:24px;flex-wrap:wrap}
.compare-panel{flex:1;min-width:300px}
.panel-title{font-weight:bold;font-size:.9rem;color:#444;margin-bottom:8px}
.panel-meta{display:flex;gap:16px;flex-wrap:wrap;font-size:.8rem;color:#666;margin-top:8px}
'''


def _color(skill: str) -> str:
    return _SKILL_COLORS.get(skill.lower(), _DEFAULT_COLOR)


def _fmt_tokens(n: int | None) -> str:
    return f'{n:,}' if n is not None else '—'


def _fmt_cost(n: int | None) -> str:
    return f'${n * COST_PER_TOKEN:.4f}' if n is not None else '—'


def _fmt_dur(seconds: float) -> str:
    m, s = divmod(int(seconds), 60)
    return f'{m}m {s:02d}s'


# ---------------------------------------------------------------------------
# Histogram helpers
# ---------------------------------------------------------------------------

def _nice_step(value: float) -> int:
    """Round value up to the nearest multiple of 5 000."""
    if value <= 0:
        return 5000
    return max(5000, int(math.ceil(value / 5000) * 5000))


def _make_buckets(tokens: list[int], min_buckets: int = 4) -> list[tuple[int, int]]:
    """Compute evenly-spaced, round-number bucket boundaries covering all token values."""
    lo, hi = min(tokens), max(tokens)
    if lo == hi:
        # Single value — build 4 buckets centered around it
        step = _nice_step(lo * 0.1) if lo > 0 else 5000
        start = max(0, (lo // step) * step)
        return [(start + i * step, start + (i + 1) * step) for i in range(min_buckets)]
    raw_width = (hi - lo) / min_buckets
    step = _nice_step(raw_width)
    start = (lo // step) * step
    buckets: list[tuple[int, int]] = []
    b = start
    while b <= hi:
        buckets.append((b, b + step))
        b += step
    while len(buckets) < min_buckets:
        buckets.append((buckets[-1][1], buckets[-1][1] + step))
    return buckets


def _histogram_svg(sp: int, tokens: list[int]) -> str:
    """Render a vertical bar histogram SVG for sessions with the given SP value."""
    buckets = _make_buckets(tokens)
    counts = [sum(1 for t in tokens if lo <= t < hi) for lo, hi in buckets]
    # Last bucket is right-inclusive to catch exact boundary values
    lo, hi = buckets[-1]
    counts[-1] = sum(1 for t in tokens if lo <= t <= hi)

    max_count = max(counts) if any(c > 0 for c in counts) else 1
    bar_w, gap, left, top, bottom, chart_h = 72, 10, 44, 24, 52, 120
    svg_w = left + len(buckets) * (bar_w + gap) + gap
    svg_h = top + chart_h + bottom

    lines = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{svg_w}" height="{svg_h}" '
        f'style="font-family:monospace;font-size:11px;">',
    ]
    # Y axis line
    lines.append(
        f'<line x1="{left}" y1="{top}" x2="{left}" y2="{top + chart_h}" '
        f'stroke="#ddd" stroke-width="1"/>'
    )
    # Y axis ticks (0 to max_count)
    for tick in range(0, max_count + 1):
        ty = top + chart_h - int(tick / max_count * chart_h)
        lines.append(
            f'<text x="{left - 4}" y="{ty + 4}" text-anchor="end" fill="#888">{tick}</text>'
        )
    # Bars
    for i, (count, (blo, bhi)) in enumerate(zip(counts, buckets)):
        x = left + gap // 2 + i * (bar_w + gap)
        bar_h = int(count / max_count * chart_h) if max_count else 0
        y = top + chart_h - bar_h
        if bar_h:
            lines.append(
                f'<rect x="{x}" y="{y}" width="{bar_w}" height="{bar_h}" fill="#2196F3" rx="2"/>'
            )
        lines.append(
            f'<text x="{x + bar_w // 2}" y="{max(top - 2, y - 4)}" '
            f'text-anchor="middle" fill="#333">{count}</text>'
        )
        label = f'{blo // 1000}k\u2013{bhi // 1000}k'
        lines.append(
            f'<text x="{x + bar_w // 2}" y="{top + chart_h + 18}" '
            f'text-anchor="middle" fill="#555">{label}</text>'
        )
    # Baseline
    lines.append(
        f'<line x1="{left}" y1="{top + chart_h}" x2="{svg_w - gap}" y2="{top + chart_h}" '
        f'stroke="#ccc" stroke-width="1"/>'
    )
    lines.append('</svg>')
    return '\n'.join(lines)


def _histograms_section(sessions: list[dict]) -> str:
    with_sp = [s for s in sessions if s['sp'] is not None and s['total_tokens'] is not None]
    if not with_sp:
        return (
            '<div class="card"><h2>Token Distribution by Story Points</h2>'
            '<p style="color:#888">No sessions with story points data yet. '
            'Run <code>report.bat</code> after each session.</p></div>'
        )
    sp_groups: dict[int, list[int]] = {}
    for s in with_sp:
        sp_groups.setdefault(s['sp'], []).append(s['total_tokens'])

    parts = ['<div class="card"><h2>Token Distribution by Story Points</h2><div class="hist-row">']
    for sp in sorted(sp_groups):
        n = len(sp_groups[sp])
        svg = _histogram_svg(sp, sp_groups[sp])
        label = f'{sp} SP ({n} session{"s" if n != 1 else ""})'
        parts.append(f'<div class="hist-block"><div class="hist-title">{label}</div>{svg}</div>')
    parts.append('</div></div>')
    return '\n'.join(parts)


# ---------------------------------------------------------------------------
# Side-by-side comparison
# ---------------------------------------------------------------------------

def _comparison_section(sessions: list[dict]) -> str:
    if not sessions:
        return (
            '<div class="card"><h2>Session Comparison</h2>'
            '<p style="color:#888">No sessions found.</p></div>'
        )
    js_sessions = []
    for i, s in enumerate(sessions):
        label = f'{s["us"]} \u2014 {s["date"]}'
        total_sec = sum(seg['duration_sec'] for seg in s['segments'])
        js_sessions.append({
            'idx': i,
            'label': label,
            'us': s['us'],
            'sp': s['sp'],
            'total_tokens': s['total_tokens'],
            'planning_count': s['planning_count'],
            'total_sec': total_sec,
            'segments': [
                {'skill': seg['skill'], 'duration_sec': seg['duration_sec']}
                for seg in s['segments']
            ],
        })

    opts_a = '\n'.join(f'<option value="{s["idx"]}">{s["label"]}</option>' for s in js_sessions)
    opts_b = '\n'.join(
        f'<option value="{s["idx"]}" {"selected" if s["idx"] == min(1, len(js_sessions) - 1) else ""}>'
        f'{s["label"]}</option>'
        for s in js_sessions
    )
    colors_js = json.dumps(_SKILL_COLORS)
    sessions_js = json.dumps(js_sessions)

    return f'''<div class="card">
  <h2>Session Comparison</h2>
  <div class="compare-controls">
    <div><label>Session A</label><br><select id="selA" onchange="renderComparison()">{opts_a}</select></div>
    <div><label>Session B</label><br><select id="selB" onchange="renderComparison()">{opts_b}</select></div>
  </div>
  <div class="compare-panels" id="comparePanels"></div>
</div>
<script>
const SESSIONS={sessions_js};
const COLORS={colors_js};
const DC='{_DEFAULT_COLOR}';
function fmtDur(sec){{const m=Math.floor(sec/60),s=Math.round(sec%60);return m+'m '+String(s).padStart(2,'0')+'s';}}
function timelineSVG(segs,total){{
  const bh=26,gap=5,lw=90,cw=340;
  const sh=segs.length*(bh+gap)+10;
  let o=[`<svg xmlns="http://www.w3.org/2000/svg" width="${{lw+cw+60}}" height="${{sh}}" style="font-family:monospace;font-size:11px;">`];
  segs.forEach((seg,i)=>{{
    const y=i*(bh+gap)+4,pct=total>0?seg.duration_sec/total:0,bw=Math.max(4,Math.round(pct*cw));
    const c=COLORS[seg.skill]||DC;
    o.push(`<text x="${{lw-6}}" y="${{y+bh/2+4}}" text-anchor="end" fill="#333">/${{seg.skill}}</text>`);
    o.push(`<rect x="${{lw}}" y="${{y}}" width="${{bw}}" height="${{bh}}" fill="${{c}}" rx="3"/>`);
    o.push(`<text x="${{lw+bw+6}}" y="${{y+bh/2+4}}" fill="#555">${{fmtDur(seg.duration_sec)}}</text>`);
  }});
  o.push('</svg>');return o.join('');
}}
function renderPanel(s){{
  const svg=s.segments.length?timelineSVG(s.segments,s.total_sec):'<p style="color:#aaa">No agent data</p>';
  const tok=s.total_tokens!=null?s.total_tokens.toLocaleString():'—';
  const sp=s.sp!=null?s.sp+' SP':'—';
  return `<div class="compare-panel"><div class="panel-title">${{s.label}}</div>${{svg}}<div class="panel-meta"><span>Tokens: ${{tok}}</span><span>Duration: ${{fmtDur(s.total_sec)}}</span><span>SP: ${{sp}}</span><span>/planning: ${{s.planning_count}}</span></div></div>`;
}}
function renderComparison(){{
  const a=SESSIONS[+document.getElementById('selA').value];
  const b=SESSIONS[+document.getElementById('selB').value];
  document.getElementById('comparePanels').innerHTML=renderPanel(a)+renderPanel(b);
}}
renderComparison();
</script>'''


# ---------------------------------------------------------------------------
# Sessions table
# ---------------------------------------------------------------------------

def _sessions_table(sessions: list[dict]) -> str:
    rows = []
    for s in sessions:
        short_id = s['session_id'][:8] + '\u2026'
        sp_str = str(s['sp']) if s['sp'] is not None else '—'
        rows.append(
            f'<tr>'
            f'<td title="{s["session_id"]}">{short_id}</td>'
            f'<td>{s["date"]}</td>'
            f'<td>{s["us"]}</td>'
            f'<td>{sp_str}</td>'
            f'<td>{_fmt_tokens(s["total_tokens"])}</td>'
            f'<td>{_fmt_cost(s["total_tokens"])}</td>'
            f'<td>{s["planning_count"]}</td>'
            f'<td>{s["dev_count"]}</td>'
            f'<td>{s["notes"] or "—"}</td>'
            f'</tr>'
        )
    rows_html = '\n'.join(rows) if rows else '<tr><td colspan="9">No sessions found.</td></tr>'
    return (
        '<div class="card"><h2>All Sessions</h2><table>'
        '<thead><tr><th>Session</th><th>Date</th><th>US</th><th>SP</th>'
        '<th>Total Tokens</th><th>Est. Cost</th><th>/planning</th><th>/dev</th><th>Notes</th>'
        f'</tr></thead><tbody>{rows_html}</tbody></table></div>'
    )


# ---------------------------------------------------------------------------
# Full HTML assembly
# ---------------------------------------------------------------------------

def build_html(sessions: list[dict]) -> str:
    """Generate the complete self-contained dashboard HTML."""
    generated = datetime.now().strftime('%Y-%m-%d %H:%M')
    count = len(sessions)
    noun = 'session' if count == 1 else 'sessions'
    return (
        f'<!DOCTYPE html>\n<html lang="en">\n<head>\n<meta charset="UTF-8">\n'
        f'<title>Friendsheet \u2014 Agent Observability Dashboard</title>\n'
        f'<style>{_CSS}</style>\n</head>\n<body>\n\n'
        f'<div class="card"><h1>Agent Observability Dashboard</h1>'
        f'<div class="subtitle">Generated: {generated} &nbsp;|&nbsp; {count} {noun} loaded</div></div>\n\n'
        f'{_histograms_section(sessions)}\n\n'
        f'{_comparison_section(sessions)}\n\n'
        f'{_sessions_table(sessions)}\n\n'
        f'</body>\n</html>'
    )
