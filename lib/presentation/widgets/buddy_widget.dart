import 'package:flutter/material.dart';

import '../../data/models/meeting.dart';
import '../../data/models/person.dart';
import '../ai_chat/buddy_chat_mode.dart';

/// Floating Buddy widget anchored at the bottom-left of HomeScreen.
///
/// The Buddy icon (statistics_illustration) is always visible.
/// When [isExpanded] is true, a chat bubble card appears above the icon,
/// visually suggesting that the message comes from Buddy (the icon).
///
/// All state lives in [BuddyWidgetProvider]; this widget is purely presentational.
class BuddyWidget extends StatelessWidget {
  const BuddyWidget({
    super.key,
    required this.suggestedMeetings,
    required this.urgentBirthdayPersons,
    required this.daysUntilBirthday,
    required this.upcomingBirthdayInfo,
    required this.lapsedPersons,
    required this.isExpanded,
    required this.onDismiss,
    required this.onSaveMemoriesTap,
    required this.onBirthdayTap,
    required this.onLongTimeNoSeeTap,
    required this.onIconTap,
  });

  /// Top-3 meetings without notes — shows 'Save Your Memories' button when non-empty.
  final List<Meeting> suggestedMeetings;

  /// Persons whose birthday falls within the next 5 days.
  final List<Person> urgentBirthdayPersons;

  /// Maps personId to days until their next birthday.
  final Map<String, int> daysUntilBirthday;

  /// All persons with a birthday set, sorted by days until birthday.
  final List<BirthdayPersonInfo> upcomingBirthdayInfo;

  /// Top-3 persons not seen in 90+ days, sorted by longest absence.
  final List<LapsedPersonInfo> lapsedPersons;

  /// When true, the chat bubble card is visible above the icon.
  final bool isExpanded;

  /// Called when the user taps the [X] close button — collapses the bubble.
  final VoidCallback onDismiss;

  /// Called from the 'Save Your Memories' button — opens meeting-notes-list mode.
  final VoidCallback onSaveMemoriesTap;

  /// Called from the birthday CTA button — opens the appropriate birthday flow.
  final VoidCallback onBirthdayTap;

  /// Called from the 'Long time no see' button — opens LTNS chat mode.
  final VoidCallback onLongTimeNoSeeTap;

  /// Called when the user taps the Buddy icon — opens AIChatScreen in greeting mode.
  final VoidCallback onIconTap;

  static const double _kIconSize = 224.0;

  @override
  Widget build(BuildContext context) {
    final icon = GestureDetector(
      onTap: onIconTap,
      child: Image.asset(
        'assets/images/statistics_illustration.png',
        width: _kIconSize,
        height: _kIconSize,
      ),
    );

    if (!isExpanded) return icon;

    // Column layout: bubble above icon.
    // Avoids SizedBox/Stack clip that would block hit-testing for widgets
    // positioned above the SizedBox bounds.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BuddyBubble(
                suggestedMeetings: suggestedMeetings,
                urgentBirthdayPersons: urgentBirthdayPersons,
                daysUntilBirthday: daysUntilBirthday,
                upcomingBirthdayInfo: upcomingBirthdayInfo,
                lapsedPersons: lapsedPersons,
                onDismiss: onDismiss,
                onSaveMemoriesTap: onSaveMemoriesTap,
                onBirthdayTap: onBirthdayTap,
                onLongTimeNoSeeTap: onLongTimeNoSeeTap,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Transform.translate(
                  offset: const Offset(0, -1),
                  child: const SizedBox(
                    width: 28,
                    height: 16,
                    child: CustomPaint(painter: _TailPainter()),
                  ),
                ),
              ),
            ],
          ),
        ),
        icon,
      ],
    );
  }
}

class _BuddyBubble extends StatelessWidget {
  const _BuddyBubble({
    required this.suggestedMeetings,
    required this.urgentBirthdayPersons,
    required this.daysUntilBirthday,
    required this.upcomingBirthdayInfo,
    required this.lapsedPersons,
    required this.onDismiss,
    required this.onSaveMemoriesTap,
    required this.onBirthdayTap,
    required this.onLongTimeNoSeeTap,
  });

  final List<Meeting> suggestedMeetings;
  final List<Person> urgentBirthdayPersons;
  final Map<String, int> daysUntilBirthday;
  final List<BirthdayPersonInfo> upcomingBirthdayInfo;
  final List<LapsedPersonInfo> lapsedPersons;
  final VoidCallback onDismiss;
  final VoidCallback onSaveMemoriesTap;
  final VoidCallback onBirthdayTap;
  final VoidCallback onLongTimeNoSeeTap;

  static const _buttonStyle = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Color(0xFF4CAF50)),
    foregroundColor: WidgetStatePropertyAll(Colors.white),
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    ),
    textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 13)),
  );

  String _birthdayButtonLabel() {
    final urgentCount = urgentBirthdayPersons.length;
    if (urgentCount == 1) {
      final person = urgentBirthdayPersons[0];
      final days = daysUntilBirthday[person.id] ?? 0;
      return '🎂 ${person.firstName}\'s birthday is in $days ${days == 1 ? 'day' : 'days'}!';
    }
    if (urgentCount > 1) {
      return '🎂 $urgentCount friends have birthdays soon!';
    }
    // No urgent birthday — offer to check upcoming ones.
    return '🗓 Check upcoming birthdays';
  }

  @override
  Widget build(BuildContext context) {
    final hasMeetings = suggestedMeetings.isNotEmpty;
    final hasBirthdays = upcomingBirthdayInfo.isNotEmpty;
    final hasLapsed = lapsedPersons.isNotEmpty;
    final showAnyButton = hasMeetings || hasBirthdays || hasLapsed;

    final message = showAnyButton
        ? 'Hey! Need help? Here\'s what I can do for you:'
        : 'Hey! Can I help you with anything?';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            // Right padding leaves room for the X button in the top-right corner.
            padding: const EdgeInsets.fromLTRB(12, 10, 36, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, style: const TextStyle(fontSize: 13)),
                if (hasMeetings) ...[
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: onSaveMemoriesTap,
                    style: _buttonStyle,
                    child: const Text('💾 Save Your Memories'),
                  ),
                ],
                if (hasBirthdays) ...[
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: onBirthdayTap,
                    style: _buttonStyle,
                    child: Text(_birthdayButtonLabel()),
                  ),
                ],
                if (hasLapsed) ...[
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: onLongTimeNoSeeTap,
                    style: _buttonStyle,
                    child: Text(
                      '👋 Long time no see — ${lapsedPersons.first.daysSinceLastMeeting} days',
                    ),
                  ),
                ],
              ],
            ),
          ),
          // X button anchored at top-right corner of the bubble.
          Positioned(
            top: 2,
            right: 2,
            child: IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              tooltip: 'Dismiss',
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a right-triangle tail that visually connects the chat bubble above
/// to the Buddy icon below. The top edge seamlessly overlaps the bubble's
/// bottom border; only the diagonal (hypotenuse) edge is drawn.
class _TailPainter extends CustomPainter {
  const _TailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Triangle: top-left (0,0) — top-right (w,0) — bottom-left (0,h).
    // Filled white to match the bubble background; no visible border stroke.
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_TailPainter old) => false;
}
