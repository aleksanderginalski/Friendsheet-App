import 'package:flutter/material.dart';

import '../../data/models/activity_category.dart';
import '../../data/repositories/statistics_repository.dart';
import '../activities/activity_icons.dart';

/// One row in the hierarchical visibility list.
class _TreeRow {
  final ActivityBreakdownEntry entry;

  /// Null when the category is not found in the provided categories list.
  final ActivityCategory? category;

  /// 0 = root, 1 = child, 2 = grandchild.
  final int depth;

  const _TreeRow({
    required this.entry,
    required this.category,
    required this.depth,
  });
}

/// Dialog for toggling activity visibility in the Activity Breakdown chart.
/// Entries are displayed as an indented hierarchy derived from [categories].
/// Changes are applied immediately via [onToggle] — no confirm button needed.
///
/// [onAutoSelectTop10] returns the new hidden set after applying the top-10
/// default so the dialog can update its local checkbox state without closing.
/// [onToggleSelectAll] is a simple callback — the dialog updates local state
/// itself and notifies the provider via this callback.
class ActivityVisibilityDialog extends StatefulWidget {
  final List<ActivityBreakdownEntry> entries;
  final List<ActivityCategory> categories;
  final Set<String> hiddenActivities;
  final void Function(String categoryId) onToggle;
  final Future<Set<String>> Function() onAutoSelectTop10;
  final VoidCallback onToggleSelectAll;

  const ActivityVisibilityDialog({
    super.key,
    required this.entries,
    required this.categories,
    required this.hiddenActivities,
    required this.onToggle,
    required this.onAutoSelectTop10,
    required this.onToggleSelectAll,
  });

  @override
  State<ActivityVisibilityDialog> createState() =>
      _ActivityVisibilityDialogState();
}

class _ActivityVisibilityDialogState extends State<ActivityVisibilityDialog> {
  // Local copy so checkboxes update immediately without waiting for provider.
  late Set<String> _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = Set.from(widget.hiddenActivities);
  }

  /// Calls the provider to apply the top-10 selection, then syncs local state
  /// with the returned hidden set so checkboxes update without closing the dialog.
  Future<void> _applyTop10() async {
    final newHidden = await widget.onAutoSelectTop10();
    if (mounted) setState(() => _hidden = newHidden);
  }

  /// Toggles all activities:
  /// - All visible (nothing hidden) → deselect all (hide everything).
  /// - Any hidden → select all (clear hidden set).
  /// Updates local state immediately, then notifies the provider.
  void _applyToggleSelectAll() {
    if (_hidden.isEmpty) {
      // All visible → deselect all.
      setState(
        () => _hidden = widget.entries.map((e) => e.categoryId).toSet(),
      );
    } else {
      // Some hidden → select all.
      setState(() => _hidden = {});
    }
    widget.onToggleSelectAll();
  }

  void _toggle(String categoryId) {
    setState(() {
      if (_hidden.contains(categoryId)) {
        _hidden.remove(categoryId);
      } else {
        _hidden.add(categoryId);
      }
    });
    widget.onToggle(categoryId);
  }

  /// Builds an ordered flat list of tree rows from the entries and categories.
  /// Roots appear first; their children follow immediately, indented by depth.
  List<_TreeRow> _buildTree() {
    final categoryById = {for (final c in widget.categories) c.id: c};
    final entryIds = {for (final e in widget.entries) e.categoryId};
    final visited = <String>{};
    final rows = <_TreeRow>[];

    // Recursively adds an entry and all its descendant entries.
    void addSubtree(ActivityBreakdownEntry entry, int depth) {
      if (visited.contains(entry.categoryId)) return;
      visited.add(entry.categoryId);
      rows.add(_TreeRow(
        entry: entry,
        category: categoryById[entry.categoryId],
        depth: depth,
      ));
      // Add children: entries whose category's parentCategoryId matches this one.
      for (final child in widget.entries) {
        final childCat = categoryById[child.categoryId];
        if (childCat?.parentCategoryId == entry.categoryId) {
          addSubtree(child, depth + 1);
        }
      }
    }

    // Root entries: category has no parent present in the entries list.
    for (final entry in widget.entries) {
      final cat = categoryById[entry.categoryId];
      final parentIsInEntries = cat?.parentCategoryId != null &&
          entryIds.contains(cat!.parentCategoryId);
      if (!parentIsInEntries) {
        addSubtree(entry, 0);
      }
    }

    // Safety pass: add any entries skipped due to unexpected hierarchy.
    for (final entry in widget.entries) {
      if (!visited.contains(entry.categoryId)) {
        rows.add(_TreeRow(
          entry: entry,
          category: categoryById[entry.categoryId],
          depth: 0,
        ));
      }
    }

    return rows;
  }

  Widget _buildRow(_TreeRow row) {
    final isVisible = !_hidden.contains(row.entry.categoryId);

    return InkWell(
      onTap: () => _toggle(row.entry.categoryId),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Indentation: 16dp per depth level.
            SizedBox(width: 16.0 * row.depth),
            ActivityIcon(identifier: row.category?.iconIdentifier, size: 31),
            const SizedBox(width: 8),
            Expanded(child: Text(row.entry.name)),
            Checkbox(
              value: isVisible,
              onChanged: (_) => _toggle(row.entry.categoryId),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _buildTree();
    // Three-state selection: all selected, none selected, or partial.
    final allSelected = _hidden.isEmpty;
    final noneSelected = widget.entries.isNotEmpty &&
        widget.entries.every((e) => _hidden.contains(e.categoryId));
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
      title: const Text('Activity Visibility'),
      // SingleChildScrollView + Column required — ListView crashes inside
      // AlertDialog due to IntrinsicWidth incompatibility.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
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
            ...rows.map(_buildRow),
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
