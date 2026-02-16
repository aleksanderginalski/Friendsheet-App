
import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import 'login_screen.dart';

/// Home screen shown to authenticated users

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Handle logout button press

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text(
          'Are you sure you want to log out?\n\n'
          'You\'ll need to sign in again to access your meetings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('LOG OUT'),
          ),
        ],
      ),
    );

    // If user confirmed, proceed with logout
    if (confirmed == true && context.mounted) {
      try {
        final AuthService authService = AuthService();
        await authService.signOut();

        if (context.mounted) {
          // Navigate to login screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } catch (e) {
        // Show error if logout fails
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to log out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final String userName = authService.userDisplayName ?? 'Friend';
    final String userEmail = authService.userEmail ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('FRIENDSHEET'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          // Logout button in app bar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome message
              Text(
                'Welcome back, $userName! 👋',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                userEmail,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),

              // Add meeting button (placeholder for future feature)
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to Add Meeting screen (US-010)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add Meeting feature coming in US-010!'),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('ADD NEW MEETING'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  minimumSize: const Size(200, 56),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}