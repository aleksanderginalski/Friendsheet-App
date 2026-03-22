import 'package:flutter/material.dart';

import '../../data/models/activity_category.dart';
import 'activity_icons.dart';

/// Full-screen search picker for selecting a merge target.
/// Returns the selected [ActivityCategory] via [Navigator.pop].
/// Returns null if the user navigates back without picking.
///
/// Default view: hierarchical — roots with their children indented below.
/// Search active: flat filtered list with parent name as subtitle.
class MergeCategoryPickerScreen extends StatefulWidget {
  final ActivityCategory source;
  final List<ActivityCategory> candidates;

  const MergeCategoryPickerScreen({
    super.key,
    required this.source,
    required this.candidates,
  });

  @override
  State<MergeCategoryPickerScreen> createState() =>
      _MergeCategoryPickerScreenState();
}

class _MergeCategoryPickerScreenState extends State<MergeCategoryPickerScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _query = _controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Builds an ordered list for hierarchy view: roots with children interleaved.
  List<_PickerEntry> get _hierarchyEntries {
    final roots = widget.candidates
        .where((c) => c.parentCategoryId == null)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final result = <_PickerEntry>[];
    for (final root in roots) {
      final children = widget.candidates
          .where((c) => c.parentCategoryId == root.id)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      result.add(_PickerEntry(category: root, isChild: false));
      for (var i = 0; i < children.length; i++) {
        result.add(_PickerEntry(
          category: children[i],
          isChild: true,
          isLastChild: i == children.length - 1,
        ));
      }
    }
    return result;
  }

  // Flat filtered list for active search.
  List<ActivityCategory> get _searchResults {
    final q = _query.toLowerCase();
    return widget.candidates
        .where((c) => c.name.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Returns the display name of the parent category, if any.
  String? _parentName(ActivityCategory category) {
    if (category.parentCategoryId == null) return null;
    try {
      return widget.candidates
          .firstWhere((c) => c.id == category.parentCategoryId)
          .name;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Merge "${widget.source.name}" into\u2026'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search categories\u2026',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: _query.isEmpty ? _buildHierarchyList() : _buildSearchList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchyList() {
    final entries = _hierarchyEntries;
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final entry = entries[i];
        if (entry.isChild) {
          return _ChildPickerTile(
            category: entry.category,
            isLast: entry.isLastChild,
            onTap: () => Navigator.pop(context, entry.category),
          );
        }
        return ListTile(
          leading: ActivityIcon(identifier: entry.category.iconIdentifier),
          title: Text(entry.category.name),
          onTap: () => Navigator.pop(context, entry.category),
        );
      },
    );
  }

  Widget _buildSearchList() {
    final results = _searchResults;
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final cat = results[i];
        final parentName = _parentName(cat);
        return ListTile(
          leading: ActivityIcon(identifier: cat.iconIdentifier),
          title: Text(cat.name),
          subtitle: parentName != null ? Text(parentName) : null,
          onTap: () => Navigator.pop(context, cat),
        );
      },
    );
  }
}

class _PickerEntry {
  final ActivityCategory category;
  final bool isChild;
  final bool isLastChild;

  const _PickerEntry({
    required this.category,
    required this.isChild,
    this.isLastChild = false,
  });
}

// Indented child tile with tree connector line, matching ActivitiesListScreen style.
class _ChildPickerTile extends StatelessWidget {
  final ActivityCategory category;
  final bool isLast;
  final VoidCallback onTap;

  const _ChildPickerTile({
    required this.category,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).colorScheme.outlineVariant;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: CustomPaint(
              painter: _TreeLinePainter(isLast: isLast, color: lineColor),
            ),
          ),
          Expanded(
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 8, right: 16),
              leading: ActivityIcon(identifier: category.iconIdentifier),
              title: Text(category.name),
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

// Draws T-shape (non-last) or L-shape (last child) tree connector.
class _TreeLinePainter extends CustomPainter {
  final bool isLast;
  final Color color;

  const _TreeLinePainter({required this.isLast, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final midX = size.width / 2;
    final midY = size.height / 2;

    canvas.drawLine(
      Offset(midX, 0),
      Offset(midX, isLast ? midY : size.height),
      paint,
    );
    canvas.drawLine(Offset(midX, midY), Offset(size.width, midY), paint);
  }

  @override
  bool shouldRepaint(_TreeLinePainter old) =>
      old.isLast != isLast || old.color != color;
}
