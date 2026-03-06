import 'package:flutter/material.dart';

import '../../core/theme/chart_colors.dart';
import '../../data/models/activity_category.dart';
import '../../data/repositories/statistics_repository.dart';

/// Maximum rendered height for a single bar, in logical pixels.
const _kMaxBarHeight = 110.0;

/// Fixed heights for bar column sections.
const _kWeightHeight = 20.0;
const _kNameHeight = 32.0;

/// Total height of the horizontal-scrolling chart area.
const _kChartHeight = _kMaxBarHeight + _kWeightHeight + _kNameHeight;

/// Fixed width per item slot — includes padding on both sides.
const _kItemWidth = 56.0;

/// Duration for bar-height and position entrance/change animations.
const _kAnimationDuration = Duration(milliseconds: 600);

double _barHeight(int weight, int maxW) =>
    (weight / maxW * _kMaxBarHeight).clamp(2.0, _kMaxBarHeight);

/// Displays a vertical bar chart of persons ranked by meeting weight for
/// the selected activity, with hide/show controls.
class WhoPerActivityWidget extends StatelessWidget {
  final List<PersonActivityEntry> entries;
  final List<ActivityCategory> categories;
  final String? selectedCategoryId;
  final Set<String> hiddenPersonIds;
  final int hiddenCount;
  final VoidCallback onSelectActivity;
  final void Function(String personId, String name) onToggleHidden;

  const WhoPerActivityWidget({
    super.key,
    required this.entries,
    required this.categories,
    required this.selectedCategoryId,
    required this.hiddenPersonIds,
    required this.hiddenCount,
    required this.onSelectActivity,
    required this.onToggleHidden,
  });

  String _selectedName() {
    if (selectedCategoryId == null) return 'Select activity';
    try {
      return categories.firstWhere((c) => c.id == selectedCategoryId).name;
    } catch (_) {
      return 'Select activity';
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleEntries =
        entries.where((e) => !hiddenPersonIds.contains(e.personId)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Who Per Activity',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onSelectActivity,
          icon: const Icon(Icons.filter_list, size: 18),
          label: Text(_selectedName()),
        ),
        const SizedBox(height: 12),
        if (selectedCategoryId == null)
          const Text(
            'Select an activity above to see the ranking.',
            style: TextStyle(color: Colors.grey),
          )
        else if (visibleEntries.isEmpty)
          const Text(
            'No data for this activity.',
            style: TextStyle(color: Colors.grey),
          )
        else
          _BarChart(
            visibleEntries: visibleEntries,
            onToggleHidden: onToggleHidden,
          ),
        if (hiddenCount > 0)
          GestureDetector(
            onTap: () => _showHiddenPersonsDialog(context),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '$hiddenCount person(s) hidden — tap to show',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showHiddenPersonsDialog(BuildContext context) {
    final hiddenEntries =
        entries.where((e) => hiddenPersonIds.contains(e.personId)).toList();

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hidden Persons'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: hiddenEntries
                .map(
                  (e) => ListTile(
                    title: Text(e.name),
                    trailing: TextButton(
                      onPressed: () {
                        onToggleHidden(e.personId, e.name);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Show'),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}

/// Horizontally scrollable animated bar chart for person activity ranking.
/// Bar heights and positions animate on first render and on every data change.
/// Bars are absolutely positioned inside a Stack so position changes animate
/// smoothly when the ranking changes between years.
class _BarChart extends StatefulWidget {
  final List<PersonActivityEntry> visibleEntries;
  final void Function(String personId, String name) onToggleHidden;

  const _BarChart({
    required this.visibleEntries,
    required this.onToggleHidden,
  });

  @override
  State<_BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<_BarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;

  // Last non-empty entries — retained during data changes so bars stay
  // visible instead of briefly showing an empty state.
  List<PersonActivityEntry> _displayedEntries = [];

  // Entry order locked when new data arrives, before the controller restarts.
  // build() derives targetLeft from this list so bar indices are stable for
  // the entire animation duration.
  List<PersonActivityEntry> _animatingEntries = [];

  @override
  void initState() {
    super.initState();
    _displayedEntries = widget.visibleEntries;
    _animatingEntries = widget.visibleEntries;
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
  void didUpdateWidget(_BarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update displayed entries when new data arrives — keep the
    // previous set visible during any transient empty state.
    if (widget.visibleEntries.isNotEmpty &&
        widget.visibleEntries != oldWidget.visibleEntries) {
      _displayedEntries = widget.visibleEntries;
      // Lock order before restarting the controller so targetLeft values
      // are stable for the entire animation duration.
      _animatingEntries = widget.visibleEntries;
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

  void _showOptions(BuildContext context, String personId, String name) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_off),
              title: Text('Hide $name'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onToggleHidden(personId, name);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // _animatingEntries is locked at animation start — using it here
    // ensures targetLeft indices are stable across parent rebuilds that
    // happen mid-animation.
    final visibleEntries = _animatingEntries;
    final maxW = visibleEntries.fold<int>(
      1,
      (prev, e) => e.weightSum > prev ? e.weightSum : prev,
    );

    if (_displayedEntries.isEmpty) return const SizedBox.shrink();

    return SizedBox(
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
                key: ValueKey(entry.personId),
                entry: entry,
                personId: entry.personId,
                controller: _curvedAnimation,
                targetLeft: index * _kItemWidth,
                targetBarHeight: _barHeight(entry.weightSum, maxW),
                onLongPress: () =>
                    _showOptions(context, entry.personId, entry.name),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// A person bar absolutely positioned inside a Stack.
/// Animates both its left position and bar height driven by the shared
/// [controller] owned by the parent. Each instance maintains its own tweens
/// so it can start from its previous position/height when the parent restarts
/// the controller on a year change.
class _AnimatedBarItem extends StatefulWidget {
  final PersonActivityEntry entry;
  final String personId;
  final Animation<double> controller;
  final double targetLeft;
  final double targetBarHeight;
  final VoidCallback onLongPress;

  const _AnimatedBarItem({
    super.key,
    required this.entry,
    required this.personId,
    required this.controller,
    required this.targetLeft,
    required this.targetBarHeight,
    required this.onLongPress,
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
        // Weight label — fixed height above the bar area.
        SizedBox(
          height: _kWeightHeight,
          child: Center(
            child: Text(
              widget.entry.weightSum.toString(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        // Bar area — Expanded fills remaining space; bar aligns to bottom
        // so all bars share the same baseline regardless of height.
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
                  width: 2.0,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
          ),
        ),
        // Name label — fixed height prevents uneven column tops.
        SizedBox(
          height: _kNameHeight,
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              widget.entry.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9),
              maxLines: 2,
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
          child: GestureDetector(
            onLongPress: widget.onLongPress,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: _buildBarColumn(barHeight),
            ),
          ),
        );
      },
    );
  }
}
