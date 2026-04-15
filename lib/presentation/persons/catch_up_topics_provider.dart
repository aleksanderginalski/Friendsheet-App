import 'package:flutter/foundation.dart';

import '../../data/models/catch_up_topic.dart';
import '../../data/repositories/catch_up_topic_repository.dart';
import '../../data/services/auth_service.dart';

// Manages catch-up topics state for a single person on PersonDetailScreen.
// Kept separate from PersonDetailProvider to maintain single responsibility.
class CatchUpTopicsProvider extends ChangeNotifier {
  final CatchUpTopicRepository _repository;
  final AuthService _authService;

  CatchUpTopicsProvider({
    CatchUpTopicRepository? repository,
    AuthService? authService,
  })  : _repository = repository ?? CatchUpTopicRepository(),
        _authService = authService ?? AuthService();

  List<CatchUpTopic> _topics = [];
  bool _isLoading = false;
  String? _errorMessage;
  // Guards against notifyListeners() calls after dispose() — prevents
  // '_dependents.isEmpty' assertion when the route is popped mid-async.
  bool _disposed = false;

  List<CatchUpTopic> get topics => _topics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Routes all notifyListeners() calls through a disposed check.
  // Prevents assertion errors when async operations complete after route pop.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  // Fetches active topics for [personId] from cache / Firestore.
  Future<void> loadTopics(String personId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authService.currentUserId!;
      _topics = await _repository.getActive(userId, personId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Creates a new topic and inserts it at the top of the local list.
  // Does NOT call loadTopics — avoids the synchronous notifyListeners()
  // (_isLoading = true) that fires mid-keyboard-animation and causes
  // 'dirty widget in wrong build scope' assertion errors.
  Future<void> addTopic(
    String personId,
    String text,
    String? contextLabel,
  ) async {
    try {
      final userId = _authService.currentUserId!;
      final id = await _repository.add(userId, personId, text, contextLabel);
      // notifyListeners() fires only after the async Firestore write,
      // i.e. between event loop iterations — safe outside any build phase.
      _topics = [
        CatchUpTopic(
          id: id,
          text: text,
          contextLabel: contextLabel,
          createdAt: DateTime.now(),
        ),
        ..._topics,
      ];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Removes a topic from the local list immediately, then deletes from Firestore.
  Future<void> deleteTopic(String personId, String topicId) async {
    _topics = _topics.where((t) => t.id != topicId).toList();
    notifyListeners();

    try {
      final userId = _authService.currentUserId!;
      await _repository.delete(userId, personId, topicId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
