import 'package:flutter/material.dart';

import '../../data/models/friends_quest_task.dart';
import '../../data/models/person.dart';

class QuestTaskTile extends StatelessWidget {
  final FriendsQuestTask task;
  final Map<String, Person> personMap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  const QuestTaskTile({
    super.key,
    required this.task,
    required this.personMap,
    required this.onEdit,
    required this.onDelete,
    required this.onComplete,
  });

  String _subtitle() {
    final names = task.assignedPersonIds.isEmpty
        ? ''
        : task.assignedPersonIds
            .map((id) => personMap[id]?.fullName ?? id)
            .join(', ');
    final label = task.contextLabel ?? '';
    if (names.isNotEmpty && label.isNotEmpty) return '$names · $label';
    if (names.isNotEmpty) return names;
    if (label.isNotEmpty) return label;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final sub = _subtitle();
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: task.isCompleted ? null : (_) => onComplete(),
      ),
      title: Text(
        task.text,
        style: task.isCompleted
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: sub.isNotEmpty ? Text(sub) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
