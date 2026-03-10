// lib/presentation/widgets/person_autocomplete.dart

import 'package:flutter/material.dart';
import '../../data/models/person.dart';

/// Callback-based person search widget.
/// Does not depend on any specific Provider — all state is passed via callbacks.
class PersonAutocomplete extends StatefulWidget {
  final List<Person> selectedPersons;
  final List<Person> Function(String query) onSearch;
  final void Function(Person person) onPersonAdded;
  final Future<void> Function({
    required String firstName,
    String? lastName,
  }) onNewPerson;
  final void Function(Person person) onPersonRemoved;
  final String? participantsError;

  const PersonAutocomplete({
    super.key,
    required this.selectedPersons,
    required this.onSearch,
    required this.onPersonAdded,
    required this.onNewPerson,
    required this.onPersonRemoved,
    this.participantsError,
  });

  @override
  State<PersonAutocomplete> createState() => _PersonAutocompleteState();
}

class _PersonAutocompleteState extends State<PersonAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  List<Person> _suggestions = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    setState(() {
      _suggestions = widget.onSearch(query);
    });
  }

  void _onSelectPerson(Person person) {
    widget.onPersonAdded(person);
    _controller.clear();
    setState(() => _suggestions = []);
  }

  void _clearInput() {
    _controller.clear();
    setState(() => _suggestions = []);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Search or add participant...',
            border: const OutlineInputBorder(),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearInput,
                  )
                : const Icon(Icons.search),
          ),
          onChanged: _onChanged,
        ),
        if (_suggestions.isNotEmpty || _controller.text.trim().isNotEmpty)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                ..._suggestions.map(
                  (person) => ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(person.fullName),
                    onTap: () => _onSelectPerson(person),
                  ),
                ),
                if (_controller.text.trim().isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: Text(
                      'Add "${_controller.text.trim()}" as new person',
                    ),
                    onTap: () => _showAddPersonDialog(
                      context,
                      _controller.text.trim(),
                    ),
                  ),
              ],
            ),
          ),
        if (widget.participantsError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.participantsError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        if (widget.selectedPersons.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.selectedPersons
                  .map(
                    (person) => Chip(
                      label: Text(person.fullName),
                      onDeleted: () => widget.onPersonRemoved(person),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Future<void> _showAddPersonDialog(
    BuildContext context,
    String initialName,
  ) async {
    final parts = initialName.split(' ');
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    // Dialog returns raw strings; caller handles Firestore save via onNewPerson
    final result = await showDialog<({String firstName, String lastName})>(
      context: context,
      builder: (_) => AddPersonDialog(
        initialFirstName: firstName,
        initialLastName: lastName,
      ),
    );

    if (result != null && context.mounted) {
      await widget.onNewPerson(
        firstName: result.firstName,
        lastName: result.lastName.isEmpty ? null : result.lastName,
      );
      _clearInput();
    }
  }
}

// ---------------------------------------------------------------------------
// Add Person Dialog — returns raw strings only, no Firestore logic
// ---------------------------------------------------------------------------

class AddPersonDialog extends StatefulWidget {
  final String initialFirstName;
  final String initialLastName;

  const AddPersonDialog({
    super.key,
    required this.initialFirstName,
    this.initialLastName = '',
  });

  @override
  State<AddPersonDialog> createState() => _AddPersonDialogState();
}

class _AddPersonDialogState extends State<AddPersonDialog> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  String? _firstNameError;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialFirstName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final firstName = _firstNameController.text.trim();
    if (firstName.isEmpty) {
      setState(() => _firstNameError = 'First name is required');
      return;
    }

    // Return raw strings — Provider is responsible for saving to Firestore
    Navigator.of(context).pop((
      firstName: firstName,
      lastName: _lastNameController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Person'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(
              labelText: 'First name *',
              errorText: _firstNameError,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) {
              if (_firstNameError != null) {
                setState(() => _firstNameError = null);
              }
            },
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last name (optional)',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () => _submit(context),
          child: const Text('ADD'),
        ),
      ],
    );
  }
}
