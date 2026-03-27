# Friendsheet - Requirements Documentation

**Version:** 2.5
**Date:** March 2026
**Author:** Product Owner
**Status:** Updated — FR-025 partially implemented (US-087: AI Chat Screen)

**Change Log:**
- v1.1 — Authentication changed from email/password to Google Sign-In
- v2.0 — Full roadmap requirements added for M2-M8
- v2.1 — M6 redesigned: Google Photos replaced by Meeting Import Hub (Google Calendar + Google Photos); ImportCandidate architecture introduced
- v2.2 — FR-026 added: Friend Groups (US-062); Person and FriendGroup data model updated
- v2.3 — FR-029 added: Person Meetings List (US-099); FR-030 added: Delete Received Package (US-098)
- v2.4 — FR-031 implemented: Meeting Notes as `List<String>` (US-100)
- v2.5 — FR-025 partially implemented: AI Chat Screen (Buddy) delivered (US-087); consent flow (US-085), API key management (US-088), context builder (US-086) all ✅
- v2.6 — FR-033 added: Tool Calling (US-110) — Buddy queries only relevant data via OpenAI function calling, supports arbitrary date ranges; FR-034 added: Offline-First Mode (US-111) — full CRUD available offline via Firestore SDK write queue + Hive cache (US-109)

---

## 1. Introduction

### 1.1 Document Purpose
This document defines the functional and non-functional requirements for Friendsheet across all planned milestones.

### 1.2 Application Purpose
The application enables users to track meetings with friends with the ability to generate statistics, manage their social history, and optionally share data with friends who join the app.

### 1.3 Milestone Scope Overview

| Milestone | Name | Status |
|-----------|------|--------|
| M1 | Add Meeting | ✅ Completed |
| M2 | Management & CRUD | ✅ Completed |
| M3 | Statistics & Export | ✅ Completed |
| M3.5 | Visual Design & Brand Identity | 🔄 In Progress |
| M4 | Google Play Release | 📋 Planned |
| M5 | Social: Data Sharing | 📋 Planned |
| M6 | Custom Dashboard | 📋 Planned |
| M7 | AI Assistant | 🔄 In Progress |

---

## 2. Functional Requirements — M1 (Completed)

### FR-001: User Authentication ✅
User signs in via Google Sign-In (SSO). First-time users automatically registered. Auth state persists across restarts.

### FR-002: Adding a Meeting ✅
User adds meeting with name (max 50 chars), date, weight (Fibonacci: 1,2,3,5,8,13,21), participants (min 1), activities (min 1).

### FR-003: Managing Meeting Participants ✅
Autocomplete from existing persons. Add new person (firstName required, lastName optional). Chips display. No duplicates.

### FR-004: Managing Meeting Activities ✅
Autocomplete from existing activities (global + private). Add new activity. Chips display. No duplicates.

### FR-005: User Logout ✅
Signs out from both Google Sign-In and Firebase Auth. Clears local auth state. Redirects to login screen.

---

## 3. Functional Requirements — M2: Management & CRUD (Completed)

### FR-006: Meetings List View ✅
**Priority:** MUST HAVE

**Description:**
User can view all their meetings in a chronological list grouped by year.

**Acceptance Criteria:**
- Meetings displayed newest first (reverse chronological order)
- Meetings grouped by year with year as section header
- Current year and previous year expanded by default
- Years older than 1 year collapsed by default, expandable on tap
- Each meeting card shows: name, date, participant count, weight
- Empty state message when no meetings exist
- Tapping meeting opens Meeting Detail screen

---

### FR-007: Meeting Detail & Edit ✅
**Priority:** MUST HAVE

**Description:**
User can view full meeting details and edit or delete a meeting.

**Acceptance Criteria:**
- Detail screen shows all fields: name, date, weight, participants (full names), activities (with category)
- Edit button opens pre-populated edit form
- All fields editable
- Save updates Firestore document (updatedAt refreshed)
- Delete requires confirmation dialog
- After delete, user returns to Meetings List

---

### FR-008: Persons List & Management ✅
**Priority:** MUST HAVE

**Description:**
User can view, search, edit and delete persons.

**Acceptance Criteria:**
- Alphabetical list of all persons
- Search/filter by name — supports full-name combined queries (e.g. "Jan K" matches "Jan Kowalski")
- Person detail shows: full name, meeting count
- Edit: first name and last name editable
- Delete: requires confirmation
- Warning shown if person has associated meetings
- Cannot silently delete person with meetings — explicit confirmation required
- Persons with duplicate names display contextual nick suffix: `"Jan Kowalski · nick"`

### FR-028: Unique Person Names with Nickname Enforcement ✅
**Priority:** MUST HAVE

**Description:**
User is prevented from creating two persons with identical first and last name without
a distinguishing nickname.

**Acceptance Criteria:**
- Duplicate check: case-insensitive, trimmed firstName + lastName comparison
- Adding a person with duplicate name: nickname field revealed and required before save
- Editing a person's name to match another: non-blocking warning banner shown
- Existing duplicates: surfaced via warning banner on edit, no automatic data migration
- Contextual nick display: `"Jan Kowalski · nick"` shown only when duplicate name exists
- Applied in: Friends tab, Add Meeting autocomplete, participant chips
---

### FR-029: Person Meetings List
**Priority:** SHOULD HAVE
**Feature:** FEATURE-007 (Persons View), US-099

**Description:**
From a person's detail screen, user can navigate to a filtered list of all meetings
with that person and open any of them for editing.

**Acceptance Criteria:**
- Magnifying glass icon displayed next to the meeting count on Person Detail screen
- Tapping the icon opens a new screen listing only meetings where that person participated
- List is grouped by year and month (same layout as Meetings tab)
- Tapping a meeting navigates to Meeting Detail → Edit Meeting (existing flow)
- Empty state displayed if person has no meetings

---

### FR-030: Delete Received Meeting Package
**Priority:** SHOULD HAVE
**Feature:** FEATURE-012 (Meeting Sharing System), US-098

**Description:**
User who received a meeting package can delete it from Pending Meetings without importing any data.

**Acceptance Criteria:**
- Swipe left on a shared package tile in Meeting Inbox reveals a "Delete" action
- Confirmation dialog required before deletion
- Package document deleted from `users/{uid}/pending_meetings/` — no meetings, persons, or activities are imported
- Tile removed from the list immediately after deletion

---

### FR-009: Activity Categories ✅
**Priority:** MUST HAVE

**Description:**
Activities can be organized into a 3-level category hierarchy with icons.

**Acceptance Criteria:**
- ActivityCategory has: name, iconIdentifier, isGlobal, parentCategoryId (optional)
- Maximum 2 levels of nesting (category → subcategory)
- Icons selected from predefined set of ~50 Material icons
- Global categories: read-only for users, managed via Firebase Console
- User can create private categories at any level
- Category hierarchy used in statistics filtering (M3)

---

### FR-010: Activities List & Management ✅
**Priority:** MUST HAVE

**Description:**
User can view, add, edit and delete activities organized in category tree.

**Acceptance Criteria:**
- Activities displayed in expandable category tree
- Global activities visible but marked as read-only
- User can add private activity with name, icon, optional category
- User can edit/delete their own private activities
- User cannot edit/delete global activities
- Search/filter by activity name

---

### FR-011: Global Activity Library ✅
**Priority:** MUST HAVE

**Description:**
A prebuilt library of common activities available to all users.

**Acceptance Criteria:**
- Global categories and activities seeded in Firebase Console
- Marked with isGlobal: true, userId: null
- Read-only for all authenticated users
- Covers common social activities (sport, food, entertainment, travel, etc.)
- Each global activity has an icon assigned

---

## 4. Functional Requirements — M3: Statistics & Export ✅

### FR-012: Statistics Overview ✅
**Priority:** MUST HAVE

**Description:**
User can view aggregated statistics about their social activity.

**Acceptance Criteria:**
- Statistics screen accessible from main navigation
- Default time range: last 12 months
- Time range filter: 3 months / 6 months / 12 months / all time
- Overview shows: total meetings, unique persons met, most frequent person
- Data computed client-side from Firestore

---

### FR-013: Person Frequency Statistics ✅
**Priority:** MUST HAVE

**Description:**
User can see who they meet most and least often.

**Acceptance Criteria:**
- Ranked list of persons by meeting count (descending)
- Shows last meeting date per person
- "Haven't seen in a while" section: persons not met in 60+ days
- Filterable by time range
- Tapping person opens Person Detail screen

---

### FR-014: Activity Statistics ✅
**Priority:** MUST HAVE

**Description:**
User can see which activities they do most and with whom.

**Acceptance Criteria:**
- Ranked list of activities by occurrence count
- Category hierarchy respected: filtering by "Sport" includes all subcategories and their activities
- Per-activity: which persons are associated
- Filterable by time range and category

---

### FR-015: Data Export ✅
**Priority:** SHOULD HAVE

**Description:**
User can export all their data as a JSON file for backup purposes.

**Acceptance Criteria:**
- Export option in Settings or Profile
- Exports all meetings, persons, activities in JSON format
- File saved to device Downloads folder
- Filename: `friendsheet_export_YYYY-MM-DD.json`
- Success confirmation with file path
- Works offline (uses Firestore local cache)

---

## 5. Functional Requirements — M3.5: Visual Design & Brand Identity

### FR-026: Friend Groups ✅
**Priority:** SHOULD HAVE

**Description:**
User can organise their contacts into named groups (e.g. "Running Crew", "Work"). Groups have an optional icon chosen from the same predefined set as activity categories. A person can belong to multiple groups simultaneously. Persons not assigned to any group appear in a non-collapsible "Ungrouped" section.

**Acceptance Criteria:**
- Friends tab displays persons grouped by their assigned groups (ExpansionTile per group)
- "Ungrouped" section always visible at the bottom — non-collapsible
- AppBar `+` opens a bottom sheet offering "Add Person" or "Add Group"
- Add Group: name required (max 50 chars), icon optional (from activity_icons set)
- Edit Group: long-press on group header → bottom sheet → Edit / Delete
- Delete Group: confirmation dialog; persons are NOT deleted when group is deleted
- Assign persons to group: `person_add` icon on group trailing → multi-select bottom sheet (shows only persons not already in that group)
- Remove person from group: `PersonDetailScreen` → "Groups" section → uncheck group checkbox
- A person can belong to zero or more groups simultaneously
- Deleting a person removes them from all groups atomically (WriteBatch)
- Search in Friends tab flattens all groups into a single unstructured list
- Firestore path: `users/{uid}/friend_groups/{groupId}`
- Firestore security rules: path-based `userId` check (not `resource.data.userId`) — required for list queries

---

## 6. Functional Requirements — M4: Google Play Release 

### FR-016: Production Release
**Priority:** MUST HAVE

**Description:**
App published on Google Play Store as a publicly downloadable application.

**Acceptance Criteria:**
- App available on Google Play for Android API 21+
- App icon, screenshots, description and Privacy Policy published
- App passes Google Play review
- Version numbered as 1.0.0

---

## 7. Functional Requirements — M5: Meeting Import Hub

**Overview:** M5 introduces an extensible import system that allows users to create meetings from external data sources. The shared `MeetingInbox` (review queue) is source-agnostic — both Calendar and Photos produce `ImportCandidate` objects that flow into the same review UX.

**Architecture principle:** Adding a new import source in future milestones requires only a new data-fetching layer, not a new inbox implementation.

### FR-017: Generate Sharing Token
**Priority:** MUST HAVE

**Description:**
New user (recipient) generates a single-use sharing token to give to an existing user (sender),
enabling the sender to share meetings where the recipient participated.

**Acceptance Criteria:**
- Token generation accessible from drawer Sharing section and Home CTA (<50 meetings)
- 6-character alphanumeric token generated (e.g. "FR4K9X"), 24-hour TTL, single-use
- Token displayed with copy button and expiry time
- Token stored in `users/{uid}/sharing_tokens/` subcollection

---

### FR-018: Link Friend Account & Share Meetings
**Priority:** MUST HAVE

**Description:**
Sender (A) enters recipient's (C) sharing token in C's Person Detail screen to link accounts,
then selects which meetings to share. C receives them in Pending Meetings with full conflict resolution.

**Acceptance Criteria:**
- "Share meetings with friend" option on Person Detail screen
- Token input: validated (exists, not expired, not used); Person record updated with linkedUserId
- Sender selects meetings where C participated; controls what to include (persons, activities)
- Person data shared: first name + last name only — notes never shared
- GDPR notice shown before confirm
- Package delivered to recipient's Pending Meetings
- Recipient resolves: duplicate meetings (by date), duplicate persons (by name), duplicate activities (by name)
- All conflicts must be resolved before final import confirmed
- Clear error messages: invalid code / expired code / already used

**Technical note:** Copy-based (Option A) — data is duplicated, not shared in real-time. Data may diverge after import if sender edits original meetings.

---

### FR-019: Home Screen Onboarding CTA
**Priority:** MUST HAVE
**Feature:** FEATURE-013 (Calendar Import)

**Description:**
New users with fewer than 50 meetings see a prompt encouraging them to import past meetings from Google Calendar.

**Acceptance Criteria:**
- CTA card shown on Home Screen when user has < 50 total meetings
- Card: icon, headline, subtext, "Import from Calendar" button, dismiss (X)
- Dismissed state persisted in SharedPreferences (key: `onboarding_calendar_cta_dismissed`)
- CTA never shown again after dismiss or after ≥ 50 meetings reached
- Tapping button navigates to Calendar Permission screen

---

### FR-020: Google Calendar Import
**Priority:** MUST HAVE
**Feature:** FEATURE-013 (Calendar Import)

**Description:**
User grants read-only Google Calendar access, selects a date range and calendars, picks qualifying events, and reviews them in the Meeting Inbox before saving.

**Acceptance Criteria:**
- OAuth consent via `google_sign_in` with scope `calendar.readonly`
- Token stored via `flutter_secure_storage`
- Settings section in SettingsScreen:
  - "Disconnect Calendar" option
- Date range picker (default: last 12 months)
- Events filtered: past only, respects ALL-DAY setting
- Multi-select with "Select All / Deselect All"
- Selected events converted to `ImportCandidate` list and passed to Meeting Inbox
- Permission revocable; graceful handling if denied
- Filter panel (date range + calendar checkboxes + all-day toggle) collapsible on CalendarEventsScreen
- Drawer tile: dynamic label based on connection state ("Import from Calendar" / "Browse & Import Events")
- Home Screen CTA: visible until user reaches 50 meetings, no dismiss button

---

### FR-021: Meeting Inbox — Review & Confirm
**Priority:** MUST HAVE
**Feature:** FEATURE-013 (Calendar Import) + FEATURE-014 (Photos Import — shared)

**Description:**
User reviews import candidates from any source one by one, enriches each with meeting details, and confirms or skips each entry.

**Acceptance Criteria:**
- Inbox list shows all pending `ImportCandidate` cards with progress indicator ("X of Y reviewed")
- Tapping card opens edit screen with pre-filled fields:
  - Name (from event title or empty for photos, editable, max 50 chars)
  - Date (from event start or photo creation date, editable)
  - Weight (default: 3, Fibonacci stepper)
  - Participants (email heuristic suggestions for Calendar; manual for Photos)
  - Activities (standard autocomplete, no pre-fill)
- "Confirm" saves meeting to Firestore, removes card from inbox
- "Skip" removes card without saving
- Inbox stored in memory only (not Firestore) — resets if app is closed
- Empty inbox → success screen with count of added meetings + "Go to Meetings" CTA

---

### FR-022: Google Photos Import
**Priority:** SHOULD HAVE
**Feature:** FEATURE-014 (Photos Import)
**Target:** Post Google Play release

**Description:**
User grants read-only Google Photos access, browses their photo library, selects photos that remind them of past meetings, and reviews them in the shared Meeting Inbox.

**Acceptance Criteria:**
- OAuth consent via `google_sign_in` with scope `photoslibrary.readonly`
- Token stored via `flutter_secure_storage` (same service as Calendar)
- Photo grid: paginated, first page < 2 seconds
- Each photo shows thumbnail and creation date
- Multi-select; selected photos create `ImportCandidate` with date from photo metadata, empty title
- Flows into shared `MeetingInboxScreen` (FR-021)
- Photo NOT stored — only creation date used
- Permission revocable from Settings

---

## 8. Functional Requirements — M6: Custom Dashboard

### FR-023: Default Dashboard
**Priority:** MUST HAVE

**Description:**
User sees a configurable home screen with key metrics.

**Acceptance Criteria:**
- Dashboard shows default widgets: recent meeting count, top person this month, top activity this month
- Data sourced from Statistics layer (M3)
- Refreshes on screen focus

---

### FR-024: Dashboard Customization
**Priority:** SHOULD HAVE

**Description:**
User can add, remove and reorder dashboard widgets.

**Acceptance Criteria:**
- Edit mode for dashboard
- Widget library with available types
- Drag to reorder
- Remove widget
- Add widget from library
- Configuration persisted in Firestore
- Restored on next app launch

---

## 9. Functional Requirements — M7: AI Assistant

### FR-025: AI Assistant — Buddy (M7)
**Priority:** COULD HAVE
**Status:** 🔄 Partially Implemented — US-088 (API Key) ✅, US-085 (Consent) ✅, US-086 (Context Builder) ✅, US-087 (AI Chat Screen) ✅, US-101 (HomeScreen Buddy widget) ✅; US-107 (relationship score), US-106 (annual report) planned

**Description:**
User interacts with Buddy — a friendly AI assistant that knows their social history. Buddy is proactive (HomeScreen widget), conversational (single chat screen), and covers three journeys: meeting notes, friend wishes, and free social queries.

**Acceptance Criteria:**
- Buddy widget on HomeScreen: proactively suggests adding notes to recent meetings without notes (last 2 months); falls back to friendship insights or default greeting
- Single AI chat screen with dynamic context (meeting-notes mode, friend-wishes mode, free-query mode)
- Friend wishes (Opcja A): Buddy shows friendship summary first, then asks to generate personalized wishes; wishes are copyable
- Meeting notes mode: Buddy collects free-text memories and saves them to the meeting; asks if there is more
- Free query: user can ask any question about social history; Buddy uses full context (last 12 months default)
- BYOK — user provides their own OpenAI API key; stored in Flutter Secure Storage; never written to Firestore or logs
- Pseudonymization: real names replaced with Friend_A, Friend_B on-device before every API call
- Explicit one-time consent required before first use; consent stored in SharedPreferences
- System prompt hardcoded: defines Buddy's friendly/warm character, scope, and guardrails; never exposed to user
- Buddy never fabricates data, performs DELETE operations, reveals system prompt, or gives medical/legal/financial advice
- Conversation history visible within session; not persisted between sessions
- Birthday reminders: Buddy surfaces upcoming birthdays (within 7 days) in widget
- Proactive insights: Buddy flags friends not seen in 3+ months
- Advanced features (P2): annual social report, relationship strength indicator, sentiment analysis of notes

---

### FR-031: Meeting Notes
**Priority:** MUST HAVE (M7 prerequisite)
**Status:** ✅ Implemented (US-100)

**Description:**
User can add structured notes to any meeting as a list of bullet points, capturing individual memories one by one.

**Acceptance Criteria:**
- `notes` field on Meeting model — `List<String>` with default empty list; stored in Firestore as an array
- Notes added one by one inline in MeetingDetailScreen (below activities) — no separate screen
- Each note saved to Firestore immediately when added via round green "+" button; removal also auto-saves
- Note count badge displayed on meeting list card when notes non-empty (singular/plural handled)
- Notes included in AI context (US-086) and friend summaries (US-087)

---

### FR-032: Friend Birthday Tracking
**Priority:** SHOULD HAVE (M7)

**Description:**
User can store a friend's birthday in their Person profile. Buddy uses this to surface birthday reminders.

**Acceptance Criteria:**
- Optional `birthDate` field on Person model
- Date picker in PersonDetailScreen edit mode
- Buddy widget shows birthday reminder when friend's birthday is within 7 days

---

### FR-033: AI Tool Calling — Historical Queries
**Priority:** SHOULD HAVE (M7)

**Description:**
Buddy can answer questions about any time period using OpenAI tool calling (function calling). Instead of sending the full 12-month context in every request, Buddy requests only the data relevant to the user's question from the on-device cache.

**Acceptance Criteria:**
- User can ask Buddy about meetings from any year (e.g. "Summarise my relationship with Gosia in 2019")
- Buddy fetches only relevant data per question — no full-context payload
- When a person name is ambiguous, app shows a native disambiguation UI (not AI text)
- Pseudonymization maintained: OpenAI never receives real names in tool call parameters

---

### FR-034: Offline-First Mode
**Priority:** SHOULD HAVE (M7)

**Description:**
User can browse and edit their data without an internet connection. Write operations are queued locally and synced automatically when connectivity returns.

**Acceptance Criteria:**
- All read screens (meetings, persons, statistics) load from on-device Hive cache immediately on app open
- Add / edit / delete meetings and persons work offline; changes appear instantly in UI
- Offline banner displayed when connectivity is lost; dismissed automatically on reconnect
- Pending sync indicator shown when writes are queued and not yet confirmed by Firestore
- Online-only features (Buddy AI chat, Google Calendar import) display informative message when offline

---

## 10. Non-Functional Requirements

### NFR-001: Data Storage
- Data stored in Firestore
- Each user accesses only their own data (except global activities/categories)
- Data model supports statistics generation

### NFR-002: Performance
- Meeting save: < 3 seconds
- Autocomplete response: < 500ms
- Google Sign-In: < 5 seconds (excluding user interaction)
- Statistics screen load: < 3 seconds (client-side aggregation)
- Calendar events fetch (first page): < 3 seconds
- Photo grid load (first page): < 2 seconds

### NFR-003: Security
- All Firestore operations require authenticated user
- Row-level security via userId field
- Global data (isGlobal: true) read-only for all authenticated users
- OAuth 2.0 tokens managed by Firebase SDK (Firebase Auth) and `flutter_secure_storage` (Calendar + Photos)
- No credentials stored in app code or committed to repository
- Keystore never committed to version control (M4+)
- Raw user data never sent to LLM without explicit consent (M8)

### NFR-004: Privacy
- Google Calendar access: read-only, only event metadata used (title, date, attendee emails), no calendar data stored permanently
- Google Photos access: read-only, only photo creation date used, no photos stored
- Meeting Inbox: local memory only — not persisted to Firestore, clears on app close
- AI context: full meeting list with details sent to OpenAI API; pseudonymized on-device before every request (real names replaced with Friend_A, Friend_B...); per-person filtering applied for friend-specific queries
- AI key: user's own OpenAI API key (BYOK); stored in Flutter Secure Storage; never written to Firestore, logs, or debug console
- Data export: user owns their data and can extract it at any time
- Meeting sharing: user explicitly initiates, no automatic data sharing; notes never included in shared packages

### NFR-005: Offline Availability
- Firestore offline persistence enabled; write operations queued on-disk by SDK and replayed automatically on reconnect
- All read screens (meetings, persons, statistics, activities) available offline via Hive `LocalCacheService` (US-109)
- Add / edit / delete meetings and persons available offline — Firestore SDK queues writes (US-111)
- New authentication requires internet connection
- Statistics computed from Hive cache when offline
- Export available offline (uses local cache)
- Calendar import, Google Sign-In, and Buddy AI chat require active internet connection
- Offline banner shown automatically when connectivity is lost; dismissed on reconnect (US-111)
- Pending sync indicator shown when Firestore has queued writes not yet confirmed (US-111)

### NFR-006: Compatibility
- Android API Level 21+ (Android 5.0)
- Google Play Services required
- Google account on device required for authentication
- Internet connection required for initial auth and data sync

### NFR-007: Accessibility
- WCAG 2.1 Level AA compliance for all screens
- Minimum touch target: 48dp
- Color contrast ratio: 4.5:1 minimum
- Screen reader compatible (TalkBack)

### NFR-008: Cost Constraints
- Firestore: free tier (Spark plan) sufficient for personal use and small user base
- Google Calendar API: free quota (1M requests/day) sufficient for personal use
- Google Photos API: free quota sufficient for expected usage
- LLM API (M8): cost per query must be evaluated in spike before implementation — feature may be limited or paywalled if costs are significant

---

## 11. Data Model

### 11.1 Core Entities (M1 — implemented)

#### Meeting
```
- id: string (auto-generated)
- userId: string (owner)
- name: string (max 50 characters)
- date: DateTime
- weight: int (1, 2, 3, 5, 8, 13, 21)
- participantIds: List<string>
- categoryIds: List<string>
- createdAt: DateTime
- updatedAt: DateTime
```

#### Person
```
- id: string (auto-generated)
- userId: string (owner)
- firstName: string
- lastName: string (optional)
- nicknames: List<string> (default: [])
- createdAt: DateTime
```

#### Activity
```
- id: string (auto-generated)
- userId: string (owner, null for global)
- name: string
- categoryId: string? (optional)
- isGlobal: bool
- createdAt: DateTime
```

### 11.2 New Entities (M2+)

#### ActivityCategory (M2)
```
- id: string (auto-generated)
- userId: string (owner, null for global)
- name: string
- iconIdentifier: string (references predefined icon set)
- isGlobal: bool
- parentCategoryId: string? (optional, max 2 levels deep)
- Firestore path: users/{userId}/activity_categories (subcollection per user)
- Onboarding: global categories batch-copied to user on first login (US-020)
- createdAt: DateTime
```

#### FriendGroup (M3.5 — US-062)
```
- id: string (auto-generated)
- name: string (max 50 characters)
- iconIdentifier: string? (optional, same predefined set as ActivityCategory)
- personIds: List<string> (references to Person.id — many-to-many)
- createdAt: DateTime?
- Firestore path: users/{userId}/friend_groups (subcollection per user)
```

#### InvitationCode (M5)
```
- id: string (auto-generated)
- code: string (6-char alphanumeric, unique)
- senderId: string (userId of generator)
- targetPersonId: string (personId from sender's contacts)
- status: string (pending | used | expired)
- expiresAt: DateTime (createdAt + 48h)
- createdAt: DateTime
```

#### ImportCandidate (M5 — local memory only, NOT stored in Firestore)
```
- id: string (local UUID, session-only)
- title: string (pre-filled from event title or empty)
- date: DateTime (from event start date or photo creation date)
- attendeeEmails: List<string> (Calendar only; empty for Photos)
- sourceType: enum (calendar | photos)
```

#### DashboardConfig (M6)
```
- id: string (auto-generated)
- userId: string (owner)
- widgets: List<DashboardWidgetConfig> (ordered)
- updatedAt: DateTime
```

### 11.3 Relationships
- Meeting ↔ Person (many-to-many) via participantIds
- Meeting ↔ ActivityCategory (many-to-many) via categoryIds
- ActivityCategory → ActivityCategory (self-reference) via parentCategoryId
- FriendGroup ↔ Person (many-to-many) via personIds (group references persons, not vice versa)
- InvitationCode → Person via targetPersonId
- InvitationCode → User via senderId
- ImportCandidate → Meeting (1:1, created on Confirm action in Inbox)

---

## 12. Technical Dependencies

### 12.1 Current Stack (M1)
- Flutter SDK 3.0+, Dart 2.17+
- Firebase Auth, Cloud Firestore, Firebase Core
- google_sign_in, provider, freezed, json_serializable

### 12.2 Planned Additions

| Milestone | Package | Purpose |
|-----------|---------|---------|
| M3 | path_provider | File system access for export |
| M4 | Release signing config | Production build |
| M5 (FEATURE-013) | `google_sign_in` (extended scope: calendar.readonly) | Calendar OAuth |
| M5 (FEATURE-013) | `flutter_secure_storage` | OAuth token storage |
| M5 (FEATURE-013) | Google Calendar REST API (HTTP) | Fetch calendar events |
| M5 (FEATURE-014) | `google_sign_in` (extended scope: photoslibrary.readonly) | Photos OAuth |
| M5 (FEATURE-014) | Google Photos REST API (HTTP) | Fetch photos metadata |
| M7 | HTTP client (already available), LLM SDK TBD | AI API calls |

---

## 13. Glossary

- **MVP** — M1: minimum viable product with Add Meeting functionality
- **Meeting Weight** — Fibonacci-scale importance metric (1, 2, 3, 5, 8, 13, 21)
- **Autocomplete** — UI pattern suggesting existing values while typing
- **isGlobal** — flag indicating data managed by app (read-only for users) vs user-owned
- **Copy-based sharing** — data duplicated to recipient's Firestore, no real-time sync after import
- **TTL** — Time To Live, automatic expiry of sharing tokens after 24 hours
- **linkedUserId** — field on Person model storing the Friendsheet uid of the linked friend account
- **SharingToken** — single-use token generated by recipient (C) to authorize sender (A) to share meetings
- **iconIdentifier** — string key (e.g. "sports_tennis") referencing a predefined icon in the app
- **ImportCandidate** — transient in-memory model representing an event or photo selected for import; never persisted to Firestore
- **Meeting Inbox** — shared review queue (MeetingInboxScreen) that accepts ImportCandidate objects from any source; source-agnostic
- **sourceType** — enum field on ImportCandidate indicating the origin: `calendar` or `photos`
- **FriendGroup** — named bucket of person ID references; a person can belong to zero or more groups; groups are owned by a user via `users/{uid}/friend_groups` subcollection
- **Ungrouped** — persons not assigned to any group; shown in a permanent non-collapsible section at the bottom of the Friends tab

---

**End of Document**  
**Version 2.2 — FR-026 Friend Groups (US-062)**