// test/widget_test.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/main.dart';
import 'package:friendsheet/presentation/screens/home_screen.dart';
import 'package:friendsheet/presentation/screens/login_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'widget_test.mocks.dart';

// Mockito will generate MockAuthService class automatically
// Run: flutter pub run build_runner build
@GenerateMocks([AuthService, User])
void main() {
  // Declare mock - our "actor" pretending to be AuthService
  late MockAuthService mockAuthService;

  // setUp runs before each test - like setting up the stage before each scene
  setUp(() {
    mockAuthService = MockAuthService();
  });

  group('AuthWrapper Tests', () {
    testWidgets('shows LoginScreen when user is NOT authenticated',
        (WidgetTester tester) async {
      // Arrange: Mock returns null - no user logged in
      when(mockAuthService.authStateChanges).thenAnswer(
        (_) => Stream.value(null),
      );

      // Act: Build widget with injected mock
      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(authService: mockAuthService),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: LoginScreen is shown
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('shows HomeScreen when user IS authenticated',
        (WidgetTester tester) async {
      // Arrange: Mock returns a User - someone is logged in
      final mockUser = MockUser();
      when(mockAuthService.authStateChanges).thenAnswer(
        (_) => Stream.value(mockUser),
      );
      // Tell mock what to return when HomeScreen asks for user data
    
      when(mockAuthService.userDisplayName).thenReturn('Test User');
      when(mockAuthService.userEmail).thenReturn('test@example.com');
      
      // Act: Build widget with injected mock
      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(authService: mockAuthService),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: HomeScreen is shown
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
}