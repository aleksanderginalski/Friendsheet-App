import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Card shown on the Home tab when the user has fewer than 50 meetings.
/// Prompts the user to request meetings from a friend via a sharing token.
class SharingCtaCard extends StatelessWidget {
  const SharingCtaCard({super.key, required this.onTap});

  final VoidCallback onTap;

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
                  l10n.sharingCtaCardTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.sharingCtaCardSubtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onTap,
                  child: Text(l10n.sharingCtaCardButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
