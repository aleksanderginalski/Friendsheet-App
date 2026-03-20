import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/import_candidate.dart';
import 'package:friendsheet/presentation/providers/meeting_inbox_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MeetingInboxProvider provider;

  final candidate1 = ImportCandidate(
    id: 'c1',
    title: 'Team lunch',
    date: DateTime(2025, 6, 1),
    attendeeEmails: const ['alice@example.com'],
    sourceType: ImportSourceType.calendar,
  );

  final candidate2 = ImportCandidate(
    id: 'c2',
    title: 'Coffee chat',
    date: DateTime(2025, 6, 5),
    attendeeEmails: const [],
    sourceType: ImportSourceType.calendar,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    provider = MeetingInboxProvider();
    await provider.loadFromPrefs();
  });

  tearDown(() {
    provider.dispose();
  });

  group('MeetingInboxProvider - addCandidates', () {
    test('with empty prefs stores incoming candidates', () {
      provider.addCandidates([candidate1, candidate2]);

      expect(provider.candidates, containsAll([candidate1, candidate2]));
      expect(provider.candidates.length, 2);
    });

    test('with persisted candidates merges and deduplicates by id', () async {
      // Pre-seed SharedPreferences with candidate1.
      SharedPreferences.setMockInitialValues({
        'meeting_inbox_candidates': jsonEncode([candidate1.toJson()]),
      });
      provider = MeetingInboxProvider();
      await provider.loadFromPrefs();

      // addCandidates with candidate2 — should merge without duplicating candidate1.
      provider.addCandidates([candidate2]);

      expect(provider.candidates.length, 2);
      expect(provider.candidates.map((c) => c.id), containsAll(['c1', 'c2']));
    });

    test('duplicate incoming ids are stored only once', () {
      provider.addCandidates([candidate1, candidate1]);

      expect(provider.candidates.length, 1);
    });
  });

  group('MeetingInboxProvider - loadFromPrefs', () {
    test('restores persisted candidates on load', () async {
      SharedPreferences.setMockInitialValues({
        'meeting_inbox_candidates': jsonEncode([candidate1.toJson()]),
      });
      provider = MeetingInboxProvider();
      await provider.loadFromPrefs();

      expect(provider.candidates.length, 1);
      expect(provider.candidates.first.id, 'c1');
    });
  });

  group('MeetingInboxProvider - skip', () {
    test('removes the candidate', () {
      provider.addCandidates([candidate1, candidate2]);
      provider.skip('c1');

      expect(provider.candidates.map((c) => c.id), isNot(contains('c1')));
      expect(provider.candidates.length, 1);
    });

    test('does not increment confirmedCount', () {
      provider.addCandidates([candidate1]);
      provider.skip('c1');

      expect(provider.confirmedCount, 0);
    });
  });

  group('MeetingInboxProvider - markConfirmed', () {
    test('removes the candidate', () {
      provider.addCandidates([candidate1, candidate2]);
      provider.markConfirmed('c1');

      expect(provider.candidates.map((c) => c.id), isNot(contains('c1')));
    });

    test('increments confirmedCount once per call', () {
      provider.addCandidates([candidate1, candidate2]);
      provider.markConfirmed('c1');
      provider.markConfirmed('c2');

      expect(provider.confirmedCount, 2);
    });
  });

  group('MeetingInboxProvider - isEmpty', () {
    test('is true after all candidates removed', () {
      provider.addCandidates([candidate1]);
      provider.skip('c1');

      expect(provider.isEmpty, isTrue);
    });

    test('is false while candidates remain', () {
      provider.addCandidates([candidate1, candidate2]);
      provider.skip('c1');

      expect(provider.isEmpty, isFalse);
    });
  });

  group('MeetingInboxProvider - persistence', () {
    test('markConfirmed removes candidate from SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      provider.addCandidates([candidate1, candidate2]);
      provider.markConfirmed('c1');

      final raw = prefs.getString('meeting_inbox_candidates');
      expect(raw, isNotNull);
      final stored = jsonDecode(raw!) as List<dynamic>;
      final ids = stored.map((e) => (e as Map)['id']).toList();
      expect(ids, isNot(contains('c1')));
    });
  });
}
