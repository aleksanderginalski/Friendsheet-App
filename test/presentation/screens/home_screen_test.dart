import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/providers/statistics_provider.dart';
import 'package:friendsheet/presentation/screens/home_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([StatisticsRepository, AuthService])
void main() {
  late MockStatisticsRepository mockRepository;
  late MockAuthService mockAuthService;
  late StatisticsProvider statisticsProvider;

  setUp(() {
    mockRepository = MockStatisticsRepository();
    mockAuthService = MockAuthService();
    statisticsProvider = StatisticsProvider(
      repository: mockRepository,
      authService: mockAuthService,
    );
  });

  tearDown(() {
    statisticsProvider.dispose();
  });

  Widget buildHomeScreen() {
    return MaterialApp(
      home: ChangeNotifierProvider.value(
        value: statisticsProvider,
        child: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen', () {
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

    testWidgets('shows year chips when years are available', (tester) async {
      when(mockAuthService.currentUserId).thenReturn('user-1');
      when(mockRepository.getAvailableYears('user-1'))
          .thenAnswer((_) async => [2026, 2025]);

      await statisticsProvider.initialize();
      await tester.pumpWidget(buildHomeScreen());

      expect(find.text('2026'), findsOneWidget);
      expect(find.text('2025'), findsOneWidget);
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
}
