import 'package:flutter/material.dart';

/// A stepper widget that allows navigating between years using arrow buttons
/// or a horizontal swipe gesture.
///
/// [availableYears] must be sorted descending (newest first).
/// Arrow buttons are disabled when the user reaches either boundary.
/// Neighbour years (±1 in availableYears) are shown dimmed on both sides.
class YearStepper extends StatelessWidget {
  final int selectedYear;
  final List<int> availableYears;
  final ValueChanged<int> onYearChanged;

  const YearStepper({
    super.key,
    required this.selectedYear,
    required this.availableYears,
    required this.onYearChanged,
  });

  // Returns the index of selectedYear in availableYears, or -1 if not found.
  int get _currentIndex => availableYears.indexOf(selectedYear);

  // Oldest year is last in the descending list.
  bool get _isOldest => _currentIndex == availableYears.length - 1;

  // Newest year is first in the descending list.
  bool get _isNewest => _currentIndex == 0;

  void _goNewer() {
    if (!_isNewest) {
      onYearChanged(availableYears[_currentIndex - 1]);
    }
  }

  void _goOlder() {
    if (!_isOldest) {
      onYearChanged(availableYears[_currentIndex + 1]);
    }
  }

  // Returns the year at currentIndex + offset in availableYears,
  // or null if the offset goes out of bounds.
  int? _neighbourYear(int offset) {
    final idx = _currentIndex + offset;
    if (idx < 0 || idx >= availableYears.length) return null;
    return availableYears[idx];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Older year occupies the left slot; newer year occupies the right slot.
    final olderYear = _neighbourYear(1);
    final newerYear = _neighbourYear(-1);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        // Positive velocity = swipe right = go to older year.
        if (velocity > 0) _goOlder();
        // Negative velocity = swipe left = go to newer year.
        if (velocity < 0) _goNewer();
      },
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Zero-padding removes default IconButton insets so both arrows
            // have identical width, keeping the row symmetric around the active year.
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.chevron_left),
              // Disabled at the oldest year boundary.
              onPressed: _isOldest ? null : _goOlder,
            ),
            // Left slot: older neighbour year, fixed width preserves layout when empty.
            SizedBox(
              width: 48,
              child: Center(
                child: olderYear != null
                    ? Text(
                        olderYear.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.35),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              selectedYear.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            // Right slot: newer neighbour year, fixed width preserves layout when empty.
            SizedBox(
              width: 48,
              child: Center(
                child: newerYear != null
                    ? Text(
                        newerYear.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.35),
                        ),
                      )
                    : null,
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.chevron_right),
              // Disabled at the newest year boundary.
              onPressed: _isNewest ? null : _goNewer,
            ),
          ],
        ),
      ),
    );
  }
}
