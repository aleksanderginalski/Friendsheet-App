// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/services/auth_service.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Main entry point of the application

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FriendsheetApp());
}

class FriendsheetApp extends StatelessWidget {
  const FriendsheetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friendsheet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF4CAF50),
        useMaterial3: true,
      ),

      // This is the key part - AuthWrapper decides which screen to show
      // based on authentication state
   
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper widget that handles authentication state
///
/// This widget listens to Firebase auth state changes and
/// automatically shows the appropriate screen:
/// - LoginScreen if user is NOT authenticated
/// - HomeScreen if user IS authenticated
///

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    // StreamBuilder listens to auth state changes in real-time

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading spinner while checking auth state
    
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            ),
          );
        }

        // Check if user is authenticated
        // snapshot.data contains the User object if signed in, null if not
    
        final bool isAuthenticated = snapshot.hasData && snapshot.data != null;

        // Show appropriate screen based on auth state
      
        if (isAuthenticated) {
          return const HomeScreen(); // User has valid badge → go to office
        } else {
          return const LoginScreen(); // No badge → go to reception
        }
      },
    );
  }
}