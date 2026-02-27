# Friendsheet - Project File Structure
**Last Updated:** lutego 27, 2026

## Root
- CLAUDE.md - Claude Code instructions — project invariants, conventions, git workflow

## lib/core/
- lib/core/utils/firebase_test.dart - Firebase connection test

## lib/data/
- lib/data/models/activity_category.dart - ActivityCategory model (Freezed) — nullable createdAt fallback, isSelectableAsActivity, copiedFromId, parentCategoryId, iconIdentifier (US-019, US-020, US-026)
- lib/data/models/activity_category.freezed.dart - Generated
- lib/data/models/activity_category.g.dart - Generated
- lib/data/models/meeting.dart - Meeting model (Freezed) — categoryIds only (US-042)
- lib/data/models/meeting.freezed.dart - Generated
- lib/data/models/meeting.g.dart - Generated
- lib/data/models/person.dart - Person model (Freezed)
- lib/data/models/person.freezed.dart - Generated
- lib/data/models/person.g.dart - Generated
- lib/data/repositories/activity_category_repository.dart - ActivityCategoryRepository — CRUD, deleteWithChildren (WriteBatch cascade), getSelectableCategories, getAncestorIds, getAllCategories, createSelectableCategory, depth validation (US-019, US-020, US-026, US-042, US-043)
- lib/data/repositories/meeting_repository.dart - MeetingRepository (Firestore CRUD — save, update, delete, stream, getMeetingsCountForPerson, removePersonFromMeetings)
- lib/data/repositories/person_repository.dart - PersonRepository (Firestore CRUD — getPersonsByUser, addPerson, updatePerson, deletePerson with cascade, getPersonsByIds)
- lib/data/services/auth_service.dart - Google Sign-In + Firebase Auth (Singleton) — batch-copy global categories on first login (US-020)

## lib/
- lib/firebase_options.dart - Firebase config (gitignored)
- lib/firebase_options.example.dart - Mock config for CI/CD
- lib/main.dart - App entry point, Firebase initialization, AuthWrapper, MainScreen as root

## lib/presentation/
- lib/presentation/activities/activities_list_provider.dart - State for Activities List screen — fetch all categories (global + private), tree expansion, search, CRUD with cascade delete (US-026, US-043)
- lib/presentation/activities/activities_list_screen.dart - Activities list screen — expandable category tree, long-press edit/delete for private categories (US-026)
- lib/presentation/activities/activity_icons.dart - Predefined icon set and resolveActivityIcon helper — maps string identifiers to Material IconData (US-026)
- lib/presentation/activities/add_edit_activity_dialog.dart - Add/Edit activity category dialog — name, parent selector, icon picker (US-026)
- lib/presentation/meetings/meeting_detail_provider.dart - State for Meeting Detail screen — resolves participantIds and categoryIds to full objects (US-020, US-026, US-042)
- lib/presentation/meetings/meeting_detail_screen.dart - Meeting detail screen — displays all fields including resolved categories, edit and delete actions (US-022, US-023, US-026)
- lib/presentation/persons/person_detail_provider.dart - State for Person Detail screen — fetches meeting count, handles update and delete (US-025)
- lib/presentation/persons/person_detail_screen.dart - Person detail screen — shows name, meeting count, edit via dialog, delete with confirmation (US-025)
- lib/presentation/persons/person_list_tile.dart - Person list tile widget — shows full name with initials avatar (US-024)
- lib/presentation/persons/persons_list_provider.dart - State for Persons List screen — one-time fetch, client-side alphabetical filter (US-024)
- lib/presentation/providers/add_meeting_provider.dart - State for Add/Edit Meeting screen — dual mode, categories + ancestor propagation, addNewActivity creates root category in user subcollection (US-020, US-026, US-042)
- lib/presentation/providers/meetings_list_provider.dart - State for Meetings List screen (stream, year grouping, expand/collapse)
- lib/presentation/screens/add_meeting_screen.dart - Add/Edit Meeting screen — dual mode based on initialMeeting parameter (US-023)
- lib/presentation/screens/home_screen.dart - Home screen (future dashboard/statistics placeholder)
- lib/presentation/screens/login_screen.dart - Google Sign-In screen
- lib/presentation/screens/main_screen.dart - Root screen after login — BottomNavigationBar with 4 tabs + FAB, owns PersonsListProvider and ActivitiesListProvider lifecycle (US-026)
- lib/presentation/screens/meetings_list_screen.dart - Meetings list grouped by year with expand/collapse sections (US-021)
- lib/presentation/screens/persons_list_screen.dart - Persons list with search/filter and navigation to PersonDetailScreen — reads PersonsListProvider from MainScreen (US-024)
- lib/presentation/widgets/activity_autocomplete.dart - Unified activity autocomplete — selectable categories from user subcollection, ancestor propagation, add-new-activity flow (US-020, US-042)
- lib/presentation/widgets/meeting_card.dart - Meeting card widget — displays name, date, participant count, weight (US-021)
- lib/presentation/widgets/meeting_date_field.dart - Date picker widget (US-011)
- lib/presentation/widgets/meeting_name_field.dart - Name input widget — pre-fills from provider in edit mode (US-023)
- lib/presentation/widgets/meeting_weight_stepper.dart - Fibonacci weight stepper widget (US-012)
- lib/presentation/widgets/person_autocomplete.dart - Participant autocomplete widget + AddPersonDialog — returns strings, save handled by Provider (BUG-42)

## test/data/
- test/data/models/activity_category_test.dart - ActivityCategory model tests — isSelectableAsActivity, copiedFromId, equality, serialization (US-019, US-020)
- test/data/models/meeting_test.dart - Meeting model tests — categoryIds only, activityIds removed (US-042)
- test/data/models/person_test.dart - Person model tests (11 tests)
- test/data/repositories/activity_category_repository_test.dart - ActivityCategoryRepository tests — CRUD, deleteWithChildren, getSelectableCategories, getAncestorIds, createSelectableCategory (US-019, US-020, US-042, US-043)
- test/data/repositories/meeting_repository_test.dart - MeetingRepository tests (9 tests)
- test/data/repositories/person_repository_test.dart - PersonRepository tests (10 tests)
- test/data/services/auth_service_test.dart - AuthService tests — batch-copy guard, first login flow (US-020)

## test/presentation/
- test/presentation/activities/activities_list_provider_test.dart - ActivitiesListProvider tests — initialize, tree filtering, expand/collapse, CRUD, deleteWithChildren verification (US-026, US-043)
- test/presentation/activities/activities_list_provider_test.mocks.dart - Generated mocks for ActivitiesListProvider tests
- test/presentation/meetings/meeting_detail_provider_test.dart - MeetingDetailProvider tests — categoryIds resolution, activityIds removed (US-020, US-042)
- test/presentation/meetings/meeting_detail_provider_test.mocks.dart - Generated mocks for MeetingDetailProvider tests
- test/presentation/persons/person_detail_provider_test.dart - PersonDetailProvider tests (US-025)
- test/presentation/persons/person_detail_provider_test.mocks.dart - Generated mocks for PersonDetailProvider tests
- test/presentation/persons/persons_list_provider_test.dart - PersonsListProvider tests (US-024)
- test/presentation/persons/persons_list_provider_test.mocks.dart - Generated mocks for PersonsListProvider tests
- test/presentation/providers/add_meeting_provider_test.dart - AddMeetingProvider tests — categories, ancestor propagation, addNewActivity (US-020, US-042)
- test/presentation/providers/add_meeting_provider_test.mocks.dart - Generated mocks for AddMeetingProvider tests
- test/presentation/providers/meetings_list_provider_test.dart - MeetingsListProvider tests (11 tests)
- test/presentation/providers/meetings_list_provider_test.mocks.dart - Generated mocks for MeetingsListProvider tests
- test/presentation/screens/add_meeting_screen_test.dart - AddMeetingScreen tests (5 tests)
- test/presentation/screens/add_meeting_screen_test.mocks.dart - Generated mocks for AddMeetingScreen tests
- test/presentation/screens/home_screen_test.dart - HomeScreen tests
- test/presentation/screens/home_screen_test.mocks.dart - Generated mocks for HomeScreen tests
- test/presentation/screens/login_screen_test.dart - LoginScreen tests (8 tests)
- test/presentation/screens/login_screen_test.mocks.dart - Generated mocks for LoginScreen tests
- test/presentation/screens/main_screen_test.dart - MainScreen tests (5 tests)
- test/presentation/screens/main_screen_test.mocks.dart - Generated mocks for MainScreen tests
- test/presentation/screens/meetings_list_screen_test.dart - MeetingsListScreen tests (5 tests)
- test/presentation/widgets/meeting_date_field_test.dart - MeetingDateField tests (4 tests)
- test/presentation/widgets/meeting_date_field_test.mocks.dart - Generated mocks for MeetingDateField tests
- test/presentation/widgets/meeting_name_field_test.dart - MeetingNameField tests (5 tests)
- test/presentation/widgets/meeting_name_field_test.mocks.dart - Generated mocks for MeetingNameField tests
- test/presentation/widgets/meeting_weight_stepper_test.dart - MeetingWeightStepper tests (5 tests)

## test/
- test/widget_test.dart - AuthWrapper tests
- test/widget_test.mocks.dart - Generated mocks (Mockito)

## scripts/migration/
- scripts/migration/migrate.py - One-time Python migration script — Excel to Firestore (US-041). Imports meetings, persons, categoryIds with ancestor propagation. Idempotent.
- scripts/migration/requirements.txt - Python dependencies: openpyxl, firebase-admin
- scripts/migration/README.md - Setup and usage instructions for migration script
- scripts/migration/serviceAccountKey.json - Firebase service account key (gitignored — never commit)
- scripts/migration/Migracja.xlsx - Source data file (gitignored — personal data)

---

## Naming Conventions
- Files: snake_case
- Classes: UpperCamelCase
- Variables/methods: lowerCamelCase
- Tests mirror lib/ structure exactly

## Rules
- Generated files (*.freezed.dart, *.g.dart) ARE committed
- firebase_options.dart is gitignored
- .gitkeep files mark empty directories
- CLAUDE.md is committed — shared instructions for Claude Code CLI
- scripts/migration/serviceAccountKey.json and *.xlsx are gitignored — never commit secrets or personal data
