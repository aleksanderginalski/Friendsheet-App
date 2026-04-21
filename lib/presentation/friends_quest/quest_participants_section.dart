import 'package:flutter/material.dart';

import '../../data/models/person.dart';
import '../../data/repositories/person_repository.dart';
import '../../l10n/app_localizations.dart';

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
    final newIds = widget.participantIds.where((id) => id != personId).toList();
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
            final l10n = AppLocalizations.of(ctx)!;
            final filtered = query.isEmpty
                ? candidates
                : candidates
                    .where((p) =>
                        p.fullName.toLowerCase().contains(query.toLowerCase()))
                    .toList();
            return AlertDialog(
              title: Text(l10n.questAddParticipantsTitle),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: l10n.questSearch,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: (v) => setDialog(() => query = v),
                    ),
                    const SizedBox(height: 4),
                    if (candidates.isEmpty)
                      Text(l10n.questAllContactsAdded)
                    else if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(l10n.questNoMatches,
                            style: const TextStyle(color: Colors.grey)),
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
                  child: Text(l10n.dialogCancel),
                ),
                TextButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () => Navigator.pop(ctx, selected.toList()),
                  child: Text(l10n.dialogAdd),
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
            AppLocalizations.of(context)!
                .questParticipantsCount(widget.participantIds.length),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (widget.participantIds.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              AppLocalizations.of(context)!.questNoParticipants,
              style: const TextStyle(color: Colors.grey),
            ),
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
          label: Text(AppLocalizations.of(context)!.questAddParticipant),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
