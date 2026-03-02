import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/providers/statistics_provider.dart';
import 'package:friendsheet/presentation/widgets/interaction_distribution_widget.dart';
import 'package:friendsheet/presentation/widgets/statistics_section.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'statistics_section_test.mocks.dart';

@GenerateMocks([
  StatisticsRepository,
  AuthService,
  ActivityCategoryRepository,
  PersonRepository,
])
void main() {
  late MockStatisticsRepository mockRepository;
  late MockAuthService mockAuthService;
  late MockActivityCategoryRepository mockCategoryRepository;
  late MockPersonRepository mockPersonRepository;
  late StatisticsProvider statisticsProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockStatisticsRepository();
    mockAuthService = MockAuthService();
    mockCategoryRepository = MockActivityCategoryRepository();
    mockPersonRepository = MockPersonRepository();
    statisticsProvider = StatisticsProvider(
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
    statisticsProvider.dispose();
  });

  Widget buildWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider.value(
          value: statisticsProvider,
          child: const StatisticsSection(),
        ),
      ),
    );
  }

  group('StatisticsSection carousel', () {
    testWidgets('when all cards visible — PageView present, empty state absent',
        (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) async => [2026]);

      await statisticsProvider.initialize();
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byType(PageView), findsOneWidget);
      expect(find.text('All statistics hidden'), findsNothing);
    });

    testWidgets('when all cards hidden — empty state widget present',
        (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) async => [2026]);

      await statisticsProvider.initialize();
      // Hide all three cards.
      await statisticsProvider
          .toggleCardVisibility(StatCardType.activityBreakdown);
      await statisticsProvider
          .toggleCardVisibility(StatCardType.whoPerActivity);
      await statisticsProvider
          .toggleCardVisibility(StatCardType.interactionDistribution);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('All statistics hidden'), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);
    });

    testWidgets(
        'InteractionDistributionWidget present on third card (not replaced by spinner)',
        (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) async => [2026]);

      await statisticsProvider.initialize();
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      // Swipe twice to reach the third card (Interaction Distribution).
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 600);
      await tester.pumpAndSettle();
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 600);
      await tester.pumpAndSettle();

      expect(find.byType(InteractionDistributionWidget), findsOneWidget);
    });

    testWidgets('long-press on card triggers toggleCardVisibility',
        (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) async => [2026]);

      await statisticsProvider.initialize();
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      // All three cards visible before the long-press.
      expect(statisticsProvider.visibleCards.length, equals(3));

      // The first GestureDetector descendant of PageView is the page-level one
      // from _buildCard — parent widgets precede their children in DFS order.
      await tester.longPress(
        find
            .descendant(
              of: find.byType(PageView),
              matching: find.byType(GestureDetector),
            )
            .first,
      );
      await tester.pump();

      // One card should now be hidden.
      expect(statisticsProvider.visibleCards.length, lessThan(3));
    });
  });
}
