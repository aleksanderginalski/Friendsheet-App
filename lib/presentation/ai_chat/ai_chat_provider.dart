import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../data/models/ai_exceptions.dart';
import '../../data/models/buddy_context.dart';
import '../../data/models/chat_message.dart';
import '../../data/services/buddy_write_service.dart';
import '../../data/services/context_builder_service.dart';
import '../../data/services/open_ai_service.dart';

/// Manages the Buddy chat session state.
/// Never holds direct references to MeetingRepository, PersonRepository,
/// or ActivityCategoryRepository — all data access goes through services.
class AIChatProvider extends ChangeNotifier {
  AIChatProvider({
    OpenAIService? openAIService,
    ContextBuilderService? contextBuilderService,
    BuddyWriteService? buddyWriteService,
  })  : _openAIService = openAIService ?? OpenAIService(),
        _contextBuilderService =
            contextBuilderService ?? ContextBuilderService(),
        _buddyWriteService = buddyWriteService ?? BuddyWriteService();

  final OpenAIService _openAIService;
  final ContextBuilderService _contextBuilderService;
  final BuddyWriteService _buddyWriteService;

  static final _dateFormat = DateFormat('dd MMM yyyy');

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? _userId;
  String? _activeMeetingId;
  String? _activePersonId;
  BuddyContext? _context;
  bool _disposed = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialises the provider for a session.
  ///
  /// Builds the appropriate context, then sets the initial Buddy greeting.
  Future<void> initialize(
    String userId, {
    String? meetingId,
    String? personId,
  }) async {
    _userId = userId;
    _activeMeetingId = meetingId;
    _activePersonId = personId;

    if (_activePersonId != null) {
      _context = await _contextBuilderService.buildPersonContext(
          userId, _activePersonId!);
    } else {
      _context = await _contextBuilderService.buildFullContext(userId);
    }

    final greeting = await _buildGreeting();
    _messages = [ChatMessage(role: 'assistant', content: greeting)];
    _safeNotify();
  }

  Future<String> _buildGreeting() async {
    if (_activeMeetingId != null) {
      final meeting = await _contextBuilderService.getMeetingById(
        _userId!,
        _activeMeetingId!,
      );
      final name = meeting?.name ?? 'this meeting';
      return 'I see you want to add notes to $name. What would you like to remember?';
    }

    final recent = await _contextBuilderService
        .findMostRecentMeetingWithoutNotes(_userId!);
    if (recent != null) {
      final dateStr = _dateFormat.format(recent.date);
      return 'I see you recently had ${recent.name} (on $dateStr). Want to add some notes about it?';
    }

    return 'Hi! I\'m Buddy \u{1F44B} I\'m here to help you explore your social life.\n\n'
        'Here are some things you can ask me:\n'
        '\u2022 Who did I meet the most this year?\n'
        '\u2022 Write a birthday wish for a friend\n'
        '\u2022 What activities have I been doing lately?';
  }

  /// Sends [text] to the AI and streams the response into a new message bubble.
  Future<void> sendMessage(String text) async {
    _messages = [..._messages, ChatMessage(role: 'user', content: text)];
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();

    try {
      final contextPrompt = _contextBuilderService.serializeToPrompt(
        _context!,
        includeNotes: _activeMeetingId != null,
      );

      // History = all messages except the initial Buddy greeting (index 0).
      final history =
          _messages.length > 1 ? _messages.sublist(1) : <ChatMessage>[];

      final buffer = StringBuffer();
      await for (final chunk in _openAIService.sendMessage(
        contextPrompt,
        history,
        text,
      )) {
        buffer.write(chunk);
      }

      final translated = _translatePseudonyms(
        buffer.toString(),
        _context!.pseudonymToRealName,
      );
      _messages = [
        ..._messages,
        ChatMessage(role: 'assistant', content: translated),
      ];
      _isLoading = false;
      _safeNotify();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _mapError(e);
      _safeNotify();
    }
  }

  /// Removes the last assistant message and re-sends the last user message.
  Future<void> retry() {
    if (_messages.isNotEmpty && _messages.last.role == 'assistant') {
      _messages = _messages.sublist(0, _messages.length - 1);
    }
    final lastUserMsg = _messages.lastWhere(
      (m) => m.role == 'user',
      orElse: () => const ChatMessage(role: 'user', content: ''),
    );
    if (lastUserMsg.content.isEmpty) return Future.value();
    return sendMessage(lastUserMsg.content);
  }

  /// Appends [notes] to the active meeting via [BuddyWriteService].
  /// Only valid when the session was opened with a [meetingId].
  Future<void> saveNotes(List<String> notes) async {
    if (_userId == null || _activeMeetingId == null) return;
    await _buddyWriteService.saveNotes(_userId!, _activeMeetingId!, notes);
  }

  /// Clears the current error banner.
  void clearError() {
    _errorMessage = null;
    _safeNotify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  String _translatePseudonyms(
      String text, Map<String, String> pseudonymToReal) {
    // Sort longest-first to prevent shorter pseudonyms (Friend_A) from
    // partially replacing longer ones (Friend_AH → "Ada MachuraH").
    final sorted = pseudonymToReal.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    var result = text;
    for (final entry in sorted) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  String _mapError(Object error) {
    if (error is NetworkException) {
      return 'No internet connection. Please try again when the network is restored.';
    }
    if (error is InvalidKeyException) {
      return 'Your API key is invalid. Please update it in Settings → AI Assistant.';
    }
    if (error is QuotaExceededException) {
      return 'OpenAI quota exceeded. Check your account at platform.openai.com.';
    }
    return 'Something went wrong. Please try again in a moment.';
  }
}
