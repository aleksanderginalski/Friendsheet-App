$descriptions = @{
    "CLAUDE.md"                                                             = "Claude Code instructions — project invariants, conventions, git workflow"
    "lib/main.dart"                                                         = "App entry point, Firebase initialization, AuthWrapper, SplashScreen as home (US-052)"
    "lib/firebase_options.dart"                                             = "Firebase config (gitignored)"
    "lib/firebase_options.example.dart"                                     = "Mock config for CI/CD"
    "lib/core/theme/app_theme.dart"                                         = "AppTheme — ThemeData with Nunito typography, ColorScheme from design brief, CardThemeData (16dp), ElevatedButton (12dp), AppBar, FAB, BottomNavigationBar (US-050)"
    "lib/core/theme/chart_colors.dart"                                      = "ChartColors — 8-color Vivid Social palette for statistics bar charts; horizontal 4-stop cylinder gradient (edge → center → center → edge); stable id.hashCode assignment; getGradient(), getBaseColor(), getStrokeColor() (US-063)"
    "lib/core/utils/firebase_test.dart"                                     = "Firebase connection test"
    "lib/data/interfaces/cache_invalidator.dart"                            = "CacheInvalidator interface — invalidateMeetingsCache(), invalidateCategoriesCache(), invalidatePersonsCache(), invalidateAllCaches(); implemented by StatisticsRepository; injected into MeetingRepository, PersonRepository, ActivityCategoryRepository (US-072)"
    "lib/data/models/activity_category.dart"                                = "ActivityCategory model (Freezed) — nullable createdAt fallback, isSelectableAsActivity, copiedFromId, parentCategoryId, iconIdentifier (US-019, US-020, US-026)"
    "lib/data/models/activity_category.freezed.dart"                        = "Generated"
    "lib/data/models/activity_category.g.dart"                              = "Generated"
    "lib/data/models/meeting.dart"                                          = "Meeting model (Freezed) — categoryIds only (US-042)"
    "lib/data/models/meeting.freezed.dart"                                  = "Generated"
    "lib/data/models/meeting.g.dart"                                        = "Generated"
    "lib/data/models/person.dart"                                           = "Person model (Freezed)"
    "lib/data/models/person.freezed.dart"                                   = "Generated"
    "lib/data/models/person.g.dart"                                         = "Generated"
    "lib/data/models/stats_data_bundle.dart"                                = "StatsDataBundle — plain Dart class holding currentYearMeetings, previousYearMeetings, categories, persons; fetched once per year via loadAllStatsData(); passed to compute* methods for zero-Firestore aggregation (US-072)"
    "lib/data/repositories/activity_category_repository.dart"               = "ActivityCategoryRepository — CRUD, deleteWithChildren (WriteBatch cascade), getSelectableCategories, getAncestorIds, getAllCategories, createSelectableCategory, depth validation; calls cacheInvalidator.invalidateCategoriesCache() on write (US-019, US-020, US-026, US-042, US-043, US-072)"
    "lib/data/repositories/meeting_repository.dart"                         = "MeetingRepository — Firestore CRUD (save, update, delete, stream, getMeetingsCountForPerson, removePersonFromMeetings); calls cacheInvalidator.invalidateMeetingsCache() on write (US-072)"
    "lib/data/repositories/person_repository.dart"                          = "PersonRepository — Firestore CRUD (getPersonsByUser, addPerson, updatePerson, deletePerson with cascade, getPersonsByIds); calls cacheInvalidator.invalidatePersonsCache() on write (US-072)"
    "lib/data/repositories/statistics_repository.dart"                      = "StatisticsRepository — implements CacheInvalidator; in-memory cache (_meetingsCache, _categoriesCache, _personsCache) with invalidate*Cache() methods; loadAllStatsData() parallel Future.wait; compute* pure synchronous methods (computeActivityBreakdown, computePersonsForActivity, computeInteractionDistribution); old async methods kept as backward-compat wrappers; getAvailableYears, getMeetingsForYear, getCumulativeInteractions; injected ActivityCategoryRepository and PersonRepository (US-027, US-028, US-029, US-030, US-050, US-072)"
    "lib/data/services/auth_service.dart"                                   = "Google Sign-In + Firebase Auth (Singleton) — batch-copy global categories on first login (US-020)"
    "lib/data/services/export_service.dart"                                 = "ExportService — fetches meetings, persons, activityCategories for userId, serializes to JSON, writes to external storage; injectable directoryProvider for test isolation (US-031)"
    "lib/presentation/activities/activities_list_provider.dart"             = "State for Activities List screen — fetch all categories (global + private), tree expansion, search, CRUD with cascade delete, hasSearchResults getter (US-026, US-043, US-055)"
    "lib/presentation/activities/activities_list_screen.dart"               = "Activities list screen — expandable category tree, subcategory indentation with T/L tree lines (CustomPainter), EmptyStateWidget for empty list and no search results, long-press edit/delete for private categories (US-026, US-055)"
    "lib/presentation/activities/activity_icons.dart"                       = "PNG asset icon map (51 entries) + resolveActivityIcon(String?) returning asset path or null + ActivityIcon widget with Icons.category fallback (US-026, US-055)"
    "lib/presentation/activities/add_edit_activity_dialog.dart"             = "Add/Edit activity category dialog — name, parent selector, 2D icon picker grid (Dialog replaces AlertDialog to avoid RenderIntrinsicWidth crash) (US-026, US-055)"
    "lib/presentation/meetings/meeting_detail_provider.dart"                = "State for Meeting Detail screen — resolves participantIds and categoryIds to full objects (US-020, US-026, US-042)"
    "lib/presentation/meetings/meeting_detail_screen.dart"                  = "Meeting detail screen — displays all fields including resolved categories with ActivityIcon, edit and delete actions (US-022, US-023, US-026, US-055)"
    "lib/presentation/persons/person_detail_provider.dart"                  = "State for Person Detail screen — fetches meeting count, handles update and delete (US-025)"
    "lib/presentation/persons/person_detail_screen.dart"                    = "Person detail screen — shows name, meeting count, edit via dialog, delete with confirmation (US-025)"
    "lib/presentation/persons/person_list_tile.dart"                        = "Person list tile widget — shows full name with initials avatar (US-024)"
    "lib/presentation/persons/persons_list_provider.dart"                   = "State for Persons List screen — one-time fetch, client-side alphabetical filter (US-024)"
    "lib/presentation/providers/add_meeting_provider.dart"                  = "State for Add/Edit Meeting screen — dual mode, categories + ancestor propagation, addNewActivity creates root category in user subcollection (US-020, US-026, US-042)"
    "lib/presentation/providers/export_provider.dart"                       = "ExportProvider — isLoading, errorMessage, lastExportPath; no-op guard when already loading; clearError() (US-031)"
    "lib/presentation/providers/meetings_list_provider.dart"                = "State for Meetings List screen — stream, year grouping, expand/collapse, client-side search (filteredMeetingsByYear computed getter) (US-021, US-054)"
    "lib/presentation/providers/statistics_provider.dart"                   = "StatisticsProvider — manages availableYears, selectedYear, activityBreakdown, whoPerActivity, interactionDistribution (yearly/cumulative mode), hidden activities + hidden persons per metric, setAllActivitiesVisibility(bool) + setAllPersonsVisibility(bool), StatCardType enum, carousel hidden-cards state (visibleCards, toggleCardVisibility, restoreAllCards); _isInitialized/_lastLoadedYear guard — initialize() and selectYear() skip fetch if data already loaded for same year; resetCache() for logout/user-switch; stores _currentBundle (StatsDataBundle) and calls compute* methods — zero additional Firestore reads on selectActivity/loadDistribution; owned by MainScreen (US-027, US-028, US-029, US-030, US-048, US-050, US-051, US-057, US-072)"
    "lib/presentation/screens/add_meeting_screen.dart"                      = "Add/Edit Meeting screen — dual mode based on initialMeeting parameter (US-023)"
    "lib/presentation/screens/home_screen.dart"                             = "Home screen — Consumer<StatisticsProvider> with StatisticsSection (US-027)"
    "lib/presentation/screens/login_screen.dart"                            = "Google Sign-In screen — Pacifico title, login illustration, ToS and Privacy Policy links via url_launcher (US-053)"
    "lib/presentation/screens/main_screen.dart"                             = "Root screen after login — BottomNavigationBar with 4 tabs + FAB + Drawer (Settings, Logout); owns PersonsListProvider, ActivitiesListProvider and StatisticsProvider lifecycle; sets statisticsRepository as cacheInvalidator on MeetingRepository, PersonRepository, ActivityCategoryRepository after construction; tap counter + Timer logic for easter egg (8 taps / 4s on AppBar title) (US-026, US-027, US-031, US-064, US-072)"
    "lib/presentation/screens/meetings_list_screen.dart"                    = "Meetings list — grouped by year, expand/collapse, SharedSearchBar, EmptyStateWidget for empty list and no search results (US-021, US-054, US-055)"
    "lib/presentation/screens/persons_list_screen.dart"                     = "Persons list — SharedSearchBar, EmptyStateWidget for empty list and no search results, navigation to PersonDetailScreen (US-024, US-054, US-055)"
    "lib/presentation/screens/settings_screen.dart"                         = "Settings screen — Export Data tile triggers ExportProvider.exportData(); SnackBar with file path on success, error message on failure (US-031)"
    "lib/presentation/screens/splash_screen.dart"                           = "SplashScreen — plays assets/animations/splash.mp4 via VideoPlayerControllerInterface, shows 'Friendsheet' in Pacifico below video, navigates to AuthWrapper on completion via pushReplacement (US-052, US-053)"
    "lib/presentation/widgets/activity_autocomplete.dart"                   = "Unified activity autocomplete — selectable categories from user subcollection, ancestor propagation, add-new-activity flow, ActivityIcon for chips and suggestions (US-020, US-042, US-055)"
    "lib/presentation/widgets/activity_breakdown_widget.dart"               = "Animated vertical bar chart — Stack + absolute positioning, ChartColors gradient per categoryId, delta % indicator (▲/▼/NEW), filter_icon.png visibility dialog trigger (replaces gear icon), auto-select top 10 logic; _lastTargetLeft fix for stationary bar animation (US-028, US-048, US-049, US-057, US-063)"
    "lib/presentation/widgets/activity_selector_dialog.dart"                = "Dialog with full category tree for selecting activity filter in WhoPerActivity metric (US-029)"
    "lib/presentation/widgets/activity_visibility_dialog.dart"              = "Dialog with hierarchical checkbox list + Auto-select top 10 + three-state toggle icon (check_box / indeterminate_check_box / check_box_outline_blank) for managing activity visibility; activity icons 31px (US-048, US-057)"
    "lib/presentation/widgets/easter_egg_dialog.dart"                       = "EasterEggDialog — dismisses on tap anywhere; displays easter_egg_icon asset + special thanks message; injectable imageWidget parameter for test isolation (US-064)"
    "lib/presentation/widgets/empty_state_widget.dart"                      = "Reusable empty state component — illustration + message; used by MeetingsListScreen and PersonsListScreen (US-054), ActivitiesListScreen (US-055)"
    "lib/presentation/widgets/interaction_distribution_widget.dart"         = "Animated bar chart showing meeting weight per person — yearly/cumulative toggle, isLoading inline spinner (widget always stays in tree), info icon (>100% explanation), filter_icon.png visibility dialog trigger (replaces gear icon), _lastTargetLeft animation architecture, ChartColors gradient per personId (US-030, US-051, US-057, US-063)"
    "lib/presentation/widgets/meeting_card.dart"                            = "Meeting card widget — displays name, date, participant count, weight (US-021)"
    "lib/presentation/widgets/meeting_date_field.dart"                      = "Date picker widget (US-011)"
    "lib/presentation/widgets/meeting_name_field.dart"                      = "Name input widget — pre-fills from provider in edit mode (US-023)"
    "lib/presentation/widgets/meeting_weight_stepper.dart"                  = "Fibonacci weight stepper widget (US-012)"
    "lib/presentation/widgets/person_autocomplete.dart"                     = "Participant autocomplete widget + AddPersonDialog — returns strings, save handled by Provider (BUG-42)"
    "lib/presentation/widgets/person_visibility_dialog.dart"                = "Flat checkbox list dialog for managing person visibility in Interaction Distribution metric + Auto-select top 10 + three-state toggle icon (check_box / indeterminate_check_box / check_box_outline_blank) (US-030, US-057)"
    "lib/presentation/widgets/shared_search_bar.dart"                       = "Reusable search bar widget — optional TextEditingController, clear button, filled background from colorScheme.surfaceContainerHighest; used in Activities, Meetings, Friends screens (US-055)"
    "lib/presentation/widgets/statistics/statistics_section.dart"           = "StatisticsSection — PageView carousel with YearStepper above; statistics_illustration displayed at bottom of screen left-aligned (height 160); _CarouselPage with AutomaticKeepAliveClientMixin keeps off-screen State alive; long-press hides card + SnackBar; empty state with Restore all; SharedPreferences key: stats_carousel_hidden_cards (US-027, US-028, US-029, US-030, US-048, US-051, US-057, US-071)"
    "lib/presentation/widgets/who_per_activity_widget.dart"                 = "Animated vertical bar chart showing persons ranked by weight sum for selected activity — ChartColors gradient per personId, _lastTargetLeft/_lastTargetBarHeight reorder animation, fixed column tops, no legend (labels below bars only); long-press hide/show; SharedPreferences hidden persons (US-029, US-050, US-063)"
    "lib/presentation/widgets/year_stepper.dart"                            = "YearStepper — pure StatelessWidget; 5-slot row layout: [←] [prev year dimmed] [active year centered, bold, primary color] [next year dimmed] [→]; arrows disabled at year boundaries; neighbour slots fixed width 48dp for stable layout; swipe gesture preserved (US-027, US-071)"
    "test/widget_test.dart"                                                 = "AuthWrapper tests"
    "test/widget_test.mocks.dart"                                           = "Generated mocks (Mockito)"
    "test/core/theme/chart_colors_test.dart"                                = "ChartColors tests — stable id→index assignment, palette bounds (0–7), gradient shape (4 colors, 4 stops), stop values [0.0, 0.3, 0.7, 1.0], stroke color charcoal full opacity (US-063)"
    "test/data/models/activity_category_test.dart"                          = "ActivityCategory model tests — isSelectableAsActivity, copiedFromId, equality, serialization (US-019, US-020)"
    "test/data/models/meeting_test.dart"                                    = "Meeting model tests — categoryIds only, activityIds removed (US-042)"
    "test/data/models/person_test.dart"                                     = "Person model tests (11 tests)"
    "test/data/repositories/activity_category_repository_test.dart"         = "ActivityCategoryRepository tests — CRUD, deleteWithChildren, getSelectableCategories, getAncestorIds, createSelectableCategory (US-019, US-020, US-042, US-043)"
    "test/data/repositories/meeting_repository_test.dart"                   = "MeetingRepository tests (9 tests)"
    "test/data/repositories/person_repository_test.dart"                    = "PersonRepository tests (10 tests)"
    "test/data/repositories/statistics_repository_test.dart"                = "StatisticsRepository tests — getAvailableYears, getMeetingsForYear, getActivityWeightBreakdown, getPersonsForActivity (incl. >30 participants regression test), getInteractionDistribution, getCumulativeInteractions, cache hit/miss behavior, invalidation (US-027, US-028, US-029, US-030, US-050, US-072)"
    "test/data/services/auth_service_test.dart"                             = "AuthService tests — batch-copy guard, first login flow (US-020)"
    "test/data/services/auth_service_test.mocks.dart"                       = "Generated mocks for AuthService tests"
    "test/data/services/export_service_test.dart"                           = "ExportService tests — happy path, empty data, repository throws (US-031)"
    "test/presentation/activities/activities_list_provider_test.dart"       = "ActivitiesListProvider tests — initialize, tree filtering, expand/collapse, CRUD, deleteWithChildren verification, hasSearchResults getter (US-026, US-043, US-055)"
    "test/presentation/activities/activities_list_provider_test.mocks.dart" = "Generated mocks for ActivitiesListProvider tests"
    "test/presentation/activities/activities_list_screen_test.dart"         = "ActivitiesListScreen tests — EmptyStateWidget for empty list, EmptyStateWidget for no search results, categories visible when present (US-055)"
    "test/presentation/activities/activity_icons_test.dart"                 = "activity_icons tests — resolveActivityIcon returns PNG path, null for unknown/empty/null, map size 51, all values are valid PNG paths (US-055)"
    "test/presentation/meetings/meeting_detail_provider_test.dart"          = "MeetingDetailProvider tests — categoryIds resolution, activityIds removed (US-020, US-042)"
    "test/presentation/meetings/meeting_detail_provider_test.mocks.dart"    = "Generated mocks for MeetingDetailProvider tests"
    "test/presentation/persons/person_detail_provider_test.dart"            = "PersonDetailProvider tests (US-025)"
    "test/presentation/persons/person_detail_provider_test.mocks.dart"      = "Generated mocks for PersonDetailProvider tests"
    "test/presentation/persons/persons_list_provider_test.dart"             = "PersonsListProvider tests (US-024)"
    "test/presentation/persons/persons_list_provider_test.mocks.dart"       = "Generated mocks for PersonsListProvider tests"
    "test/presentation/providers/add_meeting_provider_test.dart"            = "AddMeetingProvider tests — categories, ancestor propagation, addNewActivity (US-020, US-042)"
    "test/presentation/providers/add_meeting_provider_test.mocks.dart"      = "Generated mocks for AddMeetingProvider tests"
    "test/presentation/providers/export_provider_test.dart"                 = "ExportProvider tests — loading transitions, ExportException, generic exception, no-op guard, clearError (US-031)"
    "test/presentation/providers/export_provider_test.mocks.dart"           = "Generated mocks for ExportProvider tests"
    "test/presentation/providers/meetings_list_provider_test.dart"          = "MeetingsListProvider tests — stream grouping, expand/collapse, search filtering, no-results state (US-021, US-054)"
    "test/presentation/providers/meetings_list_provider_test.mocks.dart"    = "Generated mocks for MeetingsListProvider tests"
    "test/presentation/providers/statistics_provider_test.dart"             = "StatisticsProvider tests — initialize, selectYear, activityBreakdown, whoPerActivity, interactionDistribution, toggleMode, toggleHiddenActivity, toggleHiddenPerson, autoSelectTop10, setAllActivitiesVisibility, setAllPersonsVisibility, carousel state (toggleCardVisibility, restoreAllCards, allCardsHidden), SharedPreferences persistence, idempotent initialize guard, selectYear no-op for same year, compute* reuse via _currentBundle (US-027, US-028, US-029, US-030, US-048, US-050, US-051, US-057, US-072)"
    "test/presentation/providers/statistics_provider_test.mocks.dart"       = "Generated mocks for StatisticsProvider tests"
    "test/presentation/screens/add_meeting_screen_test.dart"                = "AddMeetingScreen tests (5 tests)"
    "test/presentation/screens/add_meeting_screen_test.mocks.dart"          = "Generated mocks for AddMeetingScreen tests"
    "test/presentation/screens/home_screen_test.dart"                       = "HomeScreen tests — StatisticsProvider integration, YearStepper rendering, easter egg tap counter reset / dialog trigger / dialog dismiss (US-027, US-064)"
    "test/presentation/screens/home_screen_test.mocks.dart"                 = "Generated mocks for HomeScreen tests"
    "test/presentation/screens/login_screen_test.dart"                      = "LoginScreen tests (8 tests)"
    "test/presentation/screens/login_screen_test.mocks.dart"                = "Generated mocks for LoginScreen tests"
    "test/presentation/screens/main_screen_test.dart"                       = "MainScreen tests (5 tests)"
    "test/presentation/screens/main_screen_test.mocks.dart"                 = "Generated mocks for MainScreen tests"
    "test/presentation/screens/meetings_list_screen_test.dart"              = "MeetingsListScreen tests — rendering, search field, filtering by name, no-results EmptyStateWidget (US-021, US-054)"
    "test/presentation/screens/splash_screen_test.dart"                     = "SplashScreen tests — 'Friendsheet' text rendered, background color #FAFAF7; uses MockVideoPlayerControllerInterface (US-052)"
    "test/presentation/widgets/empty_state_widget_test.dart"                = "EmptyStateWidget tests — renders image asset, renders message, different messages render correctly (US-054)"
    "test/presentation/widgets/interaction_distribution_widget_test.dart"   = "InteractionDistributionWidget tests — rendering, hidden hint, info icon visibility, toggle label, empty state, isLoading spinner presence/absence (US-030, US-051)"
    "test/presentation/widgets/meeting_date_field_test.dart"                = "MeetingDateField tests (4 tests)"
    "test/presentation/widgets/meeting_date_field_test.mocks.dart"          = "Generated mocks for MeetingDateField tests"
    "test/presentation/widgets/meeting_name_field_test.dart"                = "MeetingNameField tests (5 tests)"
    "test/presentation/widgets/meeting_name_field_test.mocks.dart"          = "Generated mocks for MeetingNameField tests"
    "test/presentation/widgets/meeting_weight_stepper_test.dart"            = "MeetingWeightStepper tests (5 tests)"
    "test/presentation/widgets/person_visibility_dialog_test.dart"          = "PersonVisibilityDialog tests — checkbox state, toggle callback, auto-select top 10, three-state toggle icon (US-030, US-057)"
    "test/presentation/widgets/shared_search_bar_test.dart"                 = "SharedSearchBar tests — hint text, onChanged callback, clear button visibility and behavior (US-055)"
    "test/presentation/widgets/statistics_section_test.dart"                = "StatisticsSection tests — PageView present when cards visible, empty state when all hidden, InteractionDistributionWidget always in tree regardless of isDistributionLoading (US-051)"
    "test/presentation/widgets/year_stepper_test.dart"                      = "YearStepper tests — rendering, boundary disabled states, tap callbacks, single-year edge case, dimmed neighbour years visible/hidden (US-027, US-071)"
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

# assets — static section (not scanned by lib/test crawler)
$lines.Add("")
$lines.Add("## assets/")
$lines.Add("- assets/icons/icon.png - App icon source — 1024x1024 PNG, Midjourney-generated, used by flutter_launcher_icons to generate all Android mipmap sizes and adaptive icon (US-071)")
$lines.Add("- assets/icons/activities/ - 51 custom PNG activity icons — Midjourney-generated, flat 2D style, used by ActivityIcon widget via kActivityIcons map (US-055)")
$lines.Add("- assets/animations/splash.mp4 - Splash screen animation — 3s MP4, Midjourney-generated, played by SplashScreen widget on app launch (US-052)")
$lines.Add("- assets/images/login_illustration.png - Login screen illustration — flat 2D cartoon friends, Midjourney-generated, displayed above Google Sign-In button (US-053)")
$lines.Add("- assets/images/empty_state_meetings.png - Meetings empty state illustration — two cartoon friends at a cafe table, Midjourney-generated (US-054)")
$lines.Add("- assets/images/empty_state_friends.png - Friends empty state illustration — single cartoon character waving, Midjourney-generated (US-054)")
$lines.Add("- assets/images/empty_state_activities.png - Activities empty state illustration — cartoon character with clipboard, Midjourney-generated (US-055)")
$lines.Add("- assets/images/statistics_illustration.png - Statistics Home illustration — Midjourney-generated, displayed at bottom of HomeScreen left-aligned (US-071)")
$lines.Add("- assets/images/filter_icon.png - Filter icon asset — replaces gear icon in ActivityBreakdownWidget and InteractionDistributionWidget header (US-057)")
$lines.Add("- assets/images/easter_egg_icon.png - Easter egg asset — displayed in EasterEggDialog triggered by 8 taps on AppBar title (US-064)")

# scripts/migration — static section (not scanned, files are partial gitignored)
$lines.Add("")
$lines.Add("## scripts/migration/")
$lines.Add("- scripts/migration/migrate.py - One-time Python migration script — Excel to Firestore (US-041). Imports meetings, persons, categoryIds with ancestor propagation. Idempotent.")
$lines.Add("- scripts/migration/requirements.txt - Python dependencies: openpyxl, firebase-admin")
$lines.Add("- scripts/migration/README.md - Setup and usage instructions for migration script")
$lines.Add("- scripts/migration/serviceAccountKey.json - Firebase service account key (gitignored — never commit)")
$lines.Add("- scripts/migration/Migracja.xlsx - Source data file (gitignored — personal data)")

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
$lines.Add("- scripts/migration/serviceAccountKey.json and *.xlsx are gitignored — never commit secrets or personal data")

[System.IO.File]::WriteAllLines("$PWD\PROJECT_FILES.md", $lines, [System.Text.Encoding]::UTF8)
Write-Host "PROJECT_FILES.md generated!" -ForegroundColor Green