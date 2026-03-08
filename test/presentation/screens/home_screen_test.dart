import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/providers/home_provider.dart';
import 'package:friendsheet/presentation/providers/statistics_provider.dart';
import 'package:friendsheet/presentation/screens/home_screen.dart';
import 'package:friendsheet/presentation/widgets/easter_egg_dialog.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen_test.mocks.dart';

// ---------------------------------------------------------------------------
// Helper widget that replicates the easter egg tap logic from MainScreen,
// allowing timer-based tests without requiring a full Firebase-connected
// MainScreen to be instantiated.
// ---------------------------------------------------------------------------
class _EasterEggTrigger extends StatefulWidget {
  const _EasterEggTrigger();

  @override
  State<_EasterEggTrigger> createState() => _EasterEggTriggerState();
}

class _EasterEggTriggerState extends State<_EasterEggTrigger> {
  int tapCount = 0;
  Timer? timer;

  void handleTap() {
    timer?.cancel();
    tapCount++;

    if (tapCount >= 8) {
      tapCount = 0;
      showDialog(
        context: context,
        builder: (_) => const EasterEggDialog(imageWidget: _stubImage),
      );
      return;
    }

    timer = Timer(const Duration(seconds: 4), () {
      tapCount = 0;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handleTap,
      child: const Text('Friendsheet', key: Key('easter_egg_title')),
    );
  }
}

// Stub image widget passed to EasterEggDialog in tests to avoid loading assets.
const Widget _stubImage = SizedBox(key: Key('stub_image'), height: 120);

@GenerateMocks([
  StatisticsRepository,
  AuthService,
  ActivityCategoryRepository,
  PersonRepository,
  MeetingRepository,
])
void main() {
  late MockStatisticsRepository mockRepository;
  late MockAuthService mockAuthService;
  late MockActivityCategoryRepository mockCategoryRepository;
  late MockPersonRepository mockPersonRepository;
  late MockMeetingRepository mockMeetingRepository;
  late StatisticsProvider statisticsProvider;
  late HomeProvider homeProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockStatisticsRepository();
    mockAuthService = MockAuthService();
    mockCategoryRepository = MockActivityCategoryRepository();
    mockPersonRepository = MockPersonRepository();
    mockMeetingRepository = MockMeetingRepository();
    // Default stub: never-completing stream — count stays 0.
    // ignore: argument_type_not_assignable
    when(mockMeetingRepository.getMeetingsByUser(any))
        .thenAnswer((_) => const Stream.empty());
    homeProvider = HomeProvider(meetingRepository: mockMeetingRepository);
    statisticsProvider = StatisticsProvider(
      repository: mockRepository,
      authService: mockAuthService,
      categoryRepository: mockCategoryRepository,
      personRepository: mockPersonRepository,
    );
    // Default stubs: return empty lists unless overridden per test.
    // ignore: argument_type_not_assignable
    when(mockRepository.getActivityWeightBreakdown(any, any))
        .thenAnswer((_) async => []);
    // ignore: argument_type_not_assignable
    when(mockRepository.getPersonsForActivity(any, any, any))
        .thenAnswer((_) async => []);
    // ignore: argument_type_not_assignable
    when(mockCategoryRepository.getAllCategories(any))
        .thenAnswer((_) async => []);
  });

  tearDown(() {
    statisticsProvider.dispose();
    homeProvider.dispose();
  });

  Widget buildHomeScreen() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: homeProvider),
          ChangeNotifierProvider.value(value: statisticsProvider),
        ],
        child: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen', () {
    // Dismiss the CTA so statistics are shown in these tests.
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'onboarding_calendar_cta_dismissed': true,
      });
      await homeProvider.initialize('');
    });
    testWidgets('shows loading indicator while statistics are loading',
        (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      // Completer keeps the future in-flight with no pending timers.
      final completer = Completer<List<int>>();
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) => completer.future);

      // Start loading without awaiting — provider is now mid-fetch.
      statisticsProvider.initialize();

      await tester.pumpWidget(buildHomeScreen());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete so the provider finishes cleanly before tearDown.
      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows "No meetings found" when no years are available',
        (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) async => []);

      await statisticsProvider.initialize();
      await tester.pumpWidget(buildHomeScreen());

      expect(find.text('No meetings found'), findsOneWidget);
    });

    testWidgets('shows YearStepper with selected year when years are available',
        (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      // selectedYear will be 2026 (current year) since it is in the list.
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) async => [2026, 2025]);

      await statisticsProvider.initialize();
      await tester.pumpWidget(buildHomeScreen());

      // Only the selected year is displayed as text in YearStepper.
      expect(find.text('2026'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows "Statistics" section header', (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) async => [2026]);

      await statisticsProvider.initialize();
      await tester.pumpWidget(buildHomeScreen());

      expect(find.text('Statistics'), findsOneWidget);
    });
  });

  group('EasterEgg — tap counter and dialog', () {
    Widget buildTrigger() {
      return const MaterialApp(home: Scaffold(body: _EasterEggTrigger()));
    }

    testWidgets('tap counter resets after 4 seconds', (tester) async {
      await tester.pumpWidget(buildTrigger());
      final trigger = find.byKey(const Key('easter_egg_title'));

      // Tap 3 times — counter should be 3.
      for (var i = 0; i < 3; i++) {
        await tester.tap(trigger);
      }
      await tester.pump();

      final state = tester.state<_EasterEggTriggerState>(
        find.byType(_EasterEggTrigger),
      );
      expect(state.tapCount, 3);

      // Advance clock past 4 seconds — timer fires and resets counter.
      await tester.pump(const Duration(seconds: 5));
      expect(state.tapCount, 0);

      // One more tap — counter should be 1, not 4.
      await tester.tap(trigger);
      await tester.pump();
      expect(state.tapCount, 1);
    });

    testWidgets('dialog appears after 8 rapid taps', (tester) async {
      await tester.pumpWidget(buildTrigger());
      final trigger = find.byKey(const Key('easter_egg_title'));

      for (var i = 0; i < 8; i++) {
        await tester.tap(trigger);
      }
      // One frame is enough to show the dialog; pumpAndSettle would trigger
      // asset loading and fail because image assets are not available in tests.
      await tester.pump();

      expect(find.byType(EasterEggDialog), findsOneWidget);
      expect(
        find.text(
          'Special thanks to Agatka who came up with the name for this app 💚',
        ),
        findsOneWidget,
      );
    });

    testWidgets('dialog dismisses when tapped', (tester) async {
      await tester.pumpWidget(buildTrigger());
      final trigger = find.byKey(const Key('easter_egg_title'));

      for (var i = 0; i < 8; i++) {
        await tester.tap(trigger);
      }
      await tester.pump();

      expect(find.byType(EasterEggDialog), findsOneWidget);

      // Tap the dialog to dismiss it.
      await tester.tap(find.byType(EasterEggDialog));
      await tester.pump();

      expect(find.byType(EasterEggDialog), findsNothing);
    });
  });
}
