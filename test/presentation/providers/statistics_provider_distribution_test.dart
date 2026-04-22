// test/presentation/providers/statistics_provider_distribution_test.dart
//
// Tests for StatisticsProvider distribution features:
// loadDistribution(), toggleDistributionMode(), isCumulativeMode,
// setAllPersonsActivityVisibility(), and hiddenCountForActivity.

import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/stats_data_bundle.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';
import 'package:friendsheet/presentation/providers/statistics_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'statistics_provider_test.mocks.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockStatisticsRepository mockRepository;
  late MockAuthService mockAuthService;
  late MockActivityCategoryRepository mockCategoryRepository;
  late MockPersonRepository mockPersonRepository;
  late MockFriendGroupRepository mockFriendGroupRepository;
  late StatisticsProvider provider;

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
    mockFriendGroupRepository = MockFriendGroupRepository();
    provider = StatisticsProvider(
      repository: mockRepository,
      authService: mockAuthService,
      categoryRepository: mockCategoryRepository,
      personRepository: mockPersonRepository,
      friendGroupRepository: mockFriendGroupRepository,
    );
    // Default stubs — return empty data unless overridden per test.
    // ignore: argument_type_not_assignable
    when(mockFriendGroupRepository.getGroupsByUser(any))
        .thenAnswer((_) async => []);
    // ignore: argument_type_not_assignable
    when(mockPersonRepository.getPersonsByUser(any))
        .thenAnswer((_) async => []);
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

  group('StatisticsProvider — distribution', () {
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
        expect(provider.isDistributionLoading, isFalse);
      });

      test('no-op when selectedYear is null', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => []);

        await provider.initialize();
        // _selectedYear is null when no meetings exist.
        await provider.loadDistribution();

        expect(provider.distributionEntries, isEmpty);
        expect(provider.isDistributionLoading, isFalse);
      });
    });

    group('toggleDistributionMode()', () {
      test(
          'flips mode, switches data source, restores on second toggle, '
          'and notifies listeners', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        const yearlyEntry = InteractionDistributionEntry(
          personId: 'p-yearly',
          name: 'Yearly Alice',
          currentYearWeight: 10,
          previousYearWeight: 0,
        );
        const cumulativeEntry = InteractionDistributionEntry(
          personId: 'p-cumulative',
          name: 'Cumulative Bob',
          currentYearWeight: 50,
          previousYearWeight: 0,
        );
        // ignore: argument_type_not_assignable
        when(mockRepository.computeInteractionDistribution(any))
            .thenReturn([yearlyEntry]);
        // ignore: argument_type_not_assignable
        when(mockRepository.getCumulativeInteractions(any, any))
            .thenAnswer((_) async => [cumulativeEntry]);

        await provider.initialize();
        expect(provider.isCumulativeMode, isFalse);
        expect(
          provider.distributionEntries.map((e) => e.personId),
          contains('p-yearly'),
        );

        var notifyCount = 0;
        provider.addListener(() => notifyCount++);

        // Switch to cumulative: mode flips, data replaces, repo called.
        await provider.toggleDistributionMode();
        expect(provider.isCumulativeMode, isTrue);
        expect(
          provider.distributionEntries.map((e) => e.personId),
          contains('p-cumulative'),
        );
        expect(
          provider.distributionEntries.map((e) => e.personId),
          isNot(contains('p-yearly')),
        );
        verify(mockRepository.getCumulativeInteractions(2026, 'user-1'))
            .called(1);
        expect(notifyCount, greaterThan(0));

        // Switch back to yearly: mode flips, bundle-based data restored.
        await provider.toggleDistributionMode();
        expect(provider.isCumulativeMode, isFalse);
        expect(
          provider.distributionEntries.map((e) => e.personId),
          contains('p-yearly'),
        );
        expect(
          provider.distributionEntries.map((e) => e.personId),
          isNot(contains('p-cumulative')),
        );
      });
    });

    group('hiddenCountForActivity', () {
      test('returns correct count of deselected persons in whoPerActivity',
          () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        // ignore: argument_type_not_assignable
        when(mockRepository.computePersonsForActivity(any, any)).thenReturn([
          const PersonActivityEntry(
              personId: 'p-1', name: 'Alice', weightSum: 10),
          const PersonActivityEntry(personId: 'p-2', name: 'Bob', weightSum: 5),
          const PersonActivityEntry(
              personId: 'p-3', name: 'Charlie', weightSum: 3),
        ]);
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
        expect(provider.hiddenCountForActivity, equals(0));

        await provider.toggleSelectedPerson('p-1');
        await provider.toggleSelectedPerson('p-3');
        expect(provider.hiddenCountForActivity, equals(2));
      });
    });

    group('setAllPersonsActivitySelected()', () {
      test(
          'false deselects all (whitelist empty), true selects all, '
          'both persist to SharedPreferences', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        // ignore: argument_type_not_assignable
        when(mockRepository.computePersonsForActivity(any, any)).thenReturn([
          const PersonActivityEntry(
              personId: 'p-1', name: 'Alice', weightSum: 10),
          const PersonActivityEntry(personId: 'p-2', name: 'Bob', weightSum: 5),
        ]);
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

        await provider.setAllPersonsActivitySelected(false);
        expect(provider.selectedPersonsActivity, isEmpty);
        var prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getStringList('stats_selected_persons_activity'),
          isEmpty,
        );

        await provider.setAllPersonsActivitySelected(true);
        expect(
          provider.selectedPersonsActivity,
          containsAll(['p-1', 'p-2']),
        );
        prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getStringList('stats_selected_persons_activity'),
          containsAll(['p-1', 'p-2']),
        );
      });
    });

    group('loadDistribution() after selectYear()', () {
      test('distribution reloaded when year changes', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026, 2025]);
        const entry2026 = InteractionDistributionEntry(
          personId: 'p-2026',
          name: 'Alice',
          currentYearWeight: 10,
          previousYearWeight: 0,
        );
        const entry2025 = InteractionDistributionEntry(
          personId: 'p-2025',
          name: 'Bob',
          currentYearWeight: 7,
          previousYearWeight: 0,
        );
        // ignore: argument_type_not_assignable
        when(mockRepository.computeInteractionDistribution(any))
            .thenReturn([entry2026]);

        await provider.initialize();
        expect(
          provider.distributionEntries.map((e) => e.personId),
          contains('p-2026'),
        );

        // After selectYear(2025), the bundle changes and distribution re-computes.
        // ignore: argument_type_not_assignable
        when(mockRepository.computeInteractionDistribution(any))
            .thenReturn([entry2025]);

        await provider.selectYear(2025);

        expect(
          provider.distributionEntries.map((e) => e.personId),
          contains('p-2025'),
        );
      });

      test('distributionEntries cleared immediately when selectYear called',
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

        // Start selectYear without awaiting — sync code clears entries first.
        final future = provider.selectYear(2025);
        expect(provider.distributionEntries, isEmpty);

        await future;
      });
    });
  });
}
