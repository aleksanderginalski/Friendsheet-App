# Friendsheet — Manual Test Cases

**Version:** 2.1
**Date:** March 2026
**Scope:** M1 · M2 · M3 · M3.5 (through US-062) · M5 Calendar Import + Meeting Inbox · INF Multi-Agent System  
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
| 1 | Open app for the first time | Login screen displayed with "Sign in with Google" button | ✅ | |
| 2 | Tap "Sign in with Google" | Google account picker appears | ✅ | |
| 3 | Select Google account | Firebase auth completes, user redirected to MainScreen | ✅ | |
| 4 | Open Firestore console | `users/{uid}` document exists with `onboardingCompletedAt` field | ✅ | |
| 5 | Open `users/{uid}/activity_categories` | Global categories copied to user subcollection | ✅ | |

---

### TC-AUTH-002 — Returning user sign-in (idempotent onboarding)
**Priority:** P0  
**Related US:** US-004, US-044

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Sign out from app | Redirected to login screen | ✅ | |
| 2 | Sign in again with same Google account | Redirected to MainScreen | ✅ | |
| 3 | Open Firestore console | `users/{uid}/activity_categories` count unchanged (no duplicates) | ✅ | |

---

### TC-AUTH-003 — Session restore on app restart
**Priority:** P0  
**Related US:** US-004

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Sign in successfully | Redirected to MainScreen | ✅ | |
| 2 | Close app completely (remove from recents) | — | ✅ | |
| 3 | Reopen app | MainScreen shown immediately, no login prompt | ✅ | |

---

### TC-AUTH-004 — Logout flow
**Priority:** P1  
**Related US:** US-006

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap logout icon in AppBar | Confirmation dialog appears | ✅ | |
| 2 | Tap "Cancel" | Dialog dismissed, user stays on current screen | ✅ | |
| 3 | Tap logout icon again | Confirmation dialog appears | ✅ | |
| 4 | Tap "Confirm" / "Logout" | User signed out, redirected to login screen | ✅ | |
| 5 | Press Android back button | App does not navigate back to protected screen | ✅ | |

---

### TC-AUTH-005 — Delete account
**Priority:** P1  
**Related US:** US-076

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Settings → "Delete Account" | Confirmation dialog appears with warning text |✅ | |
| 2 | Tap "Cancel" | Dialog dismissed, account intact |✅ | |
| 3 | Tap "Delete Account" again, confirm | Google re-authentication prompt appears | ✅| |
| 4 | Complete Google re-authentication | Progress indicator shown |✅ | |
| 5 | Wait for completion | User redirected to LoginScreen |✅ | |
| 6 | Open Firestore console | `users/{uid}` document and all subcollections deleted |✅ | |
| 7 | Try to sign in with same account | New account created from scratch (no old data) |✅ | |

---

## TC-ONBOARDING: Splash & Login Screen

### TC-ONBOARDING-001 — Splash screen
**Priority:** P2  
**Related US:** US-052

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Cold start app | Splash screen shown with "Friendsheet" text below animation |✅ | |
| 2 | Wait for animation to complete (~3s) | Automatically navigates to LoginScreen or MainScreen |✅ | |
| 3 | Background color | Warm white (#FAFAF7) — no black flash |✅ | |

---

### TC-ONBOARDING-002 — Login screen visuals
**Priority:** P3  
**Related US:** US-053

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Arrive at LoginScreen | "Friendsheet" in Pacifico font, hero illustration visible |✅ | |
| 2 | Scroll to bottom | Terms of Service and Privacy Policy links visible |✅ | |
| 3 | Tap ToS link | Opens URL in browser (no crash) |✅ | |

---

## TC-NAV: Navigation & Main Screen

### TC-NAV-001 — Bottom navigation tabs
**Priority:** P1  
**Related US:** US-021

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap "Meetings" tab | Meetings list screen visible | ✅ | |
| 2 | Tap "Friends" tab | Persons list screen visible | ✅ | |
| 3 | Tap "Activities" tab | Activities list screen visible | ✅ | |
| 4 | Tap "Home" tab | Home screen visible | ✅ | |

---

### TC-NAV-002 — FAB navigation
**Priority:** P1  
**Related US:** US-021

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap FAB (+) button from any tab | Add Meeting screen opens | ✅ | |
| 2 | Press back | Returns to previous tab | ✅ | |

---

## TC-MEET: Add Meeting

### TC-MEET-001 — Successful meeting creation (happy path)
**Priority:** P0  
**Related US:** US-010 – US-015

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Add Meeting screen | Empty form shown, date defaults to today | ✅ | |
| 2 | Enter meeting name (e.g. "Coffee with Jan") | Name field shows input, character counter updates | ✅ | |
| 3 | Tap date field and select a date | Date field updates to selected date | ✅ | |
| 4 | Tap weight stepper to select weight (e.g. 3) | Weight value updates (Fibonacci: 1,2,3,5,8,13,21) | ✅ | |
| 5 | Type participant name in autocomplete | Matching suggestions appear | ✅ | |
| 6 | Select a participant | Chip added to participants field | ✅ | |
| 7 | Type activity name in autocomplete | Matching suggestions appear | ✅ | |
| 8 | Select an activity | Chip added to activities field | ✅ | |
| 9 | Tap "Save" | Loading indicator shown, then green snackbar "Meeting saved" | ✅ | |
| 10 | Check Meetings tab | New meeting appears at top of list | ✅ | |

---

### TC-MEET-002 — Meeting name validation
**Priority:** P1  
**Related US:** US-011

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Leave name field empty, tap Save | Error message shown under name field | ✅ | |
| 2 | Type exactly 50 characters | Character counter shows "50/50", input accepted | ✅ | |
| 3 | Try to type 51st character | Input blocked at 50 characters | ✅ | |

---

### TC-MEET-003 — Add new participant during meeting creation
**Priority:** P1  
**Related US:** US-013

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Type name that doesn't exist in autocomplete | "Add [name]" option appears in dropdown | ✅ | |
| 2 | Tap "Add [name]" | Dialog or inline input for firstName / lastName appears | ✅ | |
| 3 | Fill firstName, leave lastName empty, confirm | Person added as chip with firstName only | ✅ | |
| 4 | Save meeting | Person saved to Firestore, visible in Friends tab | ✅ | |

---

### TC-MEET-004 — Add new activity during meeting creation
**Priority:** P1  
**Related US:** US-014, US-043

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Type activity name that doesn't exist | "Add [name]" option appears | ✅ | |
| 2 | Tap "Add [name]" | New root activity category created | ✅ | |
| 3 | Save meeting | Activity visible in Activities tab | ✅ | |

---

### TC-MEET-005 — Duplicate participants/activities blocked
**Priority:** P2  
**Related US:** US-013, US-014

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Add participant "Jan Kowalski" | Chip appears | ✅ | |
| 2 | Try to add "Jan Kowalski" again | Already selected — not added again | ✅ | |
| 3 | Add activity "Running" | Chip appears | ✅ | |
| 4 | Try to add "Running" again | Already selected — not added again | ✅ | |

---

### TC-MEET-006 — Save validation: missing required fields
**Priority:** P0  
**Related US:** US-015

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Leave all fields empty, tap Save | Error messages shown, save blocked | ✅ | |
| 2 | Fill name only, tap Save | Error: participants required | ✅ | |
| 3 | Fill name + participant, tap Save | Error: activity required | ✅ | |
| 4 | Fill all required fields, tap Save | Meeting saved successfully | ✅ | |

---

## TC-MEET-LIST: Meetings List

### TC-MEET-LIST-001 — Meetings grouped by year and month
**Priority:** P1  
**Related US:** US-021, US-059

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Meetings tab with meetings across multiple years | Meetings grouped under year headers | ✅ | |
| 2 | Check current year section | Expanded by default | ✅ | |
| 3 | Check older year section | Collapsed by default | ✅ | |
| 4 | Tap collapsed year header | Section expands, month headers visible | ✅ | |
| 5 | Tap expanded year header | Section collapses, month headers hidden | ✅ | |
| 6 | Verify month headers | Format "March 2026 · N meetings", indented under year | ✅ | |
| 7 | Check current month | Expanded by default | ✅ | |
| 8 | Check last month with data (not current) | Expanded by default | ✅ | |
| 9 | Check older months | Collapsed by default | ✅ | |
| 10 | Tap collapsed month header | Only that month expands | ✅ | |
| 11 | Tap expanded month header | Only that month collapses | ✅ | |

---

### TC-MEET-LIST-002 — Empty state
**Priority:** P2  
**Related US:** US-021, US-054

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Meetings tab with no meetings | Illustration + "No meetings yet" message shown (no crash) | ✅ | |

---

### TC-MEET-LIST-003 — Expandable search in Meetings tab
**Priority:** P1  
**Related US:** US-059

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Meetings tab | AppBar shows title + search icon; no visible search field | ✅ | |
| 2 | Tap search icon (🔍) | Text input appears in AppBar | ✅ | |
| 3 | Type partial meeting name | List filters — only matching meetings shown | ✅ | |
| 4 | Clear text, tap ✕ | Search field disappears, full list restored | ✅ | |
| 5 | Press device back while search open | Search collapses, app does not navigate away | ✅ | |
| 6 | Search for name that doesn't exist | EmptyStateWidget shown ("no results") | ✅ | |

---

### TC-MEET-LIST-004 — AppBar actions order (Meetings)
**Priority:** P2  
**Related US:** US-059

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Meetings tab, inspect AppBar | Search icon (🔍) is the only action icon | ✅ | |

---

## TC-MEET-DETAIL: Meeting Detail & Edit

### TC-MEET-DETAIL-001 — View meeting details
**Priority:** P1  
**Related US:** US-022

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap meeting card in list | Meeting Detail screen opens | ✅ | |
| 2 | Verify displayed fields | Name, date, weight, participants (resolved names), activities with icons | ✅ | |

---

### TC-MEET-DETAIL-002 — Edit meeting (happy path)
**Priority:** P1  
**Related US:** US-023

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Meeting Detail screen | — | ✅ | |
| 2 | Tap edit button | Edit screen opens, fields pre-filled | ✅ | |
| 3 | Change meeting name | Name field updated | ✅ | |
| 4 | Tap Save | Updated meeting shown in detail screen | ✅ | |
| 5 | Return to Meetings list | Updated name visible in card | ✅ | |

---

### TC-MEET-DETAIL-003 — Delete meeting
**Priority:** P1  
**Related US:** US-023

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Meeting Detail screen | — | ✅ | |
| 2 | Tap delete button | Confirmation dialog appears | ✅ | |
| 3 | Tap "Cancel" | Dialog dismissed, meeting unchanged | ✅ | |
| 4 | Tap delete again, confirm | Meeting deleted, navigated back to list | ✅ | |
| 5 | Check Meetings list | Deleted meeting no longer visible | ✅ | |

---

## TC-FRIENDS: Persons / Friends

### TC-FRIENDS-001 — Friends tab — grouped layout
**Priority:** P1  
**Related US:** US-024, US-062

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Friends tab with no groups created | All persons shown in "Ungrouped" section |✅ | |
| 2 | Create a group "Running Crew" | New ExpansionTile appears above Ungrouped |✅ | |
| 3 | Tap group header | Group expands/collapses |✅ | |
| 4 | Ungrouped section | Always visible, non-collapsible |✅ | |
| 5 | Open with no persons | Empty state illustration shown |✅ | |

---

### TC-FRIENDS-002 — Expandable search in Friends tab
**Priority:** P1  
**Related US:** US-024, US-059, US-062

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Friends tab | AppBar shows title; no visible search field in body | ✅ | |
| 2 | Verify AppBar actions order | Add icon (➕) first, search icon (🔍) second | ✅ | |
| 3 | Tap search icon (🔍) | Text input appears | ✅ | |
| 4 | Type partial name | List flattens — matching persons shown without group headers | | |
| 5 | Search matches nickname (not firstName/lastName) | Person shown in flat search results | | |
| 6 | Tap ✕ | Search collapses, grouped view restored | | |
| 7 | Search for name that doesn't exist | Empty state or "no results" shown | ✅ | |

---

### TC-FRIENDS-003 — Add person from Friends tab
**Priority:** P1  
**Related US:** US-024

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap `+` in AppBar | Bottom sheet opens: "Add Person" / "Add Group" |✅ | |
| 2 | Tap "Add Person" | Add person dialog opens |✅ | |
| 3 | Enter firstName, leave lastName empty | Person saved, visible in Ungrouped | ✅ | |
| 4 | Enter firstName and lastName | Person saved with full name | ✅ | |

---

### TC-FRIENDS-004 — Person detail
**Priority:** P1  
**Related US:** US-025

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap person in Friends tab | Person Detail screen opens | ✅ | |
| 2 | Verify displayed fields | First name, last name, meeting count visible | ✅ | |
| 3 | Check meeting count | Correct number of meetings this person is in | ✅ | |

---

### TC-FRIENDS-005 — Edit person
**Priority:** P1  
**Related US:** US-025

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Person Detail screen | — | ✅ | |
| 2 | Tap edit | Edit dialog opens, fields pre-filled | ✅ | |
| 3 | Change last name | Field updated | ✅ | |
| 4 | Save | Updated name shown in detail and Friends list | ✅ | |

---

### TC-FRIENDS-006 — Delete person (cascade)
**Priority:** P0  
**Related US:** US-025, US-062

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Assign a person to a group | Person appears in group section |✅ | |
| 2 | Open Person Detail for that person, tap Delete, confirm | Person deleted |✅ | |
| 3 | Check affected meetings | Meetings still exist, deleted person not in participants | ✅ | |
| 4 | Check group in Friends tab | Person no longer appears in the group |✅ | |
| 5 | Open Firestore — `friend_groups` docs | `personIds` array no longer contains deleted person's ID |✅ | |

---

### TC-FRIENDS-007 — Nicknames
**Priority:** P2  
**Related US:** US-061

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Person Detail | Nicknames section visible (may be empty) |✅ | |
| 2 | Add nickname "Ania" | Chip appears in Nicknames section | | |
| 3 | Add same nickname "Ania" again | Duplicate silently ignored — chip count unchanged |✅ | |
| 4 | Add second nickname "Anka" | Second chip appears |✅ | |
| 5 | Tap ✕ on "Ania" chip | Chip removed |✅ | |
| 6 | Search for person by nickname in Friends tab | Person found in search results |✅ | |
| 7 | Search for person by nickname in Add Meeting autocomplete | Person suggested |✅ | |

---

### TC-FRIENDS-008 — Group creation
**Priority:** P1  
**Related US:** US-062

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap `+` in AppBar → "Add Group" | Add Group dialog opens |✅ | |
| 2 | Leave name empty, tap Save | Save button disabled — no action |✅ | |
| 3 | Enter name "Running Crew", no icon | Group created, appears as ExpansionTile | ✅| |
| 4 | Enter name "Coffee Friends", select icon 🏃 | Group created with icon visible in header |✅ | |
| 5 | Open Firestore — `users/{uid}/friend_groups` | Both group documents exist |✅ | |

---

### TC-FRIENDS-009 — Group edit and delete
**Priority:** P1  
**Related US:** US-062

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Long-press group "Running Crew" | Bottom sheet opens: Edit / Delete |✅ | |
| 2 | Tap Edit | Dialog pre-filled with current name and icon |✅ | |
| 3 | Change name to "Runners" | Group header updated to "Runners" | ✅| |
| 4 | Long-press "Runners", tap Delete | Confirmation dialog: "Persons will not be deleted" | ✅| |
| 5 | Confirm delete | Group removed; its persons still visible in Ungrouped |✅ | |

---

### TC-FRIENDS-010 — Assign persons to group
**Priority:** P1  
**Related US:** US-062

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Create group "Running Crew" | Group visible with 0 persons |✅ | |
| 2 | Tap `👤+` icon on "Running Crew" | AssignPersonsBottomSheet opens with unassigned persons |✅ | |
| 3 | Select "Anna Bogucka" and "John Doe" | Both checked |✅ | |
| 4 | Tap "Done" | Both persons appear under "Running Crew" | ✅| |
| 5 | Tap `👤+` again | Snackbar: "All persons already in this group" (if no remaining) |✅ | |
| 6 | Check "Ungrouped" | Anna and John no longer in Ungrouped (if not in another group) |✅ | |

---

### TC-FRIENDS-011 — Person in multiple groups
**Priority:** P2  
**Related US:** US-062

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Add "Anna" to "Running Crew" | Anna appears in Running Crew |✅ | |
| 2 | Add "Anna" to "Coffee Friends" | Anna also appears in Coffee Friends |✅ | |
| 3 | Open Anna's PersonDetailScreen | Both "Running Crew" and "Coffee Friends" checkboxes checked |✅ | |
| 4 | Uncheck "Running Crew" | Anna removed from Running Crew only |✅ | |
| 5 | Check Friends tab | Anna still in Coffee Friends, not in Running Crew |✅ | |

---

### TC-FRIENDS-012 — Manage groups from PersonDetailScreen
**Priority:** P2  
**Related US:** US-062

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open PersonDetailScreen for person not in any group | "Groups" section shows all groups unchecked |✅ | |
| 2 | Check "Running Crew" | Person immediately added to Running Crew (optimistic update) |✅ | |
| 3 | Return to Friends tab | Person visible under Running Crew |✅ | |
| 4 | Reopen PersonDetailScreen, uncheck "Running Crew" | Person removed from Running Crew |✅ | |

---

## TC-ACT: Activities

### TC-ACT-001 — Activities tree view
**Priority:** P1  
**Related US:** US-026

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Activities tab | Category tree shown with global + private categories | ✅ | |
| 2 | Tap parent category | Children expand/collapse | ✅ | |
| 3 | Verify global categories | No edit/delete on long-press (read-only) | ✅ | |
| 4 | Verify private categories | Edit/delete available on long-press | ✅ | |

---

### TC-ACT-002 — Add private activity category
**Priority:** P1  
**Related US:** US-026

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Tap add button in Activities tab | Add activity dialog opens | ✅ | |
| 2 | Enter name, select icon, leave parent empty (root) | — | ✅ | |
| 3 | Save | New root category appears in Activities tree | ✅ | |
| 4 | Add another category with parent = category from step 3 | Child category visible under parent | ✅ | |

---

### TC-ACT-003 — Edit private activity category
**Priority:** P2  
**Related US:** US-026

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Long-press private category | Edit/delete options appear | ✅ | |
| 2 | Tap Edit | Edit dialog opens with pre-filled fields | ✅ | |
| 3 | Change name | Name updated in tree | ✅ | |

---

### TC-ACT-004 — Delete category with cascade
**Priority:** P0  
**Related US:** US-026, US-043

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Create parent category "Sport" | Visible in Activities tree | ✅ | |
| 2 | Create child category "Running" under "Sport" | Visible under Sport | ✅ | |
| 3 | Long-press "Sport", tap Delete, confirm | "Sport" deleted | ✅ | |
| 4 | Check Activities tree | "Running" also gone | ✅ | |
| 5 | Open Firestore console | Neither "Sport" nor "Running" documents exist | ✅ | |
| 6 | Open Add Meeting autocomplete | "Running" not available | ✅ | |

---

### TC-ACT-005 — Delete child category (no sibling impact)
**Priority:** P1  
**Related US:** US-043

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Create parent "Sport" with children "Running" and "Cycling" | Both children visible | ✅ | |
| 2 | Delete "Running" | "Running" removed | ✅ | |
| 3 | Check tree | "Cycling" still visible under "Sport" | ✅ | |

---

### TC-ACT-006 — Activity search in Activities tab
**Priority:** P2  
**Related US:** US-026, US-055

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Type in search field in Activities tab | List filtered to matching categories | ✅ | |
| 2 | Clear search | Full tree restored | ✅ | |
| 3 | Search returns no results | EmptyStateWidget shown |✅ | |

---

## TC-STATS: Statistics

### TC-STATS-001 — Year stepper
**Priority:** P1  
**Related US:** US-027, US-071

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Home tab | Current year shown in center of stepper, bold | ✅| |
| 2 | Tap left arrow (←) | Previous year selected, charts update |✅ | |
| 3 | Tap right arrow (→) | Next year selected | ✅| |
| 4 | Swipe left on year stepper | Navigates to previous year |✅ | |
| 5 | Navigate to earliest available year | Left arrow disabled | ✅| |
| 6 | Navigate to latest year | Right arrow disabled |✅ | |

---

### TC-STATS-002 — Activity Breakdown chart
**Priority:** P1  
**Related US:** US-028, US-048, US-057

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Home tab | Activity Breakdown card visible in carousel |✅ | |
| 2 | Add meetings with different activities | Bars appear proportional to activity weight |✅ | |
| 3 | Change year | Chart animates to new data |✅ | |
| 4 | Tap filter icon (🎛) | Activity visibility dialog opens |✅ | |
| 5 | Uncheck one activity | Bar disappears from chart |✅ | |
| 6 | Tap "Auto-select top 10" | Top 10 activities checked, rest unchecked |✅ | |
| 7 | Tap "Select All" toggle | All activities checked |✅ | |
| 8 | New activity not seen in previous year | "NEW" delta indicator shown |✅ | |

---

### TC-STATS-003 — Who Per Activity chart
**Priority:** P1  
**Related US:** US-029, US-058

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Who Per Activity card | Activity selector visible, no chart until activity selected |✅ | |
| 2 | Tap activity selector | Tree picker opens with categories and leaf activities |✅ | |
| 3 | Select an activity | Chart shows persons ranked by weight for that activity |✅ | |
| 4 | Tap filter icon | Person filter dialog opens |✅ | |
| 5 | Uncheck one person | Bar disappears from chart |✅ | |
| 6 | Tap "Auto-select top 10" | Top 10 persons for current activity checked |✅ | |

---

### TC-STATS-004 — Interaction Distribution chart
**Priority:** P1  
**Related US:** US-030, US-051, US-057

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Interaction Distribution card | Persons ranked by meeting weight, yearly mode |✅ | |
| 2 | Tap yearly/cumulative toggle | Chart switches between modes, label updates |✅| |
| 3 | Tap filter icon | Person visibility dialog opens | ✅| |
| 4 | Uncheck person | Bar disappears |✅ | |
| 5 | Tap info icon (ℹ) | Explanation of >100% shown |✅ | |

---

### TC-STATS-005 — Statistics carousel
**Priority:** P2  
**Related US:** US-051, US-060

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Home tab | Carousel with ← / → arrows and 🎛 icon visible |✅ | |
| 2 | Swipe carousel left/right | Adjacent card shown |✅ | |
| 3 | Tap ← or → arrows | Adjacent card shown with wrap-around at ends | ✅| |
| 4 | Tap 🎛 (tune icon) | StatisticsVisibilityDialog opens | ✅| |
| 5 | Uncheck one card type | Card removed from carousel |✅ | |
| 6 | Try to uncheck last visible card | Checkbox disabled, tooltip shown |✅ | |
| 7 | Re-check hidden card | Card reappears in carousel |✅ | |
| 8 | Close and reopen app | Visibility settings persisted | ✅| |

---

### TC-STATS-006 — Statistics caching (Hive)
**Priority:** P2  
**Related US:** US-072, US-073

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Statistics tab (first time) | Loading state → data shown |✅ | |
| 2 | Close app completely, reopen | Home tab opens with HomeLoadingScreen briefly |✅ | |
| 3 | Navigate to Statistics | Charts load quickly without Firestore spinner (Hive hit) | ✅| |
| 4 | Add a new meeting | Statistics update to reflect new data after navigating back to Home |✅ | |

---

## TC-EXPORT: Data Export

### TC-EXPORT-001 — Export data as JSON
**Priority:** P1  
**Related US:** US-031

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Settings | "Export data as JSON" tile visible |✅ | |
| 2 | Tap Export tile | Loading indicator shown |✅ | |
| 3 | Wait for completion | Success snackbar with file path (e.g. Downloads/friendsheet_export_YYYY-MM-DD.json) |✅ | |
| 4 | Open file manager → Downloads | JSON file exists with correct filename | ✅| |
| 5 | Open JSON file | Contains meetings, persons, activities arrays | ✅| |
| 6 | Tap Export again | Second file created (does not overwrite silently) | ✅| |

---

## TC-DATA: Data Integrity

### TC-DATA-001 — Firestore path isolation
**Priority:** P0  
**Related US:** US-045

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Sign in as User A, create meetings and persons | Data visible in app | ✅ | |
| 2 | Open Firestore console | Data stored under `users/{uid-A}/meetings` and `users/{uid-A}/persons` | ✅ | |
| 3 | Verify root `/meetings` collection | Does not exist or is empty | ✅ | |

---

### TC-DATA-002 — Onboarding idempotency
**Priority:** P0  
**Related US:** US-044

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Note count of categories in `users/{uid}/activity_categories` after first login | Count = N | ✅ | |
| 2 | Sign out and sign in again | App works normally | ✅ | |
| 3 | Check category count in Firestore | Still N (no duplicates created) | ✅ | |

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
| 8 | Select 3 events, tap "Import (3)" | Navigates to MeetingInboxScreen with 3 candidates | ✅ | |

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
**Related US:** US-066, US-067

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open drawer with no calendar connected | Tile shows "Import from Calendar" | ✅ | |
| 2 | Tap "Import from Calendar" | CalendarPermissionScreen shown | ✅ | |
| 3 | Tap "Connect Google Calendar" | OAuth flow triggered | ✅ | |
| 4 | Tap "Not now" | Returns to MainScreen | ✅ | |
| 5 | Open drawer with calendar connected | Tile shows "Browse & Import Events" | ✅ | |
| 6 | Tap "Browse & Import Events" | CalendarEventsScreen opens directly | ✅ | |

---

### TC-CAL-005 — Disconnect calendar
**Priority:** P1  
**Related US:** US-066

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open Settings with calendar connected | "Disconnect Calendar" tile visible | ✅ | |
| 2 | Tap "Disconnect Calendar" | Calendar disconnected | ✅ | |
| 3 | Open drawer | Tile shows "Import from Calendar" (not "Browse & Import Events") | ✅ | |

---

### TC-CAL-006 — CTA card behaviour
**Priority:** P1  
**Related US:** US-065

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open HomeScreen with < 50 meetings | CTA card visible | ✅ | |
| 2 | Check for dismiss button | No X / dismiss button exists on CTA card | ✅ | |
| 3 | Tap "Import from Calendar" on CTA | Navigates to CalendarPermissionScreen |✅ | |
| 4 | Add meetings until total ≥ 50, reopen HomeScreen | CTA card no longer visible, statistics shown | ✅ | |

---

## TC-INBOX: Meeting Inbox

### TC-INBOX-001 — Review and confirm candidate (happy path)
**Priority:** P0  
**Related US:** US-068

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Import 3 events from Calendar | MeetingInboxScreen shows 3 candidate cards |✅ | |
| 2 | Progress indicator | Shows "0 of 3 reviewed" |✅ | |
| 3 | Tap first candidate card | InboxItemEditScreen opens, pre-filled with event title and date |✅ | |
| 4 | Verify pre-filled fields | Name = event title, date = event date, weight = 3 (default) |✅ | |
| 5 | Add activity (required), tap "Confirm" | Candidate removed from inbox, meeting saved to Firestore |✅ | |
| 6 | Return to inbox list | Progress shows "1 of 3 reviewed", 2 cards remain |✅ | |
| 7 | Confirm all remaining | Inbox empty → ImportSuccessScreen shown |✅ | |
| 8 | Check count on success screen | Shows correct number of confirmed meetings |✅ | |
| 9 | Tap "Go to Meetings" | Navigates to MeetingsListScreen, new meetings visible |✅ | |

---

### TC-INBOX-002 — Skip candidate
**Priority:** P1  
**Related US:** US-068

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open InboxItemEditScreen | — |✅ | |
| 2 | Tap "Skip" | Candidate removed from inbox WITHOUT saving to Firestore |✅ | |
| 3 | Check Meetings tab | No new meeting added |✅ | |

---

### TC-INBOX-003 — Inbox persistence across app restart
**Priority:** P1  
**Related US:** US-068

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Import 5 events, confirm 2 | 3 candidates remain |✅ | |
| 2 | Close app completely (remove from recents) | — |✅ | |
| 3 | Reopen app | Drawer shows "Pending Meetings (3)" badge |✅ | |
| 4 | Open MeetingInboxScreen | 3 remaining candidates visible |✅ | |

---

### TC-INBOX-004 — Inbox validation: confirm blocked without activity
**Priority:** P1  
**Related US:** US-068

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open InboxItemEditScreen | — |✅ | |
| 2 | Leave activities empty, tap "Confirm" | Error shown: activity required | ✅| |
| 3 | Add activity, tap "Confirm" | Meeting saved |✅ | |

---

### TC-INBOX-005 — Drawer pending meetings badge
**Priority:** P2  
**Related US:** US-068

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Open drawer with inbox empty | No "Pending Meetings" tile visible | ✅| |
| 2 | Import events | "Pending Meetings (N)" tile appears in drawer |✅ | |
| 3 | Confirm all candidates | "Pending Meetings" tile disappears from drawer | ✅| |

---

## TC-AGENTS: Multi-Agent System (US-INF-005)

Manual verification — no Flutter code involved. Run once after agent files are created or modified.

### TC-AGENTS-001 — /pm session start
**Priority:** P2
**Related US:** US-INF-005

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Run `/pm` in Claude Code | Agent greets in Polish, runs `git status` and `git log main..HEAD` | ✅ | Verified March 18, 2026 |
| 2 | Observe output | Reports clean repo or lists uncommitted changes/unpushed commits | ✅ | |
| 3 | Ask about current US | Agent asks "Nad czym dziś pracujemy?" and waits | ✅ | |
| 4 | Answer with US number | Agent routes to correct next agent (/planning, /qa, /debug, /docs) | ✅ | |

---

### TC-AGENTS-002 — /planning US verification
**Priority:** P2
**Related US:** US-INF-005

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Run `/planning` | Agent reads BACKLOG.md and asks which US to verify | ✅ | Verified March 18, 2026 |
| 2 | Provide US number | Agent checks Acceptance Criteria, dependencies, labels | ✅ | |
| 3 | Observe User Acceptance Scenario | Written in plain language, no technical jargon, in Polish | ✅ | |
| 4 | Approve scenario | Agent generates Task instruction in English for /dev | ✅ | |
| 5 | Observe instruction format | Contains: Context, Read, Tasks (numbered), Constraints, After implementation | ✅ | |

---

### TC-AGENTS-003 — /qa TEST_CASES.md update
**Priority:** P2
**Related US:** US-INF-005

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Run `/qa` | Agent asks what to test (a/b/c options) | ✅ | Verified March 18, 2026 |
| 2 | Select d) TEST_CASES.md update for non-code US | Agent updates TEST_CASES.md with manual test cases | ✅ | |
| 3 | Verify agent does NOT run flutter test | No test command executed for infrastructure-only US | ✅ | |
| 4 | Check TEST_CASES.md | New TC-AGENTS section added | ✅ | |

---

### TC-AGENTS-004 — git approval rule
**Priority:** P1
**Related US:** US-INF-005

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Complete any agent task (/planning, /qa, /docs) | Agent produces output but does NOT run `git commit` or `git push` | ✅ | Verified March 18, 2026 |
| 2 | Observe agent closing message | Agent instructs user to commit manually or approve commit | ✅ | |

---

## Regression Checklist

Run after every release or hotfix:

- [ ] TC-AUTH-001 First-time sign-in
- [ ] TC-AUTH-003 Session restore
- [ ] TC-AUTH-004 Logout
- [ ] TC-MEET-001 Successful meeting creation
- [ ] TC-MEET-006 Save validation
- [ ] TC-MEET-DETAIL-003 Delete meeting
- [ ] TC-FRIENDS-001 Friends tab grouped layout
- [ ] TC-FRIENDS-006 Delete person cascade (groups + meetings)
- [ ] TC-FRIENDS-008 Group creation
- [ ] TC-ACT-004 Delete category cascade
- [ ] TC-DATA-002 Onboarding idempotency
- [ ] TC-STATS-001 Year stepper
- [ ] TC-STATS-005 Statistics carousel visibility
- [ ] TC-CAL-001 Browse events
- [ ] TC-INBOX-001 Review and confirm meeting
- [ ] TC-INBOX-003 Inbox persistence
- [ ] TC-SHARE-001 Generate sharing token (happy path)
- [ ] TC-SHARE-003 Home screen CTA card (< 50 meetings)

---

## Bug Log

| ID | Title | TC | Priority | Status | Notes |
|----|-------|-----|----------|--------|-------|
| — | — | — | — | — | No open bugs at time of US-062 completion |

---

*Document maintained alongside BACKLOG.md. Update Status column after each test run.*
*Scope: M1 + M2 + M3 + M3.5 (through US-062) + M5 Calendar Import and Meeting Inbox + INF Multi-Agent System + US-089 Generate Sharing Token.*

---

## TC-SHARE — Sharing Token (US-089)

### TC-SHARE-001 — Generate sharing token (happy path)
**Priority:** P1
**Related US:** US-089

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Log in and open Side Drawer | Drawer shows "Import & Share" section with "Share meetings with a friend" tile | ⏭️ | |
| 2 | Tap "Share meetings with a friend" | NavigatEs to GenerateSharingTokenScreen (AppBar: "Share Token" with white text on green) | ⏭️ | |
| 3 | Wait for screen to load | 6-character alphanumeric token displayed (e.g. "A3K9BX"), expiry countdown shown ("Expires in 23h 59m") | ⏭️ | |
| 4 | Tap "Copy token" | SnackBar "Token copied!" appears; token is in clipboard | ⏭️ | |
| 5 | Return to screen within 24h | Same token shown (idempotent — no duplicate generated) | ⏭️ | |

### TC-SHARE-002 — Generate new token
**Priority:** P2
**Related US:** US-089

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | On GenerateSharingTokenScreen with existing token | "Generate new token" button visible at bottom | ⏭️ | |
| 2 | Tap "Generate new token" | Loading spinner, then new 6-character token shown with fresh 24h expiry | ⏭️ | |
| 3 | Verify old token is gone | Old token value no longer visible | ⏭️ | |

### TC-SHARE-003 — Home screen CTA card (< 50 meetings)
**Priority:** P2
**Related US:** US-089

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|
| 1 | Log in with account that has fewer than 50 meetings | Home screen shows "Build your meeting base" card | ⏭️ | |
| 2 | Verify card contents | Title "Build your meeting base", two green ElevatedButtons: "Import from Calendar" and "Request from a friend" | ⏭️ | |
| 3 | Tap "Import from Calendar" | Navigates to Google Calendar import flow | ⏭️ | |
| 4 | Tap "Request from a friend" | Navigates to GenerateSharingTokenScreen | ⏭️ | |

### TC-SHARE-004 — Error state (not authenticated)
**Priority:** P3
**Related US:** US-089

| Step | Action | Expected Result | Status | Notes |
|------|--------|----------------|--------|-------|

---

## TC-LINK: Friend Account Linking (US-090)

### Automated tests — `test/data/models/person_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-LINK-001 | `toFirestore()` includes linkedUserId when set | map contains `linkedUserId` key with correct value |
| UT-LINK-002 | `toFirestore()` omits linkedUserId key when null | map does NOT contain `linkedUserId` key |
| UT-LINK-003 | `fromFirestore()` reads linkedUserId when present in document | `person.linkedUserId == 'uid-friend-42'` |
| UT-LINK-004 | `fromFirestore()` linkedUserId is null when field absent from document | `person.linkedUserId == null` |

### Automated tests — `test/data/repositories/sharing_token_repository_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-LINK-005 | `validateAndClaimToken` returns notFound when no token matches | `result.error == TokenValidationError.notFound` |
| UT-LINK-006 | `validateAndClaimToken` returns expired when token expiresAt is in the past | `result.error == TokenValidationError.expired` |
| UT-LINK-007 | `validateAndClaimToken` returns alreadyUsed when token isUsed is true | `result.error == TokenValidationError.alreadyUsed` |
| UT-LINK-008 | `validateAndClaimToken` returns success with ownerUid and tokenId for a valid token | `result.isSuccess == true`, `ownerUid` and `tokenId` set correctly |

### Automated tests — `test/presentation/persons/person_detail_provider_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-LINK-009 | `linkFriendAccount` returns success, calls updatePerson and markAsUsed on valid token | result success, `person.linkedUserId` updated, both repo methods called once |
| UT-LINK-010 | `linkFriendAccount` returns notFound and does not call updatePerson | `error == notFound`, `updatePerson` never called |
| UT-LINK-011 | `linkFriendAccount` returns serverError when validateAndClaimToken throws | `error == serverError`, `isLinking == false` |
| 1 | Open GenerateSharingTokenScreen while not logged in | "Not authenticated" error + "Retry" button shown | ⏭️ | Covered by automated test |

---

## TC-SEND: Share Meetings (US-091)

### Automated tests — `test/data/repositories/meeting_repository_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-SEND-001 | `getMeetingsByParticipant` returns meetings for person, newest first | 2 meetings returned in descending date order |
| UT-SEND-002 | `getMeetingsByParticipant` returns empty list when person has no meetings | `results` is empty |
| UT-SEND-003 | `getMeetingsByParticipant` does not return meetings from a different user | `results` is empty |

### Automated tests — `test/data/services/meeting_package_service_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-SEND-004 | `sendPackage` writes document to recipient's `pending_meetings` with correct fields | doc exists at `users/uid-c/pending_meetings/`, `senderUid == 'uid-a'`, `meetings.length == 1` |
| UT-SEND-005 | `sendPackage` assigns non-empty auto-generated doc ID | `doc.id` is non-empty string |
| UT-SEND-006 | `sendPackage` writes to recipient subcollection, not sender | `users/uid-a/pending_meetings` is empty |

### Automated tests — `test/presentation/sharing/share_meetings_provider_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-SEND-007 | Initial state has correct defaults | all fields empty/false/null |
| UT-SEND-008 | `initialize` loads meetings, selects all, pre-fills sender name | `meetings.length == 1`, `selectedMeetingIds == {'m1'}`, `senderFirstName == 'Anna'` |
| UT-SEND-009 | `initialize` with no meetings leaves selection empty | `meetings` empty, `isAllSelected == false` |
| UT-SEND-010 | `initialize` sets errorMessage on failure | `errorMessage != null` |
| UT-SEND-011 | `toggleAll` cycles all→none→all | selection empty then full again |
| UT-SEND-012 | `toggleMeeting` adds and removes from selection | deselect then re-select in one test |
| UT-SEND-013 | `canSend` is false when firstName is empty | `canSend == false` |
| UT-SEND-014 | `canSend` is true when firstName set and meetings selected | `canSend == true` |
| UT-SEND-015 | `sendPackage` happy path returns true and calls service | `success == true`, service called once |
| UT-SEND-016 | `sendPackage` excludes targetPersonId from participants when `includePersons=true` | `participants.length == 1`, `firstName == 'Bob'` |
| UT-SEND-017 | `sendPackage` resolves categoryNames when `includeActivities=true` | `categoryNames == ['Sports']` |
| UT-SEND-018 | `sendPackage` returns false and sets errorMessage on service failure | `success == false`, `errorMessage != null` |

---

## TC-RECV: Receive Package & Resolve Duplicates (US-092)

### Automated tests — `test/data/repositories/pending_meeting_package_repository_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-RECV-001 | `fetchPackages` returns empty list when subcollection is empty | `result` is empty |
| UT-RECV-002 | `fetchPackages` returns package with correct fields from Firestore | `id`, `senderFirstName`, `meetings.length` match seeded data |
| UT-RECV-003 | `deletePackage` removes the document from Firestore | subcollection is empty after delete |

### Automated tests — `test/presentation/providers/shared_package_inbox_provider_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-RECV-004 | Initial state has correct defaults | `packages` empty, `isLoading == false`, `hasPackages == false` |
| UT-RECV-005 | `initialize` with empty userId returns early without fetching | repo never called, `isLoading == false` |
| UT-RECV-006 | `initialize` with no packages results in empty state | `packages` empty, `hasPackages == false` |
| UT-RECV-007 | `initialize` loads packages when they exist | `packages.length == 1`, `hasPackages == true` |
| UT-RECV-008 | Detects conflict when shared date matches existing meeting date | `conflictsFor('pkg1').length == 1`, conflict ID matches |
| UT-RECV-009 | Ignores time-of-day when comparing dates | same calendar day at different times → conflict detected |
| UT-RECV-010 | No conflict when dates differ by one day | `conflictsFor('pkg1')` is empty |
| UT-RECV-011 | `canProceed` is true when package has no conflicts | `canProceed('pkg1') == true` |
| UT-RECV-012 | `canProceed` is false while conflict is unresolved | `canProceed('pkg1') == false` |
| UT-RECV-013 | `canProceed` is true after all conflicts are resolved | `canProceed('pkg1') == true` after `resolveConflict` |
| UT-RECV-014 | `resolveConflict` stores the chosen resolution | `resolutionFor('pkg1', 0) == ConflictResolution.addAsNew` |
| UT-RECV-015 | `resolveConflict` overrides a previous resolution | second call wins — `resolutionFor('pkg1', 0) == skip` |
| UT-RECV-016 | `dismissPackage` removes the package from the list | `packages` empty, `hasPackages == false` |
| UT-RECV-017 | `dismissPackage` clears conflicts and resolutions | `conflictsFor` empty, `resolutionFor` returns null |

### Automated tests — `test/presentation/import/package_conflict_screen_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-RECV-018 | Renders "Review Package" title and sender name | both texts found |
| UT-RECV-019 | Non-conflicting meeting shows check icon and meeting name | `Icons.check_circle_outline` visible, meeting name shown |
| UT-RECV-020 | Continue button is enabled when no conflicts | `button.onPressed != null` |
| UT-RECV-021 | Tapping Continue dismisses package | `provider.hasPackages == false` |
| UT-RECV-022 | Conflicting meeting shows "Received" and "Yours" headers | both column headers found |
| UT-RECV-023 | Conflict card shows "Date conflict" warning text | text containing "Date conflict" found |
| UT-RECV-024 | All three resolution buttons visible (Merge / Add as new / Skip) | all three button texts found |
| UT-RECV-025 | Continue button disabled before any resolution chosen | `button.onPressed == null` |
| UT-RECV-026 | Continue enabled after resolution; selected button is FilledButton | `onPressed != null`, `FilledButton` present |
| UT-RECV-027 | Tapping Continue imports directly and shows success (no conflicts) | `find.text('Import complete!')` found |

---

## TC-CONF: Conflict Resolution UX — Activities & Persons (US-093)

### Automated tests — `test/presentation/providers/shared_package_inbox_provider_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-CONF-001 | `dismissPackage` clears activity and person state | `activityResolutionFor`, `personResolutionFor`, opt-outs all cleared |
| UT-CONF-002 | Sender is always included in `uniquePersonsFor` regardless of participants | sender found in returned map |
| UT-CONF-003 | `activityConflictsFor` detects conflict when category name matches (case-insensitive) | map has 1 entry, existing category returned |
| UT-CONF-004 | `activityConflictsFor` no conflict when name does not match | map is empty |
| UT-CONF-005 | `personConflictsFor` detects conflict when firstName + lastName match | map has 1 entry |
| UT-CONF-006 | `personConflictsFor` no conflict when names differ | map is empty |
| UT-CONF-007 | `canProceedActivities` is true when no activity conflicts | `true` |
| UT-CONF-008 | `canProceedActivities` is false while activity conflict unresolved | `false` |
| UT-CONF-009 | `canProceedActivities` is true after activity conflict resolved | `true` after `resolveActivityConflict` |
| UT-CONF-010 | `canProceedPersons` is true when no person conflicts | `true` |
| UT-CONF-011 | `canProceedPersons` is false while person conflict unresolved | `false` |
| UT-CONF-012 | `canProceedPersons` is true after person conflict resolved | `true` after `resolvePersonConflict` |
| UT-CONF-013 | `resolveActivityConflict` stores and returns the chosen resolution | `renamedName == 'Hike'` |
| UT-CONF-014 | `resolveActivityConflict` overrides a previous resolution | second call wins — `linkedCategoryId == 'cat-x'` |
| UT-CONF-015 | `resolvePersonConflict` stores and returns the chosen resolution | `nickname == 'JK'` |
| UT-CONF-016 | `resolvePersonConflict` overrides a previous resolution | second call wins — `linkedPersonId == 'p-x'` |

### Automated tests — `test/presentation/providers/package_importer_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-CONF-017 | Happy path: imports meeting, sender added, returns correct summary | `meetingsAdded==1`, `personsAdded==1`, `activitiesAdded==0` |
| UT-CONF-018 | Sender is always included in meeting `participantIds` | captured meeting contains sender's person ID |
| UT-CONF-019 | `skip` resolution excludes meeting from import | `saveMeeting` never called, `meetingsAdded==0` |
| UT-CONF-020 | `merge` resolution excludes meeting from import | `saveMeeting` never called, `meetingsAdded==0` |
| UT-CONF-021 | `addAsNew` resolution imports meeting despite conflict | `saveMeeting` called once, `meetingsAdded==1` |
| UT-CONF-022 | Creates new category when no activity resolution given | `createSelectableCategory` called once, `activitiesAdded==1` |
| UT-CONF-023 | Links to existing category when `ActivityResolution.link` given | `createSelectableCategory` never called, meeting has linked `categoryId` |
| UT-CONF-024 | Skips activity when opted out | `createSelectableCategory` never called, `activitiesAdded==0` |
| UT-CONF-025 | Links to existing person when `PersonResolution.link` given | `addPerson` never called, meeting has linked `participantId` |
| UT-CONF-026 | Creates person with nickname when `PersonResolution.nickname` given | captured person has nickname, `personsAdded==1` |
| UT-CONF-027 | Skips person when opted out | `addPerson` never called, `personsAdded==0` |
---

## TC-FUZZY: Fuzzy Activity Matching During Package Import (US-094)

### Automated tests — `test/core/utils/string_similarity_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-FUZZY-001 | Identical strings return 0.0 | `normalizedLevenshtein('sport', 'sport') == 0.0` |
| UT-FUZZY-002 | Two empty strings return 0.0 | `normalizedLevenshtein('', '') == 0.0` |
| UT-FUZZY-003 | Empty vs non-empty returns 1.0 | both directions return `1.0` |
| UT-FUZZY-004 | Completely different strings of equal length return 1.0 | `normalizedLevenshtein('abc', 'xyz') == 1.0` |
| UT-FUZZY-005 | Comparison is case-insensitive | `normalizedLevenshtein('Sport', 'sport') == 0.0` |
| UT-FUZZY-006 | One-character insertion is well below fuzzy threshold | result `< 0.4` and `> 0.0` |
| UT-FUZZY-007 | One-character deletion is well below fuzzy threshold | result `< 0.4` and `> 0.0` |
| UT-FUZZY-008 | Unrelated names exceed fuzzy threshold | result `>= 0.4` |
| UT-FUZZY-009 | Result is symmetric | `f(a,b) == f(b,a)` |

### Automated tests — `test/presentation/providers/shared_package_inbox_provider_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-FUZZY-010 | `fuzzyActivityMatchFor` detects match when distance below threshold | returns matching category |
| UT-FUZZY-011 | No fuzzy match when exact conflict already exists | `fuzzyActivityMatchFor` returns null |
| UT-FUZZY-012 | No fuzzy match when distance above threshold | returns null for unrelated names |
| UT-FUZZY-013 | Picks closest match when multiple categories are candidates | returns the closer category |
| UT-FUZZY-014 | `existingCategories` getter reflects fetched categories after initialize | returns expected list |
| UT-FUZZY-015 | `existingPersons` getter reflects fetched persons after initialize | returns expected list |
| UT-FUZZY-016 | `clearActivityResolution` removes resolution and optOut | both cleared, `activityResolutionFor` returns null |
| UT-FUZZY-017 | `clearPersonResolution` removes resolution and optOut | both cleared, `personResolutionFor` returns null |

### Automated tests — `test/presentation/providers/package_importer_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-FUZZY-018 | `ActivityResolution.skip` skips activity and excludes from `categoryIds` | `createSelectableCategory` never called, `meeting.categoryIds` empty |
| UT-FUZZY-019 | `PersonResolution.skip` skips person and excludes from `participantIds` | `addPerson` never called, `meeting.participantIds` empty |
| UT-FUZZY-020 | `PersonResolution.createNew` creates person with no nickname | captured person has empty `nicknames`, `personsAdded==1` |

### Automated tests — `test/presentation/import/package_conflict_screen_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-FUZZY-021 | Tapping Continue routes through PersonsScreen before import success | "Review Persons" shown, tapping Confirm shows "Import complete!" |

---

## TC-MERGE: Merge Activity Categories (US-095)

### Automated tests — `test/data/repositories/meeting_repository_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-MERGE-001 | replaces sourceId with targetId and removes sourceId | `categoryIds` contains `cat-target` and `cat-other`, not `cat-source` |
| UT-MERGE-002 | does not duplicate targetId when already present in meeting | `cat-target` appears exactly once, `cat-source` removed |
| UT-MERGE-003 | no-op when no meetings contain sourceId | `categoryIds` unchanged |
| UT-MERGE-004 | updates all meetings that contain sourceId | all affected meetings have `cat-target`, none have `cat-source` |

### Automated tests — `test/presentation/activities/activities_list_provider_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-MERGE-005 | mergeCandidates excludes source and returns remainder sorted alphabetically | source id absent, remaining sorted A→Z |
| UT-MERGE-006 | mergeCategory calls replaceCategoryInMeetings and deleteCategory then refreshes | both repository methods called once, getAllCategories called |

### Automated tests — `test/presentation/activities/merge_category_picker_screen_test.dart`

| ID | Test name | Expected |
|----|-----------|---------|
| UT-MERGE-007 | shows source name in app bar title | title text `Merge "Piwko" into…` visible |
| UT-MERGE-008 | hierarchy view shows root and child category names | Sport, Bieg, Piwo all visible without search |
| UT-MERGE-009 | search hides non-matching categories | only 'Piwo' ListTile visible after typing 'Piwo' |
| UT-MERGE-010 | search shows parent name as subtitle for child category | searching 'Bieg' shows ListTile with 'Bieg' title and 'Sport' subtitle |
