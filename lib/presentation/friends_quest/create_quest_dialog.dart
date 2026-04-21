import 'package:flutter/material.dart';

import '../../data/models/person.dart';
import '../../data/repositories/person_repository.dart';
import '../../l10n/app_localizations.dart';
import 'friends_quest_provider.dart';

class CreateQuestDialog extends StatefulWidget {
  final String userId;
  final FriendsQuestProvider provider;

  const CreateQuestDialog({
    super.key,
    required this.userId,
    required this.provider,
  });

  @override
  State<CreateQuestDialog> createState() => _CreateQuestDialogState();
}

class _CreateQuestDialogState extends State<CreateQuestDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<Person> _persons = [];
  final Set<String> _selectedIds = {};
  bool _loadingPersons = true;
  bool _creating = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    _loadPersons();
  }

  Future<void> _loadPersons() async {
    final persons = await PersonRepository().getPersonsByUser(widget.userId);
    if (mounted) {
      setState(() {
        _persons = persons..sort((a, b) => a.fullName.compareTo(b.fullName));
        _loadingPersons = false;
      });
    }
  }

  List<Person> get _filteredPersons {
    if (_searchQuery.isEmpty) return _persons;
    return _persons
        .where((p) => p.fullName.toLowerCase().contains(_searchQuery))
        .toList();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _creating = true);
    await widget.provider.createQuest(
      widget.userId,
      name,
      _selectedIds.toList(),
    );
    if (mounted) Navigator.pop(context);
  }

  bool get _canCreate => _nameController.text.trim().isNotEmpty && !_creating;

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPersons;
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.questNewQuestTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: l10n.questNameLabel,
                hintText: l10n.questNameHint,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.questParticipantsLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            if (_loadingPersons)
              const Center(child: CircularProgressIndicator())
            else if (_persons.isEmpty)
              Text(
                l10n.questNoContacts,
                style: const TextStyle(color: Colors.grey),
              )
            else ...[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.questSearchParticipants,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.questNoMatches,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final person = filtered[index];
                          return CheckboxListTile(
                            dense: true,
                            title: Text(person.fullName),
                            value: _selectedIds.contains(person.id),
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedIds.add(person.id);
                                } else {
                                  _selectedIds.remove(person.id);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.dialogCancel),
        ),
        TextButton(
          onPressed: _canCreate ? _create : null,
          child: _creating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.dialogCreate),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
