import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/friend_group.dart';
import 'package:friendsheet/data/repositories/friend_group_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/persons/friend_groups_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'friend_groups_provider_test.mocks.dart';

@GenerateMocks([FriendGroupRepository, AuthService])
void main() {
  late MockFriendGroupRepository mockRepo;
  late MockAuthService mockAuth;
  late FriendGroupsProvider provider;

  final group1 = FriendGroup(
    id: 'g1',
    name: 'Hikers',
    personIds: ['p1', 'p2'],
    createdAt: DateTime(2026, 3, 1),
  );
  final group2 = FriendGroup(
    id: 'g2',
    name: 'Cyclists',
    personIds: ['p2', 'p3'],
    createdAt: DateTime(2026, 3, 2),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockRepo = MockFriendGroupRepository();
    mockAuth = MockAuthService();
    when(mockAuth.currentUserId).thenReturn('u1');
    provider = FriendGroupsProvider(
      repository: mockRepo,
      authService: mockAuth,
    );
  });

  group('FriendGroupsProvider', () {
    group('loadGroups', () {
      test('sets groups from repository and clears isLoading', () async {
        when(mockRepo.getGroupsByUser('u1'))
            .thenAnswer((_) async => [group1, group2]);

        await provider.loadGroups();

        expect(provider.isLoading, isFalse);
        expect(provider.groups.length, equals(2));
        expect(provider.errorMessage, isNull);
      });

      test('sets errorMessage and clears isLoading on exception', () async {
        when(mockRepo.getGroupsByUser('u1'))
            .thenThrow(Exception('network error'));

        await provider.loadGroups();

        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNotNull);
        expect(provider.groups, isEmpty);
      });

      test('does nothing when userId is null', () async {
        when(mockAuth.currentUserId).thenReturn(null);

        await provider.loadGroups();

        verifyNever(mockRepo.getGroupsByUser(any));
        expect(provider.groups, isEmpty);
      });
    });

    group('addGroup', () {
      test('calls repository addGroup then reloads groups', () async {
        when(mockRepo.addGroup(any, any)).thenAnswer((_) async {});
        when(mockRepo.getGroupsByUser('u1')).thenAnswer((_) async => [group1]);

        await provider.addGroup(name: 'Hikers', iconIdentifier: 'hiking');

        verify(mockRepo.addGroup('u1', any)).called(1);
        verify(mockRepo.getGroupsByUser('u1')).called(1);
        expect(provider.groups.length, equals(1));
      });
    });

    group('deleteGroup', () {
      test('calls repository deleteGroup then reloads groups', () async {
        when(mockRepo.deleteGroup(any, any)).thenAnswer((_) async {});
        when(mockRepo.getGroupsByUser('u1')).thenAnswer((_) async => []);

        await provider.deleteGroup('g1');

        verify(mockRepo.deleteGroup('u1', 'g1')).called(1);
        expect(provider.groups, isEmpty);
      });
    });

    group('addPersonToGroup', () {
      test('applies optimistic update before repository call', () async {
        // Seed provider with a group that does not yet contain p3.
        when(mockRepo.getGroupsByUser('u1')).thenAnswer((_) async => [group1]);
        await provider.loadGroups();

        // Capture state during the repository call — after optimistic update.
        bool optimisticSeen = false;
        when(mockRepo.addPersonToGroup(any, any, any)).thenAnswer((_) async {
          optimisticSeen = provider.groups
              .any((g) => g.id == 'g1' && g.personIds.contains('p3'));
        });
        when(mockRepo.getGroupsByUser('u1')).thenAnswer((_) async => [group1]);

        await provider.addPersonToGroup('g1', 'p3');

        expect(optimisticSeen, isTrue);
      });

      test('does not duplicate personId already in group', () async {
        when(mockRepo.getGroupsByUser('u1')).thenAnswer((_) async => [group1]);
        await provider.loadGroups();

        when(mockRepo.addPersonToGroup(any, any, any)).thenAnswer((_) async {});
        when(mockRepo.getGroupsByUser('u1')).thenAnswer((_) async => [group1]);

        // p1 is already in group1 — optimistic update must not duplicate.
        await provider.addPersonToGroup('g1', 'p1');

        final g = provider.groups.firstWhere((g) => g.id == 'g1');
        expect(g.personIds.where((id) => id == 'p1').length, equals(1));
      });
    });

    group('removePersonFromGroup', () {
      test('applies optimistic update before repository call', () async {
        when(mockRepo.getGroupsByUser('u1')).thenAnswer((_) async => [group1]);
        await provider.loadGroups();

        bool optimisticSeen = false;
        when(mockRepo.removePersonFromGroup(any, any, any))
            .thenAnswer((_) async {
          optimisticSeen = provider.groups
              .any((g) => g.id == 'g1' && !g.personIds.contains('p1'));
        });
        when(mockRepo.getGroupsByUser('u1')).thenAnswer((_) async => [group1]);

        await provider.removePersonFromGroup('g1', 'p1');

        expect(optimisticSeen, isTrue);
      });
    });

    group('groupsForPerson', () {
      test('returns groups containing personId', () async {
        when(mockRepo.getGroupsByUser('u1'))
            .thenAnswer((_) async => [group1, group2]);
        await provider.loadGroups();

        // p2 is in both groups.
        final result = provider.groupsForPerson('p2');
        expect(result.length, equals(2));
      });

      test('returns empty list when personId not in any group', () async {
        when(mockRepo.getGroupsByUser('u1'))
            .thenAnswer((_) async => [group1, group2]);
        await provider.loadGroups();

        final result = provider.groupsForPerson('p-absent');
        expect(result, isEmpty);
      });
    });

    group('clearError', () {
      test('clears errorMessage', () async {
        when(mockRepo.getGroupsByUser('u1')).thenThrow(Exception('boom'));
        await provider.loadGroups();
        expect(provider.errorMessage, isNotNull);

        provider.clearError();

        expect(provider.errorMessage, isNull);
      });
    });
  });
}
