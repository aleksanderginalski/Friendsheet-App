// test/models/meeting_test.dart

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
      activityIds: ['activity-1'],
      createdAt: testDate,
      updatedAt: testDate,
    );

    test('creates Meeting with all required fields', () {
      expect(validMeeting.id, 'meeting-1');
      expect(validMeeting.name, 'Coffee with Anna');
      expect(validMeeting.weight, 8);
      expect(validMeeting.participantIds.length, 2);
      expect(validMeeting.activityIds.length, 1);
    });

    test('categoryIds defaults to empty list', () {
      expect(validMeeting.categoryIds, isEmpty);
    });

    test('categoryIds can be set explicitly', () {
      final meeting = Meeting(
        id: 'm1',
        userId: 'u1',
        name: 'Hiking',
        date: testDate,
        weight: 5,
        participantIds: ['p1'],
        activityIds: ['a1'],
        categoryIds: ['cat-sport', 'cat-gory'],
        createdAt: testDate,
        updatedAt: testDate,
      );
      expect(meeting.categoryIds, equals(['cat-sport', 'cat-gory']));
    });

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

    test('isValid returns false when activityIds is empty', () {
      final invalidMeeting = validMeeting.copyWith(activityIds: []);
      expect(invalidMeeting.isValid(), false);
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = validMeeting.copyWith(name: 'Updated Meeting');

      expect(updated.name, 'Updated Meeting');
      expect(updated.id, validMeeting.id); // Other fields unchanged
      expect(updated.weight, validMeeting.weight);
    });

    test('copyWith updates categoryIds', () {
      final updated = validMeeting.copyWith(
        categoryIds: ['cat-1', 'cat-2'],
      );
      expect(updated.categoryIds, equals(['cat-1', 'cat-2']));
      expect(updated.activityIds, validMeeting.activityIds);
    });

    test('equality works correctly', () {
      final meeting1 = Meeting(
        id: 'same-id',
        userId: 'user-123',
        name: 'Meeting',
        date: testDate,
        weight: 5,
        participantIds: ['p1'],
        activityIds: ['a1'],
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
        activityIds: ['a1'],
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
      expect(map['activityIds'], ['activity-1']);
      expect(map['categoryIds'], isEmpty);
    });

    test('toFirestore includes categoryIds when set', () {
      final meeting = validMeeting.copyWith(
        categoryIds: ['cat-sport', 'cat-gory'],
      );
      final map = meeting.toFirestore();
      expect(map['categoryIds'], equals(['cat-sport', 'cat-gory']));
    });

    test('JSON serialization works', () {
      // Convert to JSON
      final json = validMeeting.toJson();

      // Convert back from JSON
      final fromJson = Meeting.fromJson(json);

      expect(fromJson.id, validMeeting.id);
      expect(fromJson.name, validMeeting.name);
      expect(fromJson.weight, validMeeting.weight);
      expect(fromJson.categoryIds, isEmpty);
    });

    test('validWeights constant contains correct Fibonacci values', () {
      expect(Meeting.validWeights, [1, 2, 3, 5, 8, 13, 21]);
    });
  });
}
