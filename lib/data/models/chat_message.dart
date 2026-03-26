/// A single message in the Buddy chat session.
/// Lives in memory only — not persisted between sessions.
class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  /// 'user' or 'assistant'
  final String role;
  final String content;

  ChatMessage copyWith({String? content}) =>
      ChatMessage(role: role, content: content ?? this.content);
}
