// lib/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

/// Login screen with Google Sign-In button
class LoginScreen extends StatefulWidget {
  // AuthService injected from outside - not hardcoded inside
  final AuthService authService;

  const LoginScreen({
    super.key,
    required this.authService,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  /// Handle Google Sign-In button press
  Future<void> _handleGoogleSignIn() async {
    // Prevent double-tap
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Use injected AuthService instead of creating new instance
      final user = await widget.authService.signInWithGoogle();

      if (!mounted) return;

      if (user == null) {
        // User cancelled - just reset loading state
        // AuthWrapper will handle navigation automatically
        setState(() {
          _isLoading = false;
        });
      }
      // If user != null, AuthWrapper stream will automatically navigate to HomeScreen
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in: $e'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App branding
                const Icon(
                  Icons.people_alt,
                  size: 80,
                  color: Color(0xFF4CAF50),
                ),
                const SizedBox(height: 24),
                const Text(
                  'FRIENDSHEET',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track Your Social Life',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 64),

                // Google Sign-In button
                _isLoading
                    ? const CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      )
                    : ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        icon: Image.asset(
                          'assets/google_logo.png',
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.login,
                              color: Colors.white,
                            );
                          },
                        ),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                const SizedBox(height: 16),

                // Encouraging message
                const Text(
                  'One tap to get started! 🚀',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),

                // Terms of service
                const Text(
                  'By signing in, you agree to our\nTerms of Service',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
