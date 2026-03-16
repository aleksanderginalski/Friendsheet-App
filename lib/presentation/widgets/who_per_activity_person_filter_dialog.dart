import 'package:flutter/material.dart';

import '../../core/utils/person_sort.dart';
import '../../data/repositories/statistics_repository.dart';

/// Dialog for managing person visibility in the Who Per Activity chart.
/// All entries are shown as a flat checkbox list — persons have no hierarchy.
/// Changes are applied immediately via [onTogglePersonVisibility].
/// At least one person must remain visible — the last visible person's
/// checkbox is disabled to enforce the minimum-1 constraint.
class WhoPerActivityPersonFilterDialog extends StatefulWidget {
  final List<PersonActivityEntry> allEntries;
  final Set<String> hiddenPersonIds;
  final void Function(String personId) onTogglePersonVisibility;
  final void Function(bool selectAll) onToggleSelectAll;
  final VoidCallback onAutoSelectTop10;

  const WhoPerActivityPersonFilterDialog({
    super.key,
    required this.allEntries,
    required this.hiddenPersonIds,
    required this.onTogglePersonVisibility,
    required this.onToggleSelectAll,
    required this.onAutoSelectTop10,
  });

  @override
  State<WhoPerActivityPersonFilterDialog> createState() =>
      _WhoPerActivityPersonFilterDialogState();
}

class _WhoPerActivityPersonFilterDialogState
    extends State<WhoPerActivityPersonFilterDialog> {
  // Local copy so checkboxes update immediately without waiting for provider.
  late Set<String> _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = Set.from(widget.hiddenPersonIds);
  }

  // Returns true when [personId] is the only visible person (cannot be hidden).
  bool _isLastVisible(String personId) {
    final isVisible = !_hidden.contains(personId);
    if (!isVisible) return false;
    final visibleCount =
        widget.allEntries.where((e) => !_hidden.contains(e.personId)).length;
    return visibleCount == 1;
  }

  void _toggle(String personId) {
    // Enforce min-1: do not allow hiding the last visible person.
    if (_isLastVisible(personId)) return;
    setState(() {
      if (_hidden.contains(personId)) {
        _hidden.remove(personId);
      } else {
        _hidden.add(personId);
      }
    });
    widget.onTogglePersonVisibility(personId);
  }

  /// Delegates auto-select to the provider and closes the dialog because
  /// the local hidden set cannot be refreshed via VoidCallback.
  void _applyTop10() {
    widget.onAutoSelectTop10();
    Navigator.of(context).pop();
  }

  /// Toggles all persons:
  /// - All visible (nothing hidden) → hide all except the first person (min-1).
  /// - Any hidden → show all (clear hidden set).
  /// Updates local state immediately, then notifies the provider.
  void _applyToggleSelectAll() {
    if (_hidden.isEmpty) {
      // All visible → hide all except the first entry.
      final newHidden =
          widget.allEntries.skip(1).map((e) => e.personId).toSet();
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
    final noneSelected = widget.allEntries.isNotEmpty &&
        widget.allEntries.every((e) => _hidden.contains(e.personId));
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
      title: const Text('Filter persons'),
      // SingleChildScrollView + Column required — ListView crashes inside
      // AlertDialog due to IntrinsicWidth incompatibility.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _applyTop10,
                  child: const Text('Auto-select top 10'),
                ),
                IconButton(
                  icon: Icon(toggleIcon),
                  tooltip: toggleTooltip,
                  onPressed: _applyToggleSelectAll,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...([...widget.allEntries]..sort((a, b) => normalizeForSort(a.name)
                    .compareTo(normalizeForSort(b.name))))
                .map((entry) {
              final isVisible = !_hidden.contains(entry.personId);
              final isDisabled = _isLastVisible(entry.personId);
              return Tooltip(
                message:
                    isDisabled ? 'At least one person must remain visible' : '',
                child: CheckboxListTile(
                  value: isVisible,
                  onChanged: isDisabled ? null : (_) => _toggle(entry.personId),
                  title: Text(entry.name),
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
