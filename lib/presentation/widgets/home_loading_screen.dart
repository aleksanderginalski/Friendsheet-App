import 'package:flutter/material.dart';

/// Shown on the Home tab while [HomeProvider] waits for the first stream
/// emission. Prevents a flash of the CTA card for users with >= 50 meetings.
class HomeLoadingScreen extends StatelessWidget {
  const HomeLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/loading_icon.png',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 24),
          Text(
            'Checking who you\'ve been\nhanging out with...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
