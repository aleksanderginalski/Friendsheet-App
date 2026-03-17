import 'package:flutter/material.dart';

// Pixels of horizontal drag required to shift the preview year by one step.
// Smaller values = more sensitive drag; 50px feels natural on most screens.
const double _kPixelsPerYear = 50.0;

/// A stepper widget that allows navigating between years using arrow buttons,
/// a horizontal swipe gesture, or a continuous drag.
///
/// [availableYears] must be sorted descending (newest first).
/// Arrow buttons are disabled when the user reaches either boundary.
/// Neighbour years (±1 in availableYears) are shown dimmed on both sides.
///
/// During a horizontal drag, [_previewYear] shows the candidate year in italic
/// style; the actual year changes only when the drag is released.
class YearStepper extends StatefulWidget {
  final int selectedYear;
  final List<int> availableYears;
  final ValueChanged<int> onYearChanged;

  const YearStepper({
    super.key,
    required this.selectedYear,
    required this.availableYears,
    required this.onYearChanged,
  });

  @override
  State<YearStepper> createState() => _YearStepperState();
}

class _YearStepperState extends State<YearStepper> {
  // Year shown in the label during drag — null when not dragging.
  int? _previewYear;

  // Accumulated horizontal drag displacement in pixels.
  // Grows continuously from drag start; reset to 0 on drag end/cancel.
  double _dragAccumulator = 0.0;

  // Returns the index of selectedYear in availableYears, or -1 if not found.
  int get _currentIndex => widget.availableYears.indexOf(widget.selectedYear);

  // Oldest year is last in the descending list.
  bool get _isOldest => _currentIndex == widget.availableYears.length - 1;

  // Newest year is first in the descending list.
  bool get _isNewest => _currentIndex == 0;

  // Oldest available year — lower boundary for drag clamping.
  int get _minYear => widget.availableYears.isEmpty
      ? widget.selectedYear
      : widget.availableYears.last;

  // Newest available year — upper boundary for drag clamping.
  int get _maxYear => widget.availableYears.isEmpty
      ? widget.selectedYear
      : widget.availableYears.first;

  void _goNewer() {
    if (!_isNewest) {
      widget.onYearChanged(widget.availableYears[_currentIndex - 1]);
    }
  }

  void _goOlder() {
    if (!_isOldest) {
      widget.onYearChanged(widget.availableYears[_currentIndex + 1]);
    }
  }

  // Returns the year at currentIndex + offset in availableYears,
  // or null if the offset goes out of bounds.
  int? _neighbourYear(int offset) {
    final idx = _currentIndex + offset;
    if (idx < 0 || idx >= widget.availableYears.length) return null;
    return widget.availableYears[idx];
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragAccumulator += details.delta.dx;
    // yearDelta is the total year shift from drag start.
    // Drag right (positive dx) → go older → lower year number.
    // Drag left (negative dx) → go newer → higher year number.
    final yearDelta = (_dragAccumulator / _kPixelsPerYear).truncate();
    final candidate =
        (widget.selectedYear - yearDelta).clamp(_minYear, _maxYear);
    if (candidate != (_previewYear ?? widget.selectedYear)) {
      setState(() => _previewYear = candidate);
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_previewYear != null && _previewYear != widget.selectedYear) {
      widget.onYearChanged(_previewYear!);
    }
    setState(() {
      _previewYear = null;
      _dragAccumulator = 0.0;
    });
  }

  void _onDragCancel() {
    setState(() {
      _previewYear = null;
      _dragAccumulator = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Older year occupies the left slot; newer year occupies the right slot.
    final olderYear = _neighbourYear(1);
    final newerYear = _neighbourYear(-1);

    final displayYear = _previewYear ?? widget.selectedYear;
    final isDragging = _previewYear != null;

    // Range indicator is only meaningful when more than one year exists.
    final hasRange = _maxYear > _minYear;
    final fraction =
        hasRange ? (displayYear - _minYear) / (_maxYear - _minYear) : 0.5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onHorizontalDragCancel: _onDragCancel,
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
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.35),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Active year label — italic and dimmed while dragging to signal
                // that the displayed value is a preview, not yet committed.
                Text(
                  displayYear.toString(),
                  style: isDragging
                      ? TextStyle(
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          color: colorScheme.primary.withValues(alpha: 0.6),
                        )
                      : TextStyle(
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
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.35),
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
        ),
        // Thin track showing the selected year's position within the available
        // range. Hidden when only one year exists (no meaningful range to show).
        if (hasRange)
          SizedBox(
            width: 120,
            height: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                backgroundColor: colorScheme.onSurface.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                minHeight: 6,
              ),
            ),
          ),
      ],
    );
  }
}
