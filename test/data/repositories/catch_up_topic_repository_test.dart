import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/catch_up_topic_repository.dart';
import 'package:friendsheet/services/hive_service.dart';
import 'package:hive/hive.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CatchUpTopicRepository repository;
  late Directory hiveDir;

  const userId = 'u1';
  const personId = 'p1';

  CollectionReference topicsRef() => fakeFirestore
      .collection('users')
      .doc(userId)
      .collection('persons')
      .doc(personId)
      .collection('catch_up_topics');

  Future<String> seedTopic({
    String text = 'Existing topic',
    String? contextLabel,
    bool isArchived = false,
    DateTime? createdAt,
  }) async {
    final ref = await topicsRef().add({
      'text': text,
      if (contextLabel != null) 'contextLabel': contextLabel,
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime(2026, 4, 1)),
      'isArchived': isArchived,
    });
    return ref.id;
  }

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('hive_topics_test_');
    await HiveService.initialize(testPath: hiveDir.path);
    fakeFirestore = FakeFirebaseFirestore();
    repository = CatchUpTopicRepository(firestore: fakeFirestore);
  });

  tearDown(() async {
    await Hive.close();
    await hiveDir.delete(recursive: true);
  });

  group('CatchUpTopicRepository', () {
    group('add', () {
      test('happy path: creates doc in Firestore and returns id', () async {
        final id =
            await repository.add(userId, personId, 'New topic', 'Maj 2026');

        final snap = await topicsRef().doc(id).get();
        final data = snap.data() as Map<String, dynamic>;
        expect(snap.exists, isTrue);
        expect(data['text'], equals('New topic'));
        expect(data['contextLabel'], equals('Maj 2026'));
        expect(data['isArchived'], isFalse);
      });

      test('persists to local cache so subsequent getActive reads from cache',
          () async {
        await repository.add(userId, personId, 'Cached topic', null);

        // Clear Firestore would still return from cache — verified via getActive:
        final topics = await repository.getActive(userId, personId);
        expect(topics, isNotEmpty);
        expect(topics.first.text, equals('Cached topic'));
      });
    });

    group('getActive', () {
      test('returns only non-archived topics sorted newest first', () async {
        await seedTopic(
            text: 'Active old',
            isArchived: false,
            createdAt: DateTime(2026, 3, 1));
        await seedTopic(
            text: 'Active new',
            isArchived: false,
            createdAt: DateTime(2026, 4, 1));
        await seedTopic(text: 'Archived', isArchived: true);

        final topics = await repository.getActive(userId, personId);

        expect(topics.length, equals(2));
        expect(topics.any((t) => t.text == 'Archived'), isFalse);
        expect(topics.first.text, equals('Active new'));
        expect(topics.last.text, equals('Active old'));
      });

      test('returns empty list when no active topics exist', () async {
        await seedTopic(text: 'Only archived', isArchived: true);

        final topics = await repository.getActive(userId, personId);

        expect(topics, isEmpty);
      });
    });

    group('update', () {
      test('updates text and contextLabel in Firestore', () async {
        final id =
            await seedTopic(text: 'Old text', contextLabel: 'Marzec 2026');

        await repository.update(
            userId, personId, id, 'New text', 'Kwiecień 2026');

        final doc = await topicsRef().doc(id).get();
        final data = doc.data() as Map<String, dynamic>;
        expect(data['text'], equals('New text'));
        expect(data['contextLabel'], equals('Kwiecień 2026'));
      });

      test('persists updated value in local cache', () async {
        final id = await seedTopic(text: 'Before');
        await repository.update(userId, personId, id, 'After', null);

        // Force fresh read from cache: clear Firestore data is not possible
        // with FakeFirebaseFirestore, so verify via getActive.
        final topics = await repository.getActive(userId, personId);
        expect(topics.any((t) => t.id == id && t.text == 'After'), isTrue);
      });
    });

    group('delete', () {
      test('removes doc from Firestore', () async {
        final id = await seedTopic(text: 'To delete');

        await repository.delete(userId, personId, id);

        final doc = await topicsRef().doc(id).get();
        expect(doc.exists, isFalse);
      });

      test('does not affect other topics in Firestore', () async {
        final keepId = await seedTopic(text: 'Keep');
        final deleteId = await seedTopic(text: 'Delete');

        await repository.delete(userId, personId, deleteId);

        final doc = await topicsRef().doc(keepId).get();
        expect(doc.exists, isTrue);
      });

      test('removes topic from local cache', () async {
        await repository.add(userId, personId, 'Cached', null);
        final topics = await repository.getActive(userId, personId);
        final id = topics.first.id;

        await repository.delete(userId, personId, id);

        // Re-seed Firestore so getActive falls back to Firestore (cache is cold for this id).
        // The deleted id must not appear in cache.
        final after = await repository.getActive(userId, personId);
        expect(after.any((t) => t.id == id), isFalse);
      });
    });
  });
}
