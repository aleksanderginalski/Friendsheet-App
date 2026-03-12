import 'package:flutter/material.dart';

import '../../data/models/activity_category.dart';
import '../activities/activity_icons.dart';

/// Dialog that displays a scrollable two-level category tree.
/// Tapping any node (root or child) closes the dialog and returns
/// the selected [ActivityCategory] via Navigator.pop.
class ActivitySelectorDialog extends StatefulWidget {
  final List<ActivityCategory> categories;
  final String? selectedCategoryId;

  const ActivitySelectorDialog({
    super.key,
    required this.categories,
    this.selectedCategoryId,
  });

  @override
  State<ActivitySelectorDialog> createState() => _ActivitySelectorDialogState();
}

class _ActivitySelectorDialogState extends State<ActivitySelectorDialog> {
  List<ActivityCategory> get _roots =>
      widget.categories.where((c) => c.parentCategoryId == null).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  List<ActivityCategory> _childrenOf(String parentId) =>
      widget.categories.where((c) => c.parentCategoryId == parentId).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  @override
  Widget build(BuildContext context) {
    final roots = _roots;

    return AlertDialog(
      title: const Text('Select Activity'),
      content: SizedBox(
        height: 350,
        width: double.maxFinite,
        // SingleChildScrollView + Column to avoid the ListView-inside-
        // AlertDialog intrinsic dimension crash.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (roots.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No activities found',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              for (final root in roots) ...[
                _CategoryTile(
                  category: root,
                  isSelected: widget.selectedCategoryId == root.id,
                  indent: 0,
                  onTap: () => Navigator.of(context).pop(root),
                ),
                for (final child in _childrenOf(root.id))
                  _CategoryTile(
                    category: child,
                    isSelected: widget.selectedCategoryId == child.id,
                    indent: 1,
                    onTap: () => Navigator.of(context).pop(child),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final ActivityCategory category;
  final bool isSelected;
  final int indent;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.indent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: 8.0 + indent * 24.0,
          right: 8.0,
          top: 10,
          bottom: 10,
        ),
        child: Row(
          children: [
            ActivityIcon(identifier: category.iconIdentifier, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontWeight: indent == 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, size: 18, color: Color(0xFF4CAF50)),
          ],
        ),
      ),
    );
  }
}
