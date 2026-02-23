# Friendsheet - Project File Structure
**Last Updated:** lutego 23, 2026

## Root
- CLAUDE.md - Claude Code instructions — project invariants, conventions, git workflow

## lib/core/
- lib/core/utils/firebase_test.dart - Firebase connection test

## lib/data/
- lib/data/models/activity.dart - Activity model (Freezed)
- lib/data/models/activity.freezed.dart - Generated
- lib/data/models/activity.g.dart - Generated
- lib/data/models/meeting.dart - Meeting model (Freezed)
- lib/data/models/meeting.freezed.dart - Generated
- lib/data/models/meeting.g.dart - Generated
- lib/data/models/person.dart - Person model (Freezed)
- lib/data/models/person.freezed.dart - Generated
- lib/data/models/person.g.dart - Generated
- lib/data/repositories/activity_repository.dart - ActivityRepository (Firestore CRUD for activities, global + private, getActivitiesByIds)
- lib/data/repositories/meeting_repository.dart - MeetingRepository (Firestore CRUD for meetings — save, update, delete, stream by user)
- lib/data/repositories/person_repository.dart - PersonRepository (Firestore CRUD for persons, getPersonsByIds)
- lib/data/services/auth_service.dart - Google Sign-In + Firebase Auth (Singleton)

## lib/
- lib/firebase_options.dart - Firebase config (gitignored)
- lib/firebase_options.example.dart - Mock config for CI/CD
- lib/main.dart - App entry point, Firebase initialization, AuthWrapper, MainScreen as root

## lib/presentation/
- lib/presentation/meetings/meeting_detail_provider.dart - State for Meeting Detail screen — resolves participantIds and activityIds to full objects
- lib/presentation/meetings/meeting_detail_screen.dart - Meeting detail screen — displays all fields, edit and delete actions (US-022, US-023)
- lib/presentation/providers/add_meeting_provider.dart - State for Add/Edit Meeting screen — dual mode (create + edit), pre-fill, save, update
- lib/presentation/providers/meetings_list_provider.dart - State for Meetings List screen (stream, year grouping, expand/collapse)
- lib/presentation/screens/add_meeting_screen.dart - Add/Edit Meeting screen — dual mode based on initialMeeting parameter (US-023)
- lib/presentation/screens/home_screen.dart - Home screen (future dashboard/statistics placeholder)
- lib/presentation/screens/login_screen.dart - Google Sign-In screen
- lib/presentation/screens/main_screen.dart - Root screen after login — BottomNavigationBar with 4 tabs + FAB
- lib/presentation/screens/meetings_list_screen.dart - Meetings list grouped by year with expand/collapse sections (US-021)
- lib/presentation/widgets/activity_autocomplete.dart - Activity autocomplete widget + AddActivityDialog — returns name string, save handled by Provider (BUG-42)
- lib/presentation/widgets/meeting_card.dart - Meeting card widget — displays name, date, participant count, weight (US-021)
- lib/presentation/widgets/meeting_date_field.dart - Date picker widget (US-011)
- lib/presentation/widgets/meeting_name_field.dart - Name input widget — pre-fills from provider in edit mode (US-023)
- lib/presentation/widgets/meeting_weight_stepper.dart - Fibonacci weight stepper widget (US-012)
- lib/presentation/widgets/person_autocomplete.dart - Participant autocomplete widget + AddPersonDialog — returns strings, save handled by Provider (BUG-42)

## test/data/
- test/data/models/activity_test.dart - Activity model tests (13 tests)
- test/data/models/meeting_test.dart - Meeting model tests (12 tests)
- test/data/models/person_test.dart - Person model tests (11 tests)
- test/data/repositories/activity_repository_test.dart - ActivityRepository tests (12 tests)
- test/data/repositories/meeting_repository_test.dart - MeetingRepository tests (7 tests)
- test/data/repositories/person_repository_test.dart - PersonRepository tests (8 tests)

## test/presentation/
- test/presentation/meetings/meeting_detail_provider_test.dart - MeetingDetailProvider tests (3 tests)
- test/presentation/meetings/meeting_detail_provider_test.mocks.dart - Generated mocks for MeetingDetailProvider tests
- test/presentation/providers/add_meeting_provider_test.dart - AddMeetingProvider tests (38 tests)
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
