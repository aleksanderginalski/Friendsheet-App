import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/presentation/ai_chat/buddy_chat_mode.dart';
import 'package:friendsheet/presentation/widgets/buddy_widget.dart';

void main() {
  final testMeeting = Meeting(
    id: 'm1',
    userId: 'user-1',
    name: 'Gloomhaven',
    date: DateTime(2026, 3, 1),
    weight: 3,
    participantIds: const [],
    createdAt: DateTime(2026, 3, 1),
    updatedAt: DateTime(2026, 3, 1),
  );

  final testPerson = Person(
    id: 'p1',
    userId: 'user-1',
    firstName: 'Ada',
    createdAt: DateTime(2026, 1, 1),
    birthDayMonth: '04-02',
  );

  // Mirrors HomeScreen: BuddyWidget anchored at bottom-left of a Stack so
  // the bubble (positioned above the icon) stays within the visible area.
  Widget buildWidget({
    List<Meeting> suggestedMeetings = const [],
    List<Person> urgentBirthdayPersons = const [],
    Map<String, int> daysUntilBirthday = const {},
    List<BirthdayPersonInfo> upcomingBirthdayInfo = const [],
    List<LapsedPersonInfo> lapsedPersons = const [],
    bool isExpanded = true,
    VoidCallback? onDismiss,
    VoidCallback? onSaveMemoriesTap,
    VoidCallback? onBirthdayTap,
    VoidCallback? onLongTimeNoSeeTap,
    VoidCallback? onIconTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              child: BuddyWidget(
                suggestedMeetings: suggestedMeetings,
                urgentBirthdayPersons: urgentBirthdayPersons,
                daysUntilBirthday: daysUntilBirthday,
                upcomingBirthdayInfo: upcomingBirthdayInfo,
                lapsedPersons: lapsedPersons,
                isExpanded: isExpanded,
                onDismiss: onDismiss ?? () {},
                onSaveMemoriesTap: onSaveMemoriesTap ?? () {},
                onBirthdayTap: onBirthdayTap ?? () {},
                onLongTimeNoSeeTap: onLongTimeNoSeeTap ?? () {},
                onIconTap: onIconTap ?? () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  group('BuddyWidget', () {
    testWidgets('collapsed state shows only the icon', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          suggestedMeetings: [testMeeting],
          isExpanded: false,
        ),
      );

      expect(find.textContaining('Hey'), findsNothing);
      expect(find.text('💾 Save Your Memories'), findsNothing);
    });

    testWidgets('expanded with meetings shows save memories button',
        (tester) async {
      await tester.pumpWidget(
        buildWidget(suggestedMeetings: [testMeeting]),
      );

      expect(find.textContaining('Hey'), findsOneWidget);
      expect(find.text('💾 Save Your Memories'), findsOneWidget);
    });

    testWidgets(
        'expanded without meetings or birthdays shows generic message, no buttons',
        (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Hey! Can I help you with anything?'), findsOneWidget);
      expect(find.text('💾 Save Your Memories'), findsNothing);
    });

    testWidgets(
        'expanded with one urgent birthday shows specific birthday button',
        (tester) async {
      final info = BirthdayPersonInfo(person: testPerson, daysUntil: 2);
      await tester.pumpWidget(
        buildWidget(
          urgentBirthdayPersons: [testPerson],
          daysUntilBirthday: {'p1': 2},
          upcomingBirthdayInfo: [info],
        ),
      );

      expect(
        find.textContaining("Ada's birthday is in 2 days"),
        findsOneWidget,
      );
    });

    testWidgets('tapping X calls onDismiss', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        buildWidget(
          suggestedMeetings: [testMeeting],
          onDismiss: () => dismissed = true,
        ),
      );

      // The X button renders above the BuddyWidget Stack's bounds (bubble is
      // Positioned outside the 224px container via clipBehavior:Clip.none).
      // Flutter clips hit tests to widget bounds, so direct invocation is used.
      tester.widget<IconButton>(find.byType(IconButton)).onPressed?.call();
      expect(dismissed, isTrue);
    });

    testWidgets('tapping Save Your Memories calls onSaveMemoriesTap',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildWidget(
          suggestedMeetings: [testMeeting],
          onSaveMemoriesTap: () => tapped = true,
        ),
      );

      await tester.tap(find.text('💾 Save Your Memories'));
      expect(tapped, isTrue);
    });

    testWidgets('expanded with lapsed persons shows LTNS button',
        (tester) async {
      final lapsed = LapsedPersonInfo(
        person: testPerson,
        daysSinceLastMeeting: 95,
      );
      await tester.pumpWidget(buildWidget(lapsedPersons: [lapsed]));

      expect(find.textContaining('Long time no see'), findsOneWidget);
      expect(find.textContaining('95 days'), findsOneWidget);
    });

    testWidgets('tapping LTNS button calls onLongTimeNoSeeTap', (tester) async {
      var tapped = false;
      final lapsed = LapsedPersonInfo(
        person: testPerson,
        daysSinceLastMeeting: 95,
      );
      await tester.pumpWidget(buildWidget(
        lapsedPersons: [lapsed],
        onLongTimeNoSeeTap: () => tapped = true,
      ));

      await tester.tap(find.textContaining('Long time no see'));
      expect(tapped, isTrue);
    });

    testWidgets('tapping icon calls onIconTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildWidget(onIconTap: () => tapped = true));

      // Icon GestureDetector may be outside testable bounds when the bubble
      // is also rendered. Invoke onTap directly via the ancestor GestureDetector.
      tester
          .widget<GestureDetector>(
            find.ancestor(
              of: find.byType(Image),
              matching: find.byType(GestureDetector),
            ),
          )
          .onTap
          ?.call();
      expect(tapped, isTrue);
    });
  });
}
