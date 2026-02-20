# Friendsheet - Requirements Documentation

**Version:** 2.0  
**Date:** February 20, 2026  
**Author:** Product Owner  
**Status:** Updated — Full Roadmap M1-M8

**Change Log:**
- v1.1 — Authentication changed from email/password to Google Sign-In
- v2.0 — Full roadmap requirements added for M2-M8

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
| M2 | Management & CRUD | 🔜 Next |
| M3 | Statistics & Export | 📋 Planned |
| M4 | Google Play Release | 📋 Planned |
| M5 | Social: Data Sharing | 📋 Planned |
| M6 | Google Photos Integration | 📋 Planned |
| M7 | Custom Dashboard | 📋 Planned |
| M8 | AI Assistant | 💡 Future |

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

## 3. Functional Requirements — M2: Management & CRUD

### FR-006: Meetings List View
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

### FR-007: Meeting Detail & Edit
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

### FR-008: Persons List & Management
**Priority:** MUST HAVE

**Description:**
User can view, search, edit and delete persons.

**Acceptance Criteria:**
- Alphabetical list of all persons
- Search/filter by name
- Person detail shows: full name, meeting count
- Edit: first name and last name editable
- Delete: requires confirmation
- Warning shown if person has associated meetings
- Cannot silently delete person with meetings — explicit confirmation required

---

### FR-009: Activity Categories
**Priority:** MUST HAVE

**Description:**
Activities can be organized into a 3-level category hierarchy with icons.

**Acceptance Criteria:**
- ActivityCategory has: name, iconIdentifier, isGlobal, parentCategoryId (optional)
- Maximum 3 levels of nesting (category → subcategory → activity)
- Icons selected from predefined set of ~50 Material icons
- Global categories: read-only for users, managed via Firebase Console
- User can create private categories at any level
- Category hierarchy used in statistics filtering (M3)

---

### FR-010: Activities List & Management
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

### FR-011: Global Activity Library
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

## 4. Functional Requirements — M3: Statistics & Export

### FR-012: Statistics Overview
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

### FR-013: Person Frequency Statistics
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

### FR-014: Activity Statistics
**Priority:** MUST HAVE

**Description:**
User can see which activities they do most and with whom.

**Acceptance Criteria:**
- Ranked list of activities by occurrence count
- Category hierarchy respected: filtering by "Sport" includes all subcategories and their activities
- Per-activity: which persons are associated
- Filterable by time range and category

---

### FR-015: Data Export
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

## 5. Functional Requirements — M4: Google Play Release

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

## 6. Functional Requirements — M5: Social Data Sharing

### FR-017: Generate Invitation Code
**Priority:** MUST HAVE

**Description:**
User can generate an invitation code for a specific person in their contacts list.

**Acceptance Criteria:**
- "Share with friend" option on Person Detail screen
- 6-character alphanumeric code generated (e.g. "FR4K9X")
- Code stored in Firestore with 48-hour TTL
- Code shareable via system share sheet
- User can view active/expired codes they generated
- One code per person at a time (new code invalidates previous)

---

### FR-018: Redeem Invitation Code
**Priority:** MUST HAVE

**Description:**
New user enters an invitation code and receives shared meeting history.

**Acceptance Criteria:**
- Code entry accessible from Home screen or onboarding
- System validates: code exists, not expired, not already used
- On valid code: all sender's meetings where targetPerson appears are copied to recipient's Firestore
- Persons and activities from those meetings also copied (deduplicated by name)
- Code marked as used after successful redemption
- Success screen shows count of imported meetings
- Clear error messages: invalid code / expired code / already used

**Technical note:** Copy-based (Option A) — data is duplicated, not shared in real-time. Data may diverge after import if sender edits original meetings.

---

## 7. Functional Requirements — M6: Google Photos Integration

### FR-019: Connect Google Photos
**Priority:** MUST HAVE

**Description:**
User grants Friendsheet read-only access to their Google Photos.

**Acceptance Criteria:**
- "Browse Photos" option in Add Meeting flow
- Clear permission request explaining why photo access is needed
- Google Photos OAuth consent shown on first use
- Permission revocable from app Settings
- Graceful degradation if permission denied

---

### FR-020: Create Meeting from Photo
**Priority:** MUST HAVE

**Description:**
User browses their photos and selects one to pre-fill meeting date.

**Acceptance Criteria:**
- Photo grid showing device photos (paginated, performance-optimized)
- Tapping photo shows "Create meeting from this photo" option
- Meeting date pre-filled from photo's creation date
- User proceeds to Add Meeting screen with pre-filled date
- Photo itself is NOT stored in Firestore
- Back navigation returns to photo grid without data loss

---

## 8. Functional Requirements — M7: Custom Dashboard

### FR-021: Default Dashboard
**Priority:** MUST HAVE

**Description:**
User sees a configurable home screen with key metrics.

**Acceptance Criteria:**
- Dashboard shows default widgets: recent meeting count, top person this month, top activity this month
- Data sourced from Statistics layer (M3)
- Refreshes on screen focus

---

### FR-022: Dashboard Customization
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

## 9. Functional Requirements — M8: AI Assistant

### FR-023: AI-powered Insights
**Priority:** COULD HAVE

**Description:**
User can ask natural language questions about their social data.

**Acceptance Criteria:**
- Chat-like UI for questions
- AI has context of user's statistics summary (not raw Firestore data)
- Example queries: "Who should I reach out to this week?", "What's my most social month?"
- User explicitly consents before data sent to external API
- Error handling for API failures and rate limits
- LLM API selection based on cost/privacy spike (US-040)

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
- Photo grid load: paginated, first page < 2 seconds

### NFR-003: Security
- All Firestore operations require authenticated user
- Row-level security via userId field
- Global data (isGlobal: true) read-only for all authenticated users
- OAuth 2.0 tokens managed by Firebase SDK (Firebase Auth) and flutter_secure_storage (Google Photos)
- No credentials stored in app code or committed to repository
- Keystore never committed to version control (M4+)
- Raw user data never sent to LLM without explicit consent (M8)

### NFR-004: Privacy
- Google Photos access: read-only, only date metadata used, no photos stored
- AI context: aggregated statistics only, no raw meeting data
- Data export: user owns their data and can extract it at any time
- Invitation code sharing: user explicitly initiates, no automatic data sharing

### NFR-005: Offline Availability
- Firestore offline persistence enabled
- Authenticated users can access cached data without internet
- New authentication requires internet connection
- Statistics computed from cached data when offline
- Export available offline (uses local cache)

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
- activityIds: List<string>
- createdAt: DateTime
- updatedAt: DateTime
```

#### Person
```
- id: string (auto-generated)
- userId: string (owner)
- firstName: string
- lastName: string (optional)
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
- parentCategoryId: string? (optional, max 3 levels deep)
- createdAt: DateTime
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

#### DashboardConfig (M7)
```
- id: string (auto-generated)
- userId: string (owner)
- widgets: List<DashboardWidgetConfig> (ordered)
- updatedAt: DateTime
```

### 11.3 Relationships
- Meeting ↔ Person (many-to-many) via participantIds
- Meeting ↔ Activity (many-to-many) via activityIds
- Activity → ActivityCategory (optional) via categoryId
- ActivityCategory → ActivityCategory (self-reference) via parentCategoryId
- InvitationCode → Person via targetPersonId
- InvitationCode → User via senderId

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
| M6 | flutter_secure_storage | OAuth token storage |
| M8 | HTTP / LLM SDK (TBD) | AI API calls |

---

## 13. Glossary

- **MVP** — M1: minimum viable product with Add Meeting functionality
- **Meeting Weight** — Fibonacci-scale importance metric (1, 2, 3, 5, 8, 13, 21)
- **Autocomplete** — UI pattern suggesting existing values while typing
- **isGlobal** — flag indicating data managed by app (read-only for users) vs user-owned
- **Copy-based sharing** — data duplicated to recipient's Firestore, no real-time sync after import
- **TTL** — Time To Live, automatic expiry of invitation codes after 48 hours
- **iconIdentifier** — string key (e.g. "sports_tennis") referencing a predefined icon in the app

---

**End of Document**  
**Version 2.0 — Full Roadmap M1-M8**
