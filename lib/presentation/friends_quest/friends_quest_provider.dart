import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/catch_up_topic.dart';
import '../../data/models/friends_quest.dart';
import '../../data/models/friends_quest_task.dart';
import '../../data/models/meeting.dart';
import '../../data/repositories/catch_up_topic_repository.dart';
import '../../data/repositories/friends_quest_repository.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';

class FriendsQuestProvider extends ChangeNotifier {
  final FriendsQuestRepository _repository;
  final CatchUpTopicRepository _catchUpRepo;
  final PersonRepository _personRepo;
  final MeetingRepository _meetingRepo;

  static const _uuid = Uuid();

  List<FriendsQuest> _quests = [];
  bool _isLoading = false;

  FriendsQuestProvider({
    FriendsQuestRepository? repository,
    CatchUpTopicRepository? catchUpRepo,
    PersonRepository? personRepo,
    MeetingRepository? meetingRepo,
  })  : _repository = repository ?? FriendsQuestRepository(),
        _catchUpRepo = catchUpRepo ?? CatchUpTopicRepository(),
        _personRepo = personRepo ?? PersonRepository(),
        _meetingRepo = meetingRepo ?? MeetingRepository();

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
    try {
      final quest = await _repository.create(userId, name, participantIds);
      _quests = _repository.getAll(userId);
      if (participantIds.isNotEmpty) {
        try {
          await _importTopicsForQuest(userId, quest.id);
        } catch (_) {
          // Import failure must not block quest creation.
          _quests = _repository.getAll(userId);
          notifyListeners();
        }
      }
      _quests = _repository.getAll(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteQuest(String userId, String questId) async {
    await _repository.delete(userId, questId);
    _quests = _repository.getAll(userId);
    notifyListeners();
  }

  Future<void> addTask(
    String userId,
    String questId,
    String text,
    List<String> assignedPersonIds,
  ) async {
    String? sourceTopicId;
    String? sourcePersonId;
    if (assignedPersonIds.isNotEmpty) {
      sourceTopicId =
          await _catchUpRepo.add(userId, assignedPersonIds.first, text, null);
      sourcePersonId = assignedPersonIds.first;
      for (final pid in assignedPersonIds.skip(1)) {
        await _catchUpRepo.add(userId, pid, text, null);
      }
    }
    final quest = _quests.firstWhere((q) => q.id == questId);
    final task = FriendsQuestTask(
      id: _uuid.v4(),
      text: text,
      sourceTopicId: sourceTopicId,
      sourcePersonId: sourcePersonId,
      assignedPersonIds: assignedPersonIds,
    );
    await _repository.updateQuest(
        userId, quest.copyWith(tasks: [...quest.tasks, task]));
    _quests = _repository.getAll(userId);
    notifyListeners();
  }

  Future<void> editTask(
    String userId,
    String questId,
    String taskId,
    String newText,
  ) async {
    final quest = _quests.firstWhere((q) => q.id == questId);
    final task = quest.tasks.firstWhere((t) => t.id == taskId);

    if (task.sourceTopicId != null && task.sourcePersonId != null) {
      try {
        await _catchUpRepo.update(
            userId, task.sourcePersonId!, task.sourceTopicId!, newText, null);
      } catch (_) {}

      // Propagate to couple partner if source person is linked — regardless of quest participants.
      try {
        final persons =
            await _personRepo.getPersonsByIds([task.sourcePersonId!], userId);
        final partnerId = persons.isNotEmpty ? persons.first.partnerId : null;
        if (partnerId != null) {
          final partnerTopics = await _catchUpRepo.getActive(userId, partnerId);
          final match = partnerTopics.cast<CatchUpTopic?>().firstWhere(
                (t) =>
                    t!.text.trim().toLowerCase() ==
                    task.text.trim().toLowerCase(),
                orElse: () => null,
              );
          if (match != null) {
            await _catchUpRepo.update(
                userId, partnerId, match.id, newText, null);
          }
        }
      } catch (_) {}
    }

    final updatedTasks = quest.tasks
        .map((t) => t.id == taskId ? t.copyWith(text: newText) : t)
        .toList();
    await _repository.updateQuest(userId, quest.copyWith(tasks: updatedTasks));
    _quests = _repository.getAll(userId);
    notifyListeners();
  }

  Future<void> deleteTask(
    String userId,
    String questId,
    String taskId,
  ) async {
    final quest = _quests.firstWhere((q) => q.id == questId);
    final updatedTasks = quest.tasks.where((t) => t.id != taskId).toList();
    await _repository.updateQuest(userId, quest.copyWith(tasks: updatedTasks));
    _quests = _repository.getAll(userId);
    notifyListeners();
  }

  Future<void> updateParticipants(
    String userId,
    String questId,
    List<String> newParticipantIds,
  ) async {
    final quest = _quests.firstWhere((q) => q.id == questId);
    final manualTasks =
        quest.tasks.where((t) => t.sourceTopicId == null).toList();
    final updated = quest.copyWith(
      participantIds: newParticipantIds,
      tasks: manualTasks,
    );
    await _repository.updateQuest(userId, updated);
    _quests = _repository.getAll(userId);
    await _importTopicsForQuest(userId, questId);
  }

  Future<void> _importTopicsForQuest(String userId, String questId) async {
    final quest = _quests.firstWhere((q) => q.id == questId);
    if (quest.participantIds.isEmpty) return;

    final persons =
        await _personRepo.getPersonsByIds(quest.participantIds, userId);
    final personMap = {for (final p in persons) p.id: p};

    // Identify couple pairs both present in this quest.
    final processedIds = <String>{};
    final couplePairs = <(String, String)>[];
    for (final p in persons) {
      if (processedIds.contains(p.id)) continue;
      final partnerId = p.partnerId;
      if (partnerId != null && personMap.containsKey(partnerId)) {
        couplePairs.add((p.id, partnerId));
        processedIds.add(p.id);
        processedIds.add(partnerId);
      }
    }

    final allTasks = <FriendsQuestTask>[];

    // Build tasks for couple pairs with deduplication.
    for (final (aId, bId) in couplePairs) {
      final aTopics = await _catchUpRepo.getActive(userId, aId);
      final bTopics = await _catchUpRepo.getActive(userId, bId);

      final bTextMap = {
        for (final t in bTopics) t.text.trim().toLowerCase(): t,
      };
      final aTextMap = {
        for (final t in aTopics) t.text.trim().toLowerCase(): t,
      };

      final handledBTexts = <String>{};

      for (final aTopic in aTopics) {
        final key = aTopic.text.trim().toLowerCase();
        final bMatch = bTextMap[key];
        if (bMatch != null) {
          handledBTexts.add(key);
          allTasks.add(FriendsQuestTask(
            id: _uuid.v4(),
            text: aTopic.text,
            contextLabel: aTopic.contextLabel,
            sourceTopicId: aTopic.id,
            sourcePersonId: aId,
            assignedPersonIds: [aId, bId],
          ));
        } else {
          allTasks.add(FriendsQuestTask(
            id: _uuid.v4(),
            text: aTopic.text,
            contextLabel: aTopic.contextLabel,
            sourceTopicId: aTopic.id,
            sourcePersonId: aId,
            assignedPersonIds: [aId],
          ));
        }
      }

      // Topics unique to B.
      for (final bTopic in bTopics) {
        final key = bTopic.text.trim().toLowerCase();
        if (!handledBTexts.contains(key) && !aTextMap.containsKey(key)) {
          allTasks.add(FriendsQuestTask(
            id: _uuid.v4(),
            text: bTopic.text,
            contextLabel: bTopic.contextLabel,
            sourceTopicId: bTopic.id,
            sourcePersonId: bId,
            assignedPersonIds: [bId],
          ));
        }
      }
    }

    // Build tasks for solo participants.
    for (final p in persons) {
      if (processedIds.contains(p.id)) continue;
      final topics = await _catchUpRepo.getActive(userId, p.id);
      for (final topic in topics) {
        allTasks.add(FriendsQuestTask(
          id: _uuid.v4(),
          text: topic.text,
          contextLabel: topic.contextLabel,
          sourceTopicId: topic.id,
          sourcePersonId: p.id,
          assignedPersonIds: [p.id],
        ));
      }
    }

    await _repository.updateQuest(userId, quest.copyWith(tasks: allTasks));
    _quests = _repository.getAll(userId);
    notifyListeners();
  }

  Future<void> linkToMeeting(
      String userId, String questId, String meetingId) async {
    final quest = _quests.firstWhere((q) => q.id == questId);
    await _repository.updateQuest(
        userId, quest.copyWith(linkedMeetingId: meetingId));
    _quests = _repository.getAll(userId);
    notifyListeners();
  }

  Future<void> completeTask(
      String userId, String questId, String taskId) async {
    final quest = _quests.firstWhere((q) => q.id == questId);
    final task = quest.tasks.firstWhere((t) => t.id == taskId);
    if (task.isCompleted) return;
    if (task.sourceTopicId != null && task.sourcePersonId != null) {
      try {
        await _catchUpRepo.archive(
            userId, task.sourcePersonId!, task.sourceTopicId!);
      } catch (_) {}
    }
    final updated = quest.tasks
        .map((t) => t.id == taskId ? t.copyWith(isCompleted: true) : t)
        .toList();
    await _repository.updateQuest(userId, quest.copyWith(tasks: updated));
    _quests = _repository.getAll(userId);
    notifyListeners();
  }

  Future<void> completeQuest(String userId, String questId) async {
    final quest = _quests.firstWhere((q) => q.id == questId);
    final done = quest.tasks.where((t) => t.isCompleted).toList();
    if (quest.linkedMeetingId != null && done.isNotEmpty) {
      final all = await _meetingRepo.getAllMeetings(userId);
      final matches = all.where((m) => m.id == quest.linkedMeetingId);
      final Meeting? m = matches.isNotEmpty ? matches.first : null;
      if (m != null) {
        await _meetingRepo.updateMeeting(
          m.copyWith(notes: [...m.notes, ...done.map((t) => t.text)]),
        );
      }
    }
    await _repository.updateQuest(userId, quest.copyWith(isCompleted: true));
    _quests = _repository.getAll(userId);
    notifyListeners();
  }
}
