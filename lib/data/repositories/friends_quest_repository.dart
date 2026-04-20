import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../services/hive_service.dart';
import '../models/friends_quest.dart';

class FriendsQuestRepository {
  static const _uuid = Uuid();

  Box<dynamic> get _box => HiveService.box(HiveService.friendsQuestsBox);

  List<FriendsQuest> getAll(String userId) {
    final raw = _box.get(userId);
    if (raw == null) return [];
    return (raw as List<dynamic>)
        .map(
          (e) => FriendsQuest.fromJson(
            Map<String, dynamic>.from(jsonDecode(jsonEncode(e)) as Map),
          ),
        )
        .toList();
  }

  Future<void> _save(String userId, List<FriendsQuest> quests) async {
    await _box.put(userId, quests.map((q) => q.toJson()).toList());
  }

  Future<FriendsQuest> create(
    String userId,
    String name,
    List<String> participantIds,
  ) async {
    final quest = FriendsQuest(
      id: _uuid.v4(),
      name: name,
      participantIds: participantIds,
      createdAt: DateTime.now(),
    );
    final all = getAll(userId)..add(quest);
    await _save(userId, all);
    return quest;
  }

  Future<void> delete(String userId, String questId) async {
    final updated = getAll(userId).where((q) => q.id != questId).toList();
    await _save(userId, updated);
  }

  Future<void> updateQuest(String userId, FriendsQuest quest) async {
    final updated =
        getAll(userId).map((q) => q.id == quest.id ? quest : q).toList();
    await _save(userId, updated);
  }
}
