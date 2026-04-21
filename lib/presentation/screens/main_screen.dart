import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../data/models/google_calendar.dart';
import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/ai_key_repository.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/pending_meeting_package_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/repositories/statistics_repository.dart';
import '../../data/services/account_deletion_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/export_service.dart';
import '../../data/services/google_calendar_service.dart';
import '../../data/services/local_cache_service.dart';
import '../../main.dart' show appNavigatorKey;
import '../activities/activities_list_provider.dart';
import '../activities/activities_list_screen.dart';
import '../friends_quest/friends_quest_list_screen.dart';
import '../friends_quest/friends_quest_provider.dart';
import '../import/meeting_inbox_screen.dart';
import '../persons/friend_groups_provider.dart';
import '../persons/persons_list_provider.dart';
import '../providers/ai_settings_provider.dart';
import '../providers/buddy_widget_provider.dart';
import '../providers/calendar_settings_provider.dart';
import '../providers/delete_account_provider.dart';
import '../providers/export_provider.dart';
import '../providers/home_provider.dart';
import '../providers/meeting_inbox_provider.dart';
import '../providers/shared_package_inbox_provider.dart';
import '../providers/statistics_provider.dart';
import '../sharing/generate_sharing_token_screen.dart';
import '../widgets/easter_egg_dialog.dart';
import '../widgets/offline_banner_widget.dart';
import 'add_meeting_screen.dart';
import 'ai_settings_screen.dart';
import 'buddy_menu_screen.dart';
import 'calendar_events_screen.dart';
import 'calendar_permission_screen.dart';
import 'home_screen.dart';
import 'ltns_filter_screen.dart';
import 'meetings_list_screen.dart';
import 'persons_list_screen.dart';
import 'settings_screen.dart';

/// Main screen with bottom navigation, hosting all top-level tabs.
class MainScreen extends StatefulWidget {
  final AuthService authService;

  const MainScreen({super.key, required this.authService});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _titleTapCount = 0;
  Timer? _titleTapTimer;
  late final BuddyWidgetProvider _buddyWidgetProvider;
  late final HomeProvider _homeProvider;
  late final PersonsListProvider _personsListProvider;
  late final FriendGroupsProvider _friendGroupsProvider;
  late final ActivitiesListProvider _activitiesListProvider;
  late final StatisticsProvider _statisticsProvider;
  late final CalendarSettingsProvider _calendarSettingsProvider;
  late final MeetingInboxProvider _meetingInboxProvider;
  late final SharedPackageInboxProvider _sharedPackageInboxProvider;
  late final FriendsQuestProvider _friendsQuestProvider;

  @override
  void initState() {
    super.initState();
    _buddyWidgetProvider =
        BuddyWidgetProvider(meetingRepository: MeetingRepository());
    _homeProvider = HomeProvider(meetingRepository: MeetingRepository());
    _personsListProvider = PersonsListProvider(
      personRepository: PersonRepository(),
      authService: AuthService(),
    )..initialize();
    _friendGroupsProvider = FriendGroupsProvider();
    final activityCategoryRepository = ActivityCategoryRepository();
    final meetingRepository = MeetingRepository();
    final personRepository = PersonRepository(
      meetingRepository: meetingRepository,
    );
    final statisticsRepository = StatisticsRepository(
      categoryRepository: activityCategoryRepository,
      personRepository: personRepository,
    );
    // Wire invalidator so write operations clear statistics caches.
    meetingRepository.cacheInvalidator = statisticsRepository;
    personRepository.cacheInvalidator = statisticsRepository;
    activityCategoryRepository.cacheInvalidator = statisticsRepository;
    _activitiesListProvider = ActivitiesListProvider(
      repository: activityCategoryRepository,
      meetingRepository: meetingRepository,
    );
    _statisticsProvider = StatisticsProvider(
      repository: statisticsRepository,
      authService: AuthService(),
      categoryRepository: activityCategoryRepository,
      personRepository: personRepository,
    );
    _calendarSettingsProvider = CalendarSettingsProvider(
      calendarService: GoogleCalendarService(),
    );
    _meetingInboxProvider = MeetingInboxProvider();
    _friendsQuestProvider = FriendsQuestProvider();
    _sharedPackageInboxProvider = SharedPackageInboxProvider(
      packageRepository: PendingMeetingPackageRepository(),
      meetingRepository: meetingRepository,
      personRepository: personRepository,
      categoryRepository: activityCategoryRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initialize connectivity monitoring before any other providers.
      await ConnectivityService().initialize();
      // Ensure calendar token is loaded before drawer renders.
      await GoogleCalendarService().ensureInitialized();

      final userId = AuthService().currentUserId;
      if (userId != null) {
        // Fire-and-forget — do not await; UI must not block on cache warm-up.
        unawaited(LocalCacheService().syncFromFirestore(userId));
        _homeProvider.initialize(userId);
        _buddyWidgetProvider.initialize(userId);
        _activitiesListProvider.initialize(userId);
        _sharedPackageInboxProvider.initialize(userId);
        _friendsQuestProvider.loadQuests(userId);
      }
      _friendGroupsProvider.loadGroups();
      _statisticsProvider.initialize();
      _calendarSettingsProvider.initialize();
      _meetingInboxProvider.loadFromPrefs();
    });
  }

  void _handleTitleTap() {
    _titleTapTimer?.cancel();
    _titleTapCount++;

    if (_titleTapCount >= 7) {
      _titleTapCount = 0;
      _showEasterEgg();
      return;
    }

    _titleTapTimer = Timer(const Duration(seconds: 4), () {
      _titleTapCount = 0;
    });
  }

  void _showEasterEgg() {
    showDialog(
      context: context,
      builder: (_) => const EasterEggDialog(),
    );
  }

  @override
  void dispose() {
    _titleTapTimer?.cancel();
    _buddyWidgetProvider.dispose();
    _homeProvider.dispose();
    _personsListProvider.dispose();
    _friendGroupsProvider.dispose();
    _activitiesListProvider.dispose();
    _statisticsProvider.dispose();
    _calendarSettingsProvider.dispose();
    _meetingInboxProvider.dispose();
    _sharedPackageInboxProvider.dispose();
    _friendsQuestProvider.dispose();
    super.dispose();
  }

  void _openFriendsQuestList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _friendsQuestProvider,
          child: const FriendsQuestListScreen(),
        ),
      ),
    ).then((_) {
      final userId = AuthService().currentUserId;
      if (userId != null && mounted) {
        _friendsQuestProvider.loadQuests(userId);
      }
    });
  }

  /// Opens BuddyMenuScreen — single entry point for all Buddy features.
  void _openBuddyMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuddyMenuScreen(
          onAIAssistantTap: _openBuddyGreeting,
          onAPIKeyTap: _openAISettings,
          onLtnsFiltersTap: _openLtnsFilters,
        ),
      ),
    );
  }

  /// Opens LtnsFilterScreen — lets user choose who appears in LTNS reminders.
  /// Re-initializes BuddyWidgetProvider on return so the filter is applied
  /// immediately without requiring an app restart.
  void _openLtnsFilters() {
    final userId = AuthService().currentUserId;
    if (userId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LtnsFilterScreen(userId: userId),
      ),
    ).then((_) {
      if (!mounted) return;
      _buddyWidgetProvider.initialize(userId);
    });
  }

  /// Opens AIChatScreen in greeting mode via the Buddy drawer entry.
  /// Uses State context (always alive) — avoids stale-context bug from drawer closures.
  void _openBuddyGreeting() {
    openAIChatGreeting(context, _buddyWidgetProvider);
  }

  /// Opens AISettingsScreen for managing the OpenAI API key.
  void _openAISettings() {
    final keyRepo = AIKeyRepository();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => AISettingsProvider(repository: keyRepo),
          child: const AISettingsScreen(),
        ),
      ),
    );
  }

  /// Navigates to GenerateSharingTokenScreen using the State's own context.
  void _openSharingTokenScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GenerateSharingTokenScreen(),
      ),
    );
  }

  /// Navigates to CalendarPermissionScreen via the global navigator key.
  /// Using the navigator key avoids stale-context bugs — the key is independent
  /// of any widget's lifecycle, so navigation always reaches its destination.
  void _openCalendarPermissionScreen() {
    appNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _calendarSettingsProvider,
          child: CalendarPermissionScreen(
            onConnected: (calendars) {
              appNavigatorKey.currentState?.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: _meetingInboxProvider,
                    child: CalendarEventsScreen(
                      calendars: calendars,
                      onReconnect: _openCalendarPermissionScreen,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Navigates to MeetingInboxScreen using the State's own context.
  /// This avoids the stale-context bug when using the drawer's BuildContext
  /// after Navigator.pop() has deactivated it.
  void _openPendingMeetings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/meeting_inbox'),
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _meetingInboxProvider),
            ChangeNotifierProvider.value(value: _sharedPackageInboxProvider),
          ],
          child: const MeetingInboxScreen(),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text(
          'Are you sure you want to log out?\n\n'
          'You\'ll need to sign in again to access your meetings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('LOG OUT'),
          ),
        ],
      ),
    );

    // AuthWrapper stream automatically navigates to LoginScreen after sign-out.
    if (confirmed == true && context.mounted) {
      try {
        await widget.authService.signOut();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to log out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _buddyWidgetProvider),
        ChangeNotifierProvider.value(value: _homeProvider),
        ChangeNotifierProvider.value(value: _personsListProvider),
        ChangeNotifierProvider.value(value: _friendGroupsProvider),
        ChangeNotifierProvider.value(value: _activitiesListProvider),
        ChangeNotifierProvider.value(value: _statisticsProvider),
        ChangeNotifierProvider.value(value: _calendarSettingsProvider),
        ChangeNotifierProvider.value(value: _meetingInboxProvider),
        ChangeNotifierProvider.value(value: _sharedPackageInboxProvider),
        ChangeNotifierProvider.value(value: _friendsQuestProvider),
      ],
      child: _buildScaffold(context),
    );
  }

  // IndexedStack keeps all tab widgets alive, preserving scroll state.
  Widget _buildBody() {
    return IndexedStack(
      index: _currentIndex,
      children: const [
        HomeScreen(),
        MeetingsListScreen(),
        PersonsListScreen(),
        ActivitiesListScreen(),
      ],
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _handleTitleTap,
          child: Text(
            'Friendsheet',
            style: GoogleFonts.pacifico(
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF4CAF50)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Friendsheet',
                    style: GoogleFonts.pacifico(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                  Flexible(
                    child: Image.asset(
                      'assets/images/drawer_icon.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            // Import & Share section header — tools for building the meeting base
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Import & Share',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share meetings with a friend'),
              onTap: () {
                Navigator.pop(context);
                _openSharingTokenScreen();
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: GoogleCalendarService().isConnectedNotifier,
              builder: (context, isConnected, _) {
                return ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text(
                    isConnected
                        ? 'Browse & Import Events'
                        : 'Import from Calendar',
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    if (!ConnectivityService().isOnline) {
                      ScaffoldMessenger.of(appNavigatorKey.currentContext!)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Google Calendar requires an internet connection',
                          ),
                        ),
                      );
                      return;
                    }
                    final calendarService = GoogleCalendarService();

                    if (isConnected) {
                      // Capture messenger before the await so no BuildContext
                      // is used across an async gap.
                      final messenger = appNavigatorKey.currentContext != null
                          ? ScaffoldMessenger.maybeOf(
                              appNavigatorKey.currentContext!,
                            )
                          : null;
                      try {
                        final calendars =
                            await calendarService.fetchCalendars();
                        appNavigatorKey.currentState?.push(
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: _meetingInboxProvider,
                              child: CalendarEventsScreen(
                                calendars: calendars,
                                onReconnect: _openCalendarPermissionScreen,
                              ),
                            ),
                          ),
                        );
                      } on CalendarAuthException {
                        messenger?.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Calendar access expired — please reconnect',
                            ),
                          ),
                        );
                      } catch (e) {
                        messenger?.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Could not load calendars. Check your connection.',
                            ),
                          ),
                        );
                      }
                    } else {
                      _openCalendarPermissionScreen();
                    }
                  },
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.smart_toy_outlined),
              title: const Text('Buddy'),
              onTap: () {
                Navigator.pop(context);
                if (!ConnectivityService().isOnline) {
                  ScaffoldMessenger.of(appNavigatorKey.currentContext!)
                      .showSnackBar(
                    const SnackBar(
                      content: Text('Buddy requires an internet connection'),
                    ),
                  );
                  return;
                }
                _openBuddyMenu();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.checklist_rtl),
              title: const Text('Friends-Quest'),
              onTap: () {
                Navigator.pop(context);
                _openFriendsQuestList();
              },
            ),
            const Divider(),
            // Pending Meetings tile — shown when calendar candidates or shared packages exist.
            Consumer2<MeetingInboxProvider, SharedPackageInboxProvider>(
              builder: (context, inboxProvider, packageProvider, _) {
                final totalCount = inboxProvider.candidates.length +
                    packageProvider.packages.length;
                if (totalCount == 0) return const SizedBox.shrink();
                return ListTile(
                  leading: const Icon(Icons.inbox),
                  title: Text('Pending Meetings ($totalCount)'),
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    _openPendingMeetings();
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                          create: (_) => ExportProvider(
                            exportService: ExportService(
                              meetingRepository: MeetingRepository(),
                              personRepository: PersonRepository(),
                              activityCategoryRepository:
                                  ActivityCategoryRepository(),
                            ),
                          ),
                        ),
                        ChangeNotifierProvider.value(
                          value: _calendarSettingsProvider,
                        ),
                        ChangeNotifierProvider(
                          create: (_) => DeleteAccountProvider(
                            deletionService: AccountDeletionService(
                              firebaseAuth: FirebaseAuth.instance,
                              firestore: FirebaseFirestore.instance,
                              googleSignIn: GoogleSignIn(),
                              calendarService: GoogleCalendarService(),
                            ),
                          ),
                        ),
                      ],
                      child: const SettingsScreen(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () {
                Navigator.pop(context);
                _handleLogout(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const OfflineBannerWidget(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddMeetingScreen()),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF4CAF50),
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            // Re-fetch statistics every time the Home tab becomes active.
            if (index == 0) _statisticsProvider.initialize();
            // Re-fetch persons and groups every time the Friends tab becomes
            // active so changes from other screens are reflected immediately.
            if (index == 2) {
              _personsListProvider.initialize();
              _friendGroupsProvider.loadGroups();
            }
            // Re-fetch categories every time the Activities tab becomes active.
            if (index == 3) {
              final userId = AuthService().currentUserId;
              if (userId != null) _activitiesListProvider.initialize(userId);
            }
            setState(() => _currentIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Meetings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Friends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_tennis),
              label: 'Activities',
            ),
          ],
        ),
      ),
    );
  }
}
