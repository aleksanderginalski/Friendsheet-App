import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/ai_consent_repository.dart';
import '../../data/repositories/ai_key_repository.dart';
import '../../data/services/buddy_write_service.dart';
import '../../data/services/context_builder_service.dart';
import '../../data/services/open_ai_service.dart';
import '../providers/ai_settings_provider.dart';
import '../screens/ai_consent_screen.dart';
import '../screens/ai_settings_screen.dart';
import 'ai_chat_provider.dart';
import 'chat_bubble.dart';

/// The Buddy AI chat screen. On open it checks consent and API key,
/// then initialises the provider and shows the conversation.
class AIChatScreen extends StatefulWidget {
  const AIChatScreen({
    super.key,
    required this.userId,
    this.meetingId,
    this.personId,
  });

  final String userId;
  final String? meetingId;
  final String? personId;

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  final _consentRepo = AIConsentRepository();
  final _keyRepo = AIKeyRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkGuards());
  }

  Future<void> _checkGuards() async {
    final hasConsent = await _consentRepo.hasGrantedConsent();
    if (!mounted) return;
    if (!hasConsent) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AIConsentScreen(repository: _consentRepo),
        ),
      );
      return;
    }

    final key = await _keyRepo.loadKey();
    if (!mounted) return;
    if (key == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) =>
                AISettingsProvider(repository: AIKeyRepository()),
            child: const AISettingsScreen(),
          ),
        ),
      );
      return;
    }

    context.read<AIChatProvider>().initialize(
          widget.userId,
          meetingId: widget.meetingId,
          personId: widget.personId,
        );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    context.read<AIChatProvider>().sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openAISettings() {
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
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AIChatProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.messages.isNotEmpty) _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buddy'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount:
                  provider.messages.length + (provider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < provider.messages.length) {
                  final msg = provider.messages[index];
                  return ChatBubble(role: msg.role, content: msg.content);
                }
                // Loading indicator bubble.
                return const ChatBubble(
                  role: 'assistant',
                  content: '',
                  isLoading: true,
                );
              },
            ),
          ),
          if (provider.errorMessage != null)
            _ErrorBanner(
              message: provider.errorMessage!,
              onRetry: provider.retry,
              onSettings: _openAISettings,
              onDismiss: provider.clearError,
            ),
          _InputRow(
            controller: _textController,
            isLoading: provider.isLoading,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onRetry,
    required this.onSettings,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSettings;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isInvalidKey = message.contains('invalid');
    final isQuota = message.contains('quota');

    return Container(
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 13)),
          ),
          if (isInvalidKey)
            TextButton(
              onPressed: onSettings,
              child: const Text('Go to Settings'),
            )
          else if (isQuota)
            TextButton(onPressed: onDismiss, child: const Text('Dismiss'))
          else
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _InputRow extends StatefulWidget {
  const _InputRow({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  State<_InputRow> createState() => _InputRowState();
}

class _InputRowState extends State<_InputRow> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _hasText && !widget.isLoading;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                decoration: const InputDecoration(
                  hintText: 'Ask Buddy...',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: canSend ? (_) => widget.onSend() : null,
                minLines: 1,
                maxLines: 4,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              color: canSend ? const Color(0xFF4CAF50) : Colors.grey,
              onPressed: canSend ? widget.onSend : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Creates a standalone [AIChatScreen] wrapped in its provider.
/// Use this factory when navigating from outside an existing provider scope.
Widget buildAIChatRoute({
  required String userId,
  String? meetingId,
  String? personId,
}) {
  return ChangeNotifierProvider(
    create: (_) => AIChatProvider(
      openAIService: OpenAIService(),
      contextBuilderService: ContextBuilderService(),
      buddyWriteService: BuddyWriteService(),
    ),
    child: AIChatScreen(
      userId: userId,
      meetingId: meetingId,
      personId: personId,
    ),
  );
}
