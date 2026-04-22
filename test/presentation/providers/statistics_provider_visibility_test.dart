// test/presentation/providers/statistics_provider_visibility_test.dart
//
// Tests for StatisticsProvider hidden activities, selected persons (whitelist),
// auto-select top 10, and StatisticsVisibilityDialog state (carousel card visibility).

import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/models/person.dart';
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
    // ignore: argument_type_not_assignable
    when(mockFriendGroupRepository.getGroupsByUser(any))
        .thenAnswer((_) async => []);
    // ignore: argument_type_not_assignable
    when(mockPersonRepository.getPersonsByUser(any))
        .thenAnswer((_) async => []);
  });

  tearDown(() {
    provider.dispose();
  });

  group('StatisticsProvider — visibility', () {
    group('toggleHiddenActivity()', () {
      test('adds, removes, and persists to SharedPreferences', () async {
        await provider.toggleHiddenActivity('cat-1');
        expect(provider.hiddenActivities, contains('cat-1'));

        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getStringList('stats_hidden_activities_breakdown'),
          contains('cat-1'),
        );

        await provider.toggleHiddenActivity('cat-1');
        expect(provider.hiddenActivities, isNot(contains('cat-1')));
      });
    });

    group('applyTop10Selection()', () {
      test('replaces hidden set with all except top 10 leaf activities',
          () async {
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
        await provider.toggleHiddenActivity('cat-12');
        expect(provider.hiddenActivities, contains('cat-12'));

        await provider.applyTop10Selection();

        expect(provider.hiddenActivities, hasLength(2));
        expect(provider.hiddenActivities, containsAll(['cat-1', 'cat-2']));
        expect(provider.hiddenActivities, isNot(contains('cat-12')));
      });
    });

    group('toggleSelectedPerson()', () {
      test('adds to and removes from whitelist, persists to SharedPreferences',
          () async {
        await provider.toggleSelectedPerson('person-1');
        expect(provider.selectedPersonsActivity, contains('person-1'));

        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getStringList('stats_selected_persons_activity'),
          contains('person-1'),
        );

        await provider.toggleSelectedPerson('person-1');
        expect(
          provider.selectedPersonsActivity,
          isNot(contains('person-1')),
        );
      });
    });

    group('toggleSelectedPersonDistribution()', () {
      test('adds to and removes from whitelist, persists to SharedPreferences',
          () async {
        await provider.toggleSelectedPersonDistribution('p-1');
        expect(provider.selectedPersonsDistribution, contains('p-1'));

        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getStringList('stats_selected_persons_distribution'),
          contains('p-1'),
        );

        await provider.toggleSelectedPersonDistribution('p-1');
        expect(
          provider.selectedPersonsDistribution,
          isNot(contains('p-1')),
        );
      });
    });

    group('loadSelectedPersonsDistribution() — first launch', () {
      test('seeds whitelist with all persons when SharedPreferences key absent',
          () async {
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

        expect(provider.selectedPersonsDistribution, hasLength(12));
      });

      test('restores stored whitelist on subsequent launch', () async {
        SharedPreferences.setMockInitialValues({
          'stats_selected_persons_distribution': ['p-5', 'p-6'],
        });
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => []);

        await provider.initialize();

        expect(
          provider.selectedPersonsDistribution,
          containsAll(['p-5', 'p-6']),
        );
        expect(provider.selectedPersonsDistribution, hasLength(2));
      });
    });

    group('autoSelectTop10ForActivity()', () {
      test('whitelist set to top 10 persons when more than 10 exist', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => [2026]);
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

        expect(provider.selectedPersonsActivity, hasLength(10));
        expect(provider.selectedPersonsActivity, isNot(contains('p-1')));
        expect(provider.selectedPersonsActivity, isNot(contains('p-2')));
        expect(provider.selectedPersonsActivity, contains('p-12'));
      });
    });

    group('autoSelectTopPersonsDistribution()', () {
      test('whitelist set to top 10 persons by currentYearWeight', () async {
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

        // Deselect one person from the full whitelist then re-apply top 10.
        await provider.toggleSelectedPersonDistribution('p-12');
        expect(
          provider.selectedPersonsDistribution,
          isNot(contains('p-12')),
        );

        await provider.autoSelectTopPersonsDistribution();

        expect(provider.selectedPersonsDistribution, hasLength(10));
        expect(provider.selectedPersonsDistribution, isNot(contains('p-1')));
        expect(provider.selectedPersonsDistribution, isNot(contains('p-2')));
        expect(provider.selectedPersonsDistribution, contains('p-12'));
      });
    });

    group('setAllActivitiesVisibility()', () {
      test('false hides all, true shows all, both persist to SharedPreferences',
          () async {
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
        expect(returned, containsAll(['cat-a', 'cat-b']));
        var prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getStringList('stats_hidden_activities_breakdown'),
          containsAll(['cat-a', 'cat-b']),
        );

        final returned2 = await provider.setAllActivitiesVisibility(true);
        expect(provider.hiddenActivities, isEmpty);
        expect(returned2, isEmpty);
        prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getStringList('stats_hidden_activities_breakdown'),
          isEmpty,
        );
      });
    });

    group('setAllPersonsDistributionSelected()', () {
      test(
          'false deselects all (whitelist empty), true selects all, '
          'both persist to SharedPreferences', () async {
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

        await provider.setAllPersonsDistributionSelected(false);
        expect(provider.selectedPersonsDistribution, isEmpty);
        var prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getStringList('stats_selected_persons_distribution'),
          isEmpty,
        );

        await provider.setAllPersonsDistributionSelected(true);
        expect(
          provider.selectedPersonsDistribution,
          containsAll(['p-1', 'p-2']),
        );
        prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getStringList('stats_selected_persons_distribution'),
          containsAll(['p-1', 'p-2']),
        );
      });
    });

    group('carousel state', () {
      test(
          'toggle hides and restores card; all hidden sets allCardsHidden; '
          'restoreAllCards clears', () async {
        expect(provider.visibleCards, contains(StatCardType.activityBreakdown));

        await provider.toggleCardVisibility(StatCardType.activityBreakdown);
        expect(
          provider.visibleCards,
          isNot(contains(StatCardType.activityBreakdown)),
        );

        await provider.toggleCardVisibility(StatCardType.activityBreakdown);
        expect(provider.visibleCards, contains(StatCardType.activityBreakdown));

        await provider.toggleCardVisibility(StatCardType.activityBreakdown);
        await provider.toggleCardVisibility(StatCardType.whoPerActivity);
        await provider
            .toggleCardVisibility(StatCardType.interactionDistribution);
        expect(provider.allCardsHidden, isTrue);

        await provider.restoreAllCards();
        expect(provider.visibleCards, containsAll(StatCardType.values));
      });

      test('loadHiddenCards reads from SharedPreferences and restores state',
          () async {
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

    group('allPersons', () {
      test('initialize() populates allPersons from PersonRepository', () async {
        when(mockAuthService.currentUserId).thenReturn('user-1');
        when(mockRepository.getAvailableYears('user-1'))
            .thenAnswer((_) async => []);
        final persons = [
          Person(
            id: 'p-1',
            userId: 'user-1',
            firstName: 'Alice',
            createdAt: DateTime(2024),
          ),
          Person(
            id: 'p-2',
            userId: 'user-1',
            firstName: 'Bob',
            createdAt: DateTime(2024),
          ),
        ];
        when(mockPersonRepository.getPersonsByUser('user-1'))
            .thenAnswer((_) async => persons);

        await provider.initialize();

        expect(provider.allPersons, hasLength(2));
        expect(
          provider.allPersons.map((p) => p.id),
          containsAll(['p-1', 'p-2']),
        );
      });
    });
  });
}
