import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/catch_up_topic.dart';
import 'package:friendsheet/data/repositories/catch_up_topic_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/persons/catch_up_topics_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catch_up_topics_provider_test.mocks.dart';

@GenerateMocks([CatchUpTopicRepository, AuthService])
void main() {
  late MockCatchUpTopicRepository mockRepo;
  late MockAuthService mockAuth;
  late CatchUpTopicsProvider provider;

  final topic1 = CatchUpTopic(
    id: 't1',
    text: 'Topic one',
    createdAt: DateTime(2026, 4, 10),
  );
  final topic2 = CatchUpTopic(
    id: 't2',
    text: 'Topic two',
    contextLabel: 'Maj 2026',
    createdAt: DateTime(2026, 4, 5),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockRepo = MockCatchUpTopicRepository();
    mockAuth = MockAuthService();
    when(mockAuth.currentUserId).thenReturn('u1');
    provider = CatchUpTopicsProvider(
      repository: mockRepo,
      authService: mockAuth,
    );
  });

  group('CatchUpTopicsProvider', () {
    group('initial state', () {
      test('all defaults', () {
        expect(provider.topics, isEmpty);
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
      });
    });

    group('loadTopics', () {
      test('happy path: sets topics, clears isLoading and errorMessage',
          () async {
        when(mockRepo.getActive('u1', 'p1'))
            .thenAnswer((_) async => [topic1, topic2]);

        await provider.loadTopics('p1');

        expect(provider.isLoading, isFalse);
        expect(provider.topics.length, equals(2));
        expect(provider.errorMessage, isNull);
      });

      test('sets errorMessage and clears isLoading on exception', () async {
        when(mockRepo.getActive('u1', 'p1'))
            .thenThrow(Exception('network failure'));

        await provider.loadTopics('p1');

        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNotNull);
        expect(provider.topics, isEmpty);
      });
    });

    group('addTopic', () {
      test('prepends new topic to list after Firestore write', () async {
        when(mockRepo.getActive('u1', 'p1'))
            .thenAnswer((_) async => [topic1, topic2]);
        await provider.loadTopics('p1');

        when(mockRepo.add('u1', 'p1', 'New topic', 'Czerwiec 2026'))
            .thenAnswer((_) async => 'new-id');

        await provider.addTopic('p1', 'New topic', 'Czerwiec 2026');

        expect(provider.topics.first.id, equals('new-id'));
        expect(provider.topics.first.text, equals('New topic'));
        expect(provider.topics.first.contextLabel, equals('Czerwiec 2026'));
        expect(provider.topics.length, equals(3));
      });

      test('sets errorMessage when repository throws', () async {
        when(mockRepo.add(any, any, any, any))
            .thenThrow(Exception('write failed'));

        await provider.addTopic('p1', 'Fail topic', null);

        expect(provider.errorMessage, isNotNull);
      });
    });

    group('deleteTopic', () {
      test('removes topic optimistically before Firestore call', () async {
        when(mockRepo.getActive('u1', 'p1'))
            .thenAnswer((_) async => [topic1, topic2]);
        await provider.loadTopics('p1');

        bool optimisticSeen = false;
        when(mockRepo.delete('u1', 'p1', 't1')).thenAnswer((_) async {
          optimisticSeen = provider.topics.every((t) => t.id != 't1');
          return;
        });

        await provider.deleteTopic('p1', 't1');

        expect(optimisticSeen, isTrue);
        expect(provider.topics.any((t) => t.id == 't1'), isFalse);
        expect(provider.topics.length, equals(1));
      });
    });

    group('dispose guard', () {
      test('does not throw when notifyListeners called after dispose', () {
        provider.dispose();
        // notifyListeners after dispose must be silent — no assertion error.
        expect(() => provider.notifyListeners(), returnsNormally);
      });
    });
  });
}
