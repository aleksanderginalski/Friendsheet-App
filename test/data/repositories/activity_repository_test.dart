import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/activity_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ActivityRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = ActivityRepository(firestore: fakeFirestore);
  });

  // Helper: seeds a global activity directly in fake Firestore
  Future<void> addGlobalActivity(String name) async {
    await fakeFirestore.collection('activities').add({
      'name': name,
      'isGlobal': true,
      'userId': null,
      'categoryId': null,
      'createdAt': Timestamp.now(),
    });
  }

  // Helper: seeds a private activity directly in fake Firestore
  Future<void> addPrivateActivity(String name, String userId) async {
    await fakeFirestore.collection('activities').add({
      'name': name,
      'isGlobal': false,
      'userId': userId,
      'categoryId': null,
      'createdAt': Timestamp.now(),
    });
  }

  group('ActivityRepository', () {
    group('getActivitiesByUser', () {
      test('returns empty list when no activities exist', () async {
        final result = await repository.getActivitiesByUser('user-1');
        expect(result, isEmpty);
      });

      test('returns global activities for any user', () async {
        await addGlobalActivity('Running');

        final result = await repository.getActivitiesByUser('user-1');
        expect(result.length, equals(1));
        expect(result.first.name, equals('Running'));
      });

      test('returns private activities for correct user', () async {
        await addPrivateActivity('Yoga', 'user-1');

        final result = await repository.getActivitiesByUser('user-1');
        expect(result.length, equals(1));
        expect(result.first.name, equals('Yoga'));
      });

      test('does not return private activities of other users', () async {
        await addPrivateActivity('Yoga', 'user-2');

        final result = await repository.getActivitiesByUser('user-1');
        expect(result, isEmpty);
      });

      test('returns merged global and private activities', () async {
        await addGlobalActivity('Running');
        await addPrivateActivity('Yoga', 'user-1');

        final result = await repository.getActivitiesByUser('user-1');
        expect(result.length, equals(2));
      });

      test('global activities have isGlobal set to true', () async {
        await addGlobalActivity('Running');

        final result = await repository.getActivitiesByUser('user-1');
        expect(result.first.isGlobal, isTrue);
      });

      test('private activities have isGlobal set to false', () async {
        await addPrivateActivity('Yoga', 'user-1');

        final result = await repository.getActivitiesByUser('user-1');
        expect(result.first.isGlobal, isFalse);
      });
    });

    group('addActivity', () {
      test('returns activity with generated ID', () async {
        final saved = await repository.addActivity(
          userId: 'user-1',
          name: 'Swimming',
        );
        expect(saved.id, isNotEmpty);
      });

      test('returned activity has correct name', () async {
        final saved = await repository.addActivity(
          userId: 'user-1',
          name: 'Swimming',
        );
        expect(saved.name, equals('Swimming'));
      });

      test('returned activity has isGlobal set to false', () async {
        final saved = await repository.addActivity(
          userId: 'user-1',
          name: 'Swimming',
        );
        expect(saved.isGlobal, isFalse);
      });

      test('returned activity has correct userId', () async {
        final saved = await repository.addActivity(
          userId: 'user-42',
          name: 'Swimming',
        );
        expect(saved.userId, equals('user-42'));
      });

      test('stores document in activities collection', () async {
        final saved = await repository.addActivity(
          userId: 'user-1',
          name: 'Swimming',
        );

        final doc =
            await fakeFirestore.collection('activities').doc(saved.id).get();
        expect(doc.exists, isTrue);
      });
    });
  });
}
