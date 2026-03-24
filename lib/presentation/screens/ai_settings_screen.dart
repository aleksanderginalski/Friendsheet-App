import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_settings_provider.dart';

/// Screen for managing the user's OpenAI API key.
/// The key is stored in Flutter Secure Storage and never exposed in plain text
/// after saving — only the last 4 characters are shown.
class AISettingsScreen extends StatefulWidget {
  const AISettingsScreen({super.key});

  @override
  State<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends State<AISettingsScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize after first frame so the provider is fully attached.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AISettingsProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete API Key?'),
        content: const Text(
          'This will remove your OpenAI API key from the device. '
          'AI features will be unavailable until you add a key again.',
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
      await context.read<AISettingsProvider>().deleteKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AISettingsProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: provider.isLoading && provider.maskedKey == null
            ? const Center(child: CircularProgressIndicator())
            : provider.maskedKey != null
                ? _buildKeySet(context, provider, colorScheme)
                : _buildKeyInput(context, provider),
      ),
    );
  }

  Widget _buildKeyInput(BuildContext context, AISettingsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter your OpenAI API key to enable AI features. '
          'The key is stored securely on this device only.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'OpenAI API Key',
            hintText: 'sk-...',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => context.read<AISettingsProvider>().clearError(),
        ),
        if (provider.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            provider.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : () => context
                  .read<AISettingsProvider>()
                  .saveKey(_controller.text.trim()),
          child: provider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildKeySet(
    BuildContext context,
    AISettingsProvider provider,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Your OpenAI API key is saved on this device.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),
        const Text(
          'API Key',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          provider.maskedKey!,
          style: const TextStyle(fontSize: 18, letterSpacing: 2),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed:
              provider.isLoading ? null : () => _confirmAndDelete(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error),
          ),
          child: provider.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.error,
                  ),
                )
              : const Text('Delete Key'),
        ),
      ],
    );
  }
}
