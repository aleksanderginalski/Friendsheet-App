// test/presentation/providers/statistics_provider_year_test.dart
//
// Tests for StatisticsProvider.initialize(), selectYear(), and available years
// logic. Imports mocks from the parent file's generated mocks.

import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
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
    provider = StatisticsProvider(
      repository: mockRepository,
      authService: mockAuthService,
      categoryRepository: mockCategoryRepository,
      personRepository: mockPersonRepository,
    );
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

  group('StatisticsProvider — year logic', () {
    group('initial state', () {
      // Distribution fields included here to avoid a separate initial state group
      // in statistics_provider_distribution_test.dart.
      test('all defaults', () {
        expect(provider.isLoading, isFalse);
        expect(provider.availableYears, isEmpty);
        expect(provider.selectedYear, isNull);
        expect(provider.hasData, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.activityBreakdown, isEmpty);
        expect(provider.whoPerActivity, isEmpty);
        expect(provider.selectedActivityId, isNull);
        expect(provider.distributionEntries, isEmpty);
        expect(provider.isCumulativeMode, isFalse);
        expect(provider.hiddenPersonsDistribution, isEmpty);
        expect(provider.isDistributionLoading, isFalse);
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

      test('sets errorMessage on repository failure', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenThrow(Exception('Firestore error'));

        await provider.initialize();

        expect(provider.errorMessage, equals('Failed to load statistics'));
        expect(provider.isLoading, isFalse);
      });
    });

    group('selectYear()', () {
      test('updates selectedYear, loads data, and notifies listeners', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026, 2025]);

        await provider.initialize();
        clearInteractions(mockRepository);

        var notified = false;
        provider.addListener(() => notified = true);

        await provider.selectYear(2025);

        expect(provider.selectedYear, equals(2025));
        expect(notified, isTrue);
        verify(mockRepository.loadAllStatsData(2025, 'user-1')).called(1);
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

    group('loadHiddenActivities() — first launch', () {
      List<ActivityBreakdownEntry> makeEntries() => List.generate(
            12,
            (i) => ActivityBreakdownEntry(
              categoryId: 'cat-${12 - i}',
              name: 'Cat ${12 - i}',
              currentYearWeight: 12 - i,
              previousYearWeight: 0,
            ),
          );

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
        SharedPreferences.setMockInitialValues({});
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
        // ignore: argument_type_not_assignable
        when(mockRepository.computeActivityBreakdown(any))
            .thenReturn(makeEntries());
        when(mockRepository.loadAllStatsData(2026, 'user-1')).thenAnswer(
          (_) async => StatsDataBundle(
            currentYearMeetings: const [],
            previousYearMeetings: const [],
            categories: makeCategories(),
            persons: const [],
          ),
        );

        await provider.initialize();

        expect(provider.hiddenActivities, hasLength(2));
        expect(provider.hiddenActivities, containsAll(['cat-1', 'cat-2']));
      });

      test('subsequent launch uses stored hidden set without auto-apply',
          () async {
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
  });
}
