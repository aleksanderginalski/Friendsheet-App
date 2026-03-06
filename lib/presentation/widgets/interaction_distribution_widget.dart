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

List<InteractionDistributionEntry> _computeVisible(
  List<InteractionDistributionEntry> entries,
  Set<String> hidden,
) =>
    entries.where((e) => !hidden.contains(e.personId)).toList();

int _maxWeight(List<InteractionDistributionEntry> visible) => visible.fold<int>(
      1,
      (prev, e) => e.currentYearWeight > prev ? e.currentYearWeight : prev,
    );

double _barHeight(int weight, int maxW) =>
    (weight / maxW * _kMaxBarHeight).clamp(2.0, _kMaxBarHeight);

/// Displays Interaction Distribution as a horizontal-scrolling vertical bar chart.
/// Bar heights and positions animate on first render and on every year change.
/// Bars are absolutely positioned inside a Stack so position changes animate
/// smoothly when the ranking changes between years.
/// Supports yearly mode (with year-over-year delta) and cumulative mode.
class InteractionDistributionWidget extends StatefulWidget {
  final List<InteractionDistributionEntry> entries;
  final Set<String> hiddenPersons;
  final bool isCumulativeMode;
  final bool isLoading;
  final VoidCallback onOpenVisibilityDialog;
  final VoidCallback onToggleMode;

  const InteractionDistributionWidget({
    super.key,
    required this.entries,
    required this.hiddenPersons,
    required this.isCumulativeMode,
    required this.isLoading,
    required this.onOpenVisibilityDialog,
    required this.onToggleMode,
  });

  @override
  State<InteractionDistributionWidget> createState() =>
      _InteractionDistributionWidgetState();
}

class _InteractionDistributionWidgetState
    extends State<InteractionDistributionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;

  // Last non-empty entries — retained during loading so bars stay
  // visible instead of briefly showing "No visible persons."
  List<InteractionDistributionEntry> _displayedEntries = [];

  // Entry order locked when new data arrives, before the controller restarts.
  // build() derives targetLeft from this list so bar indices are stable for
  // the entire animation duration.
  List<InteractionDistributionEntry> _animatingEntries = [];

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
  void didUpdateWidget(InteractionDistributionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update displayed entries when new data arrives — keep the
    // previous set visible during the loading gap (empty entries).
    if (widget.entries.isNotEmpty && widget.entries != oldWidget.entries) {
      _displayedEntries = widget.entries;
      // Lock order before restarting the controller so targetLeft values
      // are stable for the entire animation duration.
      _animatingEntries = widget.entries;
      // Defer controller restart to the next frame so all _AnimatedPersonBarItem
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

  void _showInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        content: const Text(
          'A meeting with multiple people counts toward each person\'s total. '
          'This means percentages across all persons can exceed 100%.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // _animatingEntries is locked at animation start — using it here
    // ensures targetLeft indices are stable across parent rebuilds that
    // happen mid-animation.
    final visibleEntries =
        _computeVisible(_animatingEntries, widget.hiddenPersons);
    final maxW = _maxWeight(visibleEntries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Header row: title (+ optional loading spinner) on the left,
        // action controls on the right.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Interaction Distribution',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                if (widget.isLoading) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Info icon: only shown in yearly mode — explains >100% totals.
                if (!widget.isCumulativeMode)
                  IconButton(
                    icon: const Icon(Icons.info_outline, size: 16),
                    onPressed: () => _showInfoDialog(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'About interaction distribution',
                  ),
                // Mode toggle: label shows current mode, tapping switches.
                TextButton(
                  onPressed: widget.onToggleMode,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    widget.isCumulativeMode ? 'Cumulative' : 'Yearly',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, size: 20),
                  onPressed: widget.onOpenVisibilityDialog,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Manage person visibility',
                ),
              ],
            ),
          ],
        ),
        // Hint showing how many persons are hidden.
        if (widget.hiddenPersons.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${widget.hiddenPersons.length} persons hidden',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        const SizedBox(height: 8),
        // Use _displayedEntries (last non-empty data) for the guard so the
        // chart never flashes an empty state during the loading gap between
        // year changes.
        if (_computeVisible(_displayedEntries, widget.hiddenPersons).isEmpty)
          const Text(
            'No visible persons.',
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
                    return _AnimatedPersonBarItem(
                      // ValueKey tracks bar identity across reorders.
                      key: ValueKey(entry.personId),
                      entry: entry,
                      personId: entry.personId,
                      controller: _curvedAnimation,
                      targetLeft: index * _kItemWidth,
                      targetBarHeight:
                          _barHeight(entry.currentYearWeight, maxW),
                      isCumulativeMode: widget.isCumulativeMode,
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

/// A person bar absolutely positioned inside a Stack.
/// Animates both its left position and bar height driven by the shared
/// [controller] owned by the parent. Each instance maintains its own tweens
/// so it can start from its previous position/height on controller restart.
class _AnimatedPersonBarItem extends StatefulWidget {
  final InteractionDistributionEntry entry;
  final String personId;
  final Animation<double> controller;
  final double targetLeft;
  final double targetBarHeight;
  final bool isCumulativeMode;

  const _AnimatedPersonBarItem({
    super.key,
    required this.entry,
    required this.personId,
    required this.controller,
    required this.targetLeft,
    required this.targetBarHeight,
    required this.isCumulativeMode,
  });

  @override
  State<_AnimatedPersonBarItem> createState() => _AnimatedPersonBarItemState();
}

class _AnimatedPersonBarItemState extends State<_AnimatedPersonBarItem> {
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
  void didUpdateWidget(_AnimatedPersonBarItem oldWidget) {
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
            child: _PersonDeltaLabel(
              entry: widget.entry,
              isCumulativeMode: widget.isCumulativeMode,
            ),
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
                gradient: ChartColors.getGradient(widget.personId),
                border: Border.all(
                  color: ChartColors.getStrokeColor(widget.personId),
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

/// Shows a delta indicator for a person bar.
/// In cumulative mode: always '—' since delta is not applicable across all years.
/// In yearly mode: shows ▲/▼/NEW/— based on year-over-year change.
class _PersonDeltaLabel extends StatelessWidget {
  final InteractionDistributionEntry entry;
  final bool isCumulativeMode;

  const _PersonDeltaLabel({
    required this.entry,
    required this.isCumulativeMode,
  });

  @override
  Widget build(BuildContext context) {
    // Cumulative mode — delta concept does not apply across all years.
    if (isCumulativeMode) {
      return const Text(
        '—',
        style: TextStyle(color: Colors.grey, fontSize: 11),
      );
    }

    // New person this year — no previous data to compute percentage against.
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
