import 'package:flutter/material.dart';

import '../../data/models/person.dart';
import '../../data/repositories/person_repository.dart';
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
    return AlertDialog(
      title: const Text('New Quest'),
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
              decoration: const InputDecoration(
                labelText: 'Quest name',
                hintText: 'e.g. Weekend with the crew',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Participants',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            if (_loadingPersons)
              const Center(child: CircularProgressIndicator())
            else if (_persons.isEmpty)
              const Text(
                'No contacts yet.',
                style: TextStyle(color: Colors.grey),
              )
            else ...[
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search participants...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No matches.',
                          style: TextStyle(color: Colors.grey),
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
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: _canCreate ? _create : null,
          child: _creating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('CREATE'),
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
