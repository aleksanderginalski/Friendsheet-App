import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/l10n/app_localizations.dart';
import 'package:friendsheet/presentation/widgets/meeting_card.dart';

void main() {
  final baseDate = DateTime(2026, 1, 1);

  Meeting makeMeeting({List<String> notes = const []}) {
    return Meeting(
      id: 'm1',
      userId: 'u1',
      name: 'Coffee',
      date: baseDate,
      weight: 3,
      participantIds: ['p1'],
      notes: notes,
      createdAt: baseDate,
      updatedAt: baseDate,
    );
  }

  Widget buildCard(Meeting meeting) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MeetingCard(meeting: meeting, onTap: null),
      ),
    );
  }

  group('MeetingCard notes badge', () {
    testWidgets('hides notes badge when notes is empty', (tester) async {
      await tester.pumpWidget(buildCard(makeMeeting()));

      expect(find.byIcon(Icons.notes), findsNothing);
    });

    testWidgets('shows singular "1 note" badge', (tester) async {
      await tester.pumpWidget(buildCard(makeMeeting(notes: ['Guitar'])));

      expect(find.text('1 note'), findsOneWidget);
    });

    testWidgets('shows plural "2 notes" badge', (tester) async {
      await tester
          .pumpWidget(buildCard(makeMeeting(notes: ['Guitar', 'Kayaking'])));

      expect(find.text('2 notes'), findsOneWidget);
    });
  });
}
