import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/catch_up_topic.dart';
import 'package:friendsheet/data/models/friends_quest.dart';
import 'package:friendsheet/data/models/friends_quest_task.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/catch_up_topic_repository.dart';
import 'package:friendsheet/data/repositories/friends_quest_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/presentation/friends_quest/friends_quest_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'friends_quest_provider_test.mocks.dart';

@GenerateMocks(
    [FriendsQuestRepository, CatchUpTopicRepository, PersonRepository])
void main() {
  late MockFriendsQuestRepository mockRepo;
  late MockCatchUpTopicRepository mockCatchUpRepo;
  late MockPersonRepository mockPersonRepo;
  late FriendsQuestProvider provider;

  final activeQuest = FriendsQuest(
    id: 'q1',
    name: 'Weekend crew',
    participantIds: ['p1', 'p2'],
    createdAt: DateTime(2026),
  );
  final completedQuest = FriendsQuest(
    id: 'q2',
    name: 'Done quest',
    participantIds: [],
    createdAt: DateTime(2026),
    isCompleted: true,
  );

  setUp(() {
    mockRepo = MockFriendsQuestRepository();
    mockCatchUpRepo = MockCatchUpTopicRepository();
    mockPersonRepo = MockPersonRepository();
    provider = FriendsQuestProvider(
      repository: mockRepo,
      catchUpRepo: mockCatchUpRepo,
      personRepo: mockPersonRepo,
    );
  });

  tearDown(() => provider.dispose());

  group('FriendsQuestProvider', () {
    test('initial state: quests empty, activeQuests empty, not loading', () {
      expect(provider.quests, isEmpty);
      expect(provider.activeQuests, isEmpty);
      expect(provider.isLoading, false);
    });

    test('loadQuests populates quests from repository', () {
      when(mockRepo.getAll('u1')).thenReturn([activeQuest, completedQuest]);

      provider.loadQuests('u1');

      expect(provider.quests, hasLength(2));
    });

    test('activeQuests returns only non-completed quests', () {
      when(mockRepo.getAll('u1')).thenReturn([activeQuest, completedQuest]);

      provider.loadQuests('u1');

      expect(provider.activeQuests, hasLength(1));
      expect(provider.activeQuests.first.id, 'q1');
    });

    test('createQuest with no participants skips import', () async {
      final noParticipantQuest = FriendsQuest(
        id: 'q3',
        name: 'Solo',
        participantIds: [],
        createdAt: DateTime(2026),
      );
      when(mockRepo.create('u1', 'Solo', []))
          .thenAnswer((_) async => noParticipantQuest);
      when(mockRepo.getAll('u1')).thenReturn([noParticipantQuest]);

      await provider.createQuest('u1', 'Solo', []);

      verify(mockRepo.create('u1', 'Solo', [])).called(1);
      verifyNever(mockPersonRepo.getPersonsByIds(any, any));
      expect(provider.quests, hasLength(1));
      expect(provider.isLoading, false);
    });

    test('deleteQuest calls repo and refreshes list', () async {
      when(mockRepo.getAll('u1')).thenReturn([activeQuest]);
      provider.loadQuests('u1');

      when(mockRepo.delete('u1', 'q1')).thenAnswer((_) async {});
      when(mockRepo.getAll('u1')).thenReturn([]);

      await provider.deleteQuest('u1', 'q1');

      verify(mockRepo.delete('u1', 'q1')).called(1);
      expect(provider.quests, isEmpty);
    });

    test('loadQuests notifies listeners', () {
      when(mockRepo.getAll('u1')).thenReturn([activeQuest]);
      var notified = false;
      provider.addListener(() => notified = true);

      provider.loadQuests('u1');

      expect(notified, true);
    });

    test('addTask without assignees adds task and skips catchup', () async {
      when(mockRepo.getAll('u1')).thenReturn([activeQuest]);
      provider.loadQuests('u1');

      await provider.addTask('u1', 'q1', 'Buy milk', []);

      final captured = verify(mockRepo.updateQuest('u1', captureAny)).captured;
      final saved = captured.last as FriendsQuest;
      expect(saved.tasks, hasLength(1));
      expect(saved.tasks.first.text, 'Buy milk');
      expect(saved.tasks.first.assignedPersonIds, isEmpty);
      expect(saved.tasks.first.sourceTopicId, isNull);
      verifyNever(mockCatchUpRepo.add(any, any, any, any));
    });

    test('addTask with assignees calls catchup.add and sets source fields',
        () async {
      when(mockRepo.getAll('u1')).thenReturn([activeQuest]);
      provider.loadQuests('u1');
      when(mockCatchUpRepo.add('u1', 'p1', 'Buy milk', null))
          .thenAnswer((_) async => 'topic-1');
      when(mockCatchUpRepo.add('u1', 'p2', 'Buy milk', null))
          .thenAnswer((_) async => 'topic-2');

      await provider.addTask('u1', 'q1', 'Buy milk', ['p1', 'p2']);

      verify(mockCatchUpRepo.add('u1', 'p1', 'Buy milk', null)).called(1);
      verify(mockCatchUpRepo.add('u1', 'p2', 'Buy milk', null)).called(1);
      final captured = verify(mockRepo.updateQuest('u1', captureAny)).captured;
      final saved = captured.last as FriendsQuest;
      expect(saved.tasks.first.sourceTopicId, 'topic-1');
      expect(saved.tasks.first.sourcePersonId, 'p1');
      expect(saved.tasks.first.assignedPersonIds, ['p1', 'p2']);
    });

    test('deleteTask removes task from quest', () async {
      final questWithTask = activeQuest.copyWith(tasks: [
        const FriendsQuestTask(id: 't1', text: 'Do something'),
      ]);
      when(mockRepo.getAll('u1')).thenReturn([questWithTask]);
      provider.loadQuests('u1');

      await provider.deleteTask('u1', 'q1', 't1');

      final captured = verify(mockRepo.updateQuest('u1', captureAny)).captured;
      final saved = captured.last as FriendsQuest;
      expect(saved.tasks, isEmpty);
    });

    test('editTask without sourceTopicId updates text only, no catchup call',
        () async {
      final questWithTask = activeQuest.copyWith(tasks: [
        const FriendsQuestTask(id: 't1', text: 'Old text'),
      ]);
      when(mockRepo.getAll('u1')).thenReturn([questWithTask]);
      provider.loadQuests('u1');

      await provider.editTask('u1', 'q1', 't1', 'New text');

      verifyNever(mockCatchUpRepo.update(any, any, any, any, any));
      final captured = verify(mockRepo.updateQuest('u1', captureAny)).captured;
      final saved = captured.last as FriendsQuest;
      expect(saved.tasks.first.text, 'New text');
    });

    test('editTask with sourceTopicId calls catchup.update', () async {
      final questWithTask = activeQuest.copyWith(tasks: [
        const FriendsQuestTask(
          id: 't1',
          text: 'Old text',
          sourceTopicId: 'src-1',
          sourcePersonId: 'p1',
        ),
      ]);
      when(mockRepo.getAll('u1')).thenReturn([questWithTask]);
      provider.loadQuests('u1');
      when(mockPersonRepo.getPersonsByIds(['p1'], 'u1'))
          .thenAnswer((_) async => []);

      await provider.editTask('u1', 'q1', 't1', 'New text');

      verify(mockCatchUpRepo.update('u1', 'p1', 'src-1', 'New text', null))
          .called(1);
    });

    test('updateParticipants keeps manual tasks and drops imported tasks',
        () async {
      final questWithTasks = activeQuest.copyWith(tasks: [
        const FriendsQuestTask(id: 't1', text: 'Manual'),
        const FriendsQuestTask(
            id: 't2', text: 'Imported', sourceTopicId: 'src-1'),
      ]);
      when(mockRepo.getAll('u1')).thenReturn([questWithTasks]);
      provider.loadQuests('u1');
      when(mockPersonRepo.getPersonsByIds(any, any))
          .thenAnswer((_) async => []);

      await provider.updateParticipants('u1', 'q1', ['p3']);

      final allCaptured =
          verify(mockRepo.updateQuest('u1', captureAny)).captured;
      final firstSaved = allCaptured.first as FriendsQuest;
      expect(firstSaved.tasks, hasLength(1));
      expect(firstSaved.tasks.first.id, 't1');
      expect(firstSaved.participantIds, ['p3']);
    });

    test('createQuest with participants imports topics as tasks', () async {
      final createdQuest = FriendsQuest(
        id: 'q3',
        name: 'Import test',
        participantIds: ['p1'],
        createdAt: DateTime(2026),
      );
      when(mockRepo.create('u1', 'Import test', ['p1']))
          .thenAnswer((_) async => createdQuest);
      when(mockRepo.getAll('u1')).thenReturn([createdQuest]);

      final person = Person(
        id: 'p1',
        userId: 'u1',
        firstName: 'Alice',
        createdAt: DateTime(2026),
      );
      when(mockPersonRepo.getPersonsByIds(['p1'], 'u1'))
          .thenAnswer((_) async => [person]);
      final topic = CatchUpTopic(
        id: 'topic-1',
        text: 'Catch up',
        createdAt: DateTime(2026),
      );
      when(mockCatchUpRepo.getActive('u1', 'p1'))
          .thenAnswer((_) async => [topic]);

      await provider.createQuest('u1', 'Import test', ['p1']);

      final allCaptured =
          verify(mockRepo.updateQuest('u1', captureAny)).captured;
      final savedQuest = allCaptured.last as FriendsQuest;
      expect(savedQuest.tasks, hasLength(1));
      expect(savedQuest.tasks.first.text, 'Catch up');
      expect(savedQuest.tasks.first.sourceTopicId, 'topic-1');
      expect(savedQuest.tasks.first.assignedPersonIds, ['p1']);
      expect(provider.isLoading, false);
    });
  });
}
