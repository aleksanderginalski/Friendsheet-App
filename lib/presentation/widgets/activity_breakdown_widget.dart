import 'package:flutter/material.dart';

import '../../core/theme/chart_colors.dart';
import '../../data/repositories/statistics_repository.dart';

/// Fixed heights for bar column sections.
const _kDeltaHeight = 20.0;
const _kWeightHeight = 20.0;
const _kNameHeight = 32.0;

/// Total height of the horizontal-scrolling chart area.
const _kChartHeight = 200.0;

/// Maximum bar height = chart height minus the three fixed-height sections.
const _kMaxBarHeight =
    _kChartHeight - _kDeltaHeight - _kWeightHeight - _kNameHeight;

/// Fixed width per item slot — includes padding on both sides.
const _kItemWidth = 56.0;

/// Duration for bar-height and position entrance/change animations.
const _kAnimationDuration = Duration(milliseconds: 1000);

List<ActivityBreakdownEntry> _computeVisible(
  List<ActivityBreakdownEntry> entries,
  Set<String> hidden,
) =>
    entries.where((e) => !hidden.contains(e.categoryId)).toList();

int _maxWeight(List<ActivityBreakdownEntry> visible) => visible.fold<int>(
      1,
      (prev, e) => e.currentYearWeight > prev ? e.currentYearWeight : prev,
    );

double _barHeight(int weight, int maxW) =>
    (weight / maxW * _kMaxBarHeight).clamp(2.0, _kMaxBarHeight);

/// Displays the Activity Breakdown as a horizontal-scrolling vertical bar chart.
/// Bar heights and positions animate on first render and on every year change.
/// Bars are absolutely positioned inside a Stack so position changes animate
/// smoothly when the ranking changes between years.
class ActivityBreakdownWidget extends StatefulWidget {
  final List<ActivityBreakdownEntry> entries;
  final Set<String> hiddenActivities;
  final VoidCallback onOpenVisibilityDialog;

  const ActivityBreakdownWidget({
    super.key,
    required this.entries,
    required this.hiddenActivities,
    required this.onOpenVisibilityDialog,
  });

  @override
  State<ActivityBreakdownWidget> createState() =>
      _ActivityBreakdownWidgetState();
}

class _ActivityBreakdownWidgetState extends State<ActivityBreakdownWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;

  // Last non-empty entries — retained during loading so bars stay
  // visible instead of briefly showing "No visible activities."
  List<ActivityBreakdownEntry> _displayedEntries = [];

  // Entry order locked when a new year's data arrives, before the controller
  // restarts. build() derives targetLeft from this list so the index of each
  // bar is stable for the entire animation — even if the parent rebuilds due
  // to an unrelated provider notification mid-animation.
  List<ActivityBreakdownEntry> _animatingEntries = [];

  @override
  void initState() {
    super.initState();
    _displayedEntries = widget.entries;
    _animatingEntries = widget.entries;
    _controller = AnimationController(
      vsync: this,
      duration: _kAnimationDuration,
    )..forward();
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(ActivityBreakdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update displayed entries when new data arrives — keep the
    // previous set visible during the loading gap (empty entries).
    if (widget.entries.isNotEmpty && widget.entries != oldWidget.entries) {
      _displayedEntries = widget.entries;
      // Lock order before restarting the controller so targetLeft values
      // are stable for the entire animation duration.
      _animatingEntries = widget.entries;
      // Defer controller restart to the next frame so all _AnimatedBarItem
      // children receive new targetLeft via didUpdateWidget first. This
      // guarantees their tweens capture the correct current visual position
      // (controller still at previous value) before the reset to 0.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.forward(from: 0.0);
      });
    }
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _animatingEntries is locked at animation start — using it here
    // ensures targetLeft indices are stable across parent rebuilds that
    // happen mid-animation (e.g. unrelated provider notifications).
    final visibleEntries =
        _computeVisible(_animatingEntries, widget.hiddenActivities);
    final maxW = _maxWeight(visibleEntries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Header row: title + settings icon.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Activity Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: const Icon(Icons.settings, size: 20),
              onPressed: widget.onOpenVisibilityDialog,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Manage activity visibility',
            ),
          ],
        ),
        // Hint showing how many activities are hidden.
        if (widget.hiddenActivities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${widget.hiddenActivities.length} activities hidden',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        const SizedBox(height: 8),
        // Use _displayedEntries (last non-empty data) for the guard so the
        // chart never flashes an empty state during the loading gap between
        // year changes.
        if (_computeVisible(_displayedEntries, widget.hiddenActivities).isEmpty)
          const Text(
            'No visible activities.',
            style: TextStyle(color: Colors.grey),
          )
        else
          SizedBox(
            height: _kChartHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // Fixed-width SizedBox so the Stack knows its extent.
              child: SizedBox(
                width: visibleEntries.length * _kItemWidth,
                child: Stack(
                  children: visibleEntries.asMap().entries.map((e) {
                    final index = e.key;
                    final entry = e.value;
                    return _AnimatedBarItem(
                      // ValueKey tracks bar identity across reorders.
                      key: ValueKey(entry.categoryId),
                      entry: entry,
                      categoryId: entry.categoryId,
                      controller: _curvedAnimation,
                      targetLeft: index * _kItemWidth,
                      targetBarHeight:
                          _barHeight(entry.currentYearWeight, maxW),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A bar item absolutely positioned inside a Stack.
/// Animates both its left position and bar height driven by the shared
/// [controller] owned by the parent. Each instance maintains its own tweens
/// so it can start from its previous position/height when the parent restarts
/// the controller on a year change.
class _AnimatedBarItem extends StatefulWidget {
  final ActivityBreakdownEntry entry;
  final String categoryId;
  final Animation<double> controller;
  final double targetLeft;
  final double targetBarHeight;

  const _AnimatedBarItem({
    super.key,
    required this.entry,
    required this.categoryId,
    required this.controller,
    required this.targetLeft,
    required this.targetBarHeight,
  });

  @override
  State<_AnimatedBarItem> createState() => _AnimatedBarItemState();
}

class _AnimatedBarItemState extends State<_AnimatedBarItem> {
  late Tween<double> _leftTween;
  late Tween<double> _heightTween;
  late Tween<double> _opacityTween;

  // Track previous animation targets — used as begin values in didUpdateWidget
  // so tweens are stable regardless of controller timing or rebuild count.
  double _lastTargetLeft = 0.0;
  double _lastTargetBarHeight = 0.0;

  @override
  void initState() {
    super.initState();
    // First render: bar fades in at target position, height grows from 0.
    _lastTargetLeft = widget.targetLeft;
    _lastTargetBarHeight = widget.targetBarHeight;
    _leftTween = Tween<double>(
      begin: widget.targetLeft,
      end: widget.targetLeft,
    );
    _heightTween = Tween<double>(begin: 0.0, end: widget.targetBarHeight);
    _opacityTween = Tween<double>(begin: 0.0, end: 1.0);
  }

  @override
  void didUpdateWidget(_AnimatedBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Use _lastTargetLeft as begin — stable regardless of controller timing
    // or number of didUpdateWidget calls.
    _leftTween = Tween<double>(
      begin: _lastTargetLeft,
      end: widget.targetLeft,
    );
    _heightTween = Tween<double>(
      begin: _lastTargetBarHeight,
      end: widget.targetBarHeight,
    );
    // Bar already visible — no fade animation on subsequent updates.
    _opacityTween = Tween<double>(begin: 1.0, end: 1.0);

    // Update last targets AFTER building tweens.
    _lastTargetLeft = widget.targetLeft;
    _lastTargetBarHeight = widget.targetBarHeight;
  }

  Widget _buildBarColumn(double barHeight) {
    return Column(
      children: [
        // Delta indicator — FittedBox scales text if it overflows the slot.
        SizedBox(
          height: _kDeltaHeight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _DeltaLabel(entry: widget.entry),
          ),
        ),
        // Bar area — Expanded fills remaining space; bar sits at bottom.
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 32,
              height: barHeight,
              decoration: BoxDecoration(
                gradient: ChartColors.getGradient(widget.categoryId),
                border: Border.all(
                  color: ChartColors.getStrokeColor(widget.categoryId),
                  width: 1.5,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
          ),
        ),
        // Weight label — shows target value immediately (not animated).
        SizedBox(
          height: _kWeightHeight,
          child: Center(
            child: Text(
              widget.entry.currentYearWeight.toString(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        // Name label — fixed height, single line with ellipsis.
        SizedBox(
          height: _kNameHeight,
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              widget.entry.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final left = _leftTween.evaluate(widget.controller);
        final barHeight =
            _heightTween.evaluate(widget.controller).clamp(2.0, _kMaxBarHeight);
        final opacity = _opacityTween.evaluate(widget.controller);
        return Positioned(
          left: left,
          top: 0,
          width: _kItemWidth,
          height: _kChartHeight,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: _buildBarColumn(barHeight),
          ),
        );
      },
    );
  }
}

/// Shows a coloured arrow + percentage indicating year-over-year weight change.
/// Percentage formula: (delta / previousYearWeight * 100).round()
class _DeltaLabel extends StatelessWidget {
  final ActivityBreakdownEntry entry;

  const _DeltaLabel({required this.entry});

  @override
  Widget build(BuildContext context) {
    // New activity this year — no previous data to compute percentage against.
    if (entry.previousYearWeight == 0) {
      return const Text(
        'NEW',
        style: TextStyle(color: Colors.grey, fontSize: 9),
      );
    }

    final pct = (entry.delta / entry.previousYearWeight * 100).round().abs();

    if (entry.delta > 0) {
      return Text(
        '▲ +$pct%',
        style: const TextStyle(color: Colors.green, fontSize: 10),
      );
    }

    if (entry.delta < 0) {
      return Text(
        '▼ -$pct%',
        style: const TextStyle(color: Colors.red, fontSize: 10),
      );
    }

    // delta == 0 with data from both years.
    return const Text(
      '—',
      style: TextStyle(color: Colors.grey, fontSize: 11),
    );
  }
}
