import 'package:flutter/material.dart';

import '../../core/utils/person_sort.dart';
import '../../data/repositories/statistics_repository.dart';

/// Dialog for toggling person visibility in the Interaction Distribution chart.
/// All entries are shown as a flat checkbox list — persons have no hierarchy.
/// Changes are applied immediately via [onToggle] — no confirm button needed.
/// [onToggleSelectAll] is a simple callback — the dialog updates local state
/// itself and notifies the provider via this callback.
class PersonVisibilityDialog extends StatefulWidget {
  final List<InteractionDistributionEntry> allEntries;
  final Set<String> hiddenPersons;
  final VoidCallback onAutoSelectTop10;
  final void Function(String personId) onToggle;
  final VoidCallback onToggleSelectAll;

  const PersonVisibilityDialog({
    super.key,
    required this.allEntries,
    required this.hiddenPersons,
    required this.onAutoSelectTop10,
    required this.onToggle,
    required this.onToggleSelectAll,
  });

  @override
  State<PersonVisibilityDialog> createState() => _PersonVisibilityDialogState();
}

class _PersonVisibilityDialogState extends State<PersonVisibilityDialog> {
  // Local copy so checkboxes update immediately without waiting for provider.
  late Set<String> _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = Set.from(widget.hiddenPersons);
  }

  void _toggle(String personId) {
    setState(() {
      if (_hidden.contains(personId)) {
        _hidden.remove(personId);
      } else {
        _hidden.add(personId);
      }
    });
    widget.onToggle(personId);
  }

  /// Delegates auto-select to the provider and closes the dialog because
  /// the local hidden set cannot be refreshed via VoidCallback.
  void _applyTop10() {
    widget.onAutoSelectTop10();
    Navigator.of(context).pop();
  }

  /// Toggles all persons:
  /// - All visible (nothing hidden) → deselect all (hide everything).
  /// - Any hidden → select all (clear hidden set).
  /// Updates local state immediately, then notifies the provider.
  void _applyToggleSelectAll() {
    if (_hidden.isEmpty) {
      // All visible → deselect all.
      setState(
        () => _hidden = widget.allEntries.map((e) => e.personId).toSet(),
      );
    } else {
      // Some hidden → select all.
      setState(() => _hidden = {});
    }
    widget.onToggleSelectAll();
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
      title: const Text('Manage persons'),
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
              return CheckboxListTile(
                value: isVisible,
                onChanged: (_) => _toggle(entry.personId),
                title: Text(entry.name),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
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
