import 'package:flutter/material.dart';

import '../../data/models/person.dart';
import '../../l10n/app_localizations.dart';
import 'friends_quest_provider.dart';

void showQuestAddTaskDialog(
  BuildContext context, {
  required FriendsQuestProvider provider,
  required String userId,
  required String questId,
  required Map<String, Person> personMap,
  required List<String> participantIds,
}) {
  final textController = TextEditingController();
  final selectedIds = <String>{};
  var adding = false;

  showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialog) {
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l10n.questNewTaskTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: textController,
                  autofocus: true,
                  maxLength: 200,
                  decoration: InputDecoration(labelText: l10n.questTaskText),
                  onChanged: (_) => setDialog(() {}),
                ),
                if (participantIds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.questAssignTo,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView(
                      shrinkWrap: true,
                      children: participantIds.map((id) {
                        final name = personMap[id]?.fullName ?? id;
                        return CheckboxListTile(
                          dense: true,
                          title: Text(name),
                          value: selectedIds.contains(id),
                          onChanged: (v) => setDialog(() {
                            if (v == true) {
                              selectedIds.add(id);
                            } else {
                              selectedIds.remove(id);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.dialogCancel),
            ),
            TextButton(
              onPressed: textController.text.trim().isEmpty || adding
                  ? null
                  : () async {
                      setDialog(() => adding = true);
                      await provider.addTask(
                        userId,
                        questId,
                        textController.text.trim(),
                        selectedIds.toList(),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
              child: adding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.dialogAdd),
            ),
          ],
        );
      },
    ),
  );
}
