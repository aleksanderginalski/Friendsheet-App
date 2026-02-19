// lib/presentation/widgets/activity_autocomplete.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/activity.dart';
import '../../data/repositories/activity_repository.dart';
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
  List<Activity> _suggestions = [];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Updates suggestion list based on current query
  void _onSearchChanged(String query, AddMeetingProvider provider) {
    setState(() {
      _suggestions = provider.searchActivities(query);
    });
  }

  // Selects existing activity from suggestions
  void _selectActivity(Activity activity, AddMeetingProvider provider) {
    provider.selectActivity(activity);
    _controller.clear();
    setState(() => _suggestions = []);
    _focusNode.unfocus();
  }

  // Opens dialog to create and save a new activity
  Future<void> _showAddActivityDialog(
    BuildContext context,
    AddMeetingProvider provider,
    String initialName,
  ) async {
    final activity = await showDialog<Activity>(
      context: context,
      builder: (_) => AddActivityDialog(initialName: initialName),
    );

    if (activity != null && context.mounted) {
      provider.addNewActivity(activity);
      _controller.clear();
      setState(() => _suggestions = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddMeetingProvider>();
    final selectedActivities = provider.selectedActivities;
    final error = provider.activitiesError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search input field
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'Activities *',
            hintText: 'Search or add activity...',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.local_activity_outlined),
            errorText: error,
          ),
          onChanged: (query) => _onSearchChanged(query, provider),
        ),

        // Suggestions dropdown
        if (_suggestions.isNotEmpty || _controller.text.trim().isNotEmpty)
          _buildSuggestionsList(context, provider),

        // Selected activities chips
        if (selectedActivities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: selectedActivities
                  .map((a) => Chip(
                        label: Text(a.name),
                        onDeleted: () => provider.removeActivity(a),
                      ))
                  .toList(),
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
    final hasExactMatch = _suggestions.any(
      (a) => a.name.toLowerCase() == query.toLowerCase(),
    );

    return Card(
      margin: const EdgeInsets.only(top: 4),
      elevation: 4,
      child: Column(
        children: [
          // Existing activity suggestions
          ..._suggestions.map(
            (activity) => ListTile(
              leading: const Icon(Icons.local_activity_outlined),
              title: Text(activity.name),
              onTap: () => _selectActivity(activity, provider),
            ),
          ),

          // Add new activity option
          if (query.isNotEmpty && !hasExactMatch)
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

// Dialog for creating a new activity
class AddActivityDialog extends StatefulWidget {
  final String initialName;

  const AddActivityDialog({super.key, required this.initialName});

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  late final TextEditingController _nameController;
  bool _isSaving = false;
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

  Future<void> _save() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Activity name is required');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final userId = AuthService().currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final activity = await ActivityRepository().addActivity(
        userId: userId,
        name: name,
      );

      if (mounted) Navigator.of(context).pop(activity);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = 'Failed to save activity';
        });
      }
    }
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
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('SAVE'),
        ),
      ],
    );
  }
}
