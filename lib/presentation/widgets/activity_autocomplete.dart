// lib/presentation/widgets/activity_autocomplete.dart

import 'package:flutter/material.dart';
import '../../data/models/activity_category.dart';
import '../activities/activity_icons.dart';

/// Callback-based activity/category search widget.
/// Does not depend on any specific Provider — all state is passed via callbacks.
class ActivityAutocomplete extends StatefulWidget {
  final List<ActivityCategory> selectedCategories;
  final List<ActivityCategory> Function(String query) onSearch;
  final Future<void> Function(ActivityCategory category) onCategoryAdded;
  final Future<void> Function(String name) onNewActivity;
  final void Function(ActivityCategory category) onCategoryRemoved;
  final String? Function(ActivityCategory category) onGetParentName;
  final String? activitiesError;

  const ActivityAutocomplete({
    super.key,
    required this.selectedCategories,
    required this.onSearch,
    required this.onCategoryAdded,
    required this.onNewActivity,
    required this.onCategoryRemoved,
    required this.onGetParentName,
    this.activitiesError,
  });

  @override
  State<ActivityAutocomplete> createState() => _ActivityAutocompleteState();
}

class _ActivityAutocompleteState extends State<ActivityAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<ActivityCategory> _categorySuggestions = [];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _categorySuggestions = widget.onSearch(query);
    });
  }

  Future<void> _selectCategory(ActivityCategory category) async {
    await widget.onCategoryAdded(category);
    _controller.clear();
    setState(() => _categorySuggestions = []);
    _focusNode.unfocus();
  }

  // Creates a new root selectable category and selects it as a chip.
  Future<void> _addNewActivity(String name) async {
    await widget.onNewActivity(name);
    _controller.clear();
    setState(() => _categorySuggestions = []);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'Activities *',
            hintText: 'Search activities or categories...',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.local_activity_outlined),
            errorText: widget.activitiesError,
          ),
          onChanged: _onSearchChanged,
        ),
        if (_categorySuggestions.isNotEmpty ||
            _controller.text.trim().isNotEmpty)
          _buildSuggestionsList(context),
        if (widget.selectedCategories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ...widget.selectedCategories.map(
                  (c) => Chip(
                    avatar:
                        ActivityIcon(identifier: c.iconIdentifier, size: 16),
                    label: Text(c.name),
                    onDeleted: () => widget.onCategoryRemoved(c),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSuggestionsList(BuildContext context) {
    final query = _controller.text.trim();
    final hasExactMatch = _categorySuggestions.any(
      (c) => c.name.toLowerCase() == query.toLowerCase(),
    );

    return Card(
      margin: const EdgeInsets.only(top: 4),
      elevation: 4,
      child: Column(
        children: [
          // Category suggestions — shown with parent label
          ..._categorySuggestions.map(
            (category) {
              final parentName = widget.onGetParentName(category);
              return ListTile(
                leading:
                    ActivityIcon(identifier: category.iconIdentifier, size: 24),
                title: Text(category.name),
                trailing: parentName != null
                    ? Chip(
                        label: Text(
                          parentName,
                          style: const TextStyle(fontSize: 11),
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      )
                    : null,
                onTap: () => _selectCategory(category),
              );
            },
          ),
          // "Add custom" option — creates a new root category in the user's subcollection
          if (query.isNotEmpty && !hasExactMatch)
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: Text('Add "$query" as new activity'),
              onTap: () => _addNewActivity(query),
            ),
        ],
      ),
    );
  }
}
