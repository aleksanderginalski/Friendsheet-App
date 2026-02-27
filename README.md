### 🗺️ Roadmap

| Milestone | Name | Status |
|-----------|------|--------|
| M1 | Add Meeting | ✅ Completed |
| M2 | Management & CRUD | ✅ Completed |
| M3 | Statistics & Export | 🔜 Next |
| M4 | Google Play Release | 📋 Planned |
| M5 | Social: Data Sharing | 📋 Planned |
| M6 | Google Photos Integration | 📋 Planned |
| M7 | Custom Dashboard | 📋 Planned |
| M8 | AI Assistant | 💡 Future |

**M2 — Management & CRUD:** Full CRUD for meetings, persons and activities. Meetings list grouped by year (collapsed for older years). Activity categories with icons and 2-level hierarchy.

**M3 — Statistics & Export:** Person frequency stats, activity stats with category hierarchy filtering, "haven't seen in a while" alerts, JSON data export.

**M4 — Google Play Release:** Production build, store assets, Privacy Policy, public release. Portfolio milestone.

**M5 — Social: Data Sharing:** Invitation code system — Person A generates a code, Person B redeems it and receives copies of all shared meetings. Copy-based (no real-time sync).

**M6 — Google Photos Integration:** Browse device photos, select one to pre-fill meeting date. Teaches external OAuth API integration.

**M7 — Custom Dashboard:** Configurable home screen with drag-and-drop metric widgets.

**M8 — AI Assistant:** Natural language queries about social data. LLM API selection requires cost/privacy spike first.

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:
```
lib/
├── core/           # Core utilities, constants, errors
├── data/           # Data layer (models, repositories, datasources)
├── domain/         # Business logic layer (entities, use cases)
├── presentation/   # UI layer (screens, widgets, providers)
├── main.dart       # Application entry point
└── firebase_options.dart  # Firebase configuration
```

**Tech Stack:**
- **Frontend:** Flutter 3.0+ (Dart)
- **Backend:** Firebase (Auth + Firestore)
- **Architecture:** Clean Architecture / MVVM
- **State Management:** Provider

## 📚 Documentation

Comprehensive documentation is available in the project root:

- [Requirements Documentation](requirements.md) - Functional and non-functional requirements
- [Architecture Documentation](architecture.md) - System design and diagrams
- [UI/UX Documentation](wireframes.md) - Screen designs and user flows
- [Code Examples](code_snippets.md) - Implementation snippets
- [Project Structure](PROJECT_FILES.md) - Folder organization
- [Product Backlog](BACKLOG.md) - Sprint planning and user stories

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
cd friendsheet

```
2. **Claude Code users:**
A `CLAUDE.md` file is included in the repository with project conventions and workflow instructions. Claude Code reads this automatically on every session start.
```

3. **Install dependencies**
```powershell
flutter pub get
```

4. **Firebase Setup**

You need to set up your own Firebase project:

a. Create a Firebase project at https://console.firebase.google.com
b. Add an Android app with package name: `com.friendsheet.app`
c. Download `google-services.json` 
d. Place it in: `android/app/google-services.json`
e. Create `lib/firebase_options.dart` with your Firebase configuration

**Note:** `google-services.json` and `firebase_options.dart` are gitignored for security. You must create your own Firebase project.

5. **Create firebase_options.dart**

You need to create your own Firebase configuration:

a. If using FlutterFire CLI (recommended):
```bash
flutterfire configure
```

b. Or copy the example template and fill in your credentials:
```bash
cp lib/firebase_options.example.dart lib/firebase_options.dart
# Edit lib/firebase_options.dart with your Firebase project details
```

6. **Run the app**
```powershell
flutter run
```

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
✅ All tests passing (235)
✅ Code formatted correctly
✅ Firebase connected successfully
✅ CI/CD pipeline operational
```

## 📱 Supported Platforms

- ✅ **Android** - API 21+ (Android 5.0) - Current focus
- 📋 **Google Play** - Planned for M4

## 🗂️ Project Structure
```
friendsheet/
├── lib/
│   ├── core/
│   │   ├── constants/      # App-wide constants
│   │   ├── errors/         # Error handling
│   │   └── utils/          # Utility functions
│   ├── data/
│   │   ├── models/         # Data models (Freezed)
│   │   ├── repositories/   # Repository implementations
│   │   └── datasources/    # Firebase datasources
│   ├── domain/
│   │   ├── entities/       # Business entities
│   │   ├── repositories/   # Repository interfaces
│   │   └── usecases/       # Business use cases
│   ├── presentation/
│   │   ├── screens/        # UI screens
│   │   ├── widgets/        # Reusable widgets
│   │   └── providers/      # State management
│   ├── main.dart           # App entry point
│   └── firebase_options.dart  # Firebase configuration
├── android/
│   └── app/
│       ├── google-services.json  # Firebase config (gitignored)
│       └── build.gradle
├── test/                   # Unit and widget tests
├── pubspec.yaml            # Dependencies
├── analysis_options.yaml   # Linting rules
└── README.md              # This file
```

## 🎨 Code Style

This project follows Flutter's official style guide and uses `flutter_lints` for code quality.

**Key conventions:**
- Use `const` constructors where possible
- Prefer single quotes for strings
- Use trailing commas for better formatting
- Keep files focused and under 300 lines
- Document public APIs with /// comments

## 🤝 Contributing

This is currently a learning project. Contributions, issues, and feature requests are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design for UI components
- Clean Architecture pattern by Uncle Bob

## 📧 Contact

Project Link: [https://github.com/aleksanderginalski/friendsheet-app](https://github.com/aleksanderginalski/friendsheet-app)

---

**Made with ❤️ and Flutter**

**Note:** This is a learning project to understand SDLC (Software Development Life Cycle) and mobile app development with Flutter.

## 📖 Version History

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
