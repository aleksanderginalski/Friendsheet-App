import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/friends_quest.dart';
import 'package:friendsheet/data/repositories/friends_quest_repository.dart';
import 'package:friendsheet/presentation/friends_quest/friends_quest_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'friends_quest_provider_test.mocks.dart';

@GenerateMocks([FriendsQuestRepository])
void main() {
  late MockFriendsQuestRepository mockRepo;
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
    provider = FriendsQuestProvider(repository: mockRepo);
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

    test('createQuest calls repo and refreshes list', () async {
      when(mockRepo.create('u1', 'New quest', ['p1']))
          .thenAnswer((_) async => activeQuest);
      when(mockRepo.getAll('u1')).thenReturn([activeQuest]);

      await provider.createQuest('u1', 'New quest', ['p1']);

      verify(mockRepo.create('u1', 'New quest', ['p1'])).called(1);
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
  });
}
