// test/models/meeting_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';

void main() {
  group('Meeting Model Tests', () {
    // Sample test data
    final testDate = DateTime(2026, 2, 18);

    final validMeeting = Meeting(
      id: 'meeting-1',
      userId: 'user-123',
      name: 'Coffee with Anna',
      date: testDate,
      weight: 8,
      participantIds: ['person-1', 'person-2'],
      categoryIds: ['cat-1'],
      createdAt: testDate,
      updatedAt: testDate,
    );

    test('isValid returns true for valid meeting', () {
      expect(validMeeting.isValid(), true);
    });

    test('isValid returns false when name is empty', () {
      final invalidMeeting = validMeeting.copyWith(name: '');
      expect(invalidMeeting.isValid(), false);
    });

    test('isValid returns false when name exceeds 50 characters', () {
      final longName = 'A' * 51;
      final invalidMeeting = validMeeting.copyWith(name: longName);
      expect(invalidMeeting.isValid(), false);
    });

    test('isValid returns false when weight is invalid', () {
      final invalidMeeting = validMeeting.copyWith(weight: 7);
      expect(invalidMeeting.isValid(), false);
    });

    test('isValid returns false when participantIds is empty', () {
      final invalidMeeting = validMeeting.copyWith(participantIds: []);
      expect(invalidMeeting.isValid(), false);
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = validMeeting.copyWith(
        name: 'Updated Meeting',
        categoryIds: ['cat-1', 'cat-2'],
      );

      expect(updated.name, 'Updated Meeting');
      expect(updated.categoryIds, equals(['cat-1', 'cat-2']));
      expect(updated.id, validMeeting.id);
      expect(updated.weight, validMeeting.weight);
    });

    test('equality works correctly', () {
      final meeting1 = Meeting(
        id: 'same-id',
        userId: 'user-123',
        name: 'Meeting',
        date: testDate,
        weight: 5,
        participantIds: ['p1'],
        createdAt: testDate,
        updatedAt: testDate,
      );

      final meeting2 = Meeting(
        id: 'same-id',
        userId: 'user-123',
        name: 'Meeting',
        date: testDate,
        weight: 5,
        participantIds: ['p1'],
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(meeting1 == meeting2, true);
    });

    test('toFirestore converts to correct Map', () {
      final map = validMeeting.toFirestore();

      expect(map['userId'], 'user-123');
      expect(map['name'], 'Coffee with Anna');
      expect(map['weight'], 8);
      expect(map['participantIds'], ['person-1', 'person-2']);
      expect(map['categoryIds'], ['cat-1']);
      expect(map.containsKey('activityIds'), isFalse);
    });

    test('JSON serialization works', () {
      // Convert to JSON
      final json = validMeeting.toJson();

      // Convert back from JSON
      final fromJson = Meeting.fromJson(json);

      expect(fromJson.id, validMeeting.id);
      expect(fromJson.name, validMeeting.name);
      expect(fromJson.weight, validMeeting.weight);
      expect(fromJson.categoryIds, equals(['cat-1']));
    });

    test('validWeights constant contains correct Fibonacci values', () {
      expect(Meeting.validWeights, [1, 2, 3, 5, 8, 13, 21]);
    });

    test('toFirestore serializes non-empty notes list', () {
      final map = validMeeting.copyWith(
        notes: ['Guitar session', 'Kayaking'],
      ).toFirestore();

      expect(map['notes'], equals(['Guitar session', 'Kayaking']));
    });

    test('fromFirestore reads notes field from document', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final now = Timestamp.fromDate(testDate);

      final docRef = await fakeFirestore
          .collection('users')
          .doc('u1')
          .collection('meetings')
          .add({
        'userId': 'u1',
        'name': 'Test',
        'date': now,
        'weight': 3,
        'participantIds': ['p1'],
        'categoryIds': [],
        'notes': ['Guitar', 'Kayaking'],
        'createdAt': now,
        'updatedAt': now,
      });

      final meeting = Meeting.fromFirestore(await docRef.get());

      expect(meeting.notes, equals(['Guitar', 'Kayaking']));
    });

    test('fromFirestore defaults notes to empty list when field missing',
        () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final now = Timestamp.fromDate(testDate);

      final docRef = await fakeFirestore
          .collection('users')
          .doc('u1')
          .collection('meetings')
          .add({
        'userId': 'u1',
        'name': 'Test',
        'date': now,
        'weight': 3,
        'participantIds': ['p1'],
        'categoryIds': [],
        // no 'notes' field — simulates legacy document without notes
        'createdAt': now,
        'updatedAt': now,
      });

      final meeting = Meeting.fromFirestore(await docRef.get());

      expect(meeting.notes, isEmpty);
    });
  });
}
