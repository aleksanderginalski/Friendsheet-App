# Friendsheet — Manual Test Cases

**Version:** 1.0  
**Date:** February 2026  
**Scope:** M1 (Add Meeting) + M2 (Management & CRUD)  
**Tester:** QA Engineer  
**Environment:** Android physical device / emulator (API 21+)

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Pass |
| ❌ | Fail |
| ⏭️ | Skipped |
| 🔁 | Retest needed |

**Priority:** P0 = Blocker · P1 = Critical · P2 = Major · P3 = Minor

---

## TC-AUTH: Authentication

### TC-AUTH-001 — First-time Google Sign-In
**Priority:** P0  
**Related US:** US-004

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open app for the first time | Login screen displayed with "Sign in with Google" button |✅ | |
| 2 | Tap "Sign in with Google" | Google account picker appears |✅ | |
| 3 | Select Google account | Firebase auth completes, user redirected to MainScreen |✅ | |
| 4 | Open Firestore console | `users/{uid}` document exists with `onboardingCompletedAt` field |✅ | |
| 5 | Open `users/{uid}/activity_categories` | Global categories copied to user subcollection |✅ | |

---

### TC-AUTH-002 — Returning user sign-in (idempotent onboarding)
**Priority:** P0  
**Related US:** US-004, US-044

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Sign out from app | Redirected to login screen |✅ | |
| 2 | Sign in again with same Google account | Redirected to MainScreen |✅ | |
| 3 | Open Firestore console | `users/{uid}/activity_categories` count unchanged (no duplicates) |✅ | |

---

### TC-AUTH-003 — Session restore on app restart
**Priority:** P0  
**Related US:** US-004

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Sign in successfully | Redirected to MainScreen |✅ | |
| 2 | Close app completely (remove from recents) | — |✅ | |
| 3 | Reopen app | MainScreen shown immediately, no login prompt |✅ | |

---

### TC-AUTH-004 — Logout flow
**Priority:** P1  
**Related US:** US-006

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap logout icon in AppBar | Confirmation dialog appears |✅ | |
| 2 | Tap "Cancel" | Dialog dismissed, user stays on current screen |✅ | |
| 3 | Tap logout icon again | Confirmation dialog appears |✅ | |
| 4 | Tap "Confirm" / "Logout" | User signed out, redirected to login screen |✅ | |
| 5 | Press Android back button | App does not navigate back to protected screen |✅ | |

---

## TC-NAV: Navigation & Main Screen

### TC-NAV-001 — Bottom navigation tabs
**Priority:** P1  
**Related US:** US-021

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap "Meetings" tab | Meetings list screen visible |✅ | |
| 2 | Tap "Friends" tab | Persons list screen visible |✅ | |
| 3 | Tap "Activities" tab | Activities list screen visible |✅ | |
| 4 | Tap "Home" tab | Home screen visible |✅ | |

---

### TC-NAV-002 — FAB navigation
**Priority:** P1  
**Related US:** US-021

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap FAB (+) button from any tab | Add Meeting screen opens |✅ | |
| 2 | Press back | Returns to previous tab |✅ | |

---

## TC-MEET: Add Meeting

### TC-MEET-001 — Successful meeting creation (happy path)
**Priority:** P0  
**Related US:** US-010, US-011, US-012, US-013, US-014, US-015

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Add Meeting screen | Empty form shown, date defaults to today |✅ | |
| 2 | Enter meeting name (e.g. "Coffee with Jan") | Name field shows input, character counter updates |✅ | |
| 3 | Tap date field and select a date | Date field updates to selected date |✅ | |
| 4 | Tap weight stepper to select weight (e.g. 3) | Weight value updates (Fibonacci sequence: 1,2,3,5,8,13,21) |✅ | |
| 5 | Type participant name in autocomplete | Matching suggestions appear |✅ | |
| 6 | Select a participant | Chip added to participants field |✅ | |
| 7 | Type activity name in autocomplete | Matching suggestions appear |✅ | |
| 8 | Select an activity | Chip added to activities field |✅ | |
| 9 | Tap "Save" | Loading indicator shown, then green snackbar "Meeting saved" |✅ | |
| 10 | Check Meetings tab | New meeting appears at top of list |✅ | |

---

### TC-MEET-002 — Meeting name validation
**Priority:** P1  
**Related US:** US-011

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Leave name field empty, tap Save | Error message shown under name field |✅ | |
| 2 | Type exactly 50 characters | Character counter shows "50/50", input accepted |✅ | |
| 3 | Try to type 51st character | Input blocked at 50 characters |✅ | |

---

### TC-MEET-003 — Add new participant during meeting creation
**Priority:** P1  
**Related US:** US-013

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Type name that doesn't exist in autocomplete | "Add [name]" option appears in dropdown |✅| |
| 2 | Tap "Add [name]" | Dialog or inline input for firstName / lastName appears |✅ | |
| 3 | Fill firstName, leave lastName empty, confirm | Person added as chip with firstName only |✅ | |
| 4 | Save meeting | Person saved to Firestore, visible in Friends tab |✅| |

---

### TC-MEET-004 — Add new activity during meeting creation
**Priority:** P1  
**Related US:** US-014, US-043

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Type activity name that doesn't exist | "Add [name]" option appears |✅ | |
| 2 | Tap "Add [name]" | New root activity category created |✅ | |
| 3 | Save meeting | Activity visible in Activities tab |✅ | |

---

### TC-MEET-005 — Duplicate participants/activities blocked
**Priority:** P2  
**Related US:** US-013, US-014

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Add participant "Jan Kowalski" | Chip appears |✅ | |
| 2 | Try to add "Jan Kowalski" again | Already selected — not added again |✅ | |
| 3 | Add activity "Running" | Chip appears |✅ | |
| 4 | Try to add "Running" again | Already selected — not added again |✅ | |

---

### TC-MEET-006 — Save validation: missing required fields
**Priority:** P0  
**Related US:** US-015

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Leave all fields empty, tap Save | Error messages shown, save blocked |✅ | |
| 2 | Fill name only, tap Save | Error: participants required |✅ | |
| 3 | Fill name + participant, tap Save | Error: activity required |✅ | |
| 4 | Fill all required fields, tap Save | Meeting saved successfully |✅ | |

---

## TC-MEET-LIST: Meetings List

### TC-MEET-LIST-001 — Meetings grouped by year
**Priority:** P1  
**Related US:** US-021

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Meetings tab with multiple meetings across years | Meetings grouped under year headers |✅ | |
| 2 | Check current year section | Expanded by default |✅ | |
| 3 | Check older year section | Collapsed by default |✅ | |
| 4 | Tap collapsed year header | Section expands |✅ | |
| 5 | Tap expanded year header | Section collapses |✅ | |

---

### TC-MEET-LIST-002 — Empty state
**Priority:** P2  
**Related US:** US-021

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Meetings tab with no meetings | Empty state message shown (no crash) |✅ | |

---

## TC-MEET-DETAIL: Meeting Detail & Edit

### TC-MEET-DETAIL-001 — View meeting details
**Priority:** P1  
**Related US:** US-022

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap meeting card in list | Meeting Detail screen opens |✅ | |
| 2 | Verify displayed fields | Name, date, weight, participants (resolved to names), activities visible |✅ | |

---

### TC-MEET-DETAIL-002 — Edit meeting (happy path)
**Priority:** P1  
**Related US:** US-023

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Meeting Detail screen | — |✅ | |
| 2 | Tap edit button | Edit mode or Edit screen opens, fields pre-filled |✅ | |
| 3 | Change meeting name | Name field updated |✅ | |
| 4 | Tap Save | Updated meeting shown in detail screen |✅ | |
| 5 | Return to Meetings list | Updated name visible in card |✅ | |

---

### TC-MEET-DETAIL-003 — Delete meeting
**Priority:** P1  
**Related US:** US-023

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Meeting Detail screen | — |✅ | |
| 2 | Tap delete button | Confirmation dialog appears |✅ | |
| 3 | Tap "Cancel" | Dialog dismissed, meeting unchanged |✅ | |
| 4 | Tap delete again, confirm | Meeting deleted, navigated back to list |✅ | |
| 5 | Check Meetings list | Deleted meeting no longer visible |✅ | |

---

## TC-FRIENDS: Persons / Friends

### TC-FRIENDS-001 — Persons list
**Priority:** P1  
**Related US:** US-024

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Friends tab | Alphabetical list of persons shown |✅ | |
| 2 | Verify each row | Full name displayed with initials avatar |✅ | |
| 3 | Open with no persons | Empty state shown |✅ | |

---

### TC-FRIENDS-002 — Search/filter persons
**Priority:** P1  
**Related US:** US-024

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Type partial name in search field | List filtered to matching persons |✅ | |
| 2 | Clear search field | Full list restored |✅ | |
| 3 | Search for name that doesn't exist | Empty state or "no results" shown |✅ | |

---

### TC-FRIENDS-003 — Add person from Friends tab
**Priority:** P1  
**Related US:** US-024

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap add person icon in Friends tab AppBar | Add person dialog/screen opens |✅ | |
| 2 | Enter firstName, leave lastName empty | Person saved, visible in list |✅ | |
| 3 | Enter firstName and lastName | Person saved with full name |✅ | |

---

### TC-FRIENDS-004 — Person detail
**Priority:** P1  
**Related US:** US-025

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap person in Friends tab | Person Detail screen opens |✅ | |
| 2 | Verify displayed fields | First name, last name, meeting count visible |✅ | |
| 3 | Check meeting count | Correct number of meetings this person is in |✅ | |

---

### TC-FRIENDS-005 — Edit person
**Priority:** P1  
**Related US:** US-025

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Person Detail screen | — |✅ | |
| 2 | Tap edit | Edit dialog/screen opens, fields pre-filled |✅ | |
| 3 | Change last name | Field updated |✅ | |
| 4 | Save | Updated name shown in detail and Friends list |✅ | |

---

### TC-FRIENDS-006 — Delete person (cascade)
**Priority:** P0  
**Related US:** US-025

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Person Detail for person with meetings | — |✅ | |
| 2 | Tap delete | Warning shown: person has associated meetings |✅ | |
| 3 | Confirm delete | Person deleted, person removed from all meetings' participant lists |✅ | |
| 4 | Check affected meetings in Meetings list | Meetings still exist, deleted person not in participants |✅ | |
| 5 | Delete person with no meetings | No warning, deleted immediately after confirmation |✅ | |

---

## TC-ACT: Activities

### TC-ACT-001 — Activities tree view
**Priority:** P1  
**Related US:** US-026

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Activities tab | Category tree shown with global + private categories |✅ | |
| 2 | Tap parent category | Children expand/collapse |✅ | |
| 3 | Verify global categories | No edit/delete on long-press (read-only) |✅ | |
| 4 | Verify private categories | Edit/delete available on long-press |✅ | |

---

### TC-ACT-002 — Add private activity category
**Priority:** P1  
**Related US:** US-026

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap add button in Activities tab | Add activity dialog opens |✅ | |
| 2 | Enter name, select icon, leave parent empty (root) | — |✅ | |
| 3 | Save | New root category appears in Activities tree |✅ | |
| 4 | Add another category with parent = category from step 3 | Child category visible under parent |✅ | |

---

### TC-ACT-003 — Edit private activity category
**Priority:** P2  
**Related US:** US-026

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Long-press private category | Edit/delete options appear |✅ | |
| 2 | Tap Edit | Edit dialog opens with pre-filled fields |✅ | |
| 3 | Change name | Name updated in tree |✅ | |

---

### TC-ACT-004 — Delete category with cascade (US-043)
**Priority:** P0  
**Related US:** US-026, US-043

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Create parent category "Sport" | Visible in Activities tree |✅ | |
| 2 | Create child category "Running" under "Sport" | Visible under Sport |✅ | |
| 3 | Long-press "Sport", tap Delete, confirm | "Sport" deleted |✅ | |
| 4 | Check Activities tree | "Running" also gone (not visible) |✅ | |
| 5 | Open Firestore console | Neither "Sport" nor "Running" documents exist |✅ | |
| 6 | Open Add Meeting autocomplete | "Running" not available |✅ | |

---

### TC-ACT-005 — Delete child category (no sibling impact)
**Priority:** P1  
**Related US:** US-043

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Create parent "Sport" with children "Running" and "Cycling" | Both children visible ✅ | |
| 2 | Delete "Running" | "Running" removed |✅ | |
| 3 | Check tree | "Cycling" still visible under "Sport" |✅ | |

---

### TC-ACT-006 — Activity search in Activities tab
**Priority:** P2  
**Related US:** US-026

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Type in search field in Activities tab | List filtered to matching categories |✅ | |
| 2 | Clear search | Full tree restored |✅ | |

---

## TC-DATA: Data Integrity

### TC-DATA-001 — Firestore path isolation
**Priority:** P0  
**Related US:** US-045

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Sign in as User A, create meetings and persons | Data visible in app |✅ | |
| 2 | Open Firestore console | Data stored under `users/{uid-A}/meetings` and `users/{uid-A}/persons` |✅ | |
| 3 | Verify root `/meetings` collection | Does not exist or is empty |✅ | |

---

### TC-DATA-002 — Onboarding idempotency
**Priority:** P0  
**Related US:** US-044

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Note count of categories in `users/{uid}/activity_categories` after first login | Count = N |✅ | |
| 2 | Sign out and sign in again | App works normally |✅ | |
| 3 | Check category count in Firestore | Still N (no duplicates created) |✅ | |


---

## TC-CAL: Calendar Import

### TC-CAL-001 — Browse events (happy path)
**Priority:** P0
**Related US:** US-067

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Connect Google Calendar (Settings or drawer) | CalendarEventsScreen opens with events loaded | ✅ | |
| 2 | Verify default filter | Date range: last 12 months, primary calendar selected, all-day excluded | ✅ | |
| 3 | Verify event card | Title, date, all-day indicator, attendee emails visible | ✅ | |
| 4 | Tap "Import (N)" with 0 selected | Button is disabled — no action | ✅ | |
| 5 | Tap an event | Checkbox toggles, counter "N selected" increments | ✅ | |
| 6 | Tap "Select All" | All checkboxes selected | ✅ | |
| 7 | Tap "Deselect All" | All checkboxes cleared | ✅ | |
| 8 | Select 3 events, tap "Import (3)" | Snackbar: "3 events ready for import" | ✅ | |

---

### TC-CAL-002 — Filter panel
**Priority:** P1
**Related US:** US-067

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap "Filters" | Panel expands — date range, calendar checkboxes, all-day toggle visible | ✅ | |
| 2 | Change "From" date to 1 month ago | Date picker opens, date updates after selection | ✅ | |
| 3 | Tap "Apply Filters" | Event list refreshes — fewer events shown | ✅ | |
| 4 | Toggle "Exclude all-day events" off, Apply | All-day events appear in list | ✅ | |
| 5 | Deselect all calendars, Apply | Empty state shown | ✅ | |

---

### TC-CAL-003 — Empty state
**Priority:** P2
**Related US:** US-067

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Set date range with no events, Apply | Empty state: icon + "No events found" + hint text | ✅ | |
| 2 | "Import" button | Disabled — 0 selected | ✅ | |

---

### TC-CAL-004 — Drawer dynamic tile
**Priority:** P1
**Related US:** US-067

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open drawer with no calendar connected | Tile shows "Import from Calendar" | ✅ | |
| 2 | Tap "Import from Calendar" | CalendarPermissionScreen shown | ✅ | |
| 3 | Tap "Connect Google Calendar" | No error — navigates to CalendarEventsScreen | ✅ | |
| 4 | Tap "Not now" | Returns to MainScreen | ✅ | |
| 5 | Open drawer with calendar connected | Tile shows "Browse & Import Events" | ✅ | |
| 6 | Tap "Browse & Import Events" | CalendarEventsScreen opens directly | ✅ | |

---

### TC-CAL-005 — Disconnect calendar
**Priority:** P1
**Related US:** US-067

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Settings with calendar connected | "Disconnect Calendar" tile visible | ✅ | |
| 2 | Tap "Disconnect Calendar" | Calendar disconnected | ✅ | |
| 3 | Open drawer | Tile shows "Import from Calendar" (not "Browse & Import Events") | ✅ | |

---

### TC-CAL-006 — CTA card behaviour
**Priority:** P1
**Related US:** US-067

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open HomeScreen with < 50 meetings | CTA card visible, no X button | ✅ | |
| 2 | Try to find dismiss button | No dismiss/close button exists | ✅ | |
| 3 | Add meetings until total ≥ 50, reopen HomeScreen | CTA card no longer visible | ✅ | |


---

## Regression Checklist

Run after every release or hotfix:

- [ ] TC-AUTH-001 First-time sign-in
- [ ] TC-AUTH-003 Session restore
- [ ] TC-AUTH-004 Logout
- [ ] TC-MEET-001 Successful meeting creation
- [ ] TC-MEET-006 Save validation
- [ ] TC-MEET-DETAIL-003 Delete meeting
- [ ] TC-FRIENDS-006 Delete person cascade
- [ ] TC-ACT-004 Delete category cascade
- [ ] TC-DATA-002 Onboarding idempotency

---

## Bug Log

| ID | Title | TC | Priority | Status | Notes |
|----|-------|-----|----------|--------|-------|
| — | — | — | — | — | No open bugs at time of M2 completion |

---

*Document maintained alongside BACKLOG.md. Update Status column after each test run.*
