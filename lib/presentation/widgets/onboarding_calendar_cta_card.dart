import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Card shown on the Home tab when the user has fewer than 50 meetings.
/// Prompts the user to import past meetings from Google Calendar.
/// Disappears automatically once the user reaches 50 meetings.
class OnboardingCalendarCtaCard extends StatelessWidget {
  const OnboardingCalendarCtaCard({
    super.key,
    required this.onImport,
  });

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                Text(
                  l10n.onboardingCalendarCardTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.onboardingCalendarCardSubtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onImport,
                  child: Text(l10n.mainImportFromCalendar),
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
      ),
    );
  }
}
