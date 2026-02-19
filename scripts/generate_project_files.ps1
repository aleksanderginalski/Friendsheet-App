$descriptions = @{
    "lib/main.dart"                                                    = "App entry point, Firebase initialization, AuthWrapper"
    "lib/firebase_options.dart"                                        = "Firebase config (gitignored)"
    "lib/firebase_options.example.dart"                                = "Mock config for CI/CD"
    "lib/core/utils/firebase_test.dart"                                = "Firebase connection test"
    "lib/data/models/activity.dart"                                    = "Activity model (Freezed)"
    "lib/data/models/activity.freezed.dart"                            = "Generated"
    "lib/data/models/activity.g.dart"                                  = "Generated"
    "lib/data/models/meeting.dart"                                     = "Meeting model (Freezed)"
    "lib/data/models/meeting.freezed.dart"                             = "Generated"
    "lib/data/models/meeting.g.dart"                                   = "Generated"
    "lib/data/models/person.dart"                                      = "Person model (Freezed)"
    "lib/data/models/person.freezed.dart"                              = "Generated"
    "lib/data/models/person.g.dart"                                    = "Generated"
    "lib/data/repositories/person_repository.dart"                     = "PersonRepository (Firestore CRUD for persons)"
    "lib/data/services/auth_service.dart"                              = "Google Sign-In + Firebase Auth (Singleton)"
    "lib/presentation/providers/add_meeting_provider.dart"             = "State for Add Meeting screen (name, date, weight, participants)"
    "lib/presentation/screens/add_meeting_screen.dart"                 = "Add Meeting screen"
    "lib/presentation/screens/home_screen.dart"                        = "Home screen with logout"
    "lib/presentation/screens/login_screen.dart"                       = "Google Sign-In screen"
    "lib/presentation/widgets/meeting_date_field.dart"                 = "Date picker widget (US-011)"
    "lib/presentation/widgets/meeting_name_field.dart"                 = "Name input widget (US-011)"
    "lib/presentation/widgets/meeting_weight_stepper.dart"             = "Fibonacci weight stepper widget (US-012)"
    "lib/presentation/widgets/person_autocomplete.dart"                = "Participant autocomplete widget + AddPersonDialog (US-013)"
    "test/widget_test.dart"                                            = "AuthWrapper tests"
    "test/widget_test.mocks.dart"                                      = "Generated mocks (Mockito)"
    "test/data/models/activity_test.dart"                              = "Activity model tests (13 tests)"
    "test/data/models/meeting_test.dart"                               = "Meeting model tests (12 tests)"
    "test/data/models/person_test.dart"                                = "Person model tests (11 tests)"
    "test/presentation/screens/add_meeting_screen_test.dart"           = "AddMeetingScreen tests (5 tests)"
    "test/presentation/widgets/meeting_date_field_test.dart"           = "MeetingDateField tests (4 tests)"
    "test/presentation/widgets/meeting_name_field_test.dart"           = "MeetingNameField tests (5 tests)"
    "test/presentation/widgets/meeting_weight_stepper_test.dart"       = "MeetingWeightStepper tests (5 tests)"
    "test/presentation/providers/add_meeting_provider_test.dart"       = "AddMeetingProvider tests (20 tests)"
    "test/presentation/providers/add_meeting_provider_test.mocks.dart" = "Generated mocks for PersonRepository (Mockito)"
}

$date = Get-Date -Format "MMMM dd, yyyy"
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Friendsheet - Project File Structure")
$lines.Add("**Last Updated:** $date")

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

[System.IO.File]::WriteAllLines("$PWD\PROJECT_FILES.md", $lines, [System.Text.Encoding]::UTF8)
Write-Host "PROJECT_FILES.md generated!" -ForegroundColor Green