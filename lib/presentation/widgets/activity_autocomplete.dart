// lib/presentation/widgets/activity_autocomplete.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/activity_category.dart';
import '../../data/services/auth_service.dart';
import '../providers/add_meeting_provider.dart';

class ActivityAutocomplete extends StatefulWidget {
  const ActivityAutocomplete({super.key});

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

  void _onSearchChanged(String query, AddMeetingProvider provider) {
    setState(() {
      _categorySuggestions = provider.searchCategories(query);
    });
  }

  Future<void> _selectCategory(
    ActivityCategory category,
    AddMeetingProvider provider,
  ) async {
    final userId = AuthService().currentUserId;
    if (userId == null) return;
    await provider.addCategory(category, userId);
    _controller.clear();
    setState(() {
      _categorySuggestions = [];
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddMeetingProvider>();
    final selectedCategories = provider.selectedCategories;
    final error = provider.activitiesError;

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
            errorText: error,
          ),
          onChanged: (query) => _onSearchChanged(query, provider),
        ),
        if (_categorySuggestions.isNotEmpty ||
            _controller.text.trim().isNotEmpty)
          _buildSuggestionsList(context, provider),
        if (selectedCategories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ...selectedCategories.map(
                  (c) => Chip(
                    avatar: const Icon(Icons.category_outlined, size: 16),
                    label: Text(c.name),
                    onDeleted: () => provider.removeCategory(c),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSuggestionsList(
    BuildContext context,
    AddMeetingProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(top: 4),
      elevation: 4,
      child: Column(
        children: [
          // Category suggestions — shown with parent label
          ..._categorySuggestions.map(
            (category) {
              final parentName = provider.getParentName(category);
              return ListTile(
                leading: const Icon(Icons.category_outlined),
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
                onTap: () => _selectCategory(category, provider),
              );
            },
          ),
        ],
      ),
    );
  }
}
