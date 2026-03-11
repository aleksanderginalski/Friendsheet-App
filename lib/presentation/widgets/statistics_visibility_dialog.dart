import 'package:flutter/material.dart';

import '../providers/statistics_provider.dart';

/// Dialog for toggling card visibility in the Statistics carousel.
/// All StatCardType values are shown as a flat checkbox list.
/// Changes are applied immediately via [onToggleCard] — no confirm button needed.
/// At least one card must remain visible at all times — the last visible
/// card's checkbox is disabled with a tooltip.
class StatisticsVisibilityDialog extends StatefulWidget {
  final Set<StatCardType> hiddenCards;
  final void Function(StatCardType card) onToggleCard;
  final void Function(bool selectAll) onToggleSelectAll;

  const StatisticsVisibilityDialog({
    super.key,
    required this.hiddenCards,
    required this.onToggleCard,
    required this.onToggleSelectAll,
  });

  @override
  State<StatisticsVisibilityDialog> createState() =>
      _StatisticsVisibilityDialogState();
}

class _StatisticsVisibilityDialogState
    extends State<StatisticsVisibilityDialog> {
  // Local copy so checkboxes update immediately without waiting for provider.
  late Set<StatCardType> _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = Set.from(widget.hiddenCards);
  }

  String _cardLabel(StatCardType card) {
    switch (card) {
      case StatCardType.activityBreakdown:
        return 'Activity Breakdown';
      case StatCardType.whoPerActivity:
        return 'Who Per Activity';
      case StatCardType.interactionDistribution:
        return 'Interaction Distribution';
    }
  }

  // Returns true when [card] is the only visible card (cannot be hidden).
  bool _isLastVisible(StatCardType card) {
    final isVisible = !_hidden.contains(card);
    if (!isVisible) return false;
    final visibleCount =
        StatCardType.values.where((c) => !_hidden.contains(c)).length;
    return visibleCount == 1;
  }

  void _toggle(StatCardType card) {
    // Enforce min-1: do not allow hiding the last visible card.
    if (_isLastVisible(card)) return;
    setState(() {
      if (_hidden.contains(card)) {
        _hidden.remove(card);
      } else {
        _hidden.add(card);
      }
    });
    widget.onToggleCard(card);
  }

  /// Toggles all cards:
  /// - All visible (nothing hidden) → hide all except the first card (min-1).
  /// - Any hidden → show all (clear hidden set).
  /// Updates local state immediately, then notifies the provider.
  void _applyToggleSelectAll() {
    if (_hidden.isEmpty) {
      // All visible → hide all except the first card.
      final newHidden = Set.of(StatCardType.values.skip(1));
      setState(() => _hidden = newHidden);
      widget.onToggleSelectAll(false);
    } else {
      // Some hidden → show all.
      setState(() => _hidden = {});
      widget.onToggleSelectAll(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Three-state selection: all selected, none selected, or partial.
    final allSelected = _hidden.isEmpty;
    final noneSelected = StatCardType.values.isNotEmpty &&
        StatCardType.values.every((c) => _hidden.contains(c));
    final IconData toggleIcon;
    final String toggleTooltip;
    if (allSelected) {
      toggleIcon = Icons.check_box;
      toggleTooltip = 'Deselect all';
    } else if (noneSelected) {
      toggleIcon = Icons.check_box_outline_blank;
      toggleTooltip = 'Select all';
    } else {
      toggleIcon = Icons.indeterminate_check_box;
      toggleTooltip = 'Select all';
    }

    return AlertDialog(
      title: const Text('Statistics Cards'),
      // SingleChildScrollView + Column required — ListView crashes inside
      // AlertDialog due to IntrinsicWidth incompatibility.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(toggleIcon),
                  tooltip: toggleTooltip,
                  onPressed: _applyToggleSelectAll,
                ),
              ],
            ),
            ...StatCardType.values.map((card) {
              final isVisible = !_hidden.contains(card);
              final isDisabled = _isLastVisible(card);
              return Tooltip(
                message:
                    isDisabled ? 'At least one card must remain visible' : '',
                child: CheckboxListTile(
                  value: isVisible,
                  onChanged: isDisabled ? null : (_) => _toggle(card),
                  title: Text(_cardLabel(card)),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }
}
