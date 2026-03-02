import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
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
    // Default stubs — return empty lists unless overridden per test.
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
    when(mockRepository.getCumulativeInteractions(any, any))
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
        when(mockRepository.getActivityWeightBreakdown(2026, 'user-1'))
            .thenAnswer((_) async => [entry1, entry2]);

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

      test('activityBreakdown reset on year change to empty year', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026, 2023]);
        // 2026 has breakdown data.
        when(mockRepository.getActivityWeightBreakdown(2026, 'user-1'))
            .thenAnswer((_) async => [
                  const ActivityBreakdownEntry(
                    categoryId: 'cat-a',
                    name: 'Running',
                    currentYearWeight: 5,
                    previousYearWeight: 0,
                  ),
                ]);
        // 2023 has no meetings — breakdown is empty.
        when(mockRepository.getActivityWeightBreakdown(2023, 'user-1'))
            .thenAnswer((_) async => []);

        await provider.initialize();
        expect(provider.activityBreakdown, hasLength(1));

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

        // Simulate a selected year.
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
        when(mockRepository.getPersonsForActivity('sport', 2026, 'user-1'))
            .thenAnswer((_) async => [entry1, entry2]);

        await provider.selectActivity('sport');

        expect(provider.whoPerActivity, hasLength(2));
        expect(provider.whoPerActivity.first.personId, equals('p-1'));
        expect(provider.selectedActivityId, equals('sport'));
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
        when(mockRepository.getActivityWeightBreakdown(2026, 'user-1'))
            .thenAnswer((_) async => makeEntries());
        when(mockCategoryRepository.getAllCategories('user-1'))
            .thenAnswer((_) async => makeCategories());

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
        when(mockRepository.getActivityWeightBreakdown(2026, 'user-1'))
            .thenAnswer((_) async => entries);

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
        when(mockCategoryRepository.getAllCategories('user-1'))
            .thenAnswer((_) async => categories);

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
      test('populates distributionEntries after initialize with data', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        const entry = InteractionDistributionEntry(
          personId: 'p-1',
          name: 'Alice',
          currentYearWeight: 10,
          previousYearWeight: 5,
        );
        when(mockRepository.getInteractionDistribution(2026, 'user-1'))
            .thenAnswer((_) async => [entry]);

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
        final stored =
            prefs.getStringList('stats_hidden_persons_distribution');
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
        when(mockRepository.getInteractionDistribution(2026, 'user-1'))
            .thenAnswer((_) async => entries);

        await provider.initialize();

        // Bottom 2 (p-1, p-2) are hidden.
        expect(provider.hiddenPersonsDistribution, hasLength(2));
        expect(
            provider.hiddenPersonsDistribution, containsAll(['p-1', 'p-2']));
      });

      test('restores stored hidden set on subsequent launch', () async {
        SharedPreferences.setMockInitialValues({
          'stats_hidden_persons_distribution': ['p-5', 'p-6'],
        });
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => []);

        await provider.initialize();

        expect(
            provider.hiddenPersonsDistribution, containsAll(['p-5', 'p-6']));
        expect(provider.hiddenPersonsDistribution, hasLength(2));
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
        when(mockRepository.getInteractionDistribution(2026, 'user-1'))
            .thenAnswer((_) async => entries);

        await provider.initialize();

        // Pollute hidden set.
        await provider.togglePersonDistributionVisibility('p-12');
        expect(provider.hiddenPersonsDistribution, contains('p-12'));

        await provider.autoSelectTopPersonsDistribution();

        expect(provider.hiddenPersonsDistribution, hasLength(2));
        expect(
            provider.hiddenPersonsDistribution, containsAll(['p-1', 'p-2']));
        expect(
            provider.hiddenPersonsDistribution, isNot(contains('p-12')));
      });

      test('no-op when distributionEntries is empty', () async {
        expect(provider.distributionEntries, isEmpty);

        await provider.autoSelectTopPersonsDistribution();

        expect(provider.hiddenPersonsDistribution, isEmpty);
      });
    });
  });
}
