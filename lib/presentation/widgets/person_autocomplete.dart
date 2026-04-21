// lib/presentation/widgets/person_autocomplete.dart

import 'package:flutter/material.dart';

import '../../data/models/person.dart';
import '../../l10n/app_localizations.dart';

/// Callback-based person search widget.
/// Does not depend on any specific Provider — all state is passed via callbacks.
class PersonAutocomplete extends StatefulWidget {
  final List<Person> selectedPersons;
  final List<Person> Function(String query) onSearch;
  final void Function(Person person) onPersonAdded;
  final Future<void> Function({
    required String firstName,
    String? lastName,
    String? nickname,
  }) onNewPerson;
  final void Function(Person person) onPersonRemoved;
  final String? participantsError;

  /// Optional duplicate check — if provided, AddPersonDialog will enforce
  /// a nickname when [firstName + lastName] already exists.
  final bool Function(String firstName, String lastName)? personNameExists;

  const PersonAutocomplete({
    super.key,
    required this.selectedPersons,
    required this.onSearch,
    required this.onPersonAdded,
    required this.onNewPerson,
    required this.onPersonRemoved,
    this.participantsError,
    this.personNameExists,
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

  // Returns display name for [person], appending first nickname with a middle
  // dot when personNameExists reports a duplicate (same firstName + lastName).
  String _displayName(Person person) {
    if (widget.personNameExists == null) return person.fullName;
    final hasDuplicate = widget.personNameExists!(
      person.firstName,
      person.lastName ?? '',
    );
    if (hasDuplicate && person.nicknames.isNotEmpty) {
      return '${person.fullName} \u00B7 ${person.nicknames.first}';
    }
    return person.fullName;
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
                    title: Text(_displayName(person)),
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
                      label: Text(_displayName(person)),
                      onDeleted: () {
                        widget.onPersonRemoved(person);
                        // Refresh suggestions immediately after removal so the
                        // person can be re-selected without a forced retype.
                        // onPersonRemoved updates the provider's selectedPersons
                        // synchronously, so onSearch now returns correct results.
                        setState(() {
                          _suggestions = widget.onSearch(_controller.text);
                        });
                      },
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

    // AddPersonDialog calls onSave internally and then pops exactly once.
    // This eliminates the double-pop that occurred when the dialog returned a
    // record and the call-site also triggered onNewPerson after showDialog.
    await showDialog<void>(
      context: context,
      builder: (_) => AddPersonDialog(
        initialFirstName: firstName,
        initialLastName: lastName,
        personNameExists: widget.personNameExists,
        onSave: widget.onNewPerson,
      ),
    );

    if (context.mounted) _clearInput();
  }
}

// ---------------------------------------------------------------------------
// Add Person Dialog — calls onSave directly, then pops exactly once
// ---------------------------------------------------------------------------

class AddPersonDialog extends StatefulWidget {
  final String initialFirstName;
  final String initialLastName;

  /// Optional duplicate check — when provided, the nick field is revealed
  /// and save is blocked if a duplicate is found without a nickname.
  final bool Function(String firstName, String lastName)? personNameExists;

  /// Called with the validated inputs before the dialog pops.
  /// Matches the PersonAutocomplete.onNewPerson signature so it can be passed
  /// directly without an adapter lambda.
  final Future<void> Function({
    required String firstName,
    String? lastName,
    String? nickname,
  }) onSave;

  const AddPersonDialog({
    super.key,
    required this.initialFirstName,
    required this.onSave,
    this.initialLastName = '',
    this.personNameExists,
  });

  @override
  State<AddPersonDialog> createState() => _AddPersonDialogState();
}

class _AddPersonDialogState extends State<AddPersonDialog> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _nickController;
  String? _firstNameError;
  String? _duplicateError;
  bool _showNickField = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialFirstName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
    _nickController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nickController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final firstName = _firstNameController.text.trim();
    if (firstName.isEmpty) {
      setState(() => _firstNameError = 'First name is required');
      return;
    }

    final lastName = _lastNameController.text.trim();
    final nick = _nickController.text.trim();

    // When a duplicate name is found and the user has not yet entered a
    // nickname, reveal the nick field and block saving.
    if (widget.personNameExists != null &&
        widget.personNameExists!(firstName, lastName) &&
        nick.isEmpty) {
      setState(() {
        _showNickField = true;
        _duplicateError = '${[
          firstName,
          lastName
        ].where((s) => s.isNotEmpty).join(' ')} already exists. Add a nickname to tell them apart.';
      });
      return;
    }

    // All validation passed — create the person, then pop exactly once.
    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        firstName: firstName,
        lastName: lastName.isEmpty ? null : lastName,
        nickname: nick.isNotEmpty ? nick : null,
      );
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add person: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.personDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(
              labelText: l10n.personDialogFirstName,
              errorText: _firstNameError,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) {
              // Name changed — reset duplicate state so the check re-runs on
              // the next submit with the updated name.
              if (_firstNameError != null ||
                  _duplicateError != null ||
                  _showNickField) {
                setState(() {
                  _firstNameError = null;
                  _duplicateError = null;
                  _showNickField = false;
                });
              }
            },
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lastNameController,
            decoration: InputDecoration(
              labelText: l10n.personDialogLastName,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) {
              if (_duplicateError != null || _showNickField) {
                setState(() {
                  _duplicateError = null;
                  _showNickField = false;
                });
              }
            },
            textCapitalization: TextCapitalization.words,
          ),
          if (_duplicateError != null) ...[
            const SizedBox(height: 6),
            Text(
              _duplicateError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ],
          // Nick field is hidden by default; revealed when a duplicate is found.
          if (_showNickField) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _nickController,
              decoration: InputDecoration(
                labelText: l10n.personDialogNickname,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                // Always rebuild so the ADD button can react to the nick field
                // becoming non-empty. Also clear the error on first keystroke.
                setState(() {
                  if (_duplicateError != null) _duplicateError = null;
                });
              },
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        ElevatedButton(
          // Disabled while saving or while the nick field is visible but empty.
          onPressed: _isSaving ||
                  (_showNickField && _nickController.text.trim().isEmpty)
              ? null
              : () => _submit(context),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.dialogAdd),
        ),
      ],
    );
  }
}
