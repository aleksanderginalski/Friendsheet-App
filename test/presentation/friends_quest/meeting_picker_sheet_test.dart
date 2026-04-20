import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/presentation/friends_quest/meeting_picker_sheet.dart';

void main() {
  Meeting makeMeeting({
    required String id,
    required String name,
    required DateTime date,
  }) =>
      Meeting(
        id: id,
        userId: 'u1',
        name: name,
        date: date,
        weight: 3,
        participantIds: const [],
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  final meetings = [
    makeMeeting(id: 'm1', name: 'Coffee', date: DateTime(2026, 4, 16)),
    makeMeeting(id: 'm2', name: 'Lunch', date: DateTime(2026, 4, 2)),
    makeMeeting(id: 'm3', name: 'Dinner', date: DateTime(2025, 12, 1)),
  ];

  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(body: child),
      );

  Future<void> pumpSheet(
    WidgetTester tester, {
    List<Meeting> data = const [],
    void Function(Meeting)? onSelected,
  }) async {
    await tester.pumpWidget(wrap(MeetingPickerSheet(
      meetings: data,
      onSelected: onSelected ?? (_) {},
    )));
    await tester.pump();
  }

  group('MeetingPickerSheet', () {
    testWidgets('shows search bar', (tester) async {
      await pumpSheet(tester, data: meetings);

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows year and month headers and meeting names',
        (tester) async {
      final aprilOnly = [
        makeMeeting(id: 'm1', name: 'Coffee', date: DateTime(2026, 4, 16)),
        makeMeeting(id: 'm2', name: 'Lunch', date: DateTime(2026, 4, 2)),
      ];
      await pumpSheet(tester, data: aprilOnly);

      expect(find.text('2026'), findsOneWidget);
      expect(find.text('April'), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
    });

    testWidgets('tapping a meeting calls onSelected and pops sheet',
        (tester) async {
      Meeting? selected;
      await pumpSheet(tester, data: meetings, onSelected: (m) => selected = m);

      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();

      expect(selected?.id, 'm1');
    });

    testWidgets('search by name shows only matching meetings', (tester) async {
      await pumpSheet(tester, data: meetings);

      await tester.enterText(find.byType(TextField), 'cof');
      await tester.pump();

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Lunch'), findsNothing);
      expect(find.text('Dinner'), findsNothing);
    });

    testWidgets('search by date shows matching meeting', (tester) async {
      await pumpSheet(tester, data: meetings);

      await tester.enterText(find.byType(TextField), '16/04/2026');
      await tester.pump();

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Lunch'), findsNothing);
    });

    testWidgets('tapping year header collapses its months', (tester) async {
      await pumpSheet(tester, data: meetings);

      expect(find.text('April'), findsOneWidget);

      await tester.tap(find.text('2026'));
      await tester.pump();

      expect(find.text('April'), findsNothing);
      expect(find.text('Coffee'), findsNothing);
    });

    testWidgets('shows empty message when search matches nothing',
        (tester) async {
      await pumpSheet(tester, data: meetings);

      await tester.enterText(find.byType(TextField), 'zzznomatch');
      await tester.pump();

      expect(find.text('No meetings found.'), findsOneWidget);
    });
  });
}
