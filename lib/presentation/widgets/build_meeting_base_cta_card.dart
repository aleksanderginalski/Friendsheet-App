import 'package:flutter/material.dart';

/// Card shown on the Home tab when the user has fewer than 50 meetings.
/// Groups all tools for building the meeting base: calendar import and
/// sharing token generation.
class BuildMeetingBaseCtaCard extends StatelessWidget {
  const BuildMeetingBaseCtaCard({
    super.key,
    required this.onImport,
    required this.onShareToken,
  });

  final VoidCallback onImport;
  final VoidCallback onShareToken;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                'Build your meeting base',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You have fewer than 50 meetings. Import from Google Calendar or ask a friend to share your meetings.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onImport,
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Import from Calendar'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onShareToken,
                  icon: const Icon(Icons.share),
                  label: const Text('Request from a friend'),
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                'assets/images/cta_stats.png',
                height: 160,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
