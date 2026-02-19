# Friendsheet - Project File Structure
**Last Updated:** lutego 19, 2026

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
- lib/data/repositories/person_repository.dart - PersonRepository (Firestore CRUD for persons)
- lib/data/services/auth_service.dart - Google Sign-In + Firebase Auth (Singleton)

## lib/
- lib/firebase_options.dart - Firebase config (gitignored)
- lib/firebase_options.example.dart - Mock config for CI/CD
- lib/main.dart - App entry point, Firebase initialization, AuthWrapper

## lib/presentation/
- lib/presentation/providers/add_meeting_provider.dart - State for Add Meeting screen (name, date, weight, participants)
- lib/presentation/screens/add_meeting_screen.dart - Add Meeting screen
- lib/presentation/screens/home_screen.dart - Home screen with logout
- lib/presentation/screens/login_screen.dart - Google Sign-In screen
- lib/presentation/widgets/meeting_date_field.dart - Date picker widget (US-011)
- lib/presentation/widgets/meeting_name_field.dart - Name input widget (US-011)
- lib/presentation/widgets/meeting_weight_stepper.dart - Fibonacci weight stepper widget (US-012)
- lib/presentation/widgets/person_autocomplete.dart - Participant autocomplete widget + AddPersonDialog (US-013)

## test/data/
- test/data/models/activity_test.dart - Activity model tests (13 tests)
- test/data/models/meeting_test.dart - Meeting model tests (12 tests)
- test/data/models/person_test.dart - Person model tests (11 tests)

## test/presentation/
- test/presentation/providers/add_meeting_provider_test.dart - AddMeetingProvider tests (20 tests)
- test/presentation/providers/add_meeting_provider_test.mocks.dart - Generated mocks for PersonRepository (Mockito)
- test/presentation/screens/add_meeting_screen_test.dart - AddMeetingScreen tests (5 tests)
- test/presentation/widgets/meeting_date_field_test.dart - MeetingDateField tests (4 tests)
- test/presentation/widgets/meeting_name_field_test.dart - MeetingNameField tests (5 tests)
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
