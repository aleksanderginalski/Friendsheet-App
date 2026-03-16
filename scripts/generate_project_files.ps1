$descriptions = @{
    "CLAUDE.md"                                                                 = "Claude Code instructions — project invariants, conventions, git workflow"
    "lib/main.dart"                                                             = "App entry point, Firebase initialization, AuthWrapper, SplashScreen as home (US-052)"
    "lib/firebase_options.dart"                                                 = "Firebase config (gitignored)"
    "lib/firebase_options.example.dart"                                         = "Mock config for CI/CD"
    "lib/core/constants/app_constants.dart"                                     = "AppConstants — shared app-wide constants; chartAnimationDuration: Duration(milliseconds: 1000) used by all three statistics chart widgets (US-075)"
    "lib/core/theme/app_theme.dart"                                             = "AppTheme — ThemeData with Nunito typography, ColorScheme from design brief, CardThemeData (16dp), ElevatedButton (12dp), AppBar, FAB, BottomNavigationBar (US-050)"
    "lib/core/theme/chart_colors.dart"                                          = "ChartColors — 8-color Vivid Social palette for statistics bar charts; horizontal 4-stop cylinder gradient (edge → center → center → edge); stable id.hashCode assignment; getGradient(), getBaseColor(), getStrokeColor() (US-063)"
    "lib/core/utils/firebase_test.dart"                                         = "Firebase connection test"
    "lib/core/utils/person_search_helper.dart"                                  = "PersonSearchHelper — static matches(person, query) checks firstName, lastName, and all nicknames; shared by PersonsListProvider and PersonAutocomplete to avoid duplication (US-061)"
    "lib/core/utils/person_sort.dart"                                           = "normalizeForSort() — Polish diacritic-aware string normalization for A→Z sorting (ą→az, ć→cz, ę→ez, ł→lz, ń→nz, ó→oz, ś→sz, ź→zz, ż→zz); shared by PersonVisibilityDialog and WhoPerActivityPersonFilterDialog (US-079)"
    "lib/data/interfaces/cache_invalidator.dart"                                = "CacheInvalidator interface — invalidateMeetingsCache(), invalidateCategoriesCache(), invalidatePersonsCache(), invalidateAllCaches(); all methods Future<void> (US-072, US-073); implemented by StatisticsRepository; injected into MeetingRepository, PersonRepository, ActivityCategoryRepository"
    "lib/data/models/activity_category.dart"                                    = "ActivityCategory model (Freezed) — nullable createdAt fallback, isSelectableAsActivity, copiedFromId, parentCategoryId, iconIdentifier (US-019, US-020, US-026)"
    "lib/data/models/activity_category.freezed.dart"                            = "Generated"
    "lib/data/models/activity_category.g.dart"                                  = "Generated"
    "lib/data/models/friend_group.dart"                                         = "FriendGroup model (Freezed) — id, name, iconIdentifier (nullable), personIds: List<String>; fromFirestore with explicit type casting; toFirestore; used by FriendGroupRepository (US-062)"
    "lib/data/models/friend_group.freezed.dart"                                 = "Generated"
    "lib/data/models/friend_group.g.dart"                                       = "Generated"
    "lib/data/models/google_calendar.dart"                                      = "GoogleCalendar model — id, summary, isPrimary; CalendarAuthException for OAuth denial/failure (US-066)"
    "lib/data/models/import_candidate.dart"                                     = "ImportCandidate model (Freezed + JSON) — transient import candidate with id, title, date, attendeeEmails, sourceType; toJson/fromJson for SharedPreferences persistence (US-068)"
    "lib/data/models/import_candidate.freezed.dart"                             = "Generated"
    "lib/data/models/import_candidate.g.dart"                                   = "Generated"
    "lib/data/models/meeting.dart"                                              = "Meeting model (Freezed) — categoryIds only (US-042)"
    "lib/data/models/meeting.freezed.dart"                                      = "Generated"
    "lib/data/models/meeting.g.dart"                                            = "Generated"
    "lib/data/models/person.dart"                                               = "Person model (Freezed) — firstName, lastName, nicknames: List<String> (default []); fromFirestore null-safe nicknames parsing; toFirestore always writes nicknames field (US-061)"
    "lib/data/models/person.freezed.dart"                                       = "Generated"
    "lib/data/models/person.g.dart"                                             = "Generated"
    "lib/data/models/stats_data_bundle.dart"                                    = "StatsDataBundle — plain Dart class holding currentYearMeetings, previousYearMeetings, categories, persons; fetched once per year via loadAllStatsData(); passed to compute* methods for zero-Firestore aggregation (US-072)"
    "lib/data/repositories/activity_category_repository.dart"                   = "ActivityCategoryRepository — CRUD, deleteWithChildren (WriteBatch cascade), getSelectableCategories, getAncestorIds, getAllCategories, createSelectableCategory, depth validation; awaits cacheInvalidator.invalidateCategoriesCache() on write (US-019, US-020, US-026, US-042, US-043, US-072, US-073)"
    "lib/data/repositories/friend_group_repository.dart"                        = "FriendGroupRepository — CRUD under users/{uid}/friend_groups; addPersonToGroup (arrayUnion, idempotent), removePersonFromGroup (arrayRemove), removePersonFromAllGroups (WriteBatch cascade — called by PersonRepository.deletePerson) (US-062)"
    "lib/data/repositories/meeting_repository.dart"                             = "MeetingRepository — Firestore CRUD (save, update, delete, stream, getMeetingsCountForPerson, removePersonFromMeetings); awaits cacheInvalidator.invalidateMeetingsCache() on write (US-072, US-073)"
    "lib/data/repositories/person_repository.dart"                              = "PersonRepository — Firestore CRUD (getPersonsByUser, addPerson, updatePerson, deletePerson with cascade, getPersonsByIds); deletePerson runs removePersonFromMeetings + removePersonFromAllGroups in parallel via Future.wait; awaits cacheInvalidator.invalidatePersonsCache() on write (US-072, US-073, US-062)"
    "lib/data/repositories/statistics_repository.dart"                          = "StatisticsRepository — implements CacheInvalidator; two-level cache: in-memory (_meetingsCache, _categoriesCache, _personsCache) + Hive persistent (stats_meetings, stats_categories, stats_persons, stats_available_years boxes); JSON bridge pattern for Hive serialization; invalidate*Cache() clears both levels; loadAllStatsData() parallel Future.wait; compute* pure synchronous methods; getAvailableYears, getMeetingsForYear, getCumulativeInteractions; injected ActivityCategoryRepository and PersonRepository (US-027, US-028, US-029, US-030, US-050, US-072, US-073)"
    "lib/data/services/auth_service.dart"                                       = "Google Sign-In + Firebase Auth (Singleton) — batch-copy global categories on first login (US-020); calls HiveService.clearUserData(uid) on logout (US-073)"
    "lib/data/services/account_deletion_service.dart"                           = "AccountDeletionService — reauthenticateWithCredential() via Google, paginated Firestore subcollection delete (meetings, persons, activity_categories) in batches of 500, Firebase Auth user delete, SharedPreferences + secure storage + Hive clear (US-076)"
    "lib/data/services/export_service.dart"                                     = "ExportService — fetches meetings, persons, activityCategories for userId, serializes to JSON, writes to external storage; injectable directoryProvider for test isolation (US-031)"
    "lib/data/services/google_calendar_service.dart"                            = "GoogleCalendarService (Singleton) — incremental OAuth via requestScopes(['calendar.readonly']), token persistence in flutter_secure_storage, fetchCalendars() and fetchEvents() via Calendar REST API with _withTokenRetry<T> silent refresh on 401, revokeAccess(); CalendarAuthException propagated on unrecoverable auth failure (US-066, US-078)"
    "lib/services/hive_service.dart"                                            = "HiveService — opens all Hive boxes at startup (stats_meetings, stats_categories, stats_persons, stats_available_years); box() accessor; clearUserData(userId) removes all cache entries for a given user across all boxes; called from main.dart before runApp() and from AuthService on logout (US-073)"
    "lib/presentation/activities/activities_list_provider.dart"                 = "State for Activities List screen — fetch all categories (global + private), tree expansion, search with parent-aware filtering (parent shown when query matches parent OR any child), CRUD with cascade delete, hasSearchResults getter (US-026, US-043, US-055, US-061)"
    "lib/presentation/activities/activities_list_screen.dart"                   = "Activities list screen — expandable category tree, subcategory indentation with T/L tree lines (CustomPainter), child count badge on parent categories (US-075), EmptyStateWidget for empty list and no search results, long-press edit/delete for private categories, expandable search icon in AppBar (US-026, US-055)"
    "lib/presentation/activities/activity_icons.dart"                           = "PNG asset icon map (51 entries) + resolveActivityIcon(String?) returning asset path or null + ActivityIcon widget with Icons.category fallback (US-026, US-055)"
    "lib/presentation/activities/add_edit_activity_dialog.dart"                 = "Add/Edit activity category dialog — name, parent selector, 2D icon picker grid (Dialog replaces AlertDialog to avoid RenderIntrinsicWidth crash) (US-026, US-055)"
    "lib/presentation/meetings/meeting_detail_provider.dart"                    = "State for Meeting Detail screen — resolves participantIds and categoryIds to full objects (US-020, US-026, US-042)"
    "lib/presentation/meetings/meeting_detail_screen.dart"                      = "Meeting detail screen — displays all fields including resolved categories with ActivityIcon, edit and delete actions (US-022, US-023, US-026, US-055)"
    "lib/presentation/persons/add_edit_group_dialog.dart"                       = "AddEditGroupDialog — dual-mode (Add/Edit) Dialog with name TextField (max 50 chars) and horizontal scrollable icon picker reusing activity_icons.dart; 'None' option as first item; Save disabled when name empty; pre-fills in Edit mode (US-062)"
    "lib/presentation/persons/assign_persons_bottom_sheet.dart"                 = "AssignPersonsBottomSheet — CheckboxListTile multi-select of persons not yet in group; 'Done' button calls addPersonToGroup for each selected person; snackbar when all persons already assigned (US-062)"
    "lib/presentation/persons/friend_groups_provider.dart"                      = "FriendGroupsProvider — loadGroups, addGroup, updateGroup, deleteGroup, addPersonToGroup (optimistic), removePersonFromGroup (optimistic), groupsForPerson (pure client-side filter); owned by MainScreen alongside PersonsListProvider; reloaded on Friends tab tap (US-062)"
    "lib/presentation/persons/group_section_widgets.dart"                       = "GroupSection (ExpansionTile with ActivityIcon/fallback, person count badge, long-press handler, person_add trailing button) + UngroupedSection (divider-style header, always visible, non-collapsible) (US-062)"
    "lib/presentation/persons/nicknames_section.dart"                           = "NicknamesSection — extracted from PersonDetailScreen to keep it under 300 lines; InputChip list with add field for managing person nicknames (US-061, US-062)"
    "lib/presentation/persons/person_detail_provider.dart"                      = "State for Person Detail screen — fetches meeting count, handles update and delete, addNickname()/removeNickname() with silent dedup (US-025, US-061)"
    "lib/presentation/persons/person_detail_screen.dart"                        = "Person detail screen — shows name, meeting count, edit via dialog, delete with confirmation, NicknamesSection, _GroupsSection with CheckboxListTile per group (toggle calls addPersonToGroup/removePersonFromGroup); FriendGroupsProvider injected at call-site (US-025, US-061, US-062)"
    "lib/presentation/persons/person_list_tile.dart"                            = "Person list tile widget — shows full name with initials avatar (US-024)"
    "lib/presentation/persons/persons_list_provider.dart"                       = "State for Persons List screen — one-time fetch, client-side filter via PersonSearchHelper.matches() (firstName, lastName, nicknames) (US-024, US-061)"
    "lib/presentation/providers/add_meeting_provider.dart"                      = "State for Add/Edit Meeting screen — dual mode, categories + ancestor propagation, addNewActivity creates root category in user subcollection, searchPersons uses PersonSearchHelper (US-020, US-026, US-042, US-061)"
    "lib/presentation/providers/calendar_settings_provider.dart"                = "CalendarSettingsProvider — isConnected, availableCalendars, selectedCalendarIds, includeAllDay; connectCalendar() triggers OAuth flow, toggleCalendar/toggleAllDay persist to SharedPreferences, revokeAccess() clears token and prefs; auto-selects primary calendar on first connect (US-066)"
    "lib/presentation/providers/calendar_events_provider.dart"                  = "CalendarEventsProvider — loads calendar events via GoogleCalendarService; requiresReconnect flag set on CalendarAuthException (expired/revoked token), errorMessage set on network/other errors; reset on successful load and disconnect (US-067, US-078)"
    "lib/presentation/import/import_success_screen.dart"                        = "ImportSuccessScreen — confirmed meeting count, 'GO TO MEETINGS' CTA, clears MeetingInboxProvider (US-068)"
    "lib/presentation/import/inbox_item_edit_screen.dart"                       = "InboxItemEditScreen — pre-filled form per ImportCandidate; reuses PersonAutocomplete, ActivityAutocomplete, MeetingWeightStepper; Confirm saves to Firestore, Skip discards (US-068)"
    "lib/presentation/import/meeting_inbox_screen.dart"                         = "MeetingInboxScreen (Pending Meetings) — list of ImportCandidate cards with progress indicator; empty state with Import from Calendar CTA; auto-navigates to ImportSuccessScreen when inbox empty after processing (US-068)"
    "lib/presentation/providers/inbox_item_edit_provider.dart"                  = "InboxItemEditProvider — form state for InboxItemEditScreen; initialized from ImportCandidate; validates name/participants/categories; searchPersons uses PersonSearchHelper; calls MeetingRepository.saveMeeting() on confirm (US-068, US-061)"
    "lib/presentation/providers/meeting_inbox_provider.dart"                    = "MeetingInboxProvider — owns List<ImportCandidate> with SharedPreferences persistence (key: meeting_inbox_candidates); addCandidates() merges by id; markConfirmed/skip remove candidate; clear() resets after success; owned by MainScreen (US-068)"
    "lib/presentation/providers/delete_account_provider.dart"                   = "DeleteAccountProvider — isLoading/errorMessage state, no-op guard against double-tap, navigates to LoginScreen via appNavigatorKey on success, clearError() (US-076)"
    "lib/presentation/providers/export_provider.dart"                           = "ExportProvider — isLoading, errorMessage, lastExportPath; no-op guard when already loading; clearError() (US-031)"
    "lib/presentation/providers/home_provider.dart"                             = "HomeProvider — subscribes to meeting stream, tracks _meetingCount and _initialized flag; shouldShowCta requires _initialized && count < 50 (prevents flash on startup); isDismissed via SharedPreferences key: onboarding_calendar_cta_dismissed; dismissCta() persists dismiss state (US-065, US-073)"
    "lib/presentation/providers/meetings_list_provider.dart"                    = "State for Meetings List screen — Firestore stream, two-level grouping year→month (Map<int, Map<int, List<Meeting>>>), expand/collapse for years and months, _initDefaultExpandedMonths (current month + last month with data), client-side search via meetingsByYearAndMonth getter (US-021, US-054, US-059)"
    "lib/presentation/providers/statistics_provider.dart"                       = "StatisticsProvider — manages availableYears, selectedYear, activityBreakdown, whoPerActivity, interactionDistribution (yearly/cumulative mode), hidden activities + hidden persons per metric, setAllActivitiesVisibility(bool) + setAllPersonsActivityVisibility(bool), autoSelectTop10ForActivity() (top 10 by weightSum for current activity), StatCardType enum, carousel hidden-cards state (visibleCards, toggleCardVisibility, hiddenCards getter); _isInitialized/_lastLoadedYear guard — initialize() and selectYear() skip fetch if data already loaded for same year; resetCache() for logout/user-switch; stores _currentBundle (StatsDataBundle) and calls compute* methods — zero additional Firestore reads on selectActivity/loadDistribution; owned by MainScreen (US-027, US-028, US-029, US-030, US-048, US-050, US-051, US-057, US-058, US-060, US-072)"
    "lib/presentation/screens/add_meeting_screen.dart"                          = "Add/Edit Meeting screen — dual mode based on initialMeeting parameter (US-023)"
    "lib/presentation/screens/calendar_permission_screen.dart"                  = "CalendarPermissionScreen — explanation UI with grant/deny flow; calls CalendarSettingsProvider.connectCalendar(), navigates to SettingsScreen on success, shows CalendarAuthException error with retry option (US-065 stub, US-066 full implementation)"
    "lib/presentation/screens/calendar_events_screen.dart"                      = "CalendarEventsScreen — browse and multi-select Google Calendar events; date range + calendar filters; requiresReconnect state shows 'Calendar access expired' with Reconnect CTA (onReconnect: VoidCallback?); _handleImport reads MeetingInboxProvider from context, calls addCandidates(), navigates to MeetingInboxScreen (US-067, US-068, US-078)"
    "lib/presentation/screens/home_screen.dart"                                 = "Home screen — Consumer2<HomeProvider, StatisticsProvider>; shows HomeLoadingScreen until isInitialized; shows OnboardingCalendarCtaCard when shouldShowCta, StatisticsSection otherwise (US-065, US-073)"
    "lib/presentation/screens/login_screen.dart"                                = "Google Sign-In screen — Pacifico title, login illustration, ToS and Privacy Policy links via url_launcher (US-053)"
    "lib/presentation/screens/main_screen.dart"                                 = "Root screen after login — BottomNavigationBar with 4 tabs + FAB + Drawer (drawer_icon.png illustration in green header, Import from Calendar, Pending Meetings badge, Settings, Logout); owns HomeProvider, PersonsListProvider, FriendGroupsProvider, ActivitiesListProvider, StatisticsProvider, CalendarSettingsProvider, MeetingInboxProvider lifecycle; FriendGroupsProvider reloaded on Friends tab tap (index==2); DeleteAccountProvider added to SettingsScreen MultiProvider call-site; drawer handler catches CalendarAuthException vs generic exceptions; tap counter + Timer logic for easter egg (US-026, US-027, US-031, US-062, US-064, US-065, US-066, US-068, US-072, US-076, US-077, US-078)"
    "lib/presentation/screens/meetings_list_screen.dart"                        = "Meetings list — grouped by year→month with independent collapse/expand, _MonthHeader widget (month name + meeting count, indented 16dp), meeting item tiles indented 24dp left (fromLTRB(24,2,8,2)) for visible hierarchy, expandable search icon in AppBar (add→search order), EmptyStateWidget for empty list and no search results (US-021, US-054, US-055, US-059, US-077)"
    "lib/presentation/screens/persons_list_screen.dart"                         = "Persons list — Consumer2<PersonsListProvider, FriendGroupsProvider>; grouped view: ExpansionTile per FriendGroup (with ActivityIcon + person count badge) + UngroupedSection at bottom; AppBar + opens bottom sheet chooser (Add Person / Add Group); long-press group → Edit/Delete bottom sheet; person_add icon on group → AssignPersonsBottomSheet; FriendGroupsProvider injected at call-site into PersonDetailScreen; search flattens all sections globally; EmptyStateWidget when no persons (US-024, US-054, US-055, US-059, US-062)"
    "lib/presentation/screens/settings_screen.dart"                             = "Settings screen — Calendar section (connect/disconnect, revoke); Export Data tile triggers ExportProvider.exportData(); Delete Account destructive tile with confirmation dialog and reauthentication flow (US-031, US-066, US-076)"
    "lib/presentation/screens/splash_screen.dart"                               = "SplashScreen — plays assets/animations/splash.mp4 via VideoPlayerControllerInterface, shows 'Friendsheet' in Pacifico below video, navigates to AuthWrapper on completion via pushReplacement (US-052, US-053)"
    "lib/presentation/widgets/activity_autocomplete.dart"                       = "Unified activity autocomplete — callback-based (selectedCategories, onCategoryAdded, onCategoryRemoved); ancestor propagation, add-new-activity flow, ActivityIcon for chips; reusable in AddMeetingScreen and InboxItemEditScreen (US-020, US-042, US-055, US-068)"
    "lib/presentation/widgets/activity_breakdown_widget.dart"                   = "Animated vertical bar chart — Stack + absolute positioning, ChartColors gradient per categoryId, delta % indicator (▲/▼/NEW), filter_icon.png visibility dialog trigger (replaces gear icon), auto-select top 10 logic; _lastTargetLeft fix for stationary bar animation; AnimationController reset before forward() on year change — no pre-animation flash (US-028, US-048, US-049, US-057, US-063, US-075)"
    "lib/presentation/widgets/activity_selector_dialog.dart"                    = "Dialog with full category tree (parent headers + child activities with icons) for selecting activity filter in WhoPerActivity metric (US-029, US-058)"
    "lib/presentation/widgets/activity_visibility_dialog.dart"                  = "Dialog with hierarchical checkbox list + Auto-select top 10 + three-state toggle icon (check_box / indeterminate_check_box / check_box_outline_blank) for managing activity visibility; activity icons 31px (US-048, US-057)"
    "lib/presentation/widgets/easter_egg_dialog.dart"                           = "EasterEggDialog — dismisses on tap anywhere; displays easter_egg_icon asset + special thanks message; injectable imageWidget parameter for test isolation (US-064)"
    "lib/presentation/widgets/empty_state_widget.dart"                          = "Reusable empty state component — illustration + message; used by MeetingsListScreen and PersonsListScreen (US-054), ActivitiesListScreen (US-055)"
    "lib/presentation/widgets/home_loading_screen.dart"                         = "HomeLoadingScreen — centered loading widget with loading_icon.png (120x120) and 'Checking who you've been hanging out with...' text; shown by HomeScreen until HomeProvider._initialized is true (US-073)"
    "lib/presentation/widgets/interaction_distribution_widget.dart"             = "Animated bar chart showing meeting weight per person — yearly/cumulative toggle, isLoading inline spinner (widget always stays in tree), info icon (>100% explanation), filter_icon.png visibility dialog trigger (replaces gear icon), _lastTargetLeft animation architecture, ChartColors gradient per personId; AnimationController reset before forward() on year change — no pre-animation flash (US-030, US-051, US-057, US-063, US-075)"
    "lib/presentation/widgets/meeting_card.dart"                                = "Meeting card widget — compact layout: name, date, participant count, weight; reduced vertical padding (8dp) and font sizes as new default (US-021, US-059)"
    "lib/presentation/widgets/meeting_date_field.dart"                          = "Date picker widget (US-011)"
    "lib/presentation/widgets/meeting_name_field.dart"                          = "Name input widget — pre-fills from provider in edit mode (US-023)"
    "lib/presentation/widgets/meeting_weight_stepper.dart"                      = "Fibonacci weight stepper widget (US-012)"
    "lib/presentation/widgets/onboarding_calendar_cta_card.dart"                = "OnboardingCalendarCtaCard — centered Card with headline, subtext, 'Import from Calendar' ElevatedButton, cta_stats.png illustration; onDismiss (X button) and onImport callbacks (US-065)"
    "lib/presentation/widgets/person_autocomplete.dart"                         = "Participant autocomplete widget — callback-based (selectedPersons, onPersonAdded, onPersonRemoved); search via PersonSearchHelper.matches() (firstName, lastName, nicknames); AddPersonDialog; reusable in AddMeetingScreen and InboxItemEditScreen (US-068, US-061)"
    "lib/presentation/widgets/person_visibility_dialog.dart"                    = "Flat checkbox list dialog for managing person visibility in Interaction Distribution metric — persons sorted A→Z using normalizeForSort() (Polish diacritics aware); Auto-select top 10 + three-state toggle icon (check_box / indeterminate_check_box / check_box_outline_blank) (US-030, US-057, US-079)"
    "lib/presentation/widgets/shared_search_bar.dart"                           = "Reusable search bar widget — optional TextEditingController, clear button, filled background from colorScheme.surfaceContainerHighest; used in Activities, Meetings, Friends screens as expandable AppBar search (US-055, US-059)"
    "lib/presentation/widgets/statistics/statistics_section.dart"               = "StatisticsSection — PageView carousel with header row [< Statistics 🎛 >]; left/right arrow IconButtons (Icons.chevron_left/right) with wrap-around navigation, disabled when visibleCards.length <= 1; Icons.tune button opens StatisticsVisibilityDialog; long-press hide removed (US-060); _CarouselPage with AutomaticKeepAliveClientMixin keeps off-screen State alive; SharedPreferences key: stats_carousel_hidden_cards (US-027, US-028, US-029, US-030, US-048, US-051, US-057, US-060, US-071)"
    "lib/presentation/widgets/statistics/statistics_visibility_dialog.dart"     = "StatisticsVisibilityDialog — flat CheckboxListTile per StatCardType value; three-state select-all toggle (check_box / indeterminate_check_box / check_box_outline_blank); last-visible card checkbox disabled with tooltip 'At least one card must remain visible'; changes apply immediately, single Close button (US-060)"
    "lib/presentation/widgets/who_per_activity_widget.dart"                     = "Animated vertical bar chart showing persons ranked by weight sum for selected activity — ChartColors gradient per personId, _lastTargetLeft/_lastTargetBarHeight reorder animation, fixed column tops, no legend (labels below bars only); filter_icon.png opens WhoPerActivityPersonFilterDialog; AnimationController reset before forward() on year change — no pre-animation flash; duration unified to AppConstants.chartAnimationDuration (US-029, US-050, US-058, US-063, US-075)"
    "lib/presentation/widgets/who_per_activity_person_filter_dialog.dart"       = "Person filter dialog for WhoPerActivity — persons sorted A→Z using normalizeForSort() (Polish diacritics aware); checkbox list, three-state select-all toggle, Auto-select top 10 (top 10 by weightSum for current activity), min-1 constraint (US-058, US-079)"
    "lib/presentation/widgets/year_stepper.dart"                                = "YearStepper — pure StatelessWidget; 5-slot row layout: [←] [prev year dimmed] [active year centered, bold, primary color] [next year dimmed] [→]; arrows disabled at year boundaries; neighbour slots fixed width 48dp for stable layout; swipe gesture preserved (US-027, US-071)"
    # --- tests ---
    "test/widget_test.dart"                                                     = "AuthWrapper tests"
    "test/widget_test.mocks.dart"                                               = "Generated mocks (Mockito)"
    "test/core/theme/chart_colors_test.dart"                                    = "ChartColors tests — stable id→index assignment, palette bounds (0–7), gradient shape (4 colors, 4 stops), stop values [0.0, 0.3, 0.7, 1.0], stroke color charcoal full opacity (US-063)"
    "test/core/utils/person_search_helper_test.dart"                            = "PersonSearchHelper tests — matches by firstName, lastName, nickname (exact + partial + case-insensitive), no match, empty query returns false (US-061)"
    "test/core/utils/person_sort_test.dart"                                     = "normalizeForSort tests — Polish diacritics mapping, case-insensitive A→Z order, Ludwik before Łukasz (US-079)"
    "test/data/models/activity_category_test.dart"                              = "ActivityCategory model tests — isSelectableAsActivity, copiedFromId, equality, serialization (US-019, US-020)"
    "test/data/models/friend_group_test.dart"                                   = "FriendGroup model tests — copyWith, equality, toJson/fromJson round-trip, fromFirestore mapping, nullable iconIdentifier (13 tests) (US-062)"
    "test/data/models/meeting_test.dart"                                        = "Meeting model tests — categoryIds only, activityIds removed (US-042)"
    "test/data/models/person_test.dart"                                         = "Person model tests — nicknames default [], fromFirestore with/without field, toFirestore includes nicknames, equality, copyWith (US-061)"
    "test/data/repositories/activity_category_repository_test.dart"             = "ActivityCategoryRepository tests — CRUD, deleteWithChildren, getSelectableCategories, getAncestorIds, createSelectableCategory (US-019, US-020, US-042, US-043)"
    "test/data/repositories/friend_group_repository_test.dart"                  = "FriendGroupRepository tests — getGroupsByUser empty, addGroup, updateGroup, deleteGroup, addPersonToGroup idempotency, removePersonFromGroup, removePersonFromAllGroups WriteBatch across multiple groups (14 tests) (US-062)"
    "test/data/repositories/meeting_repository_test.dart"                       = "MeetingRepository tests (9 tests)"
    "test/data/repositories/person_repository_test.dart"                        = "PersonRepository tests (10 tests)"
    "test/data/repositories/statistics_repository_test.dart"                    = "StatisticsRepository tests — getAvailableYears, getMeetingsForYear, getActivityWeightBreakdown, getPersonsForActivity (incl. >30 participants regression test), getInteractionDistribution, getCumulativeInteractions, cache hit/miss behavior, invalidation, Hive cache hit/miss/invalidation (US-027, US-028, US-029, US-030, US-050, US-072, US-073)"
    "test/data/services/auth_service_test.dart"                                 = "AuthService tests — batch-copy guard, first login flow (US-020)"
    "test/data/services/auth_service_test.mocks.dart"                           = "Generated mocks for AuthService tests"
    "test/data/services/account_deletion_service_test.dart"                     = "AccountDeletionService tests — happy path (full sequence via FakeFirebaseFirestore + mocks), reauthentication failure (no Firestore calls), Auth delete failure (US-076)"
    "test/data/services/export_service_test.dart"                               = "ExportService tests — happy path, empty data, repository throws (US-031)"
    "test/services/google_calendar_service_test.dart"                           = "GoogleCalendarService tests — fetchCalendars/fetchEvents retry on 401 via _withTokenRetry, signInSilently null throws CalendarAuthException, network error rethrown as-is, success path no refresh called (US-078)"
    "test/presentation/activities/activities_list_provider_test.dart"           = "ActivitiesListProvider tests — initialize, tree filtering with parent-aware search (parent shown when matches OR has matching child), expand/collapse, CRUD, deleteWithChildren verification, hasSearchResults getter (US-026, US-043, US-055, US-061)"
    "test/presentation/activities/activities_list_provider_test.mocks.dart"     = "Generated mocks for ActivitiesListProvider tests"
    "test/presentation/activities/activities_list_screen_test.dart"             = "ActivitiesListScreen tests — EmptyStateWidget for empty list, EmptyStateWidget for no search results, categories visible when present (US-055)"
    "test/presentation/activities/activity_icons_test.dart"                     = "activity_icons tests — resolveActivityIcon returns PNG path, null for unknown/empty/null, map size 51, all values are valid PNG paths (US-055)"
    "test/presentation/meetings/meeting_detail_provider_test.dart"              = "MeetingDetailProvider tests — categoryIds resolution, activityIds removed (US-020, US-042)"
    "test/presentation/meetings/meeting_detail_provider_test.mocks.dart"        = "Generated mocks for MeetingDetailProvider tests"
    "test/presentation/persons/friend_groups_provider_test.dart"                = "FriendGroupsProvider tests — loadGroups, loadGroups error, addGroup, updateGroup, deleteGroup, addPersonToGroup optimistic update, removePersonFromGroup optimistic update, groupsForPerson filter, clearError (15 tests) (US-062)"
    "test/presentation/persons/friend_groups_provider_test.mocks.dart"          = "Generated mocks for FriendGroupsProvider tests"
    "test/presentation/persons/person_detail_provider_test.dart"                = "PersonDetailProvider tests — addNickname, removeNickname, silent dedup (US-025, US-061)"
    "test/presentation/persons/person_detail_provider_test.mocks.dart"          = "Generated mocks for PersonDetailProvider tests"
    "test/presentation/persons/persons_list_provider_test.dart"                 = "PersonsListProvider tests — filter by firstName, lastName, nickname; no match; empty query returns all (US-024, US-061)"
    "test/presentation/persons/persons_list_provider_test.mocks.dart"           = "Generated mocks for PersonsListProvider tests"
    "test/presentation/providers/add_meeting_provider_test.dart"                = "AddMeetingProvider tests — categories, ancestor propagation, addNewActivity (US-020, US-042)"
    "test/presentation/providers/add_meeting_provider_test.mocks.dart"          = "Generated mocks for AddMeetingProvider tests"
    "test/presentation/providers/calendar_settings_provider_test.dart"          = "CalendarSettingsProvider tests — isConnected false/true on init, includeAllDay default false, toggleAllDay persistence, toggleCalendar add/remove, revokeAccess reset (US-066)"
    "test/presentation/providers/calendar_settings_provider_test.mocks.dart"    = "Generated mocks for CalendarSettingsProvider tests"
    "test/presentation/providers/calendar_events_provider_test.dart"            = "CalendarEventsProvider tests — CalendarAuthException sets requiresReconnect true (no errorMessage), generic exception sets errorMessage (requiresReconnect false), success resets both flags (US-078)"
    "test/presentation/providers/delete_account_provider_test.dart"             = "DeleteAccountProvider tests — initial state, success path, error handling, no-op guard, clearError (8 tests) (US-076)"
    "test/presentation/providers/export_provider_test.dart"                     = "ExportProvider tests — loading transitions, ExportException, generic exception, no-op guard, clearError (US-031)"
    "test/presentation/providers/export_provider_test.mocks.dart"               = "Generated mocks for ExportProvider tests"
    "test/presentation/providers/home_provider_test.dart"                       = "HomeProvider tests — shouldShowCta false before first emission (isInitialized guard), true (count<50, not dismissed), false (count>=50), false (dismissed), dismissCta() persists to SharedPreferences (US-065, US-073)"
    "test/presentation/providers/home_provider_test.mocks.dart"                 = "Generated mocks for HomeProvider tests"
    "test/presentation/providers/inbox_item_edit_provider_test.dart"            = "InboxItemEditProvider tests — initialize pre-fill, validateName, save guards (no persons, no categories), saveMeeting called once on valid data (US-068)"
    "test/presentation/providers/inbox_item_edit_provider_test.mocks.dart"      = "Generated mocks for InboxItemEditProvider tests"
    "test/presentation/providers/meeting_inbox_provider_test.dart"              = "MeetingInboxProvider tests — initialize with empty/existing prefs, skip, markConfirmed, isEmpty, persistence after confirm (US-068)"
    "test/presentation/providers/meetings_list_provider_test.dart"              = "MeetingsListProvider tests — stream grouping year→month, expand/collapse years and months, _initDefaultExpandedMonths (current + last with data), search filtering with two-level map, no-results state (US-021, US-054, US-059)"
    "test/presentation/providers/meetings_list_provider_test.mocks.dart"        = "Generated mocks for MeetingsListProvider tests"
    "test/presentation/providers/statistics_provider_test.dart"                 = "StatisticsProvider tests — initialize, selectYear, activityBreakdown, whoPerActivity, interactionDistribution, toggleMode, toggleHiddenActivity, toggleHiddenPerson, autoSelectTop10, autoSelectTop10ForActivity, setAllActivitiesVisibility, setAllPersonsActivityVisibility, carousel state (toggleCardVisibility, hiddenCards getter, restoreAllCards, allCardsHidden), SharedPreferences persistence, idempotent initialize guard, selectYear no-op for same year, compute* reuse via _currentBundle (US-027, US-028, US-029, US-030, US-048, US-050, US-051, US-057, US-058, US-060, US-072)"
    "test/presentation/providers/statistics_provider_test.mocks.dart"           = "Generated mocks for StatisticsProvider tests"
    "test/presentation/screens/add_meeting_screen_test.dart"                    = "AddMeetingScreen tests (5 tests)"
    "test/presentation/screens/add_meeting_screen_test.mocks.dart"              = "Generated mocks for AddMeetingScreen tests"
    "test/presentation/screens/home_screen_test.dart"                           = "HomeScreen tests — HomeLoadingScreen shown when not initialized, CTA shown when shouldShowCta, StatisticsSection shown otherwise; StatisticsProvider integration, YearStepper rendering (US-027, US-064, US-065, US-073)"
    "test/presentation/screens/home_screen_test.mocks.dart"                     = "Generated mocks for HomeScreen tests"
    "test/presentation/screens/login_screen_test.dart"                          = "LoginScreen tests (8 tests)"
    "test/presentation/screens/login_screen_test.mocks.dart"                    = "Generated mocks for LoginScreen tests"
    "test/presentation/screens/main_screen_test.dart"                           = "MainScreen tests (5 tests)"
    "test/presentation/screens/main_screen_test.mocks.dart"                     = "Generated mocks for MainScreen tests"
    "test/presentation/screens/meetings_list_screen_test.dart"                  = "MeetingsListScreen tests — month-grouped rendering, year/month expand/collapse, expandable search (tap icon → field → filter → clear), no-results EmptyStateWidget (US-021, US-054, US-059)"
    "test/presentation/screens/splash_screen_test.dart"                         = "SplashScreen tests — 'Friendsheet' text rendered, background color #FAFAF7; uses MockVideoPlayerControllerInterface (US-052)"
    "test/presentation/widgets/empty_state_widget_test.dart"                    = "EmptyStateWidget tests — renders image asset, renders message, different messages render correctly (US-054)"
    "test/presentation/widgets/interaction_distribution_widget_test.dart"       = "InteractionDistributionWidget tests — rendering, hidden hint, info icon visibility, toggle label, empty state, isLoading spinner presence/absence (US-030, US-051)"
    "test/presentation/widgets/meeting_date_field_test.dart"                    = "MeetingDateField tests (4 tests)"
    "test/presentation/widgets/meeting_date_field_test.mocks.dart"              = "Generated mocks for MeetingDateField tests"
    "test/presentation/widgets/meeting_name_field_test.dart"                    = "MeetingNameField tests (5 tests)"
    "test/presentation/widgets/meeting_name_field_test.mocks.dart"              = "Generated mocks for MeetingNameField tests"
    "test/presentation/widgets/meeting_weight_stepper_test.dart"                = "MeetingWeightStepper tests (5 tests)"
    "test/presentation/widgets/person_visibility_dialog_test.dart"              = "PersonVisibilityDialog tests — checkbox state, toggle callback, auto-select top 10, three-state toggle icon, alphabetical order with Polish diacritics (Ludwik before Łukasz) (US-030, US-057, US-079)"
    "test/presentation/widgets/shared_search_bar_test.dart"                     = "SharedSearchBar tests — hint text, onChanged callback, clear button visibility and behavior (US-055)"
    "test/presentation/widgets/statistics_section_test.dart"                    = "StatisticsSection tests — PageView present when cards visible, empty state when all hidden, InteractionDistributionWidget always in tree regardless of isDistributionLoading, tapping Icons.tune opens StatisticsVisibilityDialog, long-press restore text never shown (US-051, US-060)"
    "test/presentation/widgets/statistics_section_test.mocks.dart"              = "Generated mocks for StatisticsSection tests"
    "test/presentation/widgets/statistics_visibility_dialog_test.dart"          = "StatisticsVisibilityDialog tests — checkbox per StatCardType, three-state select-all toggle icon states, last-visible card disabled with tooltip, tapping Icons.tune in StatisticsSection header opens dialog (US-060)"
    "test/presentation/widgets/who_per_activity_person_filter_dialog_test.dart" = "WhoPerActivityPersonFilterDialog tests — all persons checked by default, toggle callback, three-state toggle, last-visible disabled, auto-select top 10 present and callable, alphabetical order with Polish diacritics (Ludwik before Łukasz) (US-058, US-079)"
    "test/presentation/widgets/statistics/activity_selector_dialog_test.dart"   = "ActivitySelectorDialog tests — category headers rendered, child activities under correct parent, tap-to-select returns activity, highlight selected, empty state (US-058)"
    "test/presentation/widgets/year_stepper_test.dart"                          = "YearStepper tests — rendering, boundary disabled states, tap callbacks, single-year edge case, dimmed neighbour years visible/hidden (US-027, US-071)"
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
$lines.Add("- assets/images/filter_icon.png - Filter icon asset — replaces gear icon in ActivityBreakdownWidget, InteractionDistributionWidget, and WhoPerActivityWidget header (US-057, US-058)")
$lines.Add("- assets/images/easter_egg_icon.png - Easter egg asset — displayed in EasterEggDialog triggered by 8 taps on AppBar title (US-064)")
$lines.Add("- assets/images/cta_stats.png - Onboarding CTA illustration — displayed in OnboardingCalendarCtaCard on HomeScreen for users with fewer than 50 meetings (US-065)")
$lines.Add("- assets/images/loading_icon.png - Loading screen icon — displayed in HomeLoadingScreen while HomeProvider awaits first stream emission (US-073)")
$lines.Add("- assets/images/drawer_icon.png - Drawer header illustration — displayed in green DrawerHeader area below 'Friendsheet' label (height 80, BoxFit.contain) (US-077)")
$lines.Add("- assets/images/waiting_room.png - Pending Meetings illustration — shown in MeetingInboxScreen empty state (replaces generic Icon) and as decorative last item when list is non-empty (US-077)")

# scripts/migration — static section
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