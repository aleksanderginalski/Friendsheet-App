// lib/presentation/widgets/activity_autocomplete.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/activity.dart';
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
  List<Activity> _activitySuggestions = [];
  List<ActivityCategory> _categorySuggestions = [];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query, AddMeetingProvider provider) {
    setState(() {
      _activitySuggestions = provider.searchActivities(query);
      _categorySuggestions = provider.searchCategories(query);
    });
  }

  void _selectActivity(Activity activity, AddMeetingProvider provider) {
    provider.selectActivity(activity);
    _controller.clear();
    setState(() {
      _activitySuggestions = [];
      _categorySuggestions = [];
    });
    _focusNode.unfocus();
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
      _activitySuggestions = [];
      _categorySuggestions = [];
    });
    _focusNode.unfocus();
  }

  Future<void> _showAddActivityDialog(
    BuildContext context,
    AddMeetingProvider provider,
    String initialName,
  ) async {
    // Dialog returns raw name string, Provider handles Firestore save
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AddActivityDialog(initialName: initialName),
    );

    if (name != null && context.mounted) {
      await provider.addNewActivity(name);
      _controller.clear();
      setState(() {
        _activitySuggestions = [];
        _categorySuggestions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddMeetingProvider>();
    final selectedActivities = provider.selectedActivities;
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
        if (_activitySuggestions.isNotEmpty ||
            _categorySuggestions.isNotEmpty ||
            _controller.text.trim().isNotEmpty)
          _buildSuggestionsList(context, provider),
        if (selectedCategories.isNotEmpty || selectedActivities.isNotEmpty)
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
                ...selectedActivities.map(
                  (a) => Chip(
                    label: Text(a.name),
                    onDeleted: () => provider.removeActivity(a),
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
    final query = _controller.text.trim();
    final hasExactActivityMatch = _activitySuggestions.any(
      (a) => a.name.toLowerCase() == query.toLowerCase(),
    );

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
          // Activity suggestions — private user activities
          ..._activitySuggestions.map(
            (activity) => ListTile(
              leading: const Icon(Icons.local_activity_outlined),
              title: Text(activity.name),
              onTap: () => _selectActivity(activity, provider),
            ),
          ),
          // "Add custom" option — creates a private Activity with no category
          if (query.isNotEmpty && !hasExactActivityMatch)
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: Text('Add "$query" as new activity'),
              onTap: () => _showAddActivityDialog(context, provider, query),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Activity Dialog — returns raw name string only, no Firestore logic
// ---------------------------------------------------------------------------

class AddActivityDialog extends StatefulWidget {
  final String initialName;

  const AddActivityDialog({super.key, required this.initialName});

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  late final TextEditingController _nameController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Activity name is required');
      return;
    }

    // Return raw name string — Provider is responsible for saving to Firestore
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Activity'),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Activity name',
          errorText: _error,
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}
