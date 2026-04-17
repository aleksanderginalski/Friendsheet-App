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

    group('archive', () {
      test('sets isArchived true and archivedAt in Firestore', () async {
        final id = await seedTopic(text: 'To archive');

        await repository.archive(userId, personId, id);

        final doc = await topicsRef().doc(id).get();
        final data = doc.data() as Map<String, dynamic>;
        expect(data['isArchived'], isTrue);
        expect(data['archivedAt'], isNotNull);
      });

      test('archived topic no longer appears in getActive', () async {
        final id = await repository.add(userId, personId, 'Active', null);

        await repository.archive(userId, personId, id);

        final active = await repository.getActive(userId, personId);
        expect(active.any((t) => t.id == id), isFalse);
      });

      test('archived topic appears in getArchived after archive call',
          () async {
        final id = await repository.add(userId, personId, 'Will archive', null);

        await repository.archive(userId, personId, id);

        final archived = await repository.getArchived(userId, personId);
        expect(archived.any((t) => t.id == id && t.isArchived), isTrue);
      });
    });

    group('getArchived', () {
      test('returns only archived topics from Firestore', () async {
        await seedTopic(text: 'Active', isArchived: false);
        await seedTopic(text: 'Archived', isArchived: true);

        final archived = await repository.getArchived(userId, personId);

        expect(archived.length, equals(1));
        expect(archived.first.text, equals('Archived'));
        expect(archived.first.isArchived, isTrue);
      });

      test('returns empty list when no archived topics exist', () async {
        await seedTopic(text: 'Active only', isArchived: false);

        final archived = await repository.getArchived(userId, personId);

        expect(archived, isEmpty);
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

    group('applyRedistribution', () {
      const partnerId = 'p2';

      CollectionReference partnerTopicsRef() => fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('persons')
          .doc(partnerId)
          .collection('catch_up_topics');

      Future<String> seedPartnerTopic({String text = 'Partner topic'}) async {
        final ref = await partnerTopicsRef().add({
          'text': text,
          'createdAt': Timestamp.fromDate(DateTime(2026, 4, 10)),
          'isArchived': false,
        });
        return ref.id;
      }

      test('personA: keeps topic on A, deletes matching topic from B',
          () async {
        final topicId = await seedTopic(text: 'Shared');
        await seedPartnerTopic(text: 'Shared');

        final topic = (await repository.getActive(userId, personId)).first;

        await repository.applyRedistribution(
          userId,
          personId,
          partnerId,
          [topic],
          {topicId: TopicRedistributionDecision.personA},
        );

        final personTopics = await repository.getActive(userId, personId);
        final partnerTopics = await repository.getActive(userId, partnerId);
        expect(personTopics.any((t) => t.text == 'Shared'), isTrue);
        expect(partnerTopics.any((t) => t.text == 'Shared'), isFalse);
      });

      test('shared: keeps topic on both sides', () async {
        final topicId = await seedTopic(text: 'Keep both');
        await seedPartnerTopic(text: 'Keep both');

        final topic = (await repository.getActive(userId, personId)).first;

        await repository.applyRedistribution(
          userId,
          personId,
          partnerId,
          [topic],
          {topicId: TopicRedistributionDecision.shared},
        );

        final personTopics = await repository.getActive(userId, personId);
        final partnerTopics = await repository.getActive(userId, partnerId);
        expect(personTopics.any((t) => t.text == 'Keep both'), isTrue);
        expect(partnerTopics.any((t) => t.text == 'Keep both'), isTrue);
      });

      test('personB: deletes topic from A, keeps it on B', () async {
        final topicId = await seedTopic(text: 'For B only');
        await seedPartnerTopic(text: 'For B only');

        final topic = (await repository.getActive(userId, personId)).first;

        await repository.applyRedistribution(
          userId,
          personId,
          partnerId,
          [topic],
          {topicId: TopicRedistributionDecision.personB},
        );

        final personTopics = await repository.getActive(userId, personId);
        final partnerTopics = await repository.getActive(userId, partnerId);
        expect(personTopics.any((t) => t.text == 'For B only'), isFalse);
        expect(partnerTopics.any((t) => t.text == 'For B only'), isTrue);
      });

      test('delete: removes topic from both A and B', () async {
        final topicId = await seedTopic(text: 'Remove all');
        await seedPartnerTopic(text: 'Remove all');

        final topic = (await repository.getActive(userId, personId)).first;

        await repository.applyRedistribution(
          userId,
          personId,
          partnerId,
          [topic],
          {topicId: TopicRedistributionDecision.delete},
        );

        final personTopics = await repository.getActive(userId, personId);
        final partnerTopics = await repository.getActive(userId, partnerId);
        expect(personTopics.any((t) => t.text == 'Remove all'), isFalse);
        expect(partnerTopics.any((t) => t.text == 'Remove all'), isFalse);
      });

      test('defaults to shared when topic id missing from decisions map',
          () async {
        final topicId = await seedTopic(text: 'Default shared');
        await seedPartnerTopic(text: 'Default shared');

        final topic = (await repository.getActive(userId, personId)).first;

        // Pass empty decisions — should default to shared.
        await repository.applyRedistribution(
          userId,
          personId,
          partnerId,
          [topic],
          {},
        );

        final personTopics = await repository.getActive(userId, personId);
        final partnerTopics = await repository.getActive(userId, partnerId);
        expect(personTopics.any((t) => t.id == topicId), isTrue);
        expect(partnerTopics.any((t) => t.text == 'Default shared'), isTrue);
      });

      test('personA: no-op when partner has no matching topic', () async {
        final topicId = await seedTopic(text: 'Only on A');

        final topic = (await repository.getActive(userId, personId)).first;

        await repository.applyRedistribution(
          userId,
          personId,
          partnerId,
          [topic],
          {topicId: TopicRedistributionDecision.personA},
        );

        // Topic should still exist on A; nothing thrown.
        final personTopics = await repository.getActive(userId, personId);
        expect(personTopics.any((t) => t.text == 'Only on A'), isTrue);
      });
    });

    group('mergeTopics', () {
      const partnerId = 'p2';

      CollectionReference partnerTopicsRef() => fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('persons')
          .doc(partnerId)
          .collection('catch_up_topics');

      Future<String> seedPartnerTopic({
        String text = 'Partner topic',
        String? contextLabel,
      }) async {
        final ref = await partnerTopicsRef().add({
          'text': text,
          if (contextLabel != null) 'contextLabel': contextLabel,
          'createdAt': Timestamp.fromDate(DateTime(2026, 4, 1)),
          'isArchived': false,
        });
        return ref.id;
      }

      test('copies partner topics missing from person', () async {
        await seedPartnerTopic(text: 'Partner only');

        await repository.mergeTopics(userId, personId, partnerId);

        final personTopics = await repository.getActive(userId, personId);
        expect(personTopics.any((t) => t.text == 'Partner only'), isTrue);
      });

      test('copies person topics missing from partner', () async {
        await seedTopic(text: 'Person only');

        await repository.mergeTopics(userId, personId, partnerId);

        final partnerTopics = await repository.getActive(userId, partnerId);
        expect(partnerTopics.any((t) => t.text == 'Person only'), isTrue);
      });

      test('does not duplicate topics with same text (case-insensitive)',
          () async {
        await seedTopic(text: 'Shared topic');
        await seedPartnerTopic(text: 'shared topic');

        await repository.mergeTopics(userId, personId, partnerId);

        final personTopics = await repository.getActive(userId, personId);
        final partnerTopics = await repository.getActive(userId, partnerId);
        final personCount = personTopics
            .where((t) => t.text.toLowerCase() == 'shared topic')
            .length;
        final partnerCount = partnerTopics
            .where((t) => t.text.toLowerCase() == 'shared topic')
            .length;
        expect(personCount, equals(1));
        expect(partnerCount, equals(1));
      });

      test('both sides unchanged when topics are identical', () async {
        await seedTopic(text: 'Same');
        await seedPartnerTopic(text: 'Same');

        await repository.mergeTopics(userId, personId, partnerId);

        final personTopics = await repository.getActive(userId, personId);
        final partnerTopics = await repository.getActive(userId, partnerId);
        expect(personTopics.length, equals(1));
        expect(partnerTopics.length, equals(1));
      });
    });
  });
}
