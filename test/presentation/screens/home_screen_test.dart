import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/data/services/ltns_exclusion_service.dart';
import 'package:friendsheet/presentation/providers/buddy_widget_provider.dart';
import 'package:friendsheet/presentation/providers/home_provider.dart';
import 'package:friendsheet/presentation/providers/statistics_provider.dart';
import 'package:friendsheet/presentation/screens/home_screen.dart';
import 'package:friendsheet/presentation/widgets/build_meeting_base_cta_card.dart';
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
  LtnsExclusionService,
])
void main() {
  late MockStatisticsRepository mockRepository;
  late MockAuthService mockAuthService;
  late MockActivityCategoryRepository mockCategoryRepository;
  late MockPersonRepository mockPersonRepository;
  late MockMeetingRepository mockMeetingRepository;
  late MockLtnsExclusionService mockLtnsExclusionService;
  late StatisticsProvider statisticsProvider;
  late HomeProvider homeProvider;
  late BuddyWidgetProvider buddyWidgetProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockStatisticsRepository();
    mockAuthService = MockAuthService();
    mockCategoryRepository = MockActivityCategoryRepository();
    mockPersonRepository = MockPersonRepository();
    mockMeetingRepository = MockMeetingRepository();
    mockLtnsExclusionService = MockLtnsExclusionService();
    // Default stub: never-completing stream — count stays 0.
    // ignore: argument_type_not_assignable
    when(mockMeetingRepository.getMeetingsByUser(any))
        .thenAnswer((_) => const Stream.empty());
    // Default stub: no meetings without notes found.
    // ignore: argument_type_not_assignable
    when(mockMeetingRepository.getRecentMeetingsWithoutNotes(any, any))
        .thenAnswer((_) async => []);
    // Default stub: no persons — no birthday logic runs.
    // ignore: argument_type_not_assignable
    when(mockPersonRepository.getPersonsByUser(any))
        .thenAnswer((_) async => []);
    // Default stub: no LTNS exclusions (US-118).
    when(mockLtnsExclusionService.getExcludedIds())
        .thenAnswer((_) async => <String>{});
    homeProvider = HomeProvider(meetingRepository: mockMeetingRepository);
    buddyWidgetProvider = BuddyWidgetProvider(
      meetingRepository: mockMeetingRepository,
      personRepository: mockPersonRepository,
      ltnsExclusionService: mockLtnsExclusionService,
    );
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
    buddyWidgetProvider.dispose();
    statisticsProvider.dispose();
    homeProvider.dispose();
  });

  Widget buildHomeScreen() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: buddyWidgetProvider),
          ChangeNotifierProvider.value(value: homeProvider),
          ChangeNotifierProvider.value(value: statisticsProvider),
        ],
        child: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen', () {
    // Emit 50 meetings so shouldShowCta is false and statistics are visible.
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final controller = StreamController<List<Meeting>>();
      when(mockMeetingRepository.getMeetingsByUser(any))
          .thenAnswer((_) => controller.stream);
      await homeProvider.initialize('');
      controller.add(
        List.generate(
          50,
          (i) => Meeting(
            id: 'm$i',
            userId: '',
            name: 'Test',
            date: DateTime(2026),
            weight: 3,
            participantIds: const [],
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ),
      );
      await Future.microtask(() {});
      await controller.close();
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
      // YearStepper has one chevron_left; carousel header adds a second.
      expect(find.byIcon(Icons.chevron_left), findsWidgets);
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
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

  group('HomeScreen — CTA state (<50 meetings)', () {
    // Override setUp: emit 1 meeting so shouldShowCta is true.
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final controller = StreamController<List<Meeting>>();
      when(mockMeetingRepository.getMeetingsByUser(any))
          .thenAnswer((_) => controller.stream);
      await homeProvider.initialize('');
      controller.add([
        Meeting(
          id: 'm1',
          userId: '',
          name: 'Test',
          date: DateTime(2026),
          weight: 3,
          participantIds: const [],
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ]);
      await Future.microtask(() {});
      await controller.close();
    });

    testWidgets('shows BuildMeetingBaseCtaCard when meeting count < 50',
        (tester) async {
      await tester.pumpWidget(buildHomeScreen());
      await tester.pump();

      expect(find.byType(BuildMeetingBaseCtaCard), findsOneWidget);
    });

    testWidgets('CTA card shows both action buttons', (tester) async {
      await tester.pumpWidget(buildHomeScreen());
      await tester.pump();

      expect(find.text('Import from Calendar'), findsOneWidget);
      expect(find.text('Request from a friend'), findsOneWidget);
    });

    testWidgets('CTA card shows title "Build your meeting base"',
        (tester) async {
      await tester.pumpWidget(buildHomeScreen());
      await tester.pump();

      expect(find.text('Build your meeting base'), findsOneWidget);
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
