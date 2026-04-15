import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/catch_up_topic.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  // Seeds a topic doc into Firestore and returns its DocumentSnapshot.
  Future<DocumentSnapshot> seedDoc(Map<String, dynamic> data) async {
    final ref = await fakeFirestore
        .collection('users')
        .doc('u1')
        .collection('catch_up_topics')
        .add(data);
    return ref.get();
  }

  group('CatchUpTopic', () {
    group('fromFirestore', () {
      test('happy path: maps all fields correctly', () async {
        final now = DateTime(2026, 4, 15, 10, 0);
        final archived = DateTime(2026, 4, 20, 12, 0);
        final doc = await seedDoc({
          'text': 'Ask about the project',
          'contextLabel': 'Maj 2026',
          'createdAt': Timestamp.fromDate(now),
          'isArchived': true,
          'archivedAt': Timestamp.fromDate(archived),
        });

        final topic = CatchUpTopic.fromFirestore(doc);

        expect(topic.id, equals(doc.id));
        expect(topic.text, equals('Ask about the project'));
        expect(topic.contextLabel, equals('Maj 2026'));
        expect(topic.createdAt, equals(now));
        expect(topic.isArchived, isTrue);
        expect(topic.archivedAt, equals(archived));
      });

      test('nullable fields absent: contextLabel and archivedAt are null',
          () async {
        final doc = await seedDoc({
          'text': 'Catch up on travels',
          'createdAt': Timestamp.fromDate(DateTime(2026, 3, 1)),
          'isArchived': false,
        });

        final topic = CatchUpTopic.fromFirestore(doc);

        expect(topic.contextLabel, isNull);
        expect(topic.archivedAt, isNull);
        expect(topic.isArchived, isFalse);
      });

      test('missing createdAt falls back to epoch', () async {
        final doc = await seedDoc({'text': 'Topic without date'});

        final topic = CatchUpTopic.fromFirestore(doc);

        expect(topic.createdAt, equals(DateTime.fromMillisecondsSinceEpoch(0)));
      });

      test('missing isArchived defaults to false', () async {
        final doc = await seedDoc({
          'text': 'No archived field',
          'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
        });

        final topic = CatchUpTopic.fromFirestore(doc);

        expect(topic.isArchived, isFalse);
      });
    });

    group('toFirestore', () {
      test('serializes all non-null fields', () async {
        final now = DateTime(2026, 4, 15);
        final archived = DateTime(2026, 4, 20);
        final topic = CatchUpTopic(
          id: 'tid',
          text: 'My topic',
          contextLabel: 'Czerwiec 2026',
          createdAt: now,
          isArchived: true,
          archivedAt: archived,
        );

        final map = topic.toFirestore();

        expect(map['text'], equals('My topic'));
        expect(map['contextLabel'], equals('Czerwiec 2026'));
        expect(map['createdAt'], equals(Timestamp.fromDate(now)));
        expect(map['isArchived'], isTrue);
        expect(map['archivedAt'], equals(Timestamp.fromDate(archived)));
      });

      test('omits contextLabel and archivedAt when null', () async {
        final topic = CatchUpTopic(
          id: 'tid',
          text: 'Simple topic',
          createdAt: DateTime(2026, 4, 1),
        );

        final map = topic.toFirestore();

        expect(map.containsKey('contextLabel'), isFalse);
        expect(map.containsKey('archivedAt'), isFalse);
      });
    });

    group('copyWith', () {
      test('creates updated copy without mutating original', () {
        final original = CatchUpTopic(
          id: 'tid',
          text: 'Original',
          createdAt: DateTime(2026, 4, 1),
        );

        final updated =
            original.copyWith(text: 'Updated', contextLabel: 'Lipiec 2026');

        expect(updated.text, equals('Updated'));
        expect(updated.contextLabel, equals('Lipiec 2026'));
        expect(updated.id, equals('tid'));
        expect(original.text, equals('Original'));
      });
    });
  });
}
