import 'package:flutter/material.dart';

import '../../data/models/friend_group.dart';
import '../../data/models/person.dart';
import '../widgets/shared_search_bar.dart';
import 'friend_groups_provider.dart';

// Bottom sheet for assigning multiple persons to a group.
// Shows only persons not yet in the group (available list).
// Calls addPersonToGroup for each selection on "Done".
class AssignPersonsBottomSheet extends StatefulWidget {
  final FriendGroup group;
  final List<Person> available;
  final FriendGroupsProvider groupsProvider;
  final ScrollController scrollController;

  const AssignPersonsBottomSheet({
    super.key,
    required this.group,
    required this.available,
    required this.groupsProvider,
    required this.scrollController,
  });

  @override
  State<AssignPersonsBottomSheet> createState() =>
      _AssignPersonsBottomSheetState();
}

class _AssignPersonsBottomSheetState extends State<AssignPersonsBottomSheet> {
  final Set<String> _selected = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    Navigator.of(context).pop();
    for (final id in _selected) {
      await widget.groupsProvider.addPersonToGroup(widget.group.id, id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? widget.available
        : widget.available
            .where((p) =>
                p.fullName.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Column(
      children: [
        SharedSearchBar(
          controller: _searchController,
          hintText: 'Search...',
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No results'))
              : ListView.builder(
                  controller: widget.scrollController,
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final person = filtered[i];
                    return CheckboxListTile(
                      value: _selected.contains(person.id),
                      title: Text(person.fullName),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selected.add(person.id);
                          } else {
                            _selected.remove(person.id);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected.isEmpty ? null : _done,
              child: const Text('Done'),
            ),
          ),
        ),
      ],
    );
  }
}
