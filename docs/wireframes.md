# Friendsheet — Wireframes & UI Documentation

**Responsible Role:** UX/UI Designer  
**Version:** 2.2 (US-099 — PersonMeetingsScreen added; US-098 — swipe-to-delete package in MeetingInboxScreen)
**Last Updated:** March 2026

---

## Navigation Structure

### Bottom Navigation Bar
```
┌─────────────────────────────────────┐
│  Screen Title                   ⋮  │  ← drawer trigger (logout only)
├─────────────────────────────────────┤
│                                     │
│         [Screen Content]            │
│                                     │
│                      [+]            │  ← FAB (Add Meeting), all tabs
└─────────────────────────────────────┘
│  🏠    │  📅    │  👥    │  🏷️    │
│ Home   │Meetings│Friends │Activities│
└────────┴────────┴────────┴──────────┘
```

| Index | Icon | Label | Screen |
|-------|------|-------|--------|
| 0 | home | Home | HomeScreen |
| 1 | calendar_today | Meetings | MeetingsListScreen |
| 2 | people | Friends | PersonsListScreen |
| 3 | sports_tennis | Activities | ActivitiesListScreen |

### Drawer (accessible from ⋮ in AppBar)
```
┌─────────────────────────────────────┐
│  [drawer_icon.png]                  │
│  Friendsheet                        │
│  ─────────────────────────────────  │
│  📅 Import from Calendar            │  ← dynamic: "Browse & Import Events"
│     when calendar connected         │    when calendar connected
│  ─────────────────────────────────  │
│  🚪 Log Out                         │
└─────────────────────────────────────┘
```

**Drawer tile behavior:**
- Calendar NOT connected → `"Import from Calendar"` → navigates to `CalendarPermissionScreen`
- Calendar connected → `"Browse & Import Events"` → navigates to `CalendarEventsScreen`

---

## Screen 1: Login Screen

```
┌─────────────────────────────────────┐
│                                     │
│         [Friendsheet Logo]          │
│       Track Your Social Life        │
│                                     │
│         [Hero Illustration]         │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  [G]  Sign in with Google   │   │
│  └─────────────────────────────┘   │
│                                     │
│    By signing in, you agree to     │
│         our Terms of Service       │
│                                     │
└─────────────────────────────────────┘
```

**States:**

| State | Appearance |
|-------|-----------|
| Idle | Button enabled, full opacity |
| Loading | Spinner replaces button label — `"Signing in..."` |
| Error | Snackbar or inline error below button |

**Behavior:**
- Single tap → Google account picker (OS-level, not custom UI)
- First-time user → Firebase creates account automatically
- Returning user → logs in directly
- On success → navigates to `HomeScreen`, clears navigation stack

---

## Screen 2: HomeScreen

```
┌─────────────────────────────────────┐
│  Friendsheet                    ⋮  │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐  │
│  │  🤖 Hey! You recently had     │  │  ← BuddyWidget (expanded, default)
│  │  "Game Night with friends" —  │  │    shows last meeting without notes
│  │  want to save your memories?  │  │    (within last 2 months)
│  │                               │  │
│  │  [Let's do it!]           [X] │  │  ← X collapses to icon
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  📅 Import your past meetings │  │  ← CalendarOnboardingCta
│  │  Connect Google Calendar to   │  │    visible when < 50 meetings
│  │  get started quickly          │  │    AND not dismissed
│  │                               │  │
│  │  [Import from Calendar]  [X]  │  │
│  └───────────────────────────────┘  │
│                                     │
│  <   Statistics             🎛  >  │
│  ┌───────────────────────────────┐  │
│  │     [Statistics Card]         │  │
│  └───────────────────────────────┘  │
│              ● ○ ○                  │
│                                     │
│  🤖                                 │  ← Buddy icon (bottom-left, always
└─────────────────────────────────────┘    visible when widget is closed)
│  🏠    │  📅    │  👥    │  🏷️    │
└─────────────────────────────────────┘
```

### BuddyWidget
Widget priority order (highest wins):
1. **Birthday reminder** — friend with `birthDate` within next 7 days → "🎂 [Name]'s birthday is in X days — want Buddy to write something special?"
2. **Missing notes** — last meeting without notes within last 2 months → "Hey! You recently had [meeting name] — want to save your memories?"
3. **Long time no see** — any friend not seen in 3+ months → "You haven't seen [Name] in a while — maybe time to catch up?"
4. **Default** — "Hey! Can I help you with anything?"

- Expanded by default on app launch
- Closed by `[X]` button → Buddy icon persists in bottom-left corner of HomeScreen (always visible when widget closed)
- Tapping Buddy icon: reopens widget if message available; otherwise opens `AIChatScreen` in free-query mode
- Tapping the action button: opens `AIChatScreen` in the relevant mode (meeting-notes / wishes / free)

### CalendarOnboardingCta
- Visible when: `totalMeetings < 50` AND not dismissed
- Dismissed by: tapping `[X]` OR tapping `[Import from Calendar]`
- Dismissed state persisted in SharedPreferences — survives app restart
- Once dismissed or ≥ 50 meetings → never shown again

### Statistics Section Header
```
[<]   Statistics   [🎛]   [>]
```
- `[<]` / `[>]` — carousel arrow navigation, wrap-around (last→first, first→last)
- `[🎛]` — `Icons.tune` — opens `StatisticsVisibilityDialog`
- Arrows show `onPressed: null` (visually disabled) when only 1 card visible
- Swipe gesture on carousel works in parallel with arrows

### Statistics Cards (StatCard enum)
| Card | Content |
|------|---------|
| `activityBreakdown` | Animated bar chart — top activities by occurrence |
| `whoPerActivity` | Who you do each activity with |
| `interactionDistribution` | Interaction weight per person (yearly/cumulative toggle) |

Each card:
- Persists state via `AutomaticKeepAliveClientMixin` (no reload on swipe)
- Has individual year filter (3m / 6m / 12m / all time)
- Has visibility toggle managed by `StatisticsVisibilityDialog`

### StatisticsVisibilityDialog
```
┌─────────────────────────────────────┐
│  Statistics Cards               [☑] │  ← three-state select-all
├─────────────────────────────────────┤
│  ☑  Activity Breakdown              │
│  ☑  Who Per Activity                │
│  ☐  Interaction Distribution        │  ← unchecked = hidden from carousel
│                                     │
│  ☑  [last visible — disabled]       │  ← tooltip: "At least 1 card must
│                                     │    remain visible"
├─────────────────────────────────────┤
│                         [  CLOSE  ] │
└─────────────────────────────────────┘
```

**Select-all toggle states:**

| Icon | Meaning | Tap action |
|------|---------|------------|
| `check_box` | All visible | Deselect all (min 1 enforced) |
| `indeterminate_check_box` | Partial | Select all |
| `check_box_outline_blank` | All hidden | Select all |

- Changes apply immediately — no confirm step
- Persistence: SharedPreferences key `stats_carousel_hidden_cards`

---

## Screen 3: MeetingsListScreen

### Default State
```
┌─────────────────────────────────────┐
│  MY MEETINGS                🔍  ⋮  │  ← search icon expands inline
├─────────────────────────────────────┤
│                                     │
│  2026  ▼                            │
│    March 2026 · 3 meetings  ▼       │
│    ┌─────────────────────────────┐  │
│    │ Coffee with Anna   Feb 8 ⚖3│  │  ← compact MeetingCard
│    └─────────────────────────────┘  │
│    ┌─────────────────────────────┐  │
│    │ Team lunch         Feb 5 ⚖8│  │
│    └─────────────────────────────┘  │
│    February 2026 · 2 meetings  ▶    │  ← collapsed month
│                                     │
│  2025  ▶  (collapsed year)          │
│                                     │
└─────────────────────────────────────┘
│  🏠  │  📅  │  👥  │  🏷️          │
└─────────────────────────────────────┘
```

### Grouping & Collapse Behavior
- Structure: Year → Month → MeetingCards
- Current month: expanded by default
- Previous month: expanded by default
- Older months: collapsed
- Current year: expanded by default
- Older years: collapsed
- Tap year/month header → toggle expand/collapse

### MeetingCard (compact variant)
```
┌─────────────────────────────────────┐
│ Coffee with Anna          Feb 8  ⚖3│
│ 2 people · Running, Coffee          │
└─────────────────────────────────────┘
```
- Reduced padding and font sizes vs original card
- Tap → `MeetingDetailScreen`

### Search State
```
│  [🔍 Search meetings...        ] ✕  │  ← tap 🔍 to expand, ✕ to close
├─────────────────────────────────────┤
│  [filtered meeting cards]           │
└─────────────────────────────────────┘
```

### Empty State
```
┌─────────────────────────────────────┐
│             [Illustration]          │
│       No meetings yet!              │
│    Tap + to add your first          │
└─────────────────────────────────────┘
```

---

## Screen 4: MeetingDetailScreen

```
┌─────────────────────────────────────┐
│  ← Meeting Detail           ✏️  🗑  │
├─────────────────────────────────────┤
│                                     │
│  Coffee with Anna                   │
│  February 8, 2026                   │
│  ⚖  Weight: 3                       │
│                                     │
│  Participants                        │
│  Anna Smith                    [+]  │
│    ⭐ +2: Zorganizowała całe wyjście │
│  John Doe                      [+]  │
│                                     │
│  Activities                          │
│  ☕ Coffee · 🏃 Running              │
│                                     │
└─────────────────────────────────────┘
```

**Person Bonus Dialog (US-130):**
```
┌─────────────────────────────────────┐
│  Bonus dla Anna Smith               │
├─────────────────────────────────────┤
│  Punkty                             │
│  ○ 1   ● 2   ○ 3                   │
│                                     │
│  Za co?                             │
│  ┌─────────────────────────────┐   │
│  │ Zorganizowała całe wyjście  │   │
│  └─────────────────────────────┘   │
│                                     │
│         [Anuluj]  [Dodaj bonus]     │
└─────────────────────────────────────┘
```

**Behavior:**
- `✏️` → opens `EditMeetingScreen` (pre-filled form)
- `🗑` → confirmation dialog → delete → back to `MeetingsListScreen`
- Participants shown as resolved full names (not IDs)
- Activities shown with category icons
- `[+]` per participant → opens PersonBonusDialog (point picker 1–3 + required comment)
- Existing bonuses shown below participant name (star icon + points + comment)
- Long press on bonus → delete confirmation → removes bonus and its notes entry

---

## Screen 5: Add / Edit Meeting Screen

```
┌─────────────────────────────────────┐
│  ← ADD MEETING                      │
├─────────────────────────────────────┤
│                                     │
│  Meeting Name *                     │
│  ┌─────────────────────────────┐   │
│  │ e.g., Coffee with Anna      │   │
│  └─────────────────────────────┘   │
│  0/50                               │
│                                     │
│  Date *                             │
│  ┌──────────────────┐  📅          │
│  │  08/02/2026      │              │
│  └──────────────────┘              │
│                                     │
│  Weight *                           │
│  ┌──────────────────────────────┐  │
│  │   [-]    3    [+]            │  │
│  └──────────────────────────────┘  │
│  Fibonacci: 1, 2, 3, 5, 8, 13, 21  │
│                                     │
│  Participants * (min. 1)            │
│  ┌─────────────────────────────┐   │
│  │ 🔍 Type name...             │   │
│  └─────────────────────────────┘   │
│  [x] Anna Smith  [x] John Doe       │
│                                     │
│  Activities * (min. 1)              │
│  ┌─────────────────────────────┐   │
│  │ 🔍 Add activity...          │   │
│  └─────────────────────────────┘   │
│  [x] Coffee ☕  [x] Running 🏃      │
│                                     │
│  ┌─────────────────────────────────┐│
│  │          SAVE MEETING           ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

**Behavior:**
- Name: max 50 chars, required
- Date: defaults to today, date picker on tap
- Weight: Fibonacci stepper (1→2→3→5→8→13→21), default 3
- Participants: autocomplete from Firestore — `"Add [name]"` option creates new person
- Activities: autocomplete from user's category tree — `"Add [name]"` creates root category
- Save button disabled during network call (prevents double submit)
- Validation: all three required fields must be filled before save

---

## Screen 6: PersonsListScreen (Friends Tab) — US-062

Persons are displayed in named groups (friend groups) with an "Ungrouped" section at the bottom for persons not assigned to any group.

```
┌─────────────────────────────────────┐
│  Friends                  🔍  +  ⋮  │
├─────────────────────────────────────┤
│                                     │
│  ▼ 🏃 Running Crew            👤+  │  ← ExpansionTile: group name + icon
│  ┌─────────────────────────────┐   │    👤+ = assign persons button
│  │  AB  Anna Bogucka           │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │  JD  John Doe               │   │
│  └─────────────────────────────┘   │
│                                     │
│  ▶ ☕ Coffee Friends           👤+  │  ← collapsed group
│                                     │
│  ─── Ungrouped ──────────────────   │  ← always visible, non-collapsible
│  ┌─────────────────────────────┐   │
│  │  MK  Maria Kowalska         │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
│  🏠  │  📅  │  👥  │  🏷️          │
└─────────────────────────────────────┘
```

### AppBar `+` button — bottom sheet chooser
```
┌─────────────────────────────────────┐
│                                     │
│  ┌─────────────────────────────┐   │
│  │  👤 Add Person              │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │  📁 Add Group               │   │
│  └─────────────────────────────┘   │
│                                     │
│                    [  CANCEL  ]     │
└─────────────────────────────────────┘
```

### Group long-press → bottom sheet
```
┌─────────────────────────────────────┐
│  Running Crew                       │
│  ─────────────────────────────────  │
│  ✏️  Edit group                     │
│  🗑  Delete group                   │
│                    [  CANCEL  ]     │
└─────────────────────────────────────┘
```
- Delete: confirmation dialog — "Persons will not be deleted"

### Add / Edit Group Dialog
```
┌─────────────────────────────────────┐
│  Add Group                          │
├─────────────────────────────────────┤
│  Name (required)                    │
│  ┌─────────────────────────────┐   │
│  │ e.g. Running Crew           │   │
│  └─────────────────────────────┘   │
│                                     │
│  Icon (optional)                    │
│  ← [ None ][ 🏃 ][ ☕ ][ 🎬 ] →   │  ← horizontal scrollable icon picker
│             selected                │    reuses activity_icons set
│                                     │
│                    [CANCEL]  [SAVE] │
└─────────────────────────────────────┘
```
- Save disabled when name is empty
- Edit mode: dialog pre-filled with current name and icon

### Assign Persons Bottom Sheet (👤+ button on group)
```
┌─────────────────────────────────────┐
│  Add to Running Crew                │
├─────────────────────────────────────┤
│  ☐  Maria Kowalska                  │  ← only persons NOT already in group
│  ☐  Piotr Wiśniewski                │
│                                     │
│                         [  DONE  ]  │
└─────────────────────────────────────┘
```
- Shows only persons not already assigned to this group
- Snackbar shown if all persons are already in the group

### Search State (active)
- Search flattens all groups into a single unstructured list — no headers
- Matches: firstName, lastName, all nicknames

### Empty State
```
│             [Illustration]          │
│     No friends added yet!           │
│  Tap + to add your first person     │
```

**Behavior:**
- `🔍` → expandable search bar (same pattern as MeetingsListScreen)
- `+` → bottom sheet chooser (Add Person / Add Group)
- Tap person row → `PersonDetailScreen`
- Long-press group header → Edit / Delete bottom sheet
- `👤+` on group → `AssignPersonsBottomSheet`

---

## Screen 7: PersonDetailScreen — US-062, US-099

```
┌─────────────────────────────────────┐
│  ← Person Detail            ✏️  🗑  │
├─────────────────────────────────────┤
│                                     │
│         AB                          │
│      Anna Bogucka                   │
│                                     │
│  Meetings together: 7  🔍           │  ← 🔍 tappable — opens PersonMeetingsScreen
│                                     │
│  ─────────────────────────────────  │
│  Nicknames                          │
│  [Ania ✕]  [Anka ✕]  [+ add]       │  ← InputChip list
│                                     │
│  ─────────────────────────────────  │
│  Groups                             │
│  ☑  🏃 Running Crew                 │  ← CheckboxListTile per group
│  ☐  ☕ Coffee Friends               │  ← tap to add/remove from group
│  ☐  (no icon) Book Club             │
│                                     │
└─────────────────────────────────────┘
```

**Behavior:**
- `✏️` → Edit Person dialog (first name / last name)
- `🗑` → confirmation dialog
  - If person has meetings: warning shown before confirmation
  - On confirm: person deleted, removed from all meetings AND all groups (cascade)
  - Meetings themselves are preserved
- Nicknames section: add via text field, remove via `✕` chip
- Groups section: each checkbox is a live toggle — checking adds to group, unchecking removes
- Groups section visible only if at least one group exists for the user
- `🔍` next to meeting count → navigates to `PersonMeetingsScreen` (US-099)

---

## Screen 7b: PersonMeetingsScreen — US-099

```
┌─────────────────────────────────────┐
│  ← Meetings with Anna               │
├─────────────────────────────────────┤
│                                     │
│  2026                               │
│    March                            │
│  ┌───────────────────────────────┐  │
│  │  🗓 Coffee break   Mar 10     │  │  ← MeetingCard (same as MeetingsListScreen)
│  │  👥 2 participants            │  │
│  └───────────────────────────────┘  │
│                                     │
│  2025                               │
│    December                         │
│  ┌───────────────────────────────┐  │
│  │  🗓 Board games    Dec 21     │  │
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

**Behavior:**
- Lists only meetings where this person is a participant
- Grouped by year and month — same layout as `MeetingsListScreen`
- Tap meeting card → `MeetingDetailScreen` → `EditMeetingScreen` (same flow as main meetings list)
- Empty state shown if person has no meetings
- Back navigation returns to `PersonDetailScreen`

---

## Screen 8: ActivitiesListScreen

```
┌─────────────────────────────────────┐
│  Activities                + 🔍    │
├─────────────────────────────────────┤
│                                     │
│  ▶ 🏃 Sport                    +   │  ← global (long-press: no action)
│  ▶ 🍕 Food & Drinks            +   │
│  ▶ 🎬 Entertainment            +   │
│  ▶ ✈️  Travel                  +   │
│  ▶ 🏔️  Góry                   +   │  ← user-created root
│                                     │
└─────────────────────────────────────┘
│  🏠  │  📅  │  👥  │  🏷️          │
└─────────────────────────────────────┘
```

### Expanded State
```
│  ▼ 🏃 Sport                    +   │
│      💪 Gym                        │  ← leaf (long-press → Edit/Delete)
│      🎾 Tennis                     │
│      🏔️  Hiking                   │
│  ▶ 🍕 Food & Drinks            +   │
```

### Add Activity Dialog
```
┌─────────────────────────────────────┐
│  Add Activity                       │
├─────────────────────────────────────┤
│  Name                               │
│  ┌─────────────────────────────┐   │
│  │ e.g. Kayaking               │   │
│  └─────────────────────────────┘   │
│                                     │
│  Parent category                    │
│  ┌─────────────────────────────┐   │
│  │ None (top-level)          ▼ │   │
│  └─────────────────────────────┘   │
│                                     │
│  Icon                               │
│  [🏃][🍕][🎬][✈️][💪][🎾]...      │
│                          CANCEL SAVE│
└─────────────────────────────────────┘
```

**Behavior:**
- All sections collapsed by default
- `+` in AppBar → Add root category (no parent preselected)
- `+` on section row → Add child (parent preselected)
- Long-press on **user-owned** category → Edit / Delete bottom sheet
- Long-press on **global** category → no action (read-only)
- Delete parent → cascade deletes all children
- Search filters leaf names, auto-expands matching sections

---

## Screen 9: SettingsScreen

```
┌─────────────────────────────────────┐
│  Settings                       ⋮  │
├─────────────────────────────────────┤
│                                     │
│  Account                            │
│  ┌─────────────────────────────┐   │
│  │  👤 John Doe                │   │
│  │     john.doe@gmail.com      │   │
│  └─────────────────────────────┘   │
│                                     │
│  Data                               │
│  ┌─────────────────────────────┐   │
│  │  📤 Export data as JSON     │   │
│  └─────────────────────────────┘   │
│                                     │
│  Google Calendar                    │
│  ┌─────────────────────────────┐   │
│  │  🔗 Connected               │   │  ← when connected
│  │  Disconnect Calendar        │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Calendar section states:**

| State | Content |
|-------|---------|
| Not connected | `"Connect Google Calendar"` tile → `CalendarPermissionScreen` |
| Connected | `"Connected ✓"` label + `"Disconnect Calendar"` tile |

**Export behavior:**
- Exports all meetings to JSON
- File saved to device Downloads folder: `friendsheet_export_YYYY-MM-DD.json`
- Success snackbar with file path shown

---

## Screen 10: CalendarPermissionScreen

```
┌─────────────────────────────────────┐
│  ← Import from Calendar             │
├─────────────────────────────────────┤
│                                     │
│         [Calendar Icon]             │
│                                     │
│   Connect Google Calendar           │
│                                     │
│   Friendsheet will read your        │
│   calendar events to help you       │
│   add past meetings. Read-only      │
│   access — we never modify your     │
│   calendar.                         │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  Connect Google Calendar    │   │
│  └─────────────────────────────┘   │
│                                     │
│           Not now                   │
│                                     │
└─────────────────────────────────────┘
```

**Behavior:**
- `"Connect Google Calendar"` → OAuth consent (Google account picker)
- On grant → navigates to `CalendarEventsScreen`
- `"Not now"` → back to previous screen
- On deny → informative message, user can retry

---

## Screen 11: CalendarEventsScreen

```
┌─────────────────────────────────────┐
│  ← Browse Events                    │
├─────────────────────────────────────┤
│  ▶ Filters                          │  ← collapsible filter panel
├─────────────────────────────────────┤
│                                     │
│  ☐ Team standup        Mon Feb 3    │  ← CalendarEventCard
│    👥 anna@, john@                  │
│                                     │
│  ☑ Coffee with Anna    Fri Jan 31   │  ← selected
│    👥 anna@work.com                 │
│                                     │
│  ☐ All-hands meeting   Thu Jan 30   │
│    (all day)                        │
│                                     │
│  2 selected  [Select All]           │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      Import (2)             │   │  ← disabled when 0 selected
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Filter Panel (expanded)
```
┌─────────────────────────────────────┐
│  ▼ Filters                          │
│                                     │
│  From    [Jan 1, 2025]  📅         │
│  To      [Feb 8, 2026]  📅         │
│                                     │
│  Calendars                          │
│  ☑ john.doe@gmail.com (primary)     │
│  ☑ Work Calendar                    │
│                                     │
│  ☑ Exclude all-day events           │
│                                     │
│  [  Apply Filters  ]                │
└─────────────────────────────────────┘
```

**Behavior:**
- Default date range: last 12 months
- Default: primary calendar selected, all-day excluded
- `"Apply Filters"` → triggers API call with new params
- Multi-select with checkboxes; `"Select All"` / `"Deselect All"`
- `"Import (N)"` disabled when 0 selected
- On import → creates `ImportCandidate` list → navigates to `MeetingInboxScreen`

### Empty State
```
│           📅                        │
│   No events found                   │
│   Try adjusting the date range      │
│   or calendar filters               │
```

---

## Screen 12: MeetingInboxScreen

```
┌─────────────────────────────────────┐
│  ← Meeting Inbox                    │
│  2 of 5 reviewed                    │  ← progress indicator
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐  │
│  │  📅 Team standup   Feb 3      │  │  ← ImportCandidate card
│  │  👥 anna@, john@              │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  📅 Coffee with Anna  Jan 31  │  │
│  │  👥 anna@work.com             │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │  ← already reviewed cards
│  │  ✅ All-hands   Jan 30        │  │    (confirmed or skipped)
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

**Behavior:**
- Source-agnostic — Calendar (US-067) and Photos (US-070) both feed into same inbox
- Candidates persisted in SharedPreferences (`meeting_inbox_candidates`) — survive app restart
- `MeetingInboxProvider` owned by `MainScreen` for full-session lifetime
- Drawer shows `"Pending Meetings (N)"` badge when inbox is non-empty
- Tap card → `InboxItemEditScreen`
- When inbox empty → `ImportSuccessScreen`
- Shared packages (peer-to-peer): swipe left on package tile → "Delete" action (US-098)
  - Confirmation dialog shown before deletion
  - Package removed from `users/{uid}/pending_meetings/` without any data import

---

## Screen 13: InboxItemEditScreen

```
┌─────────────────────────────────────┐
│  ← Review Meeting                   │
├─────────────────────────────────────┤
│                                     │
│  Meeting Name *                     │
│  ┌─────────────────────────────┐   │
│  │ Team standup                │   │  ← pre-filled from event title
│  └─────────────────────────────┘   │
│                                     │
│  Date *                             │
│  ┌──────────────────┐  📅          │
│  │  03/02/2026      │              │  ← pre-filled from event date
│  └──────────────────┘              │
│                                     │
│  Weight *                           │
│  ┌──────────────────────────────┐  │
│  │   [-]    3    [+]            │  │  ← default 3, Fibonacci stepper
│  └──────────────────────────────┘  │
│                                     │
│  Participants                        │
│  Suggested from attendees:          │
│  [✓ Anna Smith]  [✓ John Doe]       │  ← email heuristic suggestions
│  [+ Add manually]                   │
│                                     │
│  Activities * (min. 1)              │
│  ┌─────────────────────────────┐   │
│  │ 🔍 Add activity...          │   │  ← no pre-fill, standard autocomplete
│  └─────────────────────────────┘   │
│                                     │
│  ┌──────────────┐  ┌─────────────┐ │
│  │    SKIP      │  │   CONFIRM   │ │
│  └──────────────┘  └─────────────┘ │
└─────────────────────────────────────┘
```

**Behavior:**
- `"Confirm"` → saves meeting to Firestore, removes candidate from inbox, back to inbox list
- `"Skip"` → removes candidate from inbox without saving, back to inbox list
- Back navigation (← ) → returns to inbox list without data loss
- Participant suggestions: attendee emails parsed via heuristic (`firstname.lastname@domain`)
- Each suggestion can be accepted (added as chip) or dismissed

---

## Screen 14: ImportSuccessScreen

```
┌─────────────────────────────────────┐
│                                     │
│         [Success Illustration]      │
│                                     │
│      Import complete! 🎉            │
│                                     │
│      4 meetings added to            │
│      Friendsheet                    │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      Go to Meetings         │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Behavior:**
- Shown when inbox is empty (all candidates confirmed or skipped)
- Displays count of meetings actually confirmed (not total candidates)
- `"Go to Meetings"` → navigates to `MeetingsListScreen`, clears inbox navigation stack

---

## Navigation Flow

```
LoginScreen
    └── HomeScreen (Tab 0)
          ├── [FAB] → AddMeetingScreen
          ├── [CTA] → CalendarPermissionScreen → CalendarEventsScreen
          │                                           └── [Import] → MeetingInboxScreen
          │                                                               ├── card tap → InboxItemEditScreen
          │                                                               └── (empty) → ImportSuccessScreen
          │
          ├── [Drawer] → "Import from Calendar"  → CalendarPermissionScreen
          │           → "Browse & Import Events" → CalendarEventsScreen
          │           → "Pending Meetings (N)"   → MeetingInboxScreen (when inbox non-empty)
          │
          ├── Tab 1: MeetingsListScreen
          │     ├── MeetingCard tap → MeetingDetailScreen
          │     │     └── [✏️] → EditMeetingScreen
          │     └── [FAB] → AddMeetingScreen
          │
          ├── Tab 2: PersonsListScreen
          │     ├── Person tap → PersonDetailScreen (with FriendGroupsProvider injected)
          │     │     └── [🔍 meeting count] → PersonMeetingsScreen
          │     │           ├── MeetingCard tap → MeetingDetailScreen → EditMeetingScreen
          │     │           └── ← back → PersonDetailScreen
          │     ├── [+] → bottom sheet (Add Person / Add Group)
          │     └── Group [👤+] → AssignPersonsBottomSheet
          │
          ├── Tab 3: ActivitiesListScreen
          │
          └── [⋮ Drawer] → SettingsScreen
                └── Calendar section → CalendarPermissionScreen
                                          └── CalendarEventsScreen
```

---

## Design System Reference

| Token | Value |
|-------|-------|
| Primary | `#43A047` (Green) |
| Secondary | `#FFB300` (Amber) |
| Error | `#E53935` (Red) |
| Surface | `#FAFAF7` (Warm White) |
| Font | Nunito |
| Card radius | 16dp |
| Button radius | 12dp |
| Chip radius | 8dp |
| Bottom sheet radius | 24dp (top corners) |
| Dialog radius | 20dp |
| Min touch target | 48dp |
| Base spacing unit | 8dp |

---

---

## Screen 15: AIChatScreen — US-087

```
┌─────────────────────────────────────┐
│  ←  Buddy                       ⋮  │  ← back button, Buddy name in header
├─────────────────────────────────────┤
│                                     │
│         ┌──────────────────────┐   │
│         │ Hey! I see you had   │   │  ← Buddy message bubble (left-aligned)
│         │ "Game Night" last    │   │
│         │ Saturday. Tell me    │   │
│         │ about it!            │   │
│         └──────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │  ← User message bubble (right-aligned)
│  │ Bania z chłopakami, granie  │   │
│  │ w piłkę, prezentacja proj.  │   │
│  └─────────────────────────────┘   │
│                                     │
│         ┌──────────────────────┐   │
│         │ Got it! Saved to     │   │
│         │ "Game Night". 🎉     │   │
│         │ Anything else to add?│   │
│         └──────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  [Type a message...]         [Send] │
└─────────────────────────────────────┘
```

**Modes:**

| Mode | Entry point | Context sent to AI |
|------|------------|-------------------|
| Meeting notes | BuddyWidget tap (specific meeting) | That meeting's details |
| Friend wishes | User mentions a person name | Meetings with that person only (last 12 months) |
| Free query | BuddyWidget icon tap / default | Full meeting history (last 12 months) |

**Empty state (free query, no prior messages):**
- Shows 3 example prompts: "Who did I see most this year?", "Write birthday wishes for [Name]", "Who should I catch up with?"

**Guard logic (on screen open):**
- No API key → navigate to `AISettingsScreen`
- No consent → navigate to `AIConsentScreen`

---

## Screen 16: AIConsentScreen — US-085

```
┌─────────────────────────────────────┐
│  ←  Before we start                 │
├─────────────────────────────────────┤
│                                     │
│      🤖  Meet Buddy                 │
│                                     │
│  Buddy uses OpenAI to answer your   │
│  questions about your social life.  │
│                                     │
│  What IS sent to OpenAI:            │
│  • Anonymized meeting summaries     │
│    (Friend_A, Friend_B — not real   │
│    names)                           │
│  • Activity names and dates         │
│  • Your meeting notes (anonymized)  │
│                                     │
│  What is NOT sent:                  │
│  • Real names of your friends       │
│  • Raw Firestore data               │
│  • Your API key (stays on device)   │
│                                     │
│  [Privacy Policy]                   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │     I understand, let's go  │   │  ← active tap required
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

## Screen 17: AISettingsScreen — US-088

```
┌─────────────────────────────────────┐
│  ←  AI Assistant Settings           │
├─────────────────────────────────────┤
│                                     │
│  OpenAI API Key                     │
│  ┌─────────────────────────────┐   │
│  │  sk-...••••••••••••••abcd  │   │  ← masked, shows last 4 chars
│  └─────────────────────────────┘   │
│  [Change Key]        [Delete Key]   │
│                                     │
│  Your key is stored securely on     │
│  this device and never shared.      │
│                                     │
└─────────────────────────────────────┘
```

**Navigation:** Accessible from Settings tab and from guard redirect in `AIChatScreen`.

---

*This document reflects the implemented state of Friendsheet as of US-099. Screens 15–17 planned for M7.*
*Update when new screens or significant UI changes are shipped.*

---

## Screen 7 (updated): PersonDetailScreen — M8 additions (US-120, US-121, US-122)

Updated layout with Catch-up List section and Couple Link:

```
┌─────────────────────────────────────┐
│  ← Person Detail            ✏️  🗑  │
├─────────────────────────────────────┤
│                                     │
│         AB                          │
│      Anna Bogucka                   │
│                                     │
│  Meetings together: 7  🔍           │
│                                     │
│  ─────────────────────────────────  │
│  Catch-up List                      │  ← new section (US-120, US-121)
│  ┌───────────────────────────────┐  │
│  │  July — Japan trip        ✓  │  │  ← ✓ = Mark as discussed
│  │  September — new apartment    │  │
│  └───────────────────────────────┘  │
│  [+ Add topic]                      │
│                                     │
│  ▸ History (2)                      │  ← collapsible archived topics (US-121)
│                                     │
│  ─────────────────────────────────  │
│  Partner                            │  ← Couple Link section (US-122)
│  Linked with: Tomek W.     [Unlink] │  ← or [Link as couple] if unlinked
│                                     │
│  ─────────────────────────────────  │
│  Nicknames                          │
│  [Ania ✕]  [Anka ✕]  [+ add]       │
│                                     │
│  ─────────────────────────────────  │
│  Groups                             │
│  ☑  🏃 Running Crew                 │
│  ☐  ☕ Coffee Friends               │
│                                     │
└─────────────────────────────────────┘
```

**Catch-up List behavior:**
- Tapping `✓` → marks topic as discussed → moves to History with `archivedAt` timestamp
- `[+ Add topic]` → inline text field dialog
- Long-press or swipe on topic → delete (permanent, confirmation required)
- "History" → collapsible section, read-only, sorted by `archivedAt` desc

**Partner section behavior:**
- If no partner linked: shows `[Link as couple]` button → person picker → merge dialog
- If partner linked: shows partner name + `[Unlink]` → separation flow dialog

---

## Screen 18: FriendsQuestListScreen — US-124

```
┌─────────────────────────────────────┐
│  ←  Friends-Quest                   │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐  │
│  │  🗂 Weekend in Kraków         │  │
│  │  Tomek, Jola · 5 tasks left   │  │  ← active quest card
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  🗂 Robert's visit            │  │
│  │  Robert · 2 tasks left        │  │
│  └───────────────────────────────┘  │
│                                     │
│                              [＋]   │  ← FAB — create new quest
│                                     │
└─────────────────────────────────────┘
```

**Empty state:** "No active Friends-Quests. Tap + to prepare for your next meeting."

---

## Screen 19: FriendsQuestDetailScreen — US-125, US-126

```
┌─────────────────────────────────────┐
│  ← Weekend in Kraków       [⋮ menu] │
├─────────────────────────────────────┤
│  Participants: Tomek W., Jola K.    │
│  Meeting: Coffee break Mar 10  [+]  │  ← link to meeting (US-126)
│                                     │
│  Tasks                              │
│  ☐  Tomek — new job update          │
│  ☐  Jola — new apartment            │  ← shared topic (deduplicated)
│  ☑  Tomek — Italy photos            │  ← completed task
│  ☐  General — board game night      │  ← manual task, no person
│                                     │
│  [+ Add task]                       │
│                                     │
│  ──────────────────────────────     │
│  [Complete Quest]                   │  ← pushes notes to linked meeting
│                                     │
└─────────────────────────────────────┘
```

**Task behavior:**
- ☐ → ☑ tapping completes task; archives source Catch-up Topic on person profile
- Long-press task → edit text / delete
- Edit propagates to source topic (and partner if couple-linked)
- Delete removes from quest only; source topic unchanged
- `[⋮ menu]` → manage participants / delete quest