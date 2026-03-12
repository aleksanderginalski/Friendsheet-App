# Friendsheet — Store Graphics Brief
**Version:** 1.0.0  
**Scope:** Feature Graphic + Screenshots for Google Play Store  
**Tools:** Figma or Canva  
**Last updated:** March 2026

---

## 1. Feature Graphic (REQUIRED)

**What it is:** Banner displayed at the top of your Google Play Store page.  
**Size:** 1024 × 500 px  
**Format:** PNG or JPG, no alpha channel  
**File name:** `feature_graphic.png`

### Composition

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│   [Logo / Icon]    Friendsheet                              │
│                    Track your social life.                   │
│                                                              │
│                                        [subtle illustration] │
└──────────────────────────────────────────────────────────────┘
```

### Specs

| Element         | Value                                      |
|-----------------|--------------------------------------------|
| Background      | #43A047 (brand green) — solid or subtle gradient to #2E7D32 |
| Logo/Icon       | App icon centered-left, ~180×180 px        |
| App name        | "Friendsheet" — Nunito Bold, white, ~72px  |
| Tagline         | "Track your social life." — Nunito Regular, white 80% opacity, ~32px |
| Illustration    | Optional: simple flat friends illustration (right side) — see Midjourney prompts in design_brief.md |
| Safe zone       | Keep all text/logo 50px away from all edges |

### Canva Quick Path (no Figma needed)
1. New design → Custom size → 1024 × 500
2. Background: solid #43A047
3. Add text: "Friendsheet" (Nunito Bold or Montserrat Bold, white)
4. Add text: "Track your social life." (lighter weight, white 80%)
5. Drop in app icon PNG (use the 512×512 version from your project)
6. Export as PNG

### Acceptance Criteria
- [ ] Text is readable on green background (white on #43A047 passes contrast)
- [ ] No important content within 50px of edges (cropping risk)
- [ ] Exported at exactly 1024×500 px
- [ ] No alpha channel (save as PNG without transparency or as JPG)

---

## 2. Screenshots

**Minimum:** 2 screenshots  
**Recommended:** 4 screenshots (one per key screen)  
**Size:** 1080 × 1920 px portrait (standard Android)  
**Format:** PNG or JPG  
**File names:** `screenshot_01_home.png`, `screenshot_02_add_meeting.png`, etc.

### How to capture

**Option A — Android Emulator (recommended for clean UI):**
1. Run `flutter run` on emulator (Pixel 6 API 34 recommended)
2. Add realistic test data first (see Section 3 below)
3. Navigate to each screen
4. Screenshot: `adb exec-out screencap -p > screenshot_name.png`
   or use Android Studio Device Manager → camera icon

**Option B — Physical device:**
1. Install release APK: `flutter install --release`
2. Volume Down + Power button for screenshot
3. Transfer from Photos app

---

### Screenshot 01 — Home / Dashboard
**File:** `screenshot_01_home.png`  
**Screen:** HomeScreen / main dashboard tab

**What to show:**
- At least 3–4 meeting cards visible
- Stats widgets populated (not empty state)
- Bottom navigation visible

**Caption for Play Store:**
> EN: "Your social life at a glance"  
> PL: "Twoje życie towarzyskie w jednym miejscu"

**Acceptance Criteria:**
- [ ] No empty states visible
- [ ] Real-looking data (not "Test Meeting 1", "Test Meeting 2")
- [ ] Status bar clean (full battery, no notifications)

---

### Screenshot 02 — Add Meeting
**File:** `screenshot_02_add_meeting.png`  
**Screen:** AddMeetingScreen — partially filled form

**What to show:**
- Meeting name filled in (e.g. "Coffee with Marta")
- Date selected
- At least 2 participant chips visible
- At least 1 activity chip visible
- Weight stepper visible

**Caption for Play Store:**
> EN: "Log any meeting in seconds"  
> PL: "Zapisz każde spotkanie w kilka sekund"

**Acceptance Criteria:**
- [ ] Form looks filled and realistic
- [ ] Keyboard not visible (screenshot before keyboard appears)
- [ ] Chips are readable

---

### Screenshot 03 — Friends List
**File:** `screenshot_03_friends.png`  
**Screen:** PersonsListScreen (Friends tab)

**What to show:**
- List of 6–10 people with initials avatars
- Search bar visible at top
- Alphabetical grouping visible

**Caption for Play Store:**
> EN: "Keep track of everyone you meet"  
> PL: "Miej wszystkich znajomych pod kontrolą"

**Acceptance Criteria:**
- [ ] At least 6 people visible (no empty list)
- [ ] Names look realistic (not "Person A", "User 1")
- [ ] Avatars with initials visible

---

### Screenshot 04 — Statistics
**File:** `screenshot_04_statistics.png`  
**Screen:** StatisticsScreen

**What to show:**
- Charts/bars populated with data
- Time range selector visible
- At least "Top persons" section visible

**Caption for Play Store:**
> EN: "Discover patterns in your social life"  
> PL: "Odkryj wzorce w swoim życiu towarzyskim"

**Acceptance Criteria:**
- [ ] Charts are not empty / not loading spinner
- [ ] Data looks meaningful (enough meetings to show bars)
- [ ] Time range filter visible

---

## 3. Test Data for Screenshots

Before capturing, seed your app with realistic-looking data.  
Use your own account or a dedicated screenshot account.

**Suggested persons:**
Anna Kowalska, Marek Wiśniewski, Julia Nowak, Piotr Zając,
Karolina Dąbrowska, Tomasz Lewandowski, Ola Wróbel, Bartek Krawczyk

**Suggested meetings (last 3 months):**
- "Coffee with Anna" — 2 weeks ago — weight 3
- "Board games night" — 1 month ago — weight 5 — 4 participants
- "Running with Marek" — 3 weeks ago — weight 2
- "Dinner at Julii" — 10 days ago — weight 8 — 3 participants
- "Cinema with Karolina" — 5 days ago — weight 3

**Suggested activities:** Running, Coffee, Board Games, Cinema, Dinner

---

## 4. Delivery Checklist

| File | Size | Status |
|------|------|--------|
| `feature_graphic.png` | 1024×500 | ☐ |
| `screenshot_01_home.png` | 1080×1920 | ☐ |
| `screenshot_02_add_meeting.png` | 1080×1920 | ☐ |
| `screenshot_03_friends.png` | 1080×1920 | ☐ |
| `screenshot_04_statistics.png` | 1080×1920 | ☐ |

All files go to: `docs/store/assets/`

---

## 5. Upload Order in Google Play Console

1. Main store listing → Graphics section
2. Upload Feature Graphic first (required to proceed)
3. Upload Screenshots (drag to reorder — order matters, first = most prominent)
4. Recommended screenshot order: Home → Statistics → Add Meeting → Friends