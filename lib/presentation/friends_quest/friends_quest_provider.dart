import 'package:flutter/foundation.dart';

import '../../data/models/friends_quest.dart';
import '../../data/repositories/friends_quest_repository.dart';

class FriendsQuestProvider extends ChangeNotifier {
  final FriendsQuestRepository _repository;

  List<FriendsQuest> _quests = [];
  bool _isLoading = false;

  FriendsQuestProvider({FriendsQuestRepository? repository})
      : _repository = repository ?? FriendsQuestRepository();

  List<FriendsQuest> get quests => _quests;
  List<FriendsQuest> get activeQuests =>
      _quests.where((q) => !q.isCompleted).toList();
  bool get isLoading => _isLoading;

  void loadQuests(String userId) {
    _quests = _repository.getAll(userId);
    notifyListeners();
  }

  Future<void> createQuest(
    String userId,
    String name,
    List<String> participantIds,
  ) async {
    _isLoading = true;
    notifyListeners();
    await _repository.create(userId, name, participantIds);
    _quests = _repository.getAll(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteQuest(String userId, String questId) async {
    await _repository.delete(userId, questId);
    _quests = _repository.getAll(userId);
    notifyListeners();
  }
}
