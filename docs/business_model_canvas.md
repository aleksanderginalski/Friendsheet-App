# Business Model Canvas — Friendsheet

**Version:** 1.0
**Date:** April 2026
**Author:** Aleksander Ginalski

---

## The Canvas

```
┌─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┐
│  KEY PARTNERS       │  KEY ACTIVITIES      │  VALUE              │  CUSTOMER           │  CUSTOMER           │
│                     │                      │  PROPOSITION        │  RELATIONSHIPS      │  SEGMENTS           │
│  • Google           │  • App development   │                     │                     │                     │
│    (Play, Firebase, │  • Firebase          │  "Feel in control   │  • Journal lock-in  │  "Quantified Self"  │
│    Calendar)        │    maintenance       │  of your social     │    — value grows    │  for social life    │
│  • OpenAI           │  • ASO optimization  │  life"              │    with years of    │                     │
│  • Cloudflare       │                      │                     │    data             │  People who like    │
│    (domain)         │  BOTTLENECK:         │  • Quick meeting    │                     │  to track and       │
│                     │  User acquisition    │    logging          │  • Meeting Sharing  │  quantify their     │
│                     │  — no clear          │  • Track who you    │    (FEATURE-012)    │  life — including   │
│                     │  distribution        │    meet & how often │    as only viral    │  friendships        │
│                     │  strategy yet        │  • Prepare for      │    growth element   │                     │
│                     │                      │    next meetings    │                     │  Android +          │
├─────────────────────┤  KEY RESOURCES       │    (catch-up        ├─────────────────────┤  Google Account     │
│                     │                      │    topics)          │  CHANNELS           │                     │
│                     │  • Solo developer    │  • Statistics over  │                     │                     │
│                     │  • Flutter / Firebase│    time             │  • Organic ASO      │                     │
│                     │    stack             │                     │    (Google Play)    │                     │
│                     │  • OpenAI via BYOK   │                     │  • Word of mouth    │                     │
│                     │                      │                     │  • Long-term:       │                     │
│                     │  MISSING:            │                     │    productivity     │                     │
│                     │  Designer, Marketer  │                     │    communities      │                     │
│                     │                      │                     │    (Reddit, TikTok) │                     │
├─────────────────────┴─────────────────────┴─────────────────────┼─────────────────────┴─────────────────────┤
│  COST STRUCTURE                                                   │  REVENUE STREAMS                          │
│                                                                   │                                           │
│  • Domain: friendsheet.app — annual (Cloudflare)                 │  FREEMIUM + SUBSCRIPTION                  │
│  • Firebase: Spark free tier → Blaze pay-as-you-go at scale      │                                           │
│  • Developer time (primary cost)                                  │  FREE tier    — limited meetings/day      │
│  • No AI costs today (BYOK model — user pays OpenAI directly)    │  PREMIUM tier — $1/month                  │
│                                                                   │               — unlimited meetings        │
│  FUTURE: OpenAI API costs if AI is bundled into subscription     │               — full feature access        │
│                                                                   │                                           │
│                                                                   │  FUTURE PATH: $3–5/month when Buddy       │
│                                                                   │  AI is managed (not BYOK)                 │
└───────────────────────────────────────────────────────────────────┴───────────────────────────────────────────┘
```

---

## Key Strategic Observations

### 1. Distribution Bottleneck
The product and business model are defined — but there is no clear acquisition channel.
ASO is a long game. Consider one early activation channel:
- Post on **r/productivity** or **r/quantifiedself** (target segment is active there)
- Short-form content showing the "journal value" — years of social history in one app

### 2. AI Pricing Path (Natural Upsell)
```
TODAY       →  Free (meeting limit) + $1/month (unlimited)
FUTURE      →  Free (meeting limit) + $1/month (unlimited) + $3–5/month (Buddy managed)
```
BYOK lowers the barrier for tech-savvy early adopters.
Managed AI unlocks the mass market at a higher price point.

### 3. Lock-in Is the Moat
The longer a user tracks meetings, the more irreplaceable the app becomes.
The "journal feeling" is not a nice-to-have — it is the core retention mechanism.
Every new feature should ask: *does this deepen the journal value?*

---

## Competitive Positioning

| Dimension | Friendsheet | Monica HQ | Notion/Airtable | Paper journal |
|---|---|---|---|---|
| Mobile-first | ✅ | ❌ (web) | ⚠️ | ❌ |
| Statistics | ✅ | ⚠️ basic | ❌ DIY | ❌ |
| AI assistant | ✅ Buddy | ❌ | ❌ | ❌ |
| Warm design | ✅ | ❌ | ❌ | ✅ |
| Setup time | Low | Medium | High | None |
| Price | $1/mies. | $9/mies. | $8–16/mies. | $0 |
