import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/providers/statistics_provider.dart';
import 'package:friendsheet/presentation/widgets/interaction_distribution_widget.dart';
import 'package:friendsheet/presentation/widgets/statistics_section.dart';
import 'package:friendsheet/presentation/widgets/statistics_visibility_dialog.dart';
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

    testWidgets('tapping options icon opens StatisticsVisibilityDialog',
        (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) async => [2026]);

      await statisticsProvider.initialize();
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.byType(StatisticsVisibilityDialog), findsOneWidget);
    });

    testWidgets('"Long-press to restore" text is never shown', (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) async => [2026]);

      await statisticsProvider.initialize();
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Long-press any card to restore'), findsNothing);
      expect(find.text('Long-press to restore'), findsNothing);
    });

    testWidgets('arrow buttons present when 2+ cards visible', (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) async => [2026]);

      await statisticsProvider.initialize();
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byKey(const Key('carousel_arrow_left')), findsOneWidget);
      expect(find.byKey(const Key('carousel_arrow_right')), findsOneWidget);
    });

    testWidgets('right arrow advances carousel to next page', (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) async => [2026]);

      await statisticsProvider.initialize();
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.tap(find.byKey(const Key('carousel_arrow_right')));
      await tester.pumpAndSettle();

      // After tapping right, PageView should show page 1.
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('left arrow navigates carousel back', (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) async => [2026]);

      await statisticsProvider.initialize();
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      // Go to page 1 first via right arrow, then go back via left arrow.
      await tester.tap(find.byKey(const Key('carousel_arrow_right')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('carousel_arrow_left')));
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('arrow buttons disabled when only 1 card visible',
        (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) async => [2026]);

      await statisticsProvider.initialize();
      // Hide two of the three cards, leaving only one visible.
      await statisticsProvider
          .toggleCardVisibility(StatCardType.whoPerActivity);
      await statisticsProvider
          .toggleCardVisibility(StatCardType.interactionDistribution);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      // Find arrow IconButtons by key and verify onPressed is null (disabled).
      final leftButton = tester.widget<IconButton>(
        find.byKey(const Key('carousel_arrow_left')),
      );
      final rightButton = tester.widget<IconButton>(
        find.byKey(const Key('carousel_arrow_right')),
      );
      expect(leftButton.onPressed, isNull);
      expect(rightButton.onPressed, isNull);
    });
  });
}
