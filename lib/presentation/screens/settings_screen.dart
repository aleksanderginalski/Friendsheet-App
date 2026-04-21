import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../data/services/google_calendar_service.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_locale_provider.dart';
import '../providers/calendar_settings_provider.dart';
import '../providers/delete_account_provider.dart';
import '../providers/export_provider.dart';
import 'calendar_permission_screen.dart';

/// Settings screen with calendar connection, data export, and account deletion.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for export and delete outcomes after the first frame to show SnackBars.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExportProvider>().addListener(_onExportStateChanged);
      context.read<DeleteAccountProvider>().addListener(_onDeleteStateChanged);
    });
  }

  @override
  void dispose() {
    // Remove listeners safely — providers outlive this widget.
    if (mounted) {
      context.read<ExportProvider>().removeListener(_onExportStateChanged);
      context
          .read<DeleteAccountProvider>()
          .removeListener(_onDeleteStateChanged);
    }
    super.dispose();
  }

  void _onExportStateChanged() {
    if (!mounted) return;
    final provider = context.read<ExportProvider>();

    if (provider.lastExportPath != null && !provider.isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to: ${provider.lastExportPath}')),
      );
    }

    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
      provider.clearError();
    }
  }

  void _onDeleteStateChanged() {
    if (!mounted) return;
    final provider = context.read<DeleteAccountProvider>();

    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
      provider.clearError();
    }
  }

  Future<void> _handleExport(BuildContext context) async {
    final userId = AuthService().currentUserId;
    if (userId == null) return;
    await context.read<ExportProvider>().exportData(userId);
  }

  Future<void> _handleRevoke(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsCalendarDisconnectTitle),
        content: Text(l10n.settingsCalendarDisconnectContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.settingsCalendarDisconnect),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<CalendarSettingsProvider>().revokeAccess();
    }
  }

  Future<void> _confirmAndDeleteAccount(BuildContext context) async {
    // Read userId BEFORE opening dialog — avoid async context gap.
    final userId = AuthService().currentUserId;
    if (userId == null) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsDeleteAccountTitle),
        content: Text(l10n.settingsDeleteAccountContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.settingsDeleteAccountConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<DeleteAccountProvider>().deleteAccount(userId);
    }
  }

  String _currentLanguageName(AppLocalizations l10n) {
    final locale = context.read<AppLocaleProvider>().locale;
    if (locale.languageCode == 'pl') return l10n.languagePolish;
    return l10n.languageEnglish;
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = context.read<AppLocaleProvider>().locale;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsAppLanguage),
        content: RadioGroup<Locale>(
          groupValue: current,
          onChanged: (value) {
            if (value == null) return;
            context.read<AppLocaleProvider>().setLocale(value);
            Navigator.pop(ctx);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                value: const Locale('en'),
                title: Text(l10n.languageEnglish),
              ),
              RadioListTile<Locale>(
                value: const Locale('pl'),
                title: Text(l10n.languagePolish),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exportProvider = context.watch<ExportProvider>();
    final calendarProvider = context.watch<CalendarSettingsProvider>();
    final deleteProvider = context.watch<DeleteAccountProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildCalendarSection(context, calendarProvider),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.settingsAppLanguage),
            subtitle: Text(_currentLanguageName(l10n)),
            onTap: () => _showLanguageDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: exportProvider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            title: Text(l10n.settingsExportData),
            subtitle: Text(l10n.settingsExportSubtitle),
            enabled: !exportProvider.isLoading,
            onTap:
                exportProvider.isLoading ? null : () => _handleExport(context),
          ),
          const Divider(),
          ListTile(
            leading: deleteProvider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.delete_forever, color: colorScheme.error),
            title: Text(
              l10n.settingsDeleteAccount,
              style: TextStyle(color: colorScheme.error),
            ),
            subtitle: Text(l10n.settingsDeleteAccountSubtitle),
            enabled: !deleteProvider.isLoading,
            onTap: deleteProvider.isLoading
                ? null
                : () => _confirmAndDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(
    BuildContext context,
    CalendarSettingsProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<bool>(
      valueListenable: GoogleCalendarService().isConnectedNotifier,
      builder: (context, isConnected, _) {
        final tileL10n = AppLocalizations.of(context)!;
        if (!isConnected) {
          return ListTile(
            leading: Icon(Icons.calendar_today, color: Colors.grey[600]),
            title: Text(tileL10n.settingsCalendarSection),
            subtitle: Text(tileL10n.settingsCalendarNotConnected),
            trailing: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: provider,
                    child: const CalendarPermissionScreen(),
                  ),
                ),
              ),
              child: Text(tileL10n.settingsCalendarConnect),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l10n.settingsCalendarSection,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.link_off, color: Colors.red),
              title: Text(
                l10n.settingsCalendarDisconnectTitle,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () => _handleRevoke(context),
            ),
          ],
        );
      },
    );
  }
}
