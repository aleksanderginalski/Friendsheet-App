import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/friends_quest_task.dart';
import 'package:friendsheet/data/repositories/friends_quest_repository.dart';
import 'package:friendsheet/services/hive_service.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveDir;
  late FriendsQuestRepository repository;

  const userId = 'user-1';

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('hive_quest_test_');
    await HiveService.initialize(testPath: hiveDir.path);
    repository = FriendsQuestRepository();
  });

  tearDown(() async {
    await Hive.close();
    await hiveDir.delete(recursive: true);
  });

  group('FriendsQuestRepository', () {
    test('getAll returns empty list when no data exists', () {
      expect(repository.getAll(userId), isEmpty);
    });

    test('create adds quest with correct fields and getAll returns it',
        () async {
      final quest =
          await repository.create(userId, 'Weekend crew', ['p1', 'p2']);

      expect(quest.name, 'Weekend crew');
      expect(quest.participantIds, ['p1', 'p2']);
      expect(quest.isCompleted, false);
      expect(quest.tasks, isEmpty);
      expect(quest.id, isNotEmpty);

      final all = repository.getAll(userId);
      expect(all, hasLength(1));
      expect(all.first.id, quest.id);
      expect(all.first.name, 'Weekend crew');
    });

    test('create multiple quests preserves all entries', () async {
      await repository.create(userId, 'Quest A', []);
      await repository.create(userId, 'Quest B', ['p1']);

      expect(repository.getAll(userId), hasLength(2));
    });

    test('delete removes quest by id, others remain', () async {
      final q1 = await repository.create(userId, 'Quest A', []);
      await repository.create(userId, 'Quest B', []);

      await repository.delete(userId, q1.id);

      final remaining = repository.getAll(userId);
      expect(remaining, hasLength(1));
      expect(remaining.first.name, 'Quest B');
    });

    test('delete with unknown id leaves list unchanged', () async {
      await repository.create(userId, 'Quest A', []);

      await repository.delete(userId, 'nonexistent-id');

      expect(repository.getAll(userId), hasLength(1));
    });

    test('data is isolated per userId', () async {
      await repository.create('user-a', 'Quest A', []);
      await repository.create('user-b', 'Quest B', []);

      expect(repository.getAll('user-a'), hasLength(1));
      expect(repository.getAll('user-b'), hasLength(1));
      expect(repository.getAll('user-c'), isEmpty);
    });

    test('persists data across getAll calls (round-trip serialization)',
        () async {
      await repository.create(userId, 'Round-trip', ['p1', 'p2']);

      final loaded = repository.getAll(userId);
      expect(loaded.first.participantIds, ['p1', 'p2']);
      expect(loaded.first.isCompleted, false);
    });

    test('updateQuest replaces matching quest, others unchanged', () async {
      final q1 = await repository.create(userId, 'Quest A', []);
      await repository.create(userId, 'Quest B', []);

      const task = FriendsQuestTask(id: 't1', text: 'Do something');
      await repository.updateQuest(userId, q1.copyWith(tasks: [task]));

      final all = repository.getAll(userId);
      expect(all, hasLength(2));
      final found = all.firstWhere((q) => q.id == q1.id);
      expect(found.tasks, hasLength(1));
      expect(found.tasks.first.text, 'Do something');
      expect(all.firstWhere((q) => q.name == 'Quest B').tasks, isEmpty);
    });

    test('updateQuest persists nested tasks (round-trip serialization)',
        () async {
      final q = await repository.create(userId, 'Quest', []);
      const task = FriendsQuestTask(
        id: 't1',
        text: 'Nested task',
        contextLabel: 'ctx',
        sourceTopicId: 'src-1',
        sourcePersonId: 'p1',
        assignedPersonIds: ['p1', 'p2'],
      );
      await repository.updateQuest(userId, q.copyWith(tasks: [task]));

      final loaded = repository.getAll(userId).first;
      expect(loaded.tasks, hasLength(1));
      expect(loaded.tasks.first.text, 'Nested task');
      expect(loaded.tasks.first.contextLabel, 'ctx');
      expect(loaded.tasks.first.sourceTopicId, 'src-1');
      expect(loaded.tasks.first.assignedPersonIds, ['p1', 'p2']);
    });
  });
}
