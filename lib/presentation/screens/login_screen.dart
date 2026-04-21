// lib/presentation/screens/login_screen.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/services/auth_service.dart';
import '../../l10n/app_localizations.dart';

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
  late final TapGestureRecognizer _tosRecognizer;
  late final TapGestureRecognizer _ppRecognizer;

  @override
  void initState() {
    super.initState();
    _tosRecognizer = TapGestureRecognizer()
      ..onTap = () => _launchUrl(
            'https://aleksanderginalski.github.io/Friendsheet-App/terms',
          );
    _ppRecognizer = TapGestureRecognizer()
      ..onTap = () => _launchUrl(
            'https://aleksanderginalski.github.io/Friendsheet-App/privacy',
          );
  }

  @override
  void dispose() {
    _tosRecognizer.dispose();
    _ppRecognizer.dispose();
    super.dispose();
  }

  /// Opens URL in external browser
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

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

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.loginSignInError(e.toString())),
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;

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
                Text(
                  'Friendsheet',
                  style: GoogleFonts.pacifico(
                    fontSize: 32,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.loginTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // Login illustration — shrinks on small screens, never pushes button off screen
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: Image.asset(
                      'assets/images/login_illustration.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

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
                        label: Text(
                          l10n.loginSignInButton,
                          style: const TextStyle(
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
                Text(
                  l10n.loginTagline,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),

                // Terms of Service and Privacy Policy — tap to open in external browser
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    children: [
                      TextSpan(text: '${l10n.loginTermsPrefix}\n'),
                      TextSpan(
                        text: l10n.loginTermsLink,
                        style: TextStyle(
                          color: primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _tosRecognizer,
                      ),
                      TextSpan(text: l10n.loginTermsMiddle),
                      TextSpan(
                        text: l10n.loginPrivacyLink,
                        style: TextStyle(
                          color: primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _ppRecognizer,
                      ),
                    ],
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
