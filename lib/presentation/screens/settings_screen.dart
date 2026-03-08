import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../providers/calendar_settings_provider.dart';
import '../providers/export_provider.dart';
import 'calendar_permission_screen.dart';

/// Settings screen with calendar connection and data export functionality.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for export outcome after the first frame to show SnackBars.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExportProvider>().addListener(_onExportStateChanged);
    });
  }

  @override
  void dispose() {
    // Remove listener safely — the provider outlives this widget.
    if (mounted) {
      context.read<ExportProvider>().removeListener(_onExportStateChanged);
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

  @override
  Widget build(BuildContext context) {
    final exportProvider = context.watch<ExportProvider>();
    final calendarProvider = context.watch<CalendarSettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ..._buildCalendarSection(context, calendarProvider),
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
        ],
      ),
    );
  }

  List<Widget> _buildCalendarSection(
    BuildContext context,
    CalendarSettingsProvider provider,
  ) {
    if (!provider.isConnected) {
      return [
        ListTile(
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
        ),
      ];
    }

    return [
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
      ...provider.availableCalendars.map(
        (cal) => CheckboxListTile(
          title: Text(cal.summary),
          subtitle: cal.isPrimary ? const Text('Primary') : null,
          value: provider.selectedCalendarIds.contains(cal.id),
          onChanged: (_) => provider.toggleCalendar(cal.id),
        ),
      ),
      SwitchListTile(
        title: const Text('Include all-day events'),
        subtitle: const Text('OFF by default'),
        value: provider.includeAllDay,
        onChanged: (_) => provider.toggleAllDay(),
      ),
      ListTile(
        leading: const Icon(Icons.link_off, color: Colors.red),
        title: const Text(
          'Disconnect Calendar',
          style: TextStyle(color: Colors.red),
        ),
        onTap: () => _handleRevoke(context),
      ),
    ];
  }
}
