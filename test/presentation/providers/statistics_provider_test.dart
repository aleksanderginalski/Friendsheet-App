import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/providers/statistics_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'statistics_provider_test.mocks.dart';

@GenerateMocks([StatisticsRepository, AuthService, ActivityCategoryRepository])
void main() {
  late MockStatisticsRepository mockRepository;
  late MockAuthService mockAuthService;
  late MockActivityCategoryRepository mockCategoryRepository;
  late StatisticsProvider provider;

  setUp(() {
    mockRepository = MockStatisticsRepository();
    mockAuthService = MockAuthService();
    mockCategoryRepository = MockActivityCategoryRepository();
    provider = StatisticsProvider(
      repository: mockRepository,
      authService: mockAuthService,
      categoryRepository: mockCategoryRepository,
    );
    // Default stub: breakdown returns empty list unless overridden per test.
    // ignore: argument_type_not_assignable
    when(mockRepository.getActivityWeightBreakdown(any, any))
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
  });
}
