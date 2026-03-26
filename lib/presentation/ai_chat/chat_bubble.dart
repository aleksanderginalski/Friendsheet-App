import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// A single chat message bubble for the Buddy chat interface.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.role,
    required this.content,
    this.isLoading = false,
  });

  /// 'user' or 'assistant'
  final String role;
  final String content;

  /// When true, shows a '...' typing indicator instead of [content].
  final bool isLoading;

  bool get _isUser => role == 'user';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: _isUser ? const Color(0xFF4CAF50) : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                _isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight:
                _isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: _isUser
            ? _UserContent(content: content)
            : _BuddyContent(content: content, isLoading: isLoading),
      ),
    );
  }
}

class _UserContent extends StatelessWidget {
  const _UserContent({required this.content});
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(content, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _BuddyContent extends StatelessWidget {
  const _BuddyContent({required this.content, required this.isLoading});
  final String content;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text('...', style: TextStyle(color: Colors.black87)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 4),
          child: MarkdownBody(
            data: content,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(color: Colors.black87, fontSize: 14),
              strong: const TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.bold),
              em: const TextStyle(
                  color: Colors.black87, fontStyle: FontStyle.italic),
            ),
            shrinkWrap: true,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 16, color: Colors.black45),
          padding: const EdgeInsets.only(right: 8, bottom: 4),
          constraints: const BoxConstraints(),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: content));
          },
        ),
      ],
    );
  }
}
