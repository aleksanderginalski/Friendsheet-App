import 'package:flutter/material.dart';

import '../../data/models/meeting.dart';

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
    required this.suggestedMeeting,
    required this.isExpanded,
    required this.onDismiss,
    required this.onActionTap,
    required this.onIconTap,
  });

  /// The meeting to suggest notes for, or null when showing the default message.
  final Meeting? suggestedMeeting;

  /// When true, the chat bubble card is visible above the icon.
  final bool isExpanded;

  /// Called when the user taps the [X] close button — collapses the bubble.
  final VoidCallback onDismiss;

  /// Called from the "Let's do it!" button — opens AIChatScreen in meeting-notes mode.
  final VoidCallback onActionTap;

  /// Called when the user taps the Buddy icon — opens AIChatScreen in free-query mode.
  final VoidCallback onIconTap;

  // Vertical distance from the image bottom to where the bubble tail tip
  // should land — adjusted to align with the character's visible head area,
  // accounting for the transparent top padding in the asset.
  static const double _kIconSize = 224.0;
  static const double _kBubbleAnchor = 168.0;

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

    // Stack is sized to the icon (224×224). The bubble is positioned above
    // the character's head via Positioned(bottom: _kBubbleAnchor).
    // clipBehavior: Clip.none lets the bubble render above the Stack bounds.
    return SizedBox(
      width: _kIconSize,
      height: _kIconSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          Positioned(
            bottom: _kBubbleAnchor,
            left: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BuddyBubble(
                  suggestedMeeting: suggestedMeeting,
                  onDismiss: onDismiss,
                  onActionTap: onActionTap,
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
        ],
      ),
    );
  }
}

class _BuddyBubble extends StatelessWidget {
  const _BuddyBubble({
    required this.suggestedMeeting,
    required this.onDismiss,
    required this.onActionTap,
  });

  final Meeting? suggestedMeeting;
  final VoidCallback onDismiss;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    final message = suggestedMeeting != null
        ? 'Hey, you recently had "${suggestedMeeting!.name}" — want to save your memories?'
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
                if (suggestedMeeting != null) ...[
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: onActionTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    child: const Text("Let's do it!"),
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
