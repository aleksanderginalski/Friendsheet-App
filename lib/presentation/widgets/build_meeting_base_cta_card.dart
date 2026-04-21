import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
              Text(
                l10n.buildMeetingBaseCtaTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.buildMeetingBaseCardSubtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onImport,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(l10n.mainImportFromCalendar),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onShareToken,
                  icon: const Icon(Icons.share),
                  label: Text(l10n.buildMeetingBaseCardRequest),
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
