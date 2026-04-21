import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/repositories/ai_consent_repository.dart';
import '../../data/repositories/ai_key_repository.dart';
import '../../l10n/app_localizations.dart';
import '../providers/ai_settings_provider.dart';
import 'ai_settings_screen.dart';

/// One-time consent screen shown before the user can access AI features.
/// Explains what data IS and is NOT sent to OpenAI, then persists acceptance
/// in SharedPreferences so the screen is not shown again on subsequent visits.
class AIConsentScreen extends StatefulWidget {
  const AIConsentScreen({super.key, required this.repository});

  final AIConsentRepository repository;

  @override
  State<AIConsentScreen> createState() => _AIConsentScreenState();
}

class _AIConsentScreenState extends State<AIConsentScreen> {
  bool _isLoading = false;

  Future<void> _onAgree() async {
    setState(() => _isLoading = true);

    await widget.repository.grantConsent();

    if (!mounted) return;

    // Replace this consent screen with the AI Settings screen.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => AISettingsProvider(repository: AIKeyRepository()),
          child: const AISettingsScreen(),
        ),
      ),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(
      'https://github.com/aleksanderginalski/Friendsheet-App/blob/main/docs/privacy.md',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.aiConsentTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Before using the AI Assistant, please review how your data is handled.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      icon: Icons.upload_outlined,
                      iconColor: const Color(0xFF4CAF50),
                      title: l10n.aiConsentAlwaysSent,
                      items: const [
                        'Meeting statistics: total count, frequency, distribution by month',
                        'Activity breakdown: category names and usage counts',
                        'Social graph summary: meeting counts per friend, last meeting date, '
                            'most common shared activities',
                        'All friend names are replaced with generic identifiers '
                            '(Friend_A, Friend_B, ...) before the data leaves your device — '
                            'OpenAI never receives real names',
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: Icons.tune_outlined,
                      iconColor: Colors.orange,
                      title: l10n.aiConsentSentWhenAsked,
                      items: const [
                        'Meeting notes — included only when you request sentiment analysis '
                            '(e.g. "How have my meetings with Anna felt this year?"). '
                            'Never sent during standard statistics queries',
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: Icons.block_outlined,
                      iconColor: Colors.red,
                      title: l10n.aiConsentNeverSent,
                      items: const [
                        'Your real name or your friends\' real names',
                        'Raw Firestore data or any data not listed above',
                        'Your email address, Google UID, or any account credentials',
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'The AI Assistant uses your own OpenAI API key (BYOK). '
                      'Your key is stored in Android Keystore-backed secure storage '
                      'and is never written to Firestore or logs. '
                      'It authenticates directly with OpenAI\'s API from your device — '
                      'Friendsheet servers never see it.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _openPrivacyPolicy,
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: Text(l10n.aiConsentPrivacyPolicy),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onAgree,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.aiConsentAgree),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.black54)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
