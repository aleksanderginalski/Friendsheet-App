# Sekcje do zastąpienia w README.md

---

## 🗺️ Roadmap

| Milestone | Name | Status |
|-----------|------|--------|
| M1 | Add Meeting | ✅ Completed |
| M2 | Management & CRUD | ✅ Completed |
| M3 | Statistics & Export | ✅ Completed |
| M3.5 | Visual Design & Brand Identity | ✅ Completed |
| M4 | Google Play Release | ✅ Completed |
| M5 | Meeting Import Hub | 🔄 In Progress |
| M6 | Custom Dashboard | 📋 Planned |
| M7 | AI Assistant | 💡 Future |

**M2 — Management & CRUD:** Full CRUD for meetings, persons and activities. Meetings list grouped by year and month. Activity categories with icons and 2-level hierarchy. Friend groups for organising contacts.

**M3 — Statistics & Export:** Activity breakdown, who-per-activity and interaction distribution charts with animated bars. Year stepper with offline-first Hive cache. JSON data export.

**M3.5 — Visual Design & Brand Identity:** Custom app icon, splash screen, Nunito typography, green/amber design system, empty state illustrations, friend groups UI.

**M4 — Google Play Release:** Production build with release signing, store assets, Privacy Policy, Google Play Internal Testing track. Portfolio milestone.

**M5 — Meeting Import Hub:** Google Calendar import — browse past events, review candidates in Meeting Inbox, confirm as meetings. Peer-to-peer sharing: generate sharing token (US-089) so a friend can share their meetings with you. Extensible architecture supports future import sources (Google Photos planned).

**M6 — Custom Dashboard:** Configurable home screen with drag-and-drop metric widgets.

**M7 — AI Assistant:** Natural language queries about social data. LLM API selection requires cost/privacy spike first.

---

## 📚 Documentation

Comprehensive documentation is available in the [`docs/`](docs/) folder:

- [Requirements Documentation](docs/requirements.md) — Functional and non-functional requirements
- [Architecture Documentation](docs/architecture.md) — System design and diagrams
- [UI/UX Documentation](docs/wireframes.md) — Screen designs and user flows
- [Design Brief](docs/friendsheet_design_brief.md) — Visual identity, color palette and typography guidelines
- [Test Cases](docs/TEST_CASES.md) — Manual test cases
- [Code Examples](docs/code_snippets.md) — Implementation snippets
- [Project Structure](docs/PROJECT_FILES.md) — Full file inventory
- [Product Backlog](docs/BACKLOG.md) — Sprint planning and user stories

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK:** 3.0 or higher
- **Dart:** 2.17 or higher
- **Android Studio** or **VS Code** with Flutter plugins
- **Android Emulator** or physical Android device
- **Git** for version control
- **Firebase Account** (free tier)

### Installation

1. **Clone the repository**
```powershell
git clone https://github.com/aleksanderginalski/friendsheet-app.git
cd friendsheet-app
```

2. **Install dependencies**
```powershell
flutter pub get
```

3. **Firebase Setup**

You need to set up your own Firebase project:

   a. Create a Firebase project at https://console.firebase.google.com  
   b. Add an Android app with package name: `com.friendsheet.app`  
   c. Download `google-services.json`  
   d. Place it in: `android/app/google-services.json`  
   e. Run `flutterfire configure` to generate `lib/firebase_options.dart`

   **Note:** `google-services.json` and `firebase_options.dart` are gitignored for security. You must create your own Firebase project.

4. **Run the app**
```powershell
flutter run
```

---

## 🧪 Testing

```powershell
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run static analysis
flutter analyze

# Check code formatting
flutter format --set-exit-if-changed .
```

**Current Test Status:**
```
✅ All tests passing (538)
✅ Code formatted correctly
✅ Firebase connected successfully
✅ CI/CD pipeline operational
```

---

## 📱 Supported Platforms

- ✅ **Android** — API 21+ (Android 5.0) — current focus
- 🔄 **Google Play** — Internal Testing track active

---

## 🎨 Code Style

This project follows Flutter's official style guide and uses `flutter_lints` for code quality.

**Key conventions:**
- Use `const` constructors where possible
- Prefer single quotes for strings
- Use trailing commas for better formatting
- Keep files focused and under 300 lines
- Document public APIs with `///` comments
- Code comments and documentation in English only

---

## 🤝 Contributing

This is a personal portfolio project. If you'd like to contribute or have ideas, please **reach out to me first** before opening a pull request — I'd love to hear from you.

📧 Contact via GitHub: [@aleksanderginalski](https://github.com/aleksanderginalski)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design for UI components
- Anthropic Claude for AI-assisted development workflow

---

## 📧 Contact

Project Link: [https://github.com/aleksanderginalski/Friendsheet-App](https://github.com/aleksanderginalski/Friendsheet-App)

---

**Made with ❤️ and Flutter**

*This project documents a full SDLC journey — from backlog and architecture through implementation, testing and Google Play release.*

## 📖 Version History

### v3.43.1 — Test Suite Optimization (March 20, 2026)
- ✅ Test suite reduced from 689 → 538 tests (−151) without coverage loss
- ✅ `statistics_repository_test.dart` split into 3 focused files: `_cache_test`, `_queries_test`, `_distribution_test`
- ✅ `statistics_provider_test.dart` split into 4 focused files: `_test`, `_year_test`, `_visibility_test`, `_distribution_test`
- ✅ Shared helpers extracted: `test/helpers/test_factories.dart`, `test/helpers/firebase_test_helpers.dart`
- ✅ Model tests consolidated: Freezed defaults removed, happy-path checks all fields at once
- ✅ Repository tests consolidated: toggle behavior (add/remove/persist) in single test, duplicate coverage removed
- ✅ Provider tests consolidated: implementation detail assertions (verify() call counts, isSaving transitions) removed
- ✅ QA agent rules updated: explicit anti-patterns documented in `/qa` SKILL.md

### v3.43.0 — US-089: Generate Sharing Token (March 19, 2026)
- ✅ `SharingToken` Freezed model — `token` (6-char [A-Z0-9]), `createdAt`, `expiresAt` (24h TTL), `isUsed` (default false); stored under `users/{uid}/sharing_tokens`
- ✅ `SharingTokenRepository` — idempotent `generateToken()` (cleanup → check active → generate), `getActiveToken()` (client-side `isUsed` filter avoids composite Firestore index), `deleteToken()`, `markAsUsed()`
- ✅ `GenerateSharingTokenScreen` — token display (fontSize 36, letterSpacing 8), expiry countdown, copy button, "Generate new token" action; AppBar white text on green (explicit `titleTextStyle` override)
- ✅ Drawer reorganized: new "Import & Share" section header groups "Share meetings with a friend" + "Import from Calendar"; `Flexible` wrapper on drawer header image fixes overflow on small screens
- ✅ `BuildMeetingBaseCtaCard` replaces two separate CTA cards — single card with two green ElevatedButtons: "Import from Calendar" + "Request from a friend"
- ✅ Firestore Security Rules — `sharing_tokens` subcollection (path-based `isOwner(userId)`)
- ✅ `AccountDeletionService` — extended to delete `sharing_tokens` subcollection on account deletion
- ✅ Total test count: 636 → 675 tests (+39: model 9, repository 10, widget 7, screen 4, home screen +3, main screen +3, account deletion +1, mock regenerations)

### v3.42.0 — US-INF-009: Skills Migration — Agents Migrated to Skills Format (March 19, 2026)
- ✅ All 7 agents migrated from `.claude/commands/` to `.claude/skills/name/SKILL.md` structure
- ✅ Helper files added: `planning/task_template.md` (Task Instruction template), `retro/retro_checklist.md` (retrospective questions)
- ✅ Decision documented in `MULTI_AGENT_ARCHITECTURE.md` — all agents migrated for consistency, helper files only where concrete value exists
- ✅ `.claude/commands/` directory removed — no breaking change (both locations create same slash-command interface)
- ✅ `CLAUDE.md` Agent Directory table updated to new paths
- ✅ `.gitignore` extended — `current_task.md` excluded from version control
- ✅ `BACKLOG.md` — US-INF-009 marked ✅ COMPLETED

### v3.41.0 — US-INF-006: Strategic Agents — /discover, /retro (March 18, 2026)
- ✅ `/discover` agent validated on real session — rewrote FEATURE-012 as peer-to-peer Meeting Sharing System (US-089–093)
- ✅ `/retro` agent validated on US-INF-005 session — improvements applied to `planning.md`, `docs.md`, `retro.md`
- ✅ Both agents confirmed: strategic discussions in Polish, file changes in English
- ✅ `/discover` correctly reads BACKLOG.md context, asks clarifying questions, updates docs on "gotowe"
- ✅ `/retro` reactive + proactive modes confirmed working
- ✅ `BACKLOG.md` — US-INF-006 marked ✅ COMPLETED

### v3.40.0 — US-INF-005: Daily Flow Agents — Validation (March 18, 2026)
- ✅ `/pm`, `/planning`, `/qa`, `/debug`, `/docs` agents validated on a real US (US-INF-005 self-test)
- ✅ Full daily flow exercised: `/pm → /planning → /dev → /qa → /docs`
- ✅ All agents confirmed: git approval rule respected — no autonomous commits
- ✅ `TEST_CASES.md` extended — TC-AGENTS-001–004 manual test cases for agent behavior
- ✅ `BACKLOG.md` — US-INF-005 marked ✅ COMPLETED

### v3.39.0 — US-INF-004: Multi-Agent System Foundation (March 18, 2026)
- ✅ `MULTI_AGENT_ARCHITECTURE.md` added — full architecture for 8 specialized Claude Code agents
- ✅ `.claude/commands/` directory created with all 7 agent files: `/pm`, `/planning`, `/dev`, `/qa`, `/debug`, `/docs`, `/retro`, `/discover`
- ✅ `CLAUDE.md` extended — Multi-Agent System reference section listing all 8 agents and daily/strategic workflows
- ✅ `.claude/settings.json` evaluated and removed — `PreToolUse` hooks not supported on Windows; sensitive data protection handled via agent instructions instead
- ✅ Multi-agent daily workflow established: `/pm → /planning → /dev → manual verify → /qa → /docs → [/retro]`

### v3.38.0 — US-084: Fix Duplicate Activities on Onboarding (March 17, 2026)
- ✅ `AuthService._copyGlobalCategoriesToUser()` — added subcollection existence check (`limit(1)`) as first guard: if user already has categories → skip copy entirely
- ✅ Double guard: subcollection check (covers pre-timestamp accounts) + `onboardingCompletedAt` timestamp (covers all subsequent logins)
- ✅ New `runOnboardingIfNeeded(userId)` public method — called from `main.dart` AuthWrapper on every auth state change; non-fatal on failure
- ✅ Total test count: 635 → 636 tests (+1)

### v3.37.0 — US-083: Unique Person Names with Nickname Enforcement (March 17, 2026)
- ✅ `PersonRepository` — added `isDuplicateName(userId, firstName, lastName, {excludeId})` for case-insensitive, trimmed duplicate check
- ✅ `PersonsListProvider` — added `personNameExists(firstName, lastName, {excludeId})` (client-side, zero Firestore reads) and `displayNameFor(person)` for contextual nick display
- ✅ `AddPersonDialog` — hidden nickname field revealed on duplicate detection; ADD blocked until nick provided; editing name resets duplicate state
- ✅ `PersonDetailScreen` — non-blocking warning banner when duplicate name exists and person has no nickname
- ✅ `PersonAutocomplete` — contextual `· nick` suffix in dropdown and chips; fixed chip re-add state bug; fixed double-pop Navigator crash
- ✅ `PersonListTile` + `GroupSection` — contextual nick display via `displayName` parameter
- ✅ `PersonSearchHelper` — full-name combined search (`"Aleksander G"` matches `"Aleksander Ginalski"`)
- ✅ `AddMeetingProvider`, `InboxItemEditProvider` — propagated `personNameExists` and `nickname` support
- ✅ Total test count: 623 → 635 tests (+12)

### v3.36.0 — US-082: Unique Activity Names Validation (March 17, 2026)
- ✅ `ActivitiesListProvider` — added `activityNameExists(name, {excludeId})` for case-insensitive, trimmed duplicate check against loaded activities
- ✅ `AddEditActivityDialog` — duplicate name validation before save in both Add and Edit modes; inline `_duplicateError` display; excludeId prevents false positive on self-edit
- ✅ `AddMeetingProvider.addNewActivity()` — two-guard validation: Check 1 against `_availableCategories` (Firestore), Check 2 against `_selectedCategories` (current session)
- ✅ Total test count: 610 → 623 tests (+13)

### v3.35.0 — US-081: Continuous Year Slider in Statistics (March 17, 2026)
- ✅ `YearStepper` converted to `StatefulWidget` with `_previewYear` / `_dragAccumulator` state
- ✅ `onHorizontalDragUpdate` — accumulates total displacement, updates year label in real-time (italic, 60% opacity)
- ✅ `onHorizontalDragEnd` — commits selected year via `onYearChanged`, triggers `StatisticsProvider.selectYear()`
- ✅ `onHorizontalDragCancel` — resets without committing (no accidental year change)
- ✅ `LinearProgressIndicator` track shows position in year range — hidden when only one year exists
- ✅ Multi-year drag works correctly (total displacement, not delta-per-frame)
- ✅ Arrows `< >` and single-swipe behavior preserved
- ✅ Total test count: 603 → 610 tests (+7)

### v3.34.0 — US-080: Flat Search Results in Meetings List (March 17, 2026)
- ✅ `MeetingsListProvider` — `isSearchActive` computed getter (true when query.length >= 3), `filteredMeetings` getter for flat list rendering
- ✅ `MeetingsListScreen` — conditional layout: flat `ListView` via `_buildFlatSearchResults` when search active, grouped year→month layout otherwise
- ✅ Search empty state uses `EmptyStateWidget` (illustration + message) — consistent with all other empty states in the app
- ✅ `PersonsListProvider` — Polish diacritic-aware A→Z sort via `_normalizeForSort()` (Ł after L, not after Z)
- ✅ Total test count: 593 → 603 tests (+10)

### v3.33.0 — UX Polish (March 16 2026)
- ✅ Alphabetical sorting (A→Z) in person filter dialogs (Interaction Distribution & Who Per Activity)
- ✅ Polish diacritic-aware sorting — Łukasz sorts after Ludwik, not after Z
- ✅ Extracted `normalizeForSort()` helper to `lib/core/utils/person_sort.dart`

### v3.32.0 — US-062: Friends — Groups (March 12, 2026)
- ✅ `FriendGroup` Freezed model — `id`, `name`, `iconIdentifier` (nullable), `personIds: List<String>`; stored under `users/{uid}/friend_groups`
- ✅ `FriendGroupRepository` — full CRUD + `addPersonToGroup` (arrayUnion, idempotent), `removePersonFromGroup` (arrayRemove), `removePersonFromAllGroups` (WriteBatch cascade)
- ✅ `PersonRepository.deletePerson` — cascade extended: `Future.wait([removePersonFromMeetings, removePersonFromAllGroups])`
- ✅ `FriendGroupsProvider` — owned by `MainScreen`, optimistic updates for add/remove person, `groupsForPerson` client-side filter, reloaded on Friends tab tap
- ✅ `PersonsListScreen` refactored — `Consumer2<PersonsListProvider, FriendGroupsProvider>`; ExpansionTile per group (icon + person count badge) + non-collapsible Ungrouped section at bottom
- ✅ Group management UI — `AddEditGroupDialog` (name + horizontal icon picker), `AssignPersonsBottomSheet` (multi-select unassigned persons), long-press → Edit/Delete bottom sheet
- ✅ `PersonDetailScreen` — `_GroupsSection` with `CheckboxListTile` per group; `FriendGroupsProvider` injected at call-site
- ✅ Firestore security rules deployed for `friend_groups` subcollection (path-based `userId` check)
- ✅ `NicknamesSection` extracted from `PersonDetailScreen` (< 300 lines rule)
- ✅ Total test count: 551 → 593 tests (+42: model 13, repository 14, provider 15)

### v3.31.0 — US-061: Friends Nicknames & Activities Search Fix (March 12, 2026)
- ✅ Extended `Person` model with `nicknames: List<String>` — backward-compatible, missing Firestore field treated as empty list
- ✅ Added nickname management UI in `PersonDetailScreen` — InputChip list with add/remove, silent dedup
- ✅ Extracted `PersonSearchHelper.matches()` — shared util used by PersonsListProvider, PersonAutocomplete, AddMeetingProvider, InboxItemEditProvider
- ✅ Nickname-aware search in Friends tab and AddMeeting autocomplete — nicknames are search keys only, suggestion always shows full name
- ✅ Fixed Activities search — parent categories now appear when query matches parent name directly; parent + matching children shown when child matches
- ✅ Total test count: 551 (+20)

### v3.30.0 — US-075: Statistics & Activities UI Polish (March 12, 2026)
- ✅ Fixed pre-animation flash on year change — all three chart widgets now call `controller.reset()` before `forward()` in `didUpdateWidget`
- ✅ Extracted shared `AppConstants.chartAnimationDuration` (1000ms) — single source of truth for all chart animations
- ✅ Synchronized Who per Activity animation speed to 1000ms (was 600ms) — all three charts now animate in unison
- ✅ Added child count badge to parent activity categories — shows direct child count, hidden on leaf nodes, updates live on add/delete
- ✅ Total test count: 531 (unchanged — pure presentation layer change)

### v3.29.0 — US-076: Delete Account & All User Data (March 12, 2026)
- ✅ `AccountDeletionService` — re-authentication via `reauthenticateWithCredential()`, paginated Firestore subcollection delete (batches of 500), Firebase Auth user delete, full local storage clear (SharedPreferences + flutter_secure_storage + Hive)
- ✅ `DeleteAccountProvider` — isLoading/errorMessage state, no-op guard against double-tap, navigation via `appNavigatorKey` on success
- ✅ `SettingsScreen` — destructive "Delete Account" tile at bottom with confirmation dialog; listener pattern mirrors ExportProvider
- ✅ GDPR requirement for Google Play Data Safety section satisfied — in-app deletion available
- ✅ Total test count: 531 tests (+11 new: 3 service + 8 provider)

### v3.28.0 — US-078: Fix — Silent OAuth Token Refresh for Calendar (March 2026)
- ✅ `_withTokenRetry<T>` generic helper extracted in `GoogleCalendarService` — single retry on `CalendarAuthException`, reusable for future API integrations (Google Photos)
- ✅ Silent token refresh applied to both `fetchCalendars()` and `fetchEvents()` — expired token no longer produces "Failed to load calendars" after ~2h inactivity
- ✅ `CalendarAuthException` caught separately from network errors in drawer handler
- ✅ Drawer snackbar messages updated: auth expiry vs. network error have distinct messages
- ✅ `requiresReconnect` state in `CalendarEventsProvider` — surfaces "Calendar access expired" with Reconnect CTA instead of generic error
- ✅ Total test count: 507 → 518 tests (+11)

### v3.27.0 — US-058: Who Per Activity — Person Filter Dialog & Activity Tree Picker (March 2026)
- ✅ ActivitySelectorDialog refactored — flat list replaced with two-level tree (category headers + child activities with icons)
- ✅ WhoPerActivityPersonFilterDialog — checkbox list, three-state select-all toggle, Auto-select top 10 (by weightSum for current activity), min-1 constraint
- ✅ Long-press hide removed — person visibility managed exclusively via filter dialog (consistent with Activity Breakdown and Interaction Distribution)
- ✅ Filter icon unified — filter_icon.png replacing previous icon (consistent with other stats widgets)
- ✅ autoSelectTop10ForActivity() added to StatisticsProvider
- ✅ Total test count: 487 → 507 tests (+20)

### v3.26.0 - US-046 App Store Assets & Metadata (March 12, 2026)
- ✅ Store listing prepared: short description, full description
- ✅ Screenshots brief created
- ✅ App registered in Google Play Console
- ✅ Internal Testing track configured and active
- ✅ Fix: Google Sign-In on release build — added SHA-256 (release keystore) to Firebase
- ✅ Fix: Google Sign-In on AAB — added Google Play signing key SHA-1/SHA-256 to Firebase

## v3.25.0 — US-060: Statistics Visibility Panel
- ✅ Replaced long-press hide gesture with explicit Settings dialog (Icons.tune)
- ✅ StatisticsVisibilityDialog: checkbox per card, three-state select-all, min-1 enforcement
- ✅ Added left/right arrow navigation to carousel header with wrap-around
- ✅ Removed "Long-press to restore" empty state

### v3.24.0 — Meetings Monthly Grouping, Compact Cards & Expandable Search (US-059) — March 2026
- ✅ MeetingsListProvider extended — two-level grouping year→month (`Map<int, Map<int, List<Meeting>>>`)
- ✅ Default expand: current month + last month with meeting data (not calendar-based)
- ✅ Month sections independently collapsible — `Set<String>` keys in `"YYYY-MM"` format
- ✅ `_MonthHeader` widget — month name + meeting count, indented 16dp under year header
- ✅ MeetingCard compact variant — vertical padding 8dp, reduced font sizes (new default)
- ✅ Expandable search bar in MeetingsListScreen AppBar — mirrors ActivitiesListScreen pattern
- ✅ PersonsListScreen — static SharedSearchBar replaced with expandable AppBar search
- ✅ AppBar actions order unified across tabs: add icon → search icon (🔍)
- ✅ Total test count: 447 → 487 tests (+40)

### v3.23.0 — Persistent Local Cache & Loading Screen (US-073) — March 2026
- ✅ Hive persistent cache for statistics — near-zero Firestore reads on app restart
- ✅ Two-level cache: in-memory (US-072) + Hive disk layer (US-073)
- ✅ JSON bridge pattern — no TypeAdapter conflicts with Freezed models
- ✅ Cache invalidation on write and on logout (HiveService.clearUserData)
- ✅ HomeProvider _initialized flag — eliminates CTA card flash on startup
- ✅ HomeLoadingScreen with custom loading_icon.png

### v3.22.0 — Meeting Inbox (US-068) — March 2026
- ✅ Meeting Inbox (Pending Meetings) — review and confirm imported candidates
- ✅ SharedPreferences persistence — inbox survives app restarts
- ✅ Pending Meetings drawer tile with live candidate count badge
- ✅ Refactored PersonAutocomplete and ActivityAutocomplete to callback-based widgets

### v3.21.0 - US-067 Browse & Select Calendar Events (March 2026)
- ✅ CalendarEvent Freezed model (local memory only — never persisted to Firestore)
- ✅ ImportCandidate Freezed model + ImportSourceType enum (calendar / photos)
- ✅ GoogleCalendarService.fetchEvents() — Google Calendar REST API with date range and all-day filter
- ✅ ValueNotifier<bool> isConnectedNotifier in GoogleCalendarService for reactive connection state
- ✅ CalendarEventsProvider — fetch, filter, multi-select, buildImportCandidates()
- ✅ CalendarEventsScreen with collapsible filter panel (date range + calendar checkboxes + all-day toggle)
- ✅ CalendarEventCard widget with checkbox, title, date, attendee emails
- ✅ CalendarPermissionScreen extended with optional onConnected callback
- ✅ Drawer tile: dynamic label — "Import from Calendar" / "Browse & Import Events" via ValueListenableBuilder
- ✅ HomeScreen CTA: dismiss button removed — card visible until 50 meetings reached
- ✅ Settings: calendar selection checkboxes removed — only "Disconnect Calendar" remains
- ✅ Fix: FutureBuilder replaced with ValueListenableBuilder for reactive connection state
- ✅ Fix: finally/notifyListeners race condition in connectCalendar()
- ✅ Fix: stale drawer context resolved via _openCalendarPermissionScreen() on _MainScreenState
- ✅ uuid package added for ImportCandidate ID generation
- ✅ Total test count: 445 (all passing)

### v3.20.0 - US-066: Google Calendar Permission, Connection & Settings (March 08, 2026)
- ✅ GoogleCalendarService — incremental OAuth (calendar.readonly scope) via google_sign_in
- ✅ flutter_secure_storage for OAuth token persistence
- ✅ CalendarSettingsProvider — calendar selection, ALL-DAY toggle, revoke access
- ✅ CalendarPermissionScreen — full grant/deny flow with retry on denial
- ✅ SettingsScreen extended — Calendar section (always visible; connect/disconnect/checkboxes/toggle)
- ✅ Google Cloud Console configured — calendar.readonly scope registered
- ✅ Total test count: 440 → 447 tests (+7)

### v3.19.0 - US-065: Home Screen Onboarding CTA (March 08, 2026)
- ✅ HomeProvider — reactive meeting stream + SharedPreferences dismiss state
- ✅ OnboardingCalendarCtaCard — centered card with cta_stats.png illustration
- ✅ HomeScreen refactored — shows CTA (<50 meetings) or StatisticsSection (≥50 or dismissed)
- ✅ CalendarPermissionScreen stub added
- ✅ MainScreen Drawer — "Import from Calendar" entry point
- ✅ Total test count: 433 → 440 tests (+7)

### v3.18.0 - US-072 Optimize Statistics Firestore Reads (March 08, 2026)
- ✅ StatisticsProvider idempotency guard — initialize() skips fetch if data already loaded
- ✅ StatisticsRepository in-memory cache — keyed by userId_year, global caches for categories/persons
- ✅ CacheInvalidator interface — wired into Meeting/Person/ActivityCategory write operations
- ✅ StatsDataBundle — single Future.wait fetches all data for a year in parallel
- ✅ compute* pure synchronous methods — zero Firestore calls after initial load
- ✅ Reads reduced from ~5,200 to ~260 per session (~95% reduction)
- ✅ Total test count: 433 tests

### v3.17.0 - US-057 Filter Icon + Select All / Deselect All Toggle (March 06, 2026)
- ✅ Gear icon (⚙️) replaced with filter_icon.png asset in ActivityBreakdownWidget and InteractionDistributionWidget
- ✅ Filter icon size: 40×40
- ✅ setAllActivitiesVisibility(bool) and setAllPersonsVisibility(bool) added to StatisticsProvider
- ✅ Three-state toggle icon in ActivityVisibilityDialog and PersonVisibilityDialog (check_box / indeterminate_check_box / check_box_outline_blank)
- ✅ Activity icons in visibility dialog increased to 31px
- ✅ Total test count: 414 tests

### v3.16.0 - US-071 Statistics Home — Illustration & Enhanced Year Picker (March 06, 2026)
- ✅ statistics_illustration asset added to HomeScreen — bottom of screen, left-aligned
- ✅ YearStepper refactored — 5-slot layout: [←] [prev year dimmed] [active year] [next year dimmed] [→]
- ✅ Active year visually prominent (bold, primary color, fontSize 22)
- ✅ Neighbour year slots fixed width 48dp — layout stable when slot empty
- ✅ IconButton padding zeroed — active year stays visually centered
- ✅ Total test count: 406 tests

### v3.15.0 - US-063 Chart Visual Enhancement — Colors & Depth Effect (March 06, 2026)
- ✅ ChartColors class — 8-color Vivid Social palette independent from app theme
- ✅ Horizontal 4-stop cylinder/glass gradient (edge → center → center → edge)
- ✅ Stroke #1C1B1F 2px full opacity — clear bar separation
- ✅ ActivityBreakdownWidget, WhoPerActivityWidget, InteractionDistributionWidget refactored
- ✅ Removed local _categoryColors/_personColors maps — centralised in ChartColors
- ✅ 7 unit tests for ChartColors (stability, gradient shape, stroke color)
- ✅ Total test count: 403 tests

### v3.14.0 - US-055 Activities Polish — Icons, Tree View, Search (March 06, 2026)
- ✅ 51 custom Midjourney PNG icons replacing Material Icons in Activities
- ✅ ActivityIcon widget — renders PNG asset or Icons.category fallback
- ✅ Subcategory tree lines — T/L shape CustomPainter indentation (VS Code style)
- ✅ SharedSearchBar — reusable search widget across Activities, Friends, Meetings
- ✅ Activities search fix — EmptyStateWidget when no results (not empty parent list)
- ✅ EmptyStateWidget integrated in ActivitiesListScreen (empty list state)
- ✅ Icon picker rebuilt as 2D GridView (5 columns, scrollable)
- ✅ AlertDialog → Dialog fix (RenderIntrinsicWidth crash eliminated)
- ✅ ActivityIcon integrated in autocomplete chips and Meeting Detail screen
- ✅ empty_state_activities.png illustration added (Midjourney)
- ✅ Total test count: 371 → 396 tests (+25)

### v3.13.0 - US-054 Empty States — Meetings & Friends (March 05, 2026)
- ✅ EmptyStateWidget — reusable component (imagePath + message, no CTA)
- ✅ MeetingsListScreen: EmptyStateWidget for empty list + persistent search field above list
- ✅ MeetingsListProvider: filteredMeetingsByYear computed getter, setSearchQuery()
- ✅ PersonsListScreen: EmptyStateWidget for both empty list and no search results states
- ✅ empty_state_meetings.png and empty_state_friends.png — Midjourney flat 2D style
- ✅ pubspec.yaml: single-file asset replaced with full assets/images/ directory registration
- ✅ withValues(alpha: 0.6) used instead of deprecated withOpacity
- ✅ Total test count: 365 → 371 tests (+6)


### v3.12.0 - US-053 Login Screen Illustration & Typography Polish (March 2026)
- ✅ Login screen illustration added (Midjourney, flat 2D style)
- ✅ Pacifico font applied to app title across LoginScreen, AppBar, Drawer, SplashScreen
- ✅ People icon removed from LoginScreen
- ✅ Terms of Service and Privacy Policy links added to LoginScreen
- ✅ GitHub Pages live: terms and privacy policy hosted at aleksanderginalski.github.io/Friendsheet-App
- ✅ Settings AppBar title color fixed to white
- ✅ url_launcher added for external browser link handling
- ✅ Total test count: 366 → 365 tests (removed obsolete icon test)

### v3.11.0— Visual Design & Brand Identity 
-✅ US-056: Custom app icon — Midjourney-generated, flutter_launcher_icons, adaptive icon Android

### v3.10.1 - US-050 Flutter Theme Implementation — Design System (March 04, 2026)
- ✅ AppTheme class created in lib/core/theme/app_theme.dart
- ✅ ColorScheme.light() with full Friendsheet palette (#43A047 primary, #FAFAF7 surface, #FFB300 secondary)
- ✅ Nunito typography via google_fonts — ExtraBold/Bold/Regular/SemiBold across all text roles
- ✅ CardThemeData with 16dp border radius
- ✅ ElevatedButton theme with 12dp border radius
- ✅ AppBar, FAB, BottomNavigationBar styled consistently
- ✅ AppTheme.light applied in FriendsheetApp — replaces legacy primarySwatch: Colors.green
- ✅ Visual smoke test passed on Login, Home, Meetings, Friends screens
- ✅ Total test count: 363 tests

### v3.10.0 - US-049 Figma Design System Setup (March 04, 2026)
- ✅ Figma file created: Friendsheet — Design System
- ✅ 8 Color Styles defined (Primary/Default/Light/Dark, Secondary, Surface/Default/Subtle, Text/Primary, Status/Error)
- ✅ 6 Text Styles defined (Display 30/36, H1 24/29, H2 20/24, Body 16/24, Body Small 14/21, Caption 12/17)
- ✅ Nunito imported via Google Fonts plugin (Regular 400, SemiBold 600, Bold 700, ExtraBold 800)
- ✅ Base frame 390×844 with 8dp grid configured
- ✅ Design system serves as single source of truth for EPIC-009

### v3.9.0 - US-042 Release APK & Device Installation (March 04, 2026)
- ✅ Keystore generated and stored securely outside repository
- ✅ `android/key.properties` configured with absolute keystore path (gitignored)
- ✅ `android/app/build.gradle.kts` updated with release signing config (Kotlin DSL)
- ✅ `.gitignore` updated — added `*.jks`, `*.keystore`, `key.properties`, `android/key.properties`
- ✅ Release SHA-1 fingerprint added to Firebase Console (Google Sign-In works on device)
- ✅ `flutter build apk --release` — app-release.apk (51.3MB) generated successfully
- ✅ APK installed on personal Android device via sideload
- ✅ Smoke test passed: Sign-In, data load, add meeting all working on physical device
- ✅ Total test count: 363 tests

### v3.8.0 - US-031 JSON Export to Device (March 03, 2026)
- ✅ ExportService — fetches meetings, persons, activityCategories from Firestore
- ✅ JSON file written to device external storage (app-specific folder)
- ✅ Filename: `friendsheet_export_YYYY-MM-DD.json`
- ✅ ExportProvider — standard loading/error/path pattern
- ✅ SettingsScreen — new screen, reactive UI with SnackBar feedback
- ✅ Drawer extended with Settings tile (above logout)
- ✅ path_provider ^2.1.0 added
- ✅ Total test count: 363 tests (all passing)

### v3.7.0 - US-050 Bug Fix — Who Per Activity (March 03, 2026)
- ✅ Fixed getPersonsForActivity returning empty list when activity has >30 unique participants (Firestore whereIn limit)
- ✅ Replaced getPersonsByIds with getPersonsByUser + in-memory filtering in StatisticsRepository
- ✅ WhoPerActivityWidget: removed left legend, fixed column alignment, animated reordering with stable colors per personId
- ✅ Fixed "No data" flash on year change — whoPerActivity preserved during fetch
- ✅ Regression test: >30 participants scenario
- ✅ Total test count: 352 tests

### v3.8.0 - US-051 Statistics Carousel (March 02, 2026)
- ✅ StatisticsSection refactored from Column to horizontal PageView carousel
- ✅ YearStepper pinned above carousel — single global year selector for all cards
- ✅ Long-press on card hides it + SnackBar feedback; Restore all empty state
- ✅ _CarouselPage with AutomaticKeepAliveClientMixin — colors and animations survive swipe
- ✅ InteractionDistributionWidget always stays in widget tree (isLoading inline spinner)
- ✅ loadDistribution() isolated outside try/catch in initialize() and selectYear() — prevents silent failures
- ✅ Total test count: 351 tests


### v3.7.0 - US-030 Interaction Distribution Metric (March 02, 2026)
- ✅ InteractionDistributionEntry DTO with delta getter
- ✅ getInteractionDistribution — yearly weights per person (two-year comparison)
- ✅ getCumulativeInteractions — cumulative sum up to selected year
- ✅ StatisticsProvider extended: distribution state, yearly/cumulative toggle, hidden persons
- ✅ InteractionDistributionWidget — animated bar chart with _lastTargetLeft architecture
- ✅ PersonVisibilityDialog — flat checkbox list + auto-select top 10
- ✅ Info icon explaining >100% behaviour (yearly mode only)
- ✅ Total test count: 339 tests

### v3.6.0 - US-049 Activity Breakdown Smooth Bar Reordering Animation (March 02, 2026)
- ✅ _lastTargetLeft / _lastTargetBarHeight fields replace evaluate(controller) as tween begin
- ✅ Stationary bars guaranteed begin == end — no spurious animation
- ✅ _opacityTween added — fade-in on first bar render
- ✅ Eliminates timing-dependent bug from multiple didUpdateWidget calls
- ✅ Total test count: 290 tests

### v3.5.0 - US-048 Activity Breakdown UX Improvements (March 01, 2026)
- ✅ Animated vertical bar chart with Stack + absolute positioning
- ✅ Stable color assignment per categoryId across year changes
- ✅ Delta percentage indicator ▲/▼/NEW above each bar
- ✅ ActivityVisibilityDialog with hierarchical tree + icons
- ✅ Auto-select top 10 (excludes parents with children in breakdown)
- ✅ Hidden activities persistence (SharedPreferences)
- ✅ Smooth bar height animation on year change (1s easeInOut)
- ✅ Total test count: 290 tests### v3.5.0 - US-048 Activity Breakdown UX Improvements (March 01, 2026)
- ✅ Animated vertical bar chart with Stack + absolute positioning
- ✅ Stable color assignment per categoryId across year changes
- ✅ Delta percentage indicator ▲/▼/NEW above each bar
- ✅ ActivityVisibilityDialog with hierarchical tree + icons
- ✅ Auto-select top 10 (excludes parents with children in breakdown)
- ✅ Hidden activities persistence (SharedPreferences)
- ✅ Smooth bar height animation on year change (1s easeInOut)
- ✅ Total test count: 290 tests

### v3.4.0 - US-029 Who Per Activity Metric (February 27, 2026)
- ✅ PersonActivityEntry DTO and getPersonsForActivity with ancestor-aware filtering
- ✅ ActivitySelectorDialog with full category tree
- ✅ WhoPerActivityWidget with vertical bar chart, legend, long-press hide/show
- ✅ Hidden persons persistence (SharedPreferences: stats_hidden_persons_activity)
- ✅ Total test count: 283 tests

### v3.3.0 - US-028 Activity Breakdown Metric (February 27, 2026)
- ✅ ActivityBreakdownEntry DTO with delta getter
- ✅ getActivityWeightBreakdown — ancestor-aware weight aggregation per categoryId
- ✅ ActivityBreakdownWidget with ▲/▼/NEW delta indicators
- ✅ ActivityCategoryRepository injected into StatisticsProvider and StatisticsRepository
- ✅ Total test count: 271 tests

### v3.2.0 - US-027 Statistics Home Tab — Year Filter (February 27, 2026)
- ✅ StatisticsRepository with getAvailableYears and getMeetingsForYear
- ✅ StatisticsProvider owned by MainScreen (same lifecycle as ActivitiesListProvider)
- ✅ StatisticsSection widget on HomeScreen replacing placeholder
- ✅ YearStepper widget — ← YYYY → arrows + swipe gesture, disabled at boundaries
- ✅ Total test count: 262 tests

### v3.1.0 - US-041 Python Migration Script — Excel to Firestore (February 27, 2026)
- ✅ One-time Python migration script (`scripts/migration/migrate.py`)
- ✅ Imports 857 meetings, 92 persons from Excel to Firestore
- ✅ Pre-flight check — aborts if any activity name missing in `users/{uid}/activity_categories`
- ✅ Idempotent — meetings matched by date + name, persons deduplicated by full name
- ✅ Ancestor propagation — `categoryIds` includes leaf + all ancestor IDs (matches Flutter app behavior)
- ✅ Batch writes (max 500/batch), progress reported to console
- ✅ Weight mapping: 4 → 5 (only non-Fibonacci value in dataset)
- ✅ Secrets and personal data protected via `.gitignore`

### v2.10.1 - US-018 Manual Testing & Test Cases Document (February 27, 2026)
- ✅ TEST_CASES.md created (docs/TEST_CASES.md) — 32 manual test cases for M1 + M2
- ✅ US-044 confirmed completed (implemented in US-045, onboarding idempotency verified)
- ✅ EPIC-002 Friendsheet M2 — Management & CRUD: COMPLETED

### v2.10.0 - US-043 Fix — Unified activity flow (February 27, 2026)
- ✅ deleteWithChildren added to ActivityCategoryRepository (WriteBatch — atomic cascade delete)
- ✅ ActivitiesListProvider: deleteCategory replaced with deleteWithChildren
- ✅ Deleting a parent category removes all direct children atomically
- ✅ Orphaned records bug fixed — deleted categories no longer visible in AddMeeting autocomplete
- ✅ Total test count: 235 (all passing)


### v2.9.0 - US-045 Firestore Hierarchy Migration (February 26, 2026)
- ✅ MeetingRepository: all methods migrated to users/{uid}/meetings subcollection
- ✅ PersonRepository: all methods migrated to users/{uid}/persons subcollection
- ✅ ActivityCategoryRepository: getAllCategories reads only from users/{uid}/activity_categories
- ✅ AuthService: batch-copy path fixed to users/{uid}/activity_categories subcollection
- ✅ AuthWrapper: onboarding guard moved to session restore flow (idempotent across restarts)
- ✅ Security Rules: path-based rules for meetings, persons and users/{uid} document
- ✅ Fix: isSelectableAsActivity preserved on edit, always true on add from Activities tab
- ✅ firestore.indexes.json updated for subcollection paths
- ✅ Total test count: 232 (all passing)

### v2.8.0 - M2, US-042 Cleanup — Remove legacy Activity model (February 26, 2026)
- ✅ Activity model removed (activity.dart + generated files)
- ✅ ActivityRepository removed
- ✅ activityIds field removed from Meeting model
- ✅ AddMeetingProvider, ActivityAutocomplete, MeetingDetailProvider cleaned
- ✅ Fix: private user categories now visible in autocomplete (subcollection path corrected)
- ✅ Fix: add-new-activity flow restored from AddMeeting screen
- ✅ Total test count: 230 (all passing)

### v2.7.0 - M2, US-026 Activities List Screen (February 25, 2026)
- ✅ ActivitiesListScreen with expandable category tree (level-1 sections, level-2 leaf tiles)
- ✅ ActivitiesListProvider with search, expand/collapse, CRUD operations
- ✅ AddEditActivityDialog with icon picker (20 predefined Material icons)
- ✅ ActivityCategoryRepository.getAllCategories — merges global + private categories
- ✅ Long-press edit/delete for user-owned categories (global categories read-only)
- ✅ Fix: Firestore Security Rules — path-based userId for list queries on subcollections
- ✅ Fix: AddMeetingProvider validation includes selectedCategories
- ✅ Fix: ActivityCategory.fromFirestore — nullable createdAt fallback for global docs
- ✅ Fix: MeetingDetailScreen displays resolved category names
- ✅ Fix: AddMeetingProvider.initializeEditData restores category chips in edit mode
- ✅ Total test count: 260 (all passing)

### v2.6.0 - M2, US-020 Global Activity Library (February 24, 2026)
- ✅ ActivityCategory model extended: isSelectableAsActivity, copiedFromId
- ✅ Meeting model extended: categoryIds alongside activityIds
- ✅ Global activity library: 26 categories seeded (2-level hierarchy)
- ✅ Seed data versioned in repository (seed/global_categories.json + seed_firestore.js)
- ✅ AuthService: batch-copy global categories to user's private collection on first login
- ✅ Ancestor propagation: selecting "Góry" saves ["cat_gory", "cat_sport"] in categoryIds
- ✅ ActivityCategoryRepository: getSelectableCategories, getAncestorIds
- ✅ Unified autocomplete: selectable categories + private activities in one field
- ✅ MeetingDetailProvider: resolves categoryIds to full category objects
- ✅ Security Rules updated for first-login batch-write
- ✅ Total test count: 251 (all passing)

### v2.5.0 - US-019 Activity Categories (February 24, 2026)
- ✅ ActivityCategory model with Freezed (7 fields: id, userId, name, iconIdentifier, isGlobal, parentCategoryId, createdAt)
- ✅ ActivityCategoryRepository with full CRUD
- ✅ Hierarchy depth validation in repository (max 2 levels)
- ✅ Firestore path: users/{userId}/activity_categories (subcollection)
- ✅ Firestore Security Rules updated and deployed
- ✅ 27 new unit tests (model + repository)
- ✅ Total test count: 187 → 214 tests (+27)

### v2.4.0 - US-024 + US-025 Persons List & Person Detail (February 23, 2026)
- ✅ PersonsListScreen with alphabetical list, search/filter and empty state
- ✅ PersonListTile widget with initials avatar
- ✅ PersonDetailScreen with meeting count, edit via dialog, delete with confirmation
- ✅ Two-step delete warning when person has associated meetings
- ✅ PersonsListProvider with one-time fetch and client-side filtering
- ✅ PersonDetailProvider with meeting count query
- ✅ PersonRepository extended: updatePerson, deletePerson (with cascade)
- ✅ MeetingRepository extended: getMeetingsCountForPerson, removePersonFromMeetings
- ✅ Data integrity: deleting a person removes them from all associated meetings (WriteBatch)
- ✅ MeetingCard: warning state when participantIds is empty
- ✅ MeetingDetailScreen: loads successfully with empty participants, shows warning banner
- ✅ Add person directly from Friends tab via AppBar "+" button
- ✅ Tab renamed from "Persons" to "Friends"
- ✅ Total test count: 169 → 187 tests (+18)

### v2.3.0 - US-022 + US-023 Meeting Detail & Edit (February 23, 2026)
- ✅ MeetingDetailScreen with full meeting data (name, date, weight, participants, activities)
- ✅ MeetingDetailProvider with parallel fetch of persons and activities by ID
- ✅ getPersonsByIds and getActivitiesByIds added to repositories
- ✅ Edit meeting — AddMeetingScreen dual mode (create + edit), pre-filled form
- ✅ Delete meeting with confirmation dialog and loading state
- ✅ Updated meeting propagated back to MeetingsListScreen on navigation
- ✅ Total test count: 166 → 169 tests (+3)

### v2.2.0 - M2 Start, US-021 Meetings List Screen (February 21, 2026)
- ✅ MeetingsListScreen with meetings grouped by year (expand/collapse)
- ✅ Current and previous year expanded by default, older years collapsed
- ✅ MeetingCard widget with date, participant count and weight display
- ✅ Empty state when no meetings exist
- ✅ MainScreen with BottomNavigationBar (4 tabs: Home, Meetings, Persons, Activities)
- ✅ FAB for adding meetings accessible from any tab
- ✅ HomeScreen reserved for future statistics/dashboard (M7)
- ✅ MeetingsListProvider with real-time Firestore stream
- ✅ firestore.indexes.json and firestore.rules added to repository
- ✅ Total test count: 151 → 166 tests (+15)

### v2.1.0 - US-INF-001 Claude Code Integration (February 21, 2026)
- ✅ CLAUDE.md created for Claude Code CLI integration
- ✅ Project Invariants, Code Standards and Git workflow documented for Claude Code
- ✅ Hybrid workflow established: claude.ai for strategy, Claude Code for implementation

### v2.1.0 - Sprint 3, US-016 + US-017 (February 20, 2026)
- ✅ Repository tests: MeetingRepository (7), PersonRepository (8), ActivityRepository (12)
- ✅ Widget tests: LoginScreen (8), HomeScreen (9)
- ✅ Added fake_cloud_firestore for repository testing
- ✅ Total test count: 97 → 151 tests (+54)
- ✅ Patterns introduced: fake_cloud_firestore, Completer for async state testing

### v2.0.0 - Roadmap Planning (February 20, 2026)
- ✅ Full milestone roadmap defined (M1-M8)
- ✅ BACKLOG updated with Epics, Features and User Stories for all milestones
- ✅ Architecture decisions documented (Social: copy-based sharing, Activity icons, Google Photos OAuth)

### v1.12.0 - Sprint 2, US-015 (February 19, 2026)
- ✅ MeetingRepository with saveMeeting method
- ✅ AuthService extended with currentUserId getter
- ✅ AddMeetingProvider: saveMeeting(), isSaving state, full form validation
- ✅ Save button wired in AddMeetingScreen with loading indicator
- ✅ Success: green snackbar + navigation back to HomeScreen
- ✅ Error: red snackbar with message
- ✅ 8 new provider tests, 38 total in AddMeetingProvider test file

### v1.11.0 - Sprint 2, US-014 (February 19, 2026)
- ✅ Firestore Security Rules updated to allow global activity reads
- ✅ ActivityRepository with global and private activity support
- ✅ AddMeetingProvider extended with activities state and validation
- ✅ ActivityAutocomplete widget with AddActivityDialog
- ✅ AddMeetingScreen - activities placeholder replaced with working widget
- ✅ searchActivities logic moved from repository to provider
- ✅ 10 new provider tests, 30 total in AddMeetingProvider test file

### v1.10.0 - Sprint 2, US-013 (February 19, 2026)
- ✅ PersonRepository with getPersonsByUser and addPerson methods
- ✅ AddMeetingProvider extended with participant state management
- ✅ PersonAutocomplete widget with search suggestions and chip display
- ✅ AddPersonDialog with automatic first/last name split
- ✅ AddMeetingScreen migrated to StatefulWidget for loadPersons on init
- ✅ Fix: full name input split into firstName/lastName on dialog open
- ✅ MockPersonRepository injected in tests to avoid Firebase dependency
- ✅ 20 provider tests (100% passing), 97 total tests

### v1.9.0 - Sprint 2, US-012 (February 19, 2026)
- ✅ MeetingWeightStepper widget with +/− buttons
- ✅ Fibonacci values only (1,2,3,5,8,13,21) via index-based navigation
- ✅ Buttons disabled at min (1) and max (21) boundaries
- ✅ AddMeetingProvider refactored from raw int to index-based weight
- ✅ 15 new tests (5 widget + 10 provider), 77 total tests

### v1.8.0 - Sprint 2, US-011 (February 19, 2026)
- ✅ MeetingNameField widget with character counter (X/50)
- ✅ Focus-loss validation for meeting name field
- ✅ MeetingDateField widget with DatePicker (dd/MM/yyyy format)
- ✅ Default date set to today
- ✅ AddMeetingProvider extended with name validation logic
- ✅ AddMeetingScreen placeholders replaced with real widgets
- ✅ 11 widget tests (100% passing), 62 total tests

### v1.7.0 - Sprint 2, US-010 (February 19, 2026)
- ✅ AddMeetingScreen UI with ScrollView layout
- ✅ All form sections as placeholders (Name, Date, Weight, Participants, Activities)
- ✅ AddMeetingProvider with ChangeNotifier scaffold
- ✅ Navigation from HomeScreen to AddMeetingScreen
- ✅ Save button disabled with user info until US-015
- ✅ 5 widget tests (100% passing)

### v1.6.0 - Sprint 2, US-009 (February 19, 2026)
- ✅ Activity Model implemented with Freezed
- ✅ Global/private activity pattern (isGlobal + userId: null)
- ✅ categoryId field as String? (foundation for US-019 categories)
- ✅ Firestore and JSON serialization
- ✅ 13 unit tests (100% coverage)

### v1.5.0 - Sprint 2, US-008 (February 18, 2026)
- ✅ Person Model implemented with Freezed
- ✅ fullName getter with optional lastName support
- ✅ Firestore and JSON serialization
- ✅ 11 unit tests (100% coverage)

### v1.4.0 - Sprint 2, US-007 (February 18, 2026)
- ✅ Meeting Model implemented with Freezed
- ✅ Freezed + json_serializable integration
- ✅ 12 unit tests for Meeting model (100% coverage)

### v1.3.0 - Sprint 1, US-006 (February 17, 2026)
- ✅ User logout implemented (Google + Firebase sign out)
- ✅ Dependency Injection introduced for AuthService

### v1.2.1 - Sprint 1, US-004 (February 16, 2026)
- ✅ Google Sign-In authentication implemented
- ✅ AuthService with Singleton pattern

### v1.2.0 - Sprint 1, US-003 (February 14, 2026)
- ✅ Git repository configured
- ✅ GitHub Actions CI/CD pipeline

### v1.1.0 - Sprint 1, US-002 (February 14, 2026)
- ✅ Firebase project created and configured

### v1.0.0 - Sprint 1, US-001 (February 12, 2026)
- ✅ Initial Flutter project setup
- ✅ Clean Architecture structure implemented

## 🔐 Security Notes

**Important:** The following files contain sensitive information and are gitignored:
- `android/app/google-services.json` - Firebase configuration
- `lib/firebase_options.dart` - Firebase API keys (your real credentials)

**Never commit your real firebase_options.dart!** Each developer must create their own Firebase project and configuration files.
