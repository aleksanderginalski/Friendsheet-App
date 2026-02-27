import 'package:flutter/material.dart';

/// A stepper widget that allows navigating between years using arrow buttons
/// or a horizontal swipe gesture.
///
/// [availableYears] must be sorted descending (newest first).
/// Arrow buttons are disabled when the user reaches either boundary.
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        // Positive velocity = swipe right = go to older year.
        if (velocity > 0) _goOlder();
        // Negative velocity = swipe left = go to newer year.
        if (velocity < 0) _goNewer();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            // Disabled at the oldest year boundary.
            onPressed: _isOldest ? null : _goOlder,
          ),
          Text(
            selectedYear.toString(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            // Disabled at the newest year boundary.
            onPressed: _isNewest ? null : _goNewer,
          ),
        ],
      ),
    );
  }
}
