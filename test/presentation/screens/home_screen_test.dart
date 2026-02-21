import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/screens/home_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    // Default stubs for user data
    when(mockAuthService.userDisplayName).thenReturn('Anna Kowalska');
    when(mockAuthService.userEmail).thenReturn('anna@example.com');
  });

  // Helper: builds HomeScreen with injected mock
  Widget buildHomeScreen() {
    return MaterialApp(
      home: HomeScreen(authService: mockAuthService),
    );
  }

  group('HomeScreen', () {
    group('UI rendering', () {
      testWidgets('displays welcome message with user name', (tester) async {
        await tester.pumpWidget(buildHomeScreen());
        expect(find.text('Welcome back, Anna Kowalska! 👋'), findsOneWidget);
      });

      testWidgets('displays user email', (tester) async {
        await tester.pumpWidget(buildHomeScreen());
        expect(find.text('anna@example.com'), findsOneWidget);
      });

      testWidgets('displays fallback name when displayName is null',
          (tester) async {
        when(mockAuthService.userDisplayName).thenReturn(null);
        await tester.pumpWidget(buildHomeScreen());
        expect(find.text('Welcome back, Friend! 👋'), findsOneWidget);
      });
    });
  });
}
