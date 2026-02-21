import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

/// Home screen shown to authenticated users
class HomeScreen extends StatelessWidget {
  // AuthService injected from outside - not hardcoded inside
  final AuthService authService;

  const HomeScreen({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final String userName = authService.userDisplayName ?? 'Friend';
    final String userEmail = authService.userEmail ?? '';

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
            ],
          ),
        ),
      ),
    );
  }
}
