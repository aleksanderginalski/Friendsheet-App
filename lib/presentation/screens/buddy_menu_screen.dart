import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';

/// Sub-menu screen for Buddy (AI Assistant) features.
/// Accessible via Side Menu → Buddy.
/// Mirrors the Settings screen pattern: single tile in the drawer,
/// sub-options listed here.
class BuddyMenuScreen extends StatelessWidget {
  const BuddyMenuScreen({
    super.key,
    required this.onAIAssistantTap,
    required this.onAPIKeyTap,
    required this.onLtnsFiltersTap,
  });

  /// Called when the user taps "AI Assistant" — opens greeting mode chat.
  final VoidCallback onAIAssistantTap;

  /// Called when the user taps "API Key" — opens AI settings screen.
  final VoidCallback onAPIKeyTap;

  /// Called when the user taps "LTNS Filters" — opens the filter screen.
  final VoidCallback onLtnsFiltersTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buddy',
          style: GoogleFonts.pacifico(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: Text(l10n.buddyMenuTitle),
            subtitle: Text(l10n.buddyMenuChatSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              onAIAssistantTap();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: Text(l10n.buddyMenuApiKey),
            subtitle: Text(l10n.buddyMenuApiKeySubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              onAPIKeyTap();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.filter_list_outlined),
            title: Text(l10n.buddyMenuLtnsFilters),
            subtitle: Text(l10n.buddyMenuLtnsFiltersSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              onLtnsFiltersTap();
            },
          ),
        ],
      ),
    );
  }
}
