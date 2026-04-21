// lib/main.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/app_locale_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'services/hive_service.dart';

/// Global navigator key — used for navigation that outlives individual widget contexts.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Main entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await HiveService.initialize();

  final localeProvider = AppLocaleProvider();
  await localeProvider.loadSavedLocale();

  runApp(
    ChangeNotifierProvider.value(
      value: localeProvider,
      child: const FriendsheetApp(),
    ),
  );
}

class FriendsheetApp extends StatelessWidget {
  const FriendsheetApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<AppLocaleProvider>();

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Friendsheet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Inject real AuthService in production
      home: SplashScreen(nextScreen: AuthWrapper(authService: AuthService())),
    );
  }
}

/// AuthWrapper widget that handles authentication state routing
///
/// Accepts AuthService as a parameter (Dependency Injection pattern)
/// This makes the widget testable - in tests we can inject a mock service
/// In production we inject the real AuthService
class AuthWrapper extends StatefulWidget {
  // AuthService injected from outside - not hardcoded inside
  final AuthService authService;

  const AuthWrapper({
    super.key,
    required this.authService,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Prevents calling onboarding on every stream rebuild.
  bool _hasRunOnboarding = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            ),
          );
        }

        final bool isAuthenticated = snapshot.hasData && snapshot.data != null;

        if (isAuthenticated) {
          if (!_hasRunOnboarding) {
            _hasRunOnboarding = true;
            // Run onboarding after the frame completes to avoid calling
            // async work during build. The guard in AuthService makes this
            // idempotent across app restarts and re-logins.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.authService.runOnboardingIfNeeded(snapshot.data!.uid);
            });
          }
          return MainScreen(authService: widget.authService);
        } else {
          return LoginScreen(authService: widget.authService);
        }
      },
    );
  }
}
