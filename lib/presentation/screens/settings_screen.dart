import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/ai_key_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/google_calendar_service.dart';
import '../providers/ai_settings_provider.dart';
import '../providers/calendar_settings_provider.dart';
import '../providers/delete_account_provider.dart';
import '../providers/export_provider.dart';
import 'ai_settings_screen.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect Calendar?'),
        content: const Text(
          'This will remove Friendsheet\'s access to your Google Calendar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DISCONNECT'),
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all data including '
          'meetings, friends and activities. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<DeleteAccountProvider>().deleteAccount(userId);
    }
  }

  void _openAISettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => AISettingsProvider(repository: AIKeyRepository()),
          child: const AISettingsScreen(),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildCalendarSection(context, calendarProvider),
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: const Text('AI Assistant'),
            subtitle: const Text('Manage your OpenAI API key'),
            onTap: () => _openAISettings(context),
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
            title: const Text('Export Data'),
            subtitle: const Text('Save all data as JSON to device'),
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
              'Delete Account',
              style: TextStyle(color: colorScheme.error),
            ),
            subtitle:
                const Text('Permanently delete your account and all data'),
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
    return ValueListenableBuilder<bool>(
      valueListenable: GoogleCalendarService().isConnectedNotifier,
      builder: (context, isConnected, _) {
        if (!isConnected) {
          return ListTile(
            leading: Icon(Icons.calendar_today, color: Colors.grey[600]),
            title: const Text('Google Calendar'),
            subtitle: const Text('Not connected'),
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
              child: const Text('Connect'),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'GOOGLE CALENDAR',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.link_off, color: Colors.red),
              title: const Text(
                'Disconnect Calendar',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _handleRevoke(context),
            ),
          ],
        );
      },
    );
  }
}
