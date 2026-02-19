// lib/presentation/widgets/person_autocomplete.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/person.dart';
import '../providers/add_meeting_provider.dart';

class PersonAutocomplete extends StatefulWidget {
  const PersonAutocomplete({super.key});

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

  void _onChanged(String query, AddMeetingProvider provider) {
    setState(() {
      _suggestions = provider.searchPersons(query);
    });
  }

  void _onSelectPerson(Person person, AddMeetingProvider provider) {
    provider.selectPerson(person);
    _controller.clear();
    setState(() => _suggestions = []);
  }

  void _clearInput() {
    _controller.clear();
    setState(() => _suggestions = []);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddMeetingProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search input field
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
          onChanged: (value) => _onChanged(value, provider),
        ),

        // Suggestions dropdown
        if (_suggestions.isNotEmpty || _controller.text.trim().isNotEmpty)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                // Existing persons list
                ..._suggestions.map(
                  (person) => ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(person.fullName),
                    onTap: () => _onSelectPerson(person, provider),
                  ),
                ),

                // Add new person option – shown when query is not empty
                if (_controller.text.trim().isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title:
                        Text('Add "${_controller.text.trim()}" as new person'),
                    onTap: () => _showAddPersonDialog(
                      context,
                      _controller.text.trim(),
                      provider,
                    ),
                  ),
              ],
            ),
          ),

        // Error message
        if (provider.participantsError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              provider.participantsError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),

        // Selected persons chips
        if (provider.selectedPersons.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: provider.selectedPersons
                  .map(
                    (person) => Chip(
                      label: Text(person.fullName),
                      onDeleted: () => provider.removePerson(person),
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
    AddMeetingProvider provider,
  ) async {
    // Split on first space only – "Jan Nowak" → firstName: "Jan", lastName: "Nowak"
    final parts = initialName.split(' ');
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final Person? newPerson = await showDialog<Person>(
      context: context,
      builder: (_) => AddPersonDialog(
        initialFirstName: firstName,
        initialLastName: lastName,
      ),
    );

    if (newPerson != null && context.mounted) {
      provider.addNewPerson(newPerson);
      _clearInput();
    }
  }
}

// ---------------------------------------------------------------------------
// Add Person Dialog
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

    // Return a Person without id – repository will assign it on save
    final person = Person(
      id: '',
      userId: '',
      firstName: firstName,
      lastName: _lastNameController.text.trim().isEmpty
          ? null
          : _lastNameController.text.trim(),
      createdAt: DateTime.now(),
    );

    Navigator.of(context).pop(person);
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
