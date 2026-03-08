import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/repositories/statistics_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/export_service.dart';
import '../activities/activities_list_provider.dart';
import '../activities/activities_list_screen.dart';
import '../persons/persons_list_provider.dart';
import '../providers/export_provider.dart';
import '../providers/statistics_provider.dart';
import 'add_meeting_screen.dart';
import 'home_screen.dart';
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
  late final PersonsListProvider _personsListProvider;
  late final ActivitiesListProvider _activitiesListProvider;
  late final StatisticsProvider _statisticsProvider;

  @override
  void initState() {
    super.initState();
    _personsListProvider = PersonsListProvider(
      personRepository: PersonRepository(),
      authService: AuthService(),
    )..initialize();
    _activitiesListProvider = ActivitiesListProvider(
      repository: ActivityCategoryRepository(),
    );
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
    _statisticsProvider = StatisticsProvider(
      repository: statisticsRepository,
      authService: AuthService(),
      categoryRepository: activityCategoryRepository,
      personRepository: personRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = AuthService().currentUserId;
      if (userId != null) {
        _activitiesListProvider.initialize(userId);
      }
      _statisticsProvider.initialize();
    });
  }

  @override
  void dispose() {
    _personsListProvider.dispose();
    _activitiesListProvider.dispose();
    _statisticsProvider.dispose();
    super.dispose();
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
        ChangeNotifierProvider.value(value: _personsListProvider),
        ChangeNotifierProvider.value(value: _activitiesListProvider),
        ChangeNotifierProvider.value(value: _statisticsProvider),
      ],
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Friendsheet',
          style: GoogleFonts.pacifico(
            fontSize: 22,
            color: Colors.white,
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
              child: Text(
                'Friendsheet',
                style: GoogleFonts.pacifico(
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => ExportProvider(
                        exportService: ExportService(
                          meetingRepository: MeetingRepository(),
                          personRepository: PersonRepository(),
                          activityCategoryRepository:
                              ActivityCategoryRepository(),
                        ),
                      ),
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
      // IndexedStack keeps all tab widgets alive, preserving scroll state.
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          MeetingsListScreen(),
          PersonsListScreen(),
          ActivitiesListScreen(),
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
            // Re-fetch persons every time the Friends tab becomes active so
            // people added via AddMeetingScreen are visible immediately.
            if (index == 2) _personsListProvider.initialize();
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
