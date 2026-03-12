import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/models/stats_data_bundle.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/providers/statistics_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'statistics_provider_test.mocks.dart';

@GenerateMocks([
  StatisticsRepository,
  AuthService,
  ActivityCategoryRepository,
  PersonRepository,
])
void main() {
  // SharedPreferences requires the Flutter test binding.
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockStatisticsRepository mockRepository;
  late MockAuthService mockAuthService;
  late MockActivityCategoryRepository mockCategoryRepository;
  late MockPersonRepository mockPersonRepository;
  late StatisticsProvider provider;

  // Empty bundle used as default for loadAllStatsData stubs.
  const emptyBundle = StatsDataBundle(
    currentYearMeetings: [],
    previousYearMeetings: [],
    categories: [],
    persons: [],
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockStatisticsRepository();
    mockAuthService = MockAuthService();
    mockCategoryRepository = MockActivityCategoryRepository();
    mockPersonRepository = MockPersonRepository();
    provider = StatisticsProvider(
      repository: mockRepository,
      authService: mockAuthService,
      categoryRepository: mockCategoryRepository,
      personRepository: mockPersonRepository,
    );
    // Default stubs — return empty data unless overridden per test.
    // ignore: argument_type_not_assignable
    when(mockRepository.getAvailableYears(any)).thenAnswer((_) async => []);
    // ignore: argument_type_not_assignable
    when(mockRepository.loadAllStatsData(any, any))
        .thenAnswer((_) async => emptyBundle);
    // ignore: argument_type_not_assignable
    when(mockRepository.computeActivityBreakdown(any)).thenReturn([]);
    // ignore: argument_type_not_assignable
    when(mockRepository.computePersonsForActivity(any, any)).thenReturn([]);
    // ignore: argument_type_not_assignable
    when(mockRepository.computeInteractionDistribution(any)).thenReturn([]);
    // ignore: argument_type_not_assignable
    when(mockRepository.getCumulativeInteractions(any, any))
        .thenAnswer((_) async => []);
    // Backward-compat stubs (called by old-style tests and compat wrappers).
    // ignore: argument_type_not_assignable
    when(mockRepository.getActivityWeightBreakdown(any, any))
        .thenAnswer((_) async => []);
    // ignore: argument_type_not_assignable
    when(mockRepository.getPersonsForActivity(any, any, any))
        .thenAnswer((_) async => []);
    // ignore: argument_type_not_assignable
    when(mockRepository.getInteractionDistribution(any, any))
        .thenAnswer((_) async => []);
    // ignore: argument_type_not_assignable
    when(mockCategoryRepository.getAllCategories(any))
        .thenAnswer((_) async => []);
  });

  tearDown(() {
    provider.dispose();
  });

  group('StatisticsProvider', () {
    group('initial state', () {
      test('isLoading is false', () {
        expect(provider.isLoading, isFalse);
      });

      test('availableYears is empty', () {
        expect(provider.availableYears, isEmpty);
      });

      test('selectedYear is null', () {
        expect(provider.selectedYear, isNull);
      });

      test('hasData is false', () {
        expect(provider.hasData, isFalse);
      });

      test('errorMessage is null', () {
        expect(provider.errorMessage, isNull);
      });

      test('activityBreakdown is empty', () {
        expect(provider.activityBreakdown, isEmpty);
      });

      test('whoPerActivity is empty', () {
        expect(provider.whoPerActivity, isEmpty);
      });

      test('selectedActivityId is null', () {
        expect(provider.selectedActivityId, isNull);
      });
    });

    group('initialize()', () {
      test('sets selectedYear to current year when available', () async {
        final currentYear = DateTime.now().year;
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [currentYear, currentYear - 1]);

        await provider.initialize();

        expect(provider.selectedYear, equals(currentYear));
      });

      test(
          'sets selectedYear to most recent year when current year has no meetings',
          () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        // List sorted descending — first element is most recent.
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2024, 2023]);

        await provider.initialize();

        expect(provider.selectedYear, equals(2024));
      });

      test('sets selectedYear to null when no meetings exist', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => []);

        await provider.initialize();

        expect(provider.selectedYear, isNull);
        expect(provider.hasData, isFalse);
      });

      test('is a no-op when already loading', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        // Use a completer to keep the first call in-flight.
        when(mockRepository.getAvailableYears('user-1')).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return [2026];
        });

        // Start first call without awaiting — it will be in progress.
        final first = provider.initialize();
        // Second call should be a no-op (guard fires).
        await provider.initialize();
        await first;

        // Repository should have been called exactly once.
        verify(mockRepository.getAvailableYears('user-1')).called(1);
      });

      test('sets errorMessage on repository failure', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenThrow(Exception('Firestore error'));

        await provider.initialize();

        expect(provider.errorMessage, equals('Failed to load statistics'));
        expect(provider.isLoading, isFalse);
      });

      test('activityBreakdown populated after initialize with data', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        const entry1 = ActivityBreakdownEntry(
          categoryId: 'cat-a',
          name: 'Running',
          currentYearWeight: 10,
          previousYearWeight: 5,
        );
        const entry2 = ActivityBreakdownEntry(
          categoryId: 'cat-b',
          name: 'Cycling',
          currentYearWeight: 7,
          previousYearWeight: 0,
        );
        // ignore: argument_type_not_assignable
        when(mockRepository.computeActivityBreakdown(any))
            .thenReturn([entry1, entry2]);

        await provider.initialize();

        expect(provider.activityBreakdown, hasLength(2));
        expect(provider.activityBreakdown.first.categoryId, equals('cat-a'));
        expect(provider.activityBreakdown.last.categoryId, equals('cat-b'));
      });

      test('activityBreakdown is empty after initialize with no meetings',
          () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => []);

        await provider.initialize();

        expect(provider.activityBreakdown, isEmpty);
      });

      test('initialize() called twice skips second fetch (idempotency guard)',
          () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);

        await provider.initialize();
        await provider.initialize(); // second call — should be no-op

        // getAvailableYears called only once across both initialize() calls.
        verify(mockRepository.getAvailableYears('user-1')).called(1);
      });

      test('initialize() re-fetches after resetCache()', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);

        await provider.initialize();
        provider.resetCache();
        await provider.initialize();

        // After resetCache() the guard is cleared — fetches twice total.
        verify(mockRepository.getAvailableYears('user-1')).called(2);
      });
    });

    group('selectYear()', () {
      test('updates selectedYear and notifies listeners', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026, 2025]);

        await provider.initialize();

        var notified = false;
        provider.addListener(() => notified = true);

        await provider.selectYear(2025);

        expect(provider.selectedYear, equals(2025));
        expect(notified, isTrue);
      });

      test('selectYear() with same year is a no-op after initialize', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);

        await provider.initialize();

        // reset call count after initialize
        clearInteractions(mockRepository);

        await provider.selectYear(2026); // same as _selectedYear

        // ignore: argument_type_not_assignable
        verifyNever(mockRepository.loadAllStatsData(any, any));
      });

      test('selectYear() with different year triggers fetch', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026, 2025]);

        await provider.initialize();
        clearInteractions(mockRepository);

        await provider.selectYear(2025);

        verify(mockRepository.loadAllStatsData(2025, 'user-1')).called(1);
      });

      test('distributionEntries cleared immediately when selectYear is called',
          () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026, 2025]);
        const entry = InteractionDistributionEntry(
          personId: 'p-1',
          name: 'Alice',
          currentYearWeight: 10,
          previousYearWeight: 0,
        );
        // ignore: argument_type_not_assignable
        when(mockRepository.computeInteractionDistribution(any))
            .thenReturn([entry]);

        await provider.initialize();
        expect(provider.distributionEntries, hasLength(1));

        // Start selectYear without awaiting — synchronous code before the first
        // await already clears _distributionEntries and calls notifyListeners().
        final future = provider.selectYear(2025);
        expect(provider.distributionEntries, isEmpty);

        await future;
      });

      test('activityBreakdown reset on year change to empty year', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026, 2023]);
        const entry = ActivityBreakdownEntry(
          categoryId: 'cat-a',
          name: 'Running',
          currentYearWeight: 5,
          previousYearWeight: 0,
        );
        // 2026 has breakdown data.
        when(mockRepository.loadAllStatsData(2026, 'user-1'))
            .thenAnswer((_) async => emptyBundle);
        // ignore: argument_type_not_assignable
        when(mockRepository.computeActivityBreakdown(any)).thenReturn([entry]);

        await provider.initialize();
        expect(provider.activityBreakdown, hasLength(1));

        // Override stub for selectYear(2023) call — breakdown returns empty.
        // ignore: argument_type_not_assignable
        when(mockRepository.computeActivityBreakdown(any)).thenReturn([]);
        await provider.selectYear(2023);

        expect(provider.activityBreakdown, isEmpty);
      });
    });

    group('selectActivity()', () {
      test('whoPerActivity populated after selectActivity', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        await provider.initialize();

        const entry1 = PersonActivityEntry(
          personId: 'p-1',
          name: 'Alice',
          weightSum: 10,
        );
        const entry2 = PersonActivityEntry(
          personId: 'p-2',
          name: 'Bob',
          weightSum: 7,
        );
        // ignore: argument_type_not_assignable
        when(mockRepository.computePersonsForActivity(any, 'sport'))
            .thenReturn([entry1, entry2]);

        await provider.selectActivity('sport');

        expect(provider.whoPerActivity, hasLength(2));
        expect(provider.whoPerActivity.first.personId, equals('p-1'));
        expect(provider.selectedActivityId, equals('sport'));
      });

      test('selectActivity() uses stored bundle — no Firestore call', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        await provider.initialize();
        clearInteractions(mockRepository);

        await provider.selectActivity('sport');

        // No async repository calls made — bundle reused.
        // ignore: argument_type_not_assignable
        verifyNever(mockRepository.loadAllStatsData(any, any));
        // ignore: argument_type_not_assignable
        verifyNever(mockRepository.getPersonsForActivity(any, any, any));
      });
    });

    group('toggleHiddenActivity()', () {
      test('adds activity to hiddenActivities set', () async {
        expect(provider.hiddenActivities, isEmpty);

        await provider.toggleHiddenActivity('cat-1');

        expect(provider.hiddenActivities, contains('cat-1'));
      });

      test('removes activity from hiddenActivities set when already hidden',
          () async {
        await provider.toggleHiddenActivity('cat-1');
        expect(provider.hiddenActivities, contains('cat-1'));

        await provider.toggleHiddenActivity('cat-1');

        expect(provider.hiddenActivities, isNot(contains('cat-1')));
      });

      test('persists hidden activities to SharedPreferences', () async {
        await provider.toggleHiddenActivity('cat-1');

        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getStringList('stats_hidden_activities_breakdown');
        expect(stored, contains('cat-1'));
      });

      test('loadHiddenActivities restores state on initialize', () async {
        // Pre-populate SharedPreferences before initialize().
        SharedPreferences.setMockInitialValues({
          'stats_hidden_activities_breakdown': ['cat-x', 'cat-y'],
        });
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => []);

        await provider.initialize();

        expect(provider.hiddenActivities, containsAll(['cat-x', 'cat-y']));
      });
    });

    group('loadHiddenActivities() — first launch', () {
      // Helper: 12 entries sorted descending by currentYearWeight.
      // Top 10 by weight: cat-12 … cat-3. Bottom 2: cat-2, cat-1.
      List<ActivityBreakdownEntry> makeEntries() => List.generate(
            12,
            (i) => ActivityBreakdownEntry(
              categoryId: 'cat-${12 - i}',
              name: 'Cat ${12 - i}',
              currentYearWeight: 12 - i,
              previousYearWeight: 0,
            ),
          );

      // Helper: matching categories, all selectable leaves.
      List<ActivityCategory> makeCategories() => List.generate(
            12,
            (i) => ActivityCategory(
              id: 'cat-${i + 1}',
              userId: 'user-1',
              name: 'Cat ${i + 1}',
              iconIdentifier: 'sports_tennis',
              isGlobal: false,
              isSelectableAsActivity: true,
              createdAt: DateTime(2024),
            ),
          );

      test('auto-applies top 10 when SharedPreferences key is absent',
          () async {
        // setMockInitialValues({}) means key is absent → first launch.
        SharedPreferences.setMockInitialValues({});
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        // ignore: argument_type_not_assignable
        when(mockRepository.computeActivityBreakdown(any))
            .thenReturn(makeEntries());
        // Bundle carries categories so provider sets _allCategories.
        when(mockRepository.loadAllStatsData(2026, 'user-1')).thenAnswer(
          (_) async => StatsDataBundle(
            currentYearMeetings: const [],
            previousYearMeetings: const [],
            categories: makeCategories(),
            persons: const [],
          ),
        );

        await provider.initialize();

        // Top 10 = cat-12 … cat-3; the remaining two are hidden.
        expect(provider.hiddenActivities, hasLength(2));
        expect(provider.hiddenActivities, containsAll(['cat-1', 'cat-2']));
      });

      test('subsequent launch uses stored hidden set without auto-apply',
          () async {
        // Key present → stored value used as-is, no top-10 recompute.
        SharedPreferences.setMockInitialValues({
          'stats_hidden_activities_breakdown': ['cat-5', 'cat-6'],
        });
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => []);

        await provider.initialize();

        expect(provider.hiddenActivities, containsAll(['cat-5', 'cat-6']));
        expect(provider.hiddenActivities, hasLength(2));
      });
    });

    group('applyTop10Selection()', () {
      test('replaces hidden set with all except top 10 leaf activities',
          () async {
        // Key present (empty list) to skip first-launch auto-apply.
        SharedPreferences.setMockInitialValues({
          'stats_hidden_activities_breakdown': <String>[],
        });
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);

        final entries = List.generate(
          12,
          (i) => ActivityBreakdownEntry(
            categoryId: 'cat-${12 - i}',
            name: 'Cat ${12 - i}',
            currentYearWeight: 12 - i,
            previousYearWeight: 0,
          ),
        );
        final categories = List.generate(
          12,
          (i) => ActivityCategory(
            id: 'cat-${i + 1}',
            userId: 'user-1',
            name: 'Cat ${i + 1}',
            iconIdentifier: 'sports_tennis',
            isGlobal: false,
            isSelectableAsActivity: true,
            createdAt: DateTime(2024),
          ),
        );
        // ignore: argument_type_not_assignable
        when(mockRepository.computeActivityBreakdown(any)).thenReturn(entries);
        when(mockRepository.loadAllStatsData(2026, 'user-1')).thenAnswer(
          (_) async => StatsDataBundle(
            currentYearMeetings: const [],
            previousYearMeetings: const [],
            categories: categories,
            persons: const [],
          ),
        );

        await provider.initialize();

        // Pollute the hidden set before applying top 10.
        await provider.toggleHiddenActivity('cat-12');
        expect(provider.hiddenActivities, contains('cat-12'));

        await provider.applyTop10Selection();

        // After apply: hidden = cat-2 and cat-1 (bottom 2 by weight).
        expect(provider.hiddenActivities, hasLength(2));
        expect(provider.hiddenActivities, containsAll(['cat-1', 'cat-2']));
        expect(provider.hiddenActivities, isNot(contains('cat-12')));
      });
    });

    group('toggleHiddenPerson()', () {
      test('adds person to hiddenPersonsActivity set', () async {
        expect(provider.hiddenPersonsActivity, isEmpty);

        await provider.toggleHiddenPerson('person-1');

        expect(provider.hiddenPersonsActivity, contains('person-1'));
      });

      test('removes person from hiddenPersonsActivity set when already hidden',
          () async {
        await provider.toggleHiddenPerson('person-1');
        expect(provider.hiddenPersonsActivity, contains('person-1'));

        await provider.toggleHiddenPerson('person-1');

        expect(provider.hiddenPersonsActivity, isNot(contains('person-1')));
      });

      test('persists hidden set to SharedPreferences', () async {
        await provider.toggleHiddenPerson('person-1');

        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getStringList('stats_hidden_persons_activity');
        expect(stored, contains('person-1'));
      });

      test('removes from SharedPreferences when un-hidden', () async {
        await provider.toggleHiddenPerson('person-1');
        await provider.toggleHiddenPerson('person-1');

        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getStringList('stats_hidden_persons_activity');
        expect(stored, isNot(contains('person-1')));
      });
    });

    group('distribution initial state', () {
      test('distributionEntries is empty', () {
        expect(provider.distributionEntries, isEmpty);
      });

      test('isCumulativeMode is false', () {
        expect(provider.isCumulativeMode, isFalse);
      });

      test('hiddenPersonsDistribution is empty', () {
        expect(provider.hiddenPersonsDistribution, isEmpty);
      });

      test('isDistributionLoading is false', () {
        expect(provider.isDistributionLoading, isFalse);
      });
    });

    group('loadDistribution()', () {
      test('populates distributionEntries after initialize with data',
          () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        const entry = InteractionDistributionEntry(
          personId: 'p-1',
          name: 'Alice',
          currentYearWeight: 10,
          previousYearWeight: 5,
        );
        // ignore: argument_type_not_assignable
        when(mockRepository.computeInteractionDistribution(any))
            .thenReturn([entry]);

        await provider.initialize();

        expect(provider.distributionEntries, hasLength(1));
        expect(provider.distributionEntries.first.personId, equals('p-1'));
      });

      test('isDistributionLoading is false after load completes', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);

        await provider.initialize();

        expect(provider.isDistributionLoading, isFalse);
      });

      test('no-op when no year is selected', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => []);

        await provider.initialize();
        // _selectedYear is null when no meetings exist — loadDistribution
        // returns early without touching the repository.
        await provider.loadDistribution();

        expect(provider.distributionEntries, isEmpty);
        expect(provider.isDistributionLoading, isFalse);
      });

      test('calls getCumulativeInteractions when isCumulativeMode is true',
          () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        await provider.initialize();

        await provider.toggleDistributionMode();

        verify(mockRepository.getCumulativeInteractions(2026, 'user-1'))
            .called(1);
      });

      test('loadDistribution() uses bundle — no Firestore call in yearly mode',
          () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        await provider.initialize();
        clearInteractions(mockRepository);

        await provider.loadDistribution();

        // Yearly mode uses stored bundle — no async repo calls.
        // ignore: argument_type_not_assignable
        verifyNever(mockRepository.getInteractionDistribution(any, any));
        // ignore: argument_type_not_assignable
        verifyNever(mockRepository.loadAllStatsData(any, any));
      });
    });

    group('toggleDistributionMode()', () {
      test('flips isCumulativeMode and reloads', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        await provider.initialize();

        expect(provider.isCumulativeMode, isFalse);

        await provider.toggleDistributionMode();

        expect(provider.isCumulativeMode, isTrue);

        await provider.toggleDistributionMode();

        expect(provider.isCumulativeMode, isFalse);
      });
    });

    group('togglePersonDistributionVisibility()', () {
      test('adds person to hiddenPersonsDistribution', () async {
        await provider.togglePersonDistributionVisibility('p-1');

        expect(provider.hiddenPersonsDistribution, contains('p-1'));
      });

      test('removes person when already hidden', () async {
        await provider.togglePersonDistributionVisibility('p-1');
        await provider.togglePersonDistributionVisibility('p-1');

        expect(provider.hiddenPersonsDistribution, isNot(contains('p-1')));
      });

      test('persists to SharedPreferences', () async {
        await provider.togglePersonDistributionVisibility('p-1');

        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getStringList('stats_hidden_persons_distribution');
        expect(stored, contains('p-1'));
      });
    });

    group('loadHiddenPersonsDistribution() — first launch', () {
      test('auto-applies top 10 when SharedPreferences key is absent',
          () async {
        SharedPreferences.setMockInitialValues({});
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        // 12 entries sorted descending — top 10 = p-12 … p-3.
        final entries = List.generate(
          12,
          (i) => InteractionDistributionEntry(
            personId: 'p-${12 - i}',
            name: 'Person ${12 - i}',
            currentYearWeight: 12 - i,
            previousYearWeight: 0,
          ),
        );
        // ignore: argument_type_not_assignable
        when(mockRepository.computeInteractionDistribution(any))
            .thenReturn(entries);

        await provider.initialize();

        // Bottom 2 (p-1, p-2) are hidden.
        expect(provider.hiddenPersonsDistribution, hasLength(2));
        expect(provider.hiddenPersonsDistribution, containsAll(['p-1', 'p-2']));
      });

      test('restores stored hidden set on subsequent launch', () async {
        SharedPreferences.setMockInitialValues({
          'stats_hidden_persons_distribution': ['p-5', 'p-6'],
        });
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => []);

        await provider.initialize();

        expect(provider.hiddenPersonsDistribution, containsAll(['p-5', 'p-6']));
        expect(provider.hiddenPersonsDistribution, hasLength(2));
      });
    });

    group('autoSelectTop10ForActivity()', () {
      test('hides all except top 10 when more than 10 persons exist', () async {
        SharedPreferences.setMockInitialValues({
          'stats_hidden_persons_activity': <String>[],
        });
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        // 12 entries sorted descending — top 10 = p-12 … p-3.
        final entries = List.generate(
          12,
          (i) => PersonActivityEntry(
            personId: 'p-${12 - i}',
            name: 'Person ${12 - i}',
            weightSum: 12 - i,
          ),
        );
        // ignore: argument_type_not_assignable
        when(mockRepository.computePersonsForActivity(any, any))
            .thenReturn(entries);
        // ignore: argument_type_not_assignable
        when(mockRepository.computeActivityBreakdown(any)).thenReturn([
          const ActivityBreakdownEntry(
            categoryId: 'cat-a',
            name: 'Running',
            currentYearWeight: 10,
            previousYearWeight: 0,
          ),
        ]);

        await provider.initialize();
        await provider.selectActivity('cat-a');

        await provider.autoSelectTop10ForActivity();

        // Bottom 2 (p-1, p-2) are hidden; top 10 remain visible.
        expect(provider.hiddenPersonsActivity, hasLength(2));
        expect(provider.hiddenPersonsActivity, containsAll(['p-1', 'p-2']));
        expect(provider.hiddenPersonsActivity, isNot(contains('p-12')));
      });

      test('shows all persons when fewer than 10 exist', () async {
        SharedPreferences.setMockInitialValues({
          'stats_hidden_persons_activity': <String>[],
        });
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        // Only 5 entries — all should remain visible after top-10 auto-select.
        final entries = List.generate(
          5,
          (i) => PersonActivityEntry(
            personId: 'p-${5 - i}',
            name: 'Person ${5 - i}',
            weightSum: 5 - i,
          ),
        );
        // ignore: argument_type_not_assignable
        when(mockRepository.computePersonsForActivity(any, any))
            .thenReturn(entries);
        // ignore: argument_type_not_assignable
        when(mockRepository.computeActivityBreakdown(any)).thenReturn([
          const ActivityBreakdownEntry(
            categoryId: 'cat-a',
            name: 'Running',
            currentYearWeight: 5,
            previousYearWeight: 0,
          ),
        ]);

        await provider.initialize();
        await provider.selectActivity('cat-a');

        // Pre-hide one person to verify the method resets state correctly.
        await provider.toggleHiddenPerson('p-3');
        expect(provider.hiddenPersonsActivity, contains('p-3'));

        await provider.autoSelectTop10ForActivity();

        // Fewer than 10 persons — hidden set is empty (all visible).
        expect(provider.hiddenPersonsActivity, isEmpty);
      });

      test('no-op when whoPerActivity is empty', () async {
        expect(provider.whoPerActivity, isEmpty);

        await provider.autoSelectTop10ForActivity();

        expect(provider.hiddenPersonsActivity, isEmpty);
      });
    });

    group('autoSelectTopPersonsDistribution()', () {
      test('hides all except top 10 by currentYearWeight', () async {
        SharedPreferences.setMockInitialValues({
          'stats_hidden_persons_distribution': <String>[],
        });
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        final entries = List.generate(
          12,
          (i) => InteractionDistributionEntry(
            personId: 'p-${12 - i}',
            name: 'Person ${12 - i}',
            currentYearWeight: 12 - i,
            previousYearWeight: 0,
          ),
        );
        // ignore: argument_type_not_assignable
        when(mockRepository.computeInteractionDistribution(any))
            .thenReturn(entries);

        await provider.initialize();

        // Pollute hidden set.
        await provider.togglePersonDistributionVisibility('p-12');
        expect(provider.hiddenPersonsDistribution, contains('p-12'));

        await provider.autoSelectTopPersonsDistribution();

        expect(provider.hiddenPersonsDistribution, hasLength(2));
        expect(provider.hiddenPersonsDistribution, containsAll(['p-1', 'p-2']));
        expect(provider.hiddenPersonsDistribution, isNot(contains('p-12')));
      });

      test('no-op when distributionEntries is empty', () async {
        expect(provider.distributionEntries, isEmpty);

        await provider.autoSelectTopPersonsDistribution();

        expect(provider.hiddenPersonsDistribution, isEmpty);
      });
    });

    group('setAllActivitiesVisibility()', () {
      test('false hides all activity IDs from activityBreakdown', () async {
        SharedPreferences.setMockInitialValues({
          'stats_hidden_activities_breakdown': <String>[],
        });
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        // ignore: argument_type_not_assignable
        when(mockRepository.computeActivityBreakdown(any)).thenReturn([
          const ActivityBreakdownEntry(
            categoryId: 'cat-a',
            name: 'Running',
            currentYearWeight: 10,
            previousYearWeight: 0,
          ),
          const ActivityBreakdownEntry(
            categoryId: 'cat-b',
            name: 'Cycling',
            currentYearWeight: 5,
            previousYearWeight: 0,
          ),
        ]);

        await provider.initialize();

        final returned = await provider.setAllActivitiesVisibility(false);

        expect(provider.hiddenActivities, containsAll(['cat-a', 'cat-b']));
        expect(provider.hiddenActivities, hasLength(2));
        expect(returned, containsAll(['cat-a', 'cat-b']));
      });

      test('true clears all hidden activities', () async {
        await provider.toggleHiddenActivity('cat-a');
        await provider.toggleHiddenActivity('cat-b');
        expect(provider.hiddenActivities, hasLength(2));

        final returned = await provider.setAllActivitiesVisibility(true);

        expect(provider.hiddenActivities, isEmpty);
        expect(returned, isEmpty);
      });

      test('false persists all IDs to SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({
          'stats_hidden_activities_breakdown': <String>[],
        });
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        // ignore: argument_type_not_assignable
        when(mockRepository.computeActivityBreakdown(any)).thenReturn([
          const ActivityBreakdownEntry(
            categoryId: 'cat-a',
            name: 'Running',
            currentYearWeight: 10,
            previousYearWeight: 0,
          ),
        ]);

        await provider.initialize();
        await provider.setAllActivitiesVisibility(false);

        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getStringList('stats_hidden_activities_breakdown');
        expect(stored, contains('cat-a'));
      });

      test('true persists empty list to SharedPreferences', () async {
        await provider.toggleHiddenActivity('cat-a');
        await provider.setAllActivitiesVisibility(true);

        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getStringList('stats_hidden_activities_breakdown');
        expect(stored, isEmpty);
      });
    });

    group('setAllPersonsVisibility()', () {
      test('false hides all person IDs from distributionEntries', () async {
        SharedPreferences.setMockInitialValues({
          'stats_hidden_persons_distribution': <String>[],
        });
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        // ignore: argument_type_not_assignable
        when(mockRepository.computeInteractionDistribution(any)).thenReturn([
          const InteractionDistributionEntry(
            personId: 'p-1',
            name: 'Alice',
            currentYearWeight: 10,
            previousYearWeight: 0,
          ),
          const InteractionDistributionEntry(
            personId: 'p-2',
            name: 'Bob',
            currentYearWeight: 5,
            previousYearWeight: 0,
          ),
        ]);

        await provider.initialize();

        final returned = await provider.setAllPersonsVisibility(false);

        expect(provider.hiddenPersonsDistribution, containsAll(['p-1', 'p-2']));
        expect(provider.hiddenPersonsDistribution, hasLength(2));
        expect(returned, containsAll(['p-1', 'p-2']));
      });

      test('true clears all hidden persons', () async {
        await provider.togglePersonDistributionVisibility('p-1');
        await provider.togglePersonDistributionVisibility('p-2');
        expect(provider.hiddenPersonsDistribution, hasLength(2));

        final returned = await provider.setAllPersonsVisibility(true);

        expect(provider.hiddenPersonsDistribution, isEmpty);
        expect(returned, isEmpty);
      });

      test('false persists all IDs to SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({
          'stats_hidden_persons_distribution': <String>[],
        });
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        // ignore: argument_type_not_assignable
        when(mockRepository.computeInteractionDistribution(any)).thenReturn([
          const InteractionDistributionEntry(
            personId: 'p-1',
            name: 'Alice',
            currentYearWeight: 10,
            previousYearWeight: 0,
          ),
        ]);

        await provider.initialize();
        await provider.setAllPersonsVisibility(false);

        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getStringList('stats_hidden_persons_distribution');
        expect(stored, contains('p-1'));
      });

      test('true persists empty list to SharedPreferences', () async {
        await provider.togglePersonDistributionVisibility('p-1');
        await provider.setAllPersonsVisibility(true);

        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getStringList('stats_hidden_persons_distribution');
        expect(stored, isEmpty);
      });
    });

    group('carousel state', () {
      group('toggleCardVisibility()', () {
        test('hides a card — visibleCards no longer contains it', () async {
          expect(
            provider.visibleCards,
            contains(StatCardType.activityBreakdown),
          );

          await provider.toggleCardVisibility(StatCardType.activityBreakdown);

          expect(
            provider.visibleCards,
            isNot(contains(StatCardType.activityBreakdown)),
          );
        });

        test('called again — card restored to visibleCards', () async {
          await provider.toggleCardVisibility(StatCardType.activityBreakdown);
          expect(
            provider.visibleCards,
            isNot(contains(StatCardType.activityBreakdown)),
          );

          await provider.toggleCardVisibility(StatCardType.activityBreakdown);

          expect(
            provider.visibleCards,
            contains(StatCardType.activityBreakdown),
          );
        });

        test('allCardsHidden returns true when all three cards hidden',
            () async {
          expect(provider.allCardsHidden, isFalse);

          await provider.toggleCardVisibility(StatCardType.activityBreakdown);
          await provider.toggleCardVisibility(StatCardType.whoPerActivity);
          await provider
              .toggleCardVisibility(StatCardType.interactionDistribution);

          expect(provider.allCardsHidden, isTrue);
        });
      });

      group('restoreAllCards()', () {
        test('visibleCards contains all three cards after restore', () async {
          await provider.toggleCardVisibility(StatCardType.activityBreakdown);
          await provider.toggleCardVisibility(StatCardType.whoPerActivity);
          await provider
              .toggleCardVisibility(StatCardType.interactionDistribution);
          expect(provider.allCardsHidden, isTrue);

          await provider.restoreAllCards();

          expect(provider.visibleCards, containsAll(StatCardType.values));
        });
      });

      group('loadHiddenCards()', () {
        test('reads from SharedPreferences and restores state', () async {
          SharedPreferences.setMockInitialValues({
            'stats_carousel_hidden_cards': [
              'activityBreakdown',
              'whoPerActivity',
            ],
          });

          await provider.loadHiddenCards();

          expect(
            provider.visibleCards,
            isNot(contains(StatCardType.activityBreakdown)),
          );
          expect(
            provider.visibleCards,
            isNot(contains(StatCardType.whoPerActivity)),
          );
          expect(
            provider.visibleCards,
            contains(StatCardType.interactionDistribution),
          );
        });
      });
    });

    group('resetCache()', () {
      test('clears initialized state so next initialize() re-fetches',
          () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);

        await provider.initialize();
        provider.resetCache();
        await provider.initialize();

        verify(mockRepository.getAvailableYears('user-1')).called(2);
      });
    });
  });
}
