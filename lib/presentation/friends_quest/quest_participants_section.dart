import 'package:flutter/material.dart';

import '../../data/models/person.dart';
import '../../data/repositories/person_repository.dart';

class QuestParticipantsSection extends StatefulWidget {
  final List<String> participantIds;
  final Map<String, Person> personMap;
  final String userId;
  final Future<void> Function(List<String> newIds) onParticipantsChanged;

  const QuestParticipantsSection({
    super.key,
    required this.participantIds,
    required this.personMap,
    required this.userId,
    required this.onParticipantsChanged,
  });

  @override
  State<QuestParticipantsSection> createState() =>
      _QuestParticipantsSectionState();
}

class _QuestParticipantsSectionState extends State<QuestParticipantsSection> {
  bool _updating = false;

  Future<void> _remove(String personId) async {
    setState(() => _updating = true);
    final newIds =
        widget.participantIds.where((id) => id != personId).toList();
    await widget.onParticipantsChanged(newIds);
    if (mounted) setState(() => _updating = false);
  }

  Future<void> _showAddPersonDialog() async {
    final allPersons = await PersonRepository().getPersonsByUser(widget.userId);
    final candidates = allPersons
        .where((p) => !widget.participantIds.contains(p.id))
        .toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));

    if (!mounted) return;

    var query = '';
    final added = await showDialog<List<String>>(
      context: context,
      builder: (ctx) {
        final selected = <String>{};
        return StatefulBuilder(
          builder: (ctx, setDialog) {
            final filtered = query.isEmpty
                ? candidates
                : candidates
                    .where((p) =>
                        p.fullName.toLowerCase().contains(query.toLowerCase()))
                    .toList();
            return AlertDialog(
              title: const Text('Add participants'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search, size: 20),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: (v) => setDialog(() => query = v),
                    ),
                    const SizedBox(height: 4),
                    if (candidates.isEmpty)
                      const Text('All contacts already added.')
                    else if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No matches.',
                            style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final p = filtered[i];
                            return CheckboxListTile(
                              dense: true,
                              title: Text(p.fullName),
                              value: selected.contains(p.id),
                              onChanged: (v) => setDialog(() {
                                if (v == true) {
                                  selected.add(p.id);
                                } else {
                                  selected.remove(p.id);
                                }
                              }),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () => Navigator.pop(ctx, selected.toList()),
                  child: const Text('ADD'),
                ),
              ],
            );
          },
        );
      },
    );

    if (added != null && added.isNotEmpty && mounted) {
      setState(() => _updating = true);
      final newIds = [...widget.participantIds, ...added];
      await widget.onParticipantsChanged(newIds);
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Participants (${widget.participantIds.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (widget.participantIds.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('No participants.',
                style: TextStyle(color: Colors.grey)),
          )
        else
          ...widget.participantIds.map((id) {
            final name = widget.personMap[id]?.fullName ?? id;
            return ListTile(
              dense: true,
              title: Text(name),
              trailing: _updating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () => _remove(id),
                    ),
            );
          }),
        TextButton.icon(
          onPressed: _updating ? null : _showAddPersonDialog,
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('Add participant'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
