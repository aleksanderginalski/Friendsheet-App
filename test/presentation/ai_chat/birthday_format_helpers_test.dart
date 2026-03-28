import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/buddy_context.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/presentation/ai_chat/birthday_format_helpers.dart';
import 'package:friendsheet/presentation/ai_chat/buddy_chat_mode.dart';

void main() {
  // ---------------------------------------------------------------------------
  // formatBirthdayStats
  // ---------------------------------------------------------------------------

  group('formatBirthdayStats', () {
    const fullEntry = PersonContextEntry(
      pseudonym: 'Friend_A',
      meetingCount: 10,
      topActivities: ['Chess', 'Coffee'],
      meetingsByYear: {2026: 6, 2025: 4},
      totalWeight: 30,
    );

    test('includes year-over-year meeting counts', () {
      final result = formatBirthdayStats(fullEntry, 'Anna', 2026);
      expect(result, contains('6 meetings'));
      expect(result, contains('vs 4 in 2025'));
    });

    test('includes total weight when > 0', () {
      final result = formatBirthdayStats(fullEntry, 'Anna', 2026);
      expect(result, contains('30 pts'));
    });

    test('omits weight line when totalWeight is 0', () {
      const noWeight = PersonContextEntry(
        pseudonym: 'Friend_B',
        meetingCount: 3,
        topActivities: ['Sport'],
        totalWeight: 0,
      );
      final result = formatBirthdayStats(noWeight, 'Bob', 2026);
      expect(result, isNot(contains('pts')));
    });

    test('shows fallback text when topActivities is empty', () {
      const noActs = PersonContextEntry(
        pseudonym: 'Friend_C',
        meetingCount: 2,
        topActivities: [],
      );
      final result = formatBirthdayStats(noActs, 'Cara', 2026);
      expect(result, contains('no recorded activities yet'));
    });

    test('includes person name and total meeting count', () {
      final result = formatBirthdayStats(fullEntry, 'Anna', 2026);
      expect(result, contains('Anna'));
      expect(result, contains('10 total'));
    });
  });

  // ---------------------------------------------------------------------------
  // buildBirthdayListGreeting
  // ---------------------------------------------------------------------------

  group('buildBirthdayListGreeting', () {
    final person = Person(
      id: 'p1',
      userId: 'u1',
      firstName: 'Ada',
      createdAt: DateTime(2026, 1, 1),
      birthDayMonth: '06-15',
    );

    test('returns no-birthday message when list is empty', () {
      final result = buildBirthdayListGreeting([]);
      expect(result, contains('No birthdays found'));
    });

    test('returns prompt to tap when list is non-empty', () {
      final result = buildBirthdayListGreeting([
        BirthdayPersonInfo(person: person, daysUntil: 5),
      ]);
      expect(result, contains('upcoming birthdays'));
      expect(result, contains('Tap one'));
    });

    test('does not list person names in text (buttons handle that)', () {
      final result = buildBirthdayListGreeting([
        BirthdayPersonInfo(person: person, daysUntil: 5),
      ]);
      expect(result, isNot(contains('Ada')));
    });
  });

  // ---------------------------------------------------------------------------
  // birthdayActionLabel
  // ---------------------------------------------------------------------------

  group('birthdayActionLabel', () {
    test('includes full name when lastName is present', () {
      final person = Person(
        id: 'p1',
        userId: 'u1',
        firstName: 'Ada',
        lastName: 'Machura',
        createdAt: DateTime(2026, 1, 1),
        birthDayMonth: '06-15',
      );
      final result = birthdayActionLabel(
          BirthdayPersonInfo(person: person, daysUntil: 10));
      expect(result, contains('Ada Machura'));
    });

    test('uses firstName only when lastName is absent', () {
      final person = Person(
        id: 'p2',
        userId: 'u1',
        firstName: 'Bartek',
        createdAt: DateTime(2026, 1, 1),
        birthDayMonth: '09-20',
      );
      final result =
          birthdayActionLabel(BirthdayPersonInfo(person: person, daysUntil: 5));
      expect(result, contains('Bartek'));
      expect(result, isNot(contains('null')));
    });

    test('uses "day" singular for 1 day', () {
      final person = Person(
        id: 'p3',
        userId: 'u1',
        firstName: 'Ola',
        createdAt: DateTime(2026, 1, 1),
        birthDayMonth: '12-25',
      );
      final result =
          birthdayActionLabel(BirthdayPersonInfo(person: person, daysUntil: 1));
      expect(result, contains('1 day'));
      expect(result, isNot(contains('1 days')));
    });

    test('uses "days" plural for > 1', () {
      final person = Person(
        id: 'p4',
        userId: 'u1',
        firstName: 'Kim',
        createdAt: DateTime(2026, 1, 1),
        birthDayMonth: '04-15',
      );
      final result =
          birthdayActionLabel(BirthdayPersonInfo(person: person, daysUntil: 7));
      expect(result, contains('7 days'));
    });

    test('starts with birthday emoji', () {
      final person = Person(
        id: 'p5',
        userId: 'u1',
        firstName: 'Max',
        createdAt: DateTime(2026, 1, 1),
        birthDayMonth: '03-10',
      );
      final result =
          birthdayActionLabel(BirthdayPersonInfo(person: person, daysUntil: 3));
      expect(result, startsWith('🎂'));
    });
  });
}
