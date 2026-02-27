import 'package:flutter/material.dart';

import '../../data/models/activity_category.dart';
import '../../data/repositories/statistics_repository.dart';

/// Color palette for bar chart — one color per person (cycles if > 8 persons).
const _kPalette = [
  Color(0xFF4CAF50),
  Color(0xFF2196F3),
  Color(0xFFFF9800),
  Color(0xFFE91E63),
  Color(0xFF9C27B0),
  Color(0xFF00BCD4),
  Color(0xFFFF5722),
  Color(0xFF607D8B),
];

/// Maximum rendered height for a single bar, in logical pixels.
const _kMaxBarHeight = 110.0;

/// Displays a vertical bar chart of persons ranked by meeting weight for
/// the selected activity, with a left-side legend and hide/show controls.
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
          _BarChartWithLegend(
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

/// Row with a scrollable left legend and a horizontally scrollable bar chart.
class _BarChartWithLegend extends StatelessWidget {
  final List<PersonActivityEntry> visibleEntries;
  final void Function(String personId, String name) onToggleHidden;

  const _BarChartWithLegend({
    required this.visibleEntries,
    required this.onToggleHidden,
  });

  int get _maxWeight => visibleEntries.fold<int>(
        1,
        (prev, e) => e.weightSum > prev ? e.weightSum : prev,
      );

  @override
  Widget build(BuildContext context) {
    final maxWeight = _maxWeight;

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left legend — shows color swatch + person name.
          SizedBox(
            width: 90,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < visibleEntries.length; i++)
                    _LegendItem(
                      entry: visibleEntries[i],
                      color: _kPalette[i % _kPalette.length],
                      onLongPress: () => _showOptions(
                        context,
                        visibleEntries[i].personId,
                        visibleEntries[i].name,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Bar chart — horizontally scrollable; top-7 visible, rest on scroll.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < visibleEntries.length; i++)
                    GestureDetector(
                      onLongPress: () => _showOptions(
                        context,
                        visibleEntries[i].personId,
                        visibleEntries[i].name,
                      ),
                      child: _BarColumn(
                        entry: visibleEntries[i],
                        color: _kPalette[i % _kPalette.length],
                        maxWeight: maxWeight,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
                onToggleHidden(personId, name);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final PersonActivityEntry entry;
  final Color color;
  final VoidCallback onLongPress;

  const _LegendItem({
    required this.entry,
    required this.color,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                entry.name,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  final PersonActivityEntry entry;
  final Color color;
  final int maxWeight;

  const _BarColumn({
    required this.entry,
    required this.color,
    required this.maxWeight,
  });

  @override
  Widget build(BuildContext context) {
    final barHeight = (entry.weightSum / maxWeight * _kMaxBarHeight)
        .clamp(2.0, _kMaxBarHeight);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            entry.weightSum.toString(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Container(
            width: 36,
            height: barHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 42,
            child: Text(
              entry.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
