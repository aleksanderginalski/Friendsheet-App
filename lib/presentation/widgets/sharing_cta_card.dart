import 'package:flutter/material.dart';

/// Card shown on the Home tab when the user has fewer than 50 meetings.
/// Prompts the user to request meetings from a friend via a sharing token.
class SharingCtaCard extends StatelessWidget {
  const SharingCtaCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Request meetings from a friend',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Have a friend who uses Friendsheet? Ask them to share your meetings.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onTap,
                  child: const Text('Generate token'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
