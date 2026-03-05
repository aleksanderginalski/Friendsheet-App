import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../providers/export_provider.dart';

/// Settings screen with data export functionality.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ExportProvider>(
        builder: (context, exportProvider, _) {
          return ListView(
            children: [
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
                onTap: exportProvider.isLoading
                    ? null
                    : () => _handleExport(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
