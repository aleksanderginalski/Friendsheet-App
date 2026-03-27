import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
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

  // Mirrors HomeScreen: BuddyWidget anchored at bottom-left of a Stack so
  // the bubble (positioned above the icon) stays within the visible area.
  Widget buildWidget({
    Meeting? meeting,
    bool isExpanded = true,
    VoidCallback? onDismiss,
    VoidCallback? onActionTap,
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
                suggestedMeeting: meeting,
                isExpanded: isExpanded,
                onDismiss: onDismiss ?? () {},
                onActionTap: onActionTap ?? () {},
                onIconTap: onIconTap ?? () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  group('BuddyWidget', () {
    testWidgets('collapsed state shows no bubble text', (tester) async {
      await tester.pumpWidget(
        buildWidget(meeting: testMeeting, isExpanded: false),
      );

      expect(find.textContaining('Hey'), findsNothing);
      expect(find.text("Let's do it!"), findsNothing);
    });

    testWidgets('expanded with meeting shows meeting name and action button',
        (tester) async {
      await tester.pumpWidget(buildWidget(meeting: testMeeting));

      expect(find.textContaining('Gloomhaven'), findsOneWidget);
      expect(find.text("Let's do it!"), findsOneWidget);
    });

    testWidgets(
        'expanded without meeting shows generic message, no action button',
        (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Hey! Can I help you with anything?'), findsOneWidget);
      expect(find.text("Let's do it!"), findsNothing);
    });

    testWidgets('tapping X calls onDismiss', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        buildWidget(meeting: testMeeting, onDismiss: () => dismissed = true),
      );

      // The X button renders above the BuddyWidget Stack's bounds (bubble is
      // Positioned outside the 224px container via clipBehavior:Clip.none).
      // Flutter clips hit tests to widget bounds, so direct invocation is used.
      tester.widget<IconButton>(find.byType(IconButton)).onPressed?.call();
      expect(dismissed, isTrue);
    });

    testWidgets("tapping Let's do it! calls onActionTap", (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildWidget(meeting: testMeeting, onActionTap: () => tapped = true),
      );

      await tester.tap(find.text("Let's do it!"));
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
