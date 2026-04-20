import 'package:flutter/material.dart';

import '../../data/models/person.dart';
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
      builder: (ctx, setDialog) => AlertDialog(
        title: const Text('New task'),
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
                decoration: const InputDecoration(labelText: 'Task text'),
                onChanged: (_) => setDialog(() {}),
              ),
              if (participantIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Assign to (optional)',
                  style: TextStyle(fontWeight: FontWeight.w600),
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
            child: const Text('CANCEL'),
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
                : const Text('ADD'),
          ),
        ],
      ),
    ),
  );
}
