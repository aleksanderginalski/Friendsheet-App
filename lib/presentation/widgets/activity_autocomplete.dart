// lib/presentation/widgets/activity_autocomplete.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/activity.dart';
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

  void _onSearchChanged(String query, AddMeetingProvider provider) {
    setState(() {
      _suggestions = provider.searchActivities(query);
    });
  }

  void _selectActivity(Activity activity, AddMeetingProvider provider) {
    provider.selectActivity(activity);
    _controller.clear();
    setState(() => _suggestions = []);
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
        if (_suggestions.isNotEmpty || _controller.text.trim().isNotEmpty)
          _buildSuggestionsList(context, provider),
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
          ..._suggestions.map(
            (activity) => ListTile(
              leading: const Icon(Icons.local_activity_outlined),
              title: Text(activity.name),
              onTap: () => _selectActivity(activity, provider),
            ),
          ),
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
