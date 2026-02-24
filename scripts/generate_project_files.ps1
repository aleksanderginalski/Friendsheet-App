$descriptions = @{
    "CLAUDE.md"                                                          = "Claude Code instructions — project invariants, conventions, git workflow"
    "lib/main.dart"                                                      = "App entry point, Firebase initialization, AuthWrapper, MainScreen as root"
    "lib/firebase_options.dart"                                          = "Firebase config (gitignored)"
    "lib/firebase_options.example.dart"                                  = "Mock config for CI/CD"
    "lib/core/utils/firebase_test.dart"                                  = "Firebase connection test"
    "lib/data/models/activity.dart"                                      = "Activity model (Freezed)"
    "lib/data/models/activity.freezed.dart"                              = "Generated"
    "lib/data/models/activity.g.dart"                                    = "Generated"
    "lib/data/models/activity_category.dart"                             = "ActivityCategory model (Freezed) — isSelectableAsActivity, copiedFromId, parentCategoryId, iconIdentifier (US-020)"
    "lib/data/models/activity_category.freezed.dart"                     = "Generated"
    "lib/data/models/activity_category.g.dart"                           = "Generated"
    "lib/data/models/meeting.dart"                                       = "Meeting model (Freezed) — categoryIds + activityIds dual list (US-020)"
    "lib/data/models/meeting.freezed.dart"                               = "Generated"
    "lib/data/models/meeting.g.dart"                                     = "Generated"
    "lib/data/models/person.dart"                                        = "Person model (Freezed)"
    "lib/data/models/person.freezed.dart"                                = "Generated"
    "lib/data/models/person.g.dart"                                      = "Generated"
    "lib/data/repositories/activity_category_repository.dart"            = "ActivityCategoryRepository — CRUD, getSelectableCategories, getAncestorIds, depth validation (US-019, US-020)"
    "lib/data/repositories/activity_repository.dart"                     = "ActivityRepository — private user activities only, global + private fetch, getActivitiesByIds"
    "lib/data/repositories/meeting_repository.dart"                      = "MeetingRepository (Firestore CRUD — save, update, delete, stream, getMeetingsCountForPerson, removePersonFromMeetings)"
    "lib/data/repositories/person_repository.dart"                       = "PersonRepository (Firestore CRUD — getPersonsByUser, addPerson, updatePerson, deletePerson with cascade, getPersonsByIds)"
    "lib/data/services/auth_service.dart"                                = "Google Sign-In + Firebase Auth (Singleton) — batch-copy global categories on first login (US-020)"
    "lib/presentation/meetings/meeting_detail_provider.dart"             = "State for Meeting Detail screen — resolves participantIds, activityIds and categoryIds to full objects (US-020)"
    "lib/presentation/meetings/meeting_detail_screen.dart"               = "Meeting detail screen — displays all fields, edit and delete actions (US-022, US-023)"
    "lib/presentation/persons/person_detail_provider.dart"               = "State for Person Detail screen — fetches meeting count, handles update and delete (US-025)"
    "lib/presentation/persons/person_detail_screen.dart"                 = "Person detail screen — shows name, meeting count, edit via dialog, delete with confirmation (US-025)"
    "lib/presentation/persons/person_list_tile.dart"                     = "Person list tile widget — shows full name with initials avatar (US-024)"
    "lib/presentation/persons/persons_list_provider.dart"                = "State for Persons List screen — one-time fetch, client-side alphabetical filter (US-024)"
    "lib/presentation/providers/add_meeting_provider.dart"               = "State for Add/Edit Meeting screen — dual mode, categories + ancestor propagation + private activities (US-020)"
    "lib/presentation/providers/meetings_list_provider.dart"             = "State for Meetings List screen (stream, year grouping, expand/collapse)"
    "lib/presentation/screens/add_meeting_screen.dart"                   = "Add/Edit Meeting screen — dual mode based on initialMeeting parameter (US-023)"
    "lib/presentation/screens/home_screen.dart"                          = "Home screen (future dashboard/statistics placeholder)"
    "lib/presentation/screens/login_screen.dart"                         = "Google Sign-In screen"
    "lib/presentation/screens/main_screen.dart"                          = "Root screen after login — BottomNavigationBar with 4 tabs + FAB, owns PersonsListProvider lifecycle"
    "lib/presentation/screens/meetings_list_screen.dart"                 = "Meetings list grouped by year with expand/collapse sections (US-021)"
    "lib/presentation/screens/persons_list_screen.dart"                  = "Persons list with search/filter and navigation to PersonDetailScreen — reads PersonsListProvider from MainScreen (US-024)"
    "lib/presentation/widgets/activity_autocomplete.dart"                = "Unified activity autocomplete — selectable categories + private activities, ancestor propagation on select (US-020)"
    "lib/presentation/widgets/meeting_card.dart"                         = "Meeting card widget — displays name, date, participant count, weight (US-021)"
    "lib/presentation/widgets/meeting_date_field.dart"                   = "Date picker widget (US-011)"
    "lib/presentation/widgets/meeting_name_field.dart"                   = "Name input widget — pre-fills from provider in edit mode (US-023)"
    "lib/presentation/widgets/meeting_weight_stepper.dart"               = "Fibonacci weight stepper widget (US-012)"
    "lib/presentation/widgets/person_autocomplete.dart"                  = "Participant autocomplete widget + AddPersonDialog — returns strings, save handled by Provider (BUG-42)"
    "test/widget_test.dart"                                              = "AuthWrapper tests"
    "test/widget_test.mocks.dart"                                        = "Generated mocks (Mockito)"
    "test/data/models/activity_category_test.dart"                       = "ActivityCategory model tests — isSelectableAsActivity, copiedFromId, equality, serialization (US-019, US-020)"
    "test/data/models/activity_test.dart"                                = "Activity model tests (13 tests)"
    "test/data/models/meeting_test.dart"                                 = "Meeting model tests — categoryIds field included (US-020)"
    "test/data/models/person_test.dart"                                  = "Person model tests (11 tests)"
    "test/data/repositories/activity_category_repository_test.dart"      = "ActivityCategoryRepository tests — CRUD, getSelectableCategories, getAncestorIds (US-019, US-020)"
    "test/data/repositories/activity_repository_test.dart"               = "ActivityRepository tests (12 tests)"
    "test/data/repositories/meeting_repository_test.dart"                = "MeetingRepository tests (9 tests)"
    "test/data/repositories/person_repository_test.dart"                 = "PersonRepository tests (10 tests)"
    "test/data/services/auth_service_test.dart"                          = "AuthService tests — batch-copy guard, first login flow (US-020)"
    "test/data/services/auth_service_test.mocks.dart"                    = "Generated mocks for AuthService tests"
    "test/presentation/meetings/meeting_detail_provider_test.dart"       = "MeetingDetailProvider tests — categoryIds resolution (US-020)"
    "test/presentation/meetings/meeting_detail_provider_test.mocks.dart" = "Generated mocks for MeetingDetailProvider tests"
    "test/presentation/persons/person_detail_provider_test.dart"         = "PersonDetailProvider tests (US-025)"
    "test/presentation/persons/person_detail_provider_test.mocks.dart"   = "Generated mocks for PersonDetailProvider tests"
    "test/presentation/persons/persons_list_provider_test.dart"          = "PersonsListProvider tests (US-024)"
    "test/presentation/persons/persons_list_provider_test.mocks.dart"    = "Generated mocks for PersonsListProvider tests"
    "test/presentation/providers/add_meeting_provider_test.dart"         = "AddMeetingProvider tests — categories, ancestor propagation, dual list save (US-020)"
    "test/presentation/providers/add_meeting_provider_test.mocks.dart"   = "Generated mocks for AddMeetingProvider tests"
    "test/presentation/providers/meetings_list_provider_test.dart"       = "MeetingsListProvider tests (11 tests)"
    "test/presentation/providers/meetings_list_provider_test.mocks.dart" = "Generated mocks for MeetingsListProvider tests"
    "test/presentation/screens/add_meeting_screen_test.dart"             = "AddMeetingScreen tests (5 tests)"
    "test/presentation/screens/add_meeting_screen_test.mocks.dart"       = "Generated mocks for AddMeetingScreen tests"
    "test/presentation/screens/home_screen_test.dart"                    = "HomeScreen tests"
    "test/presentation/screens/home_screen_test.mocks.dart"              = "Generated mocks for HomeScreen tests"
    "test/presentation/screens/login_screen_test.dart"                   = "LoginScreen tests (8 tests)"
    "test/presentation/screens/login_screen_test.mocks.dart"             = "Generated mocks for LoginScreen tests"
    "test/presentation/screens/main_screen_test.dart"                    = "MainScreen tests (5 tests)"
    "test/presentation/screens/main_screen_test.mocks.dart"              = "Generated mocks for MainScreen tests"
    "test/presentation/screens/meetings_list_screen_test.dart"           = "MeetingsListScreen tests (5 tests)"
    "test/presentation/widgets/meeting_date_field_test.dart"             = "MeetingDateField tests (4 tests)"
    "test/presentation/widgets/meeting_date_field_test.mocks.dart"       = "Generated mocks for MeetingDateField tests"
    "test/presentation/widgets/meeting_name_field_test.dart"             = "MeetingNameField tests (5 tests)"
    "test/presentation/widgets/meeting_name_field_test.mocks.dart"       = "Generated mocks for MeetingNameField tests"
    "test/presentation/widgets/meeting_weight_stepper_test.dart"         = "MeetingWeightStepper tests (5 tests)"
}

$date = Get-Date -Format "MMMM dd, yyyy"
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Friendsheet - Project File Structure")
$lines.Add("**Last Updated:** $date")

$lines.Add("")
$lines.Add("## Root")
$lines.Add("- CLAUDE.md - Claude Code instructions — project invariants, conventions, git workflow")

$files = Get-ChildItem -Recurse -Path "lib\", "test\" |
Where-Object { !$_.PSIsContainer -and $_.Name -ne ".gitkeep" } |
ForEach-Object {
    $relativePath = $_.FullName.Replace($PWD.Path + "\", "").Replace("\", "/")
    $parts = $relativePath.Split("/")
    if ($parts.Count -eq 2) {
        $section = "$($parts[0])/"
    }
    else {
        $section = "$($parts[0])/$($parts[1])/"
    }
    [PSCustomObject]@{
        RelativePath = $relativePath
        Section      = $section
        SortKey      = "$section`0$relativePath"
    }
} |
Sort-Object SortKey

$currentSection = ""

foreach ($item in $files) {
    if ($item.Section -ne $currentSection) {
        $currentSection = $item.Section
        $lines.Add("")
        $lines.Add("## $currentSection")
    }
    $description = $descriptions[$item.RelativePath]
    if ($description) {
        $lines.Add("- $($item.RelativePath) - $description")
    }
    else {
        $lines.Add("- $($item.RelativePath)")
    }
}

$lines.Add("")
$lines.Add("---")
$lines.Add("")
$lines.Add("## Naming Conventions")
$lines.Add("- Files: snake_case")
$lines.Add("- Classes: UpperCamelCase")
$lines.Add("- Variables/methods: lowerCamelCase")
$lines.Add("- Tests mirror lib/ structure exactly")
$lines.Add("")
$lines.Add("## Rules")
$lines.Add("- Generated files (*.freezed.dart, *.g.dart) ARE committed")
$lines.Add("- firebase_options.dart is gitignored")
$lines.Add("- .gitkeep files mark empty directories")
$lines.Add("- CLAUDE.md is committed — shared instructions for Claude Code CLI")

[System.IO.File]::WriteAllLines("$PWD\PROJECT_FILES.md", $lines, [System.Text.Encoding]::UTF8)
Write-Host "PROJECT_FILES.md generated!" -ForegroundColor Green