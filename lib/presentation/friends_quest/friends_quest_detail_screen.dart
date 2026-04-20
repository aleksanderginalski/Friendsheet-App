import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/friends_quest_task.dart';
import '../../data/models/person.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/services/auth_service.dart';
import 'friends_quest_provider.dart';
import 'quest_participants_section.dart';
import 'quest_task_tile.dart';

class FriendsQuestDetailScreen extends StatefulWidget {
  final String questId;

  const FriendsQuestDetailScreen({super.key, required this.questId});

  @override
  State<FriendsQuestDetailScreen> createState() =>
      _FriendsQuestDetailScreenState();
}

class _FriendsQuestDetailScreenState extends State<FriendsQuestDetailScreen> {
  late final String _userId;
  Map<String, Person> _personMap = {};
  bool _loadingPersons = true;

  @override
  void initState() {
    super.initState();
    _userId = AuthService().currentUserId ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPersons());
  }

  Future<void> _loadPersons() async {
    final quest = context
        .read<FriendsQuestProvider>()
        .quests
        .firstWhere((q) => q.id == widget.questId,
            orElse: () => throw StateError('Quest not found'));
    final persons =
        await PersonRepository().getPersonsByIds(quest.participantIds, _userId);
    if (mounted) {
      setState(() {
        _personMap = {for (final p in persons) p.id: p};
        _loadingPersons = false;
      });
    }
  }

  Future<void> _reloadPersons(List<String> ids) async {
    final persons = await PersonRepository().getPersonsByIds(ids, _userId);
    if (mounted) {
      setState(() => _personMap = {for (final p in persons) p.id: p});
    }
  }

  void _showParticipantsSheet(
      FriendsQuestProvider provider, List<String> participantIds) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: QuestParticipantsSection(
          participantIds: participantIds,
          personMap: _personMap,
          userId: _userId,
          onParticipantsChanged: (newIds) async {
            await provider.updateParticipants(_userId, widget.questId, newIds);
            await _reloadPersons(newIds);
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showAddTaskDialog(
      FriendsQuestProvider provider, List<String> participantIds) {
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
                  const Text('Assign to (optional)',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView(
                      shrinkWrap: true,
                      children: participantIds.map((id) {
                        final name = _personMap[id]?.fullName ?? id;
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
                        _userId,
                        widget.questId,
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

  void _showEditTaskDialog(
      FriendsQuestProvider provider, FriendsQuestTask task) {
    final textController = TextEditingController(text: task.text);
    var saving = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('Edit task'),
          content: TextField(
            controller: textController,
            autofocus: true,
            maxLength: 200,
            decoration: const InputDecoration(labelText: 'Task text'),
            onChanged: (_) => setDialog(() {}),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: textController.text.trim().isEmpty || saving
                  ? null
                  : () async {
                      setDialog(() => saving = true);
                      await provider.editTask(
                        _userId,
                        widget.questId,
                        task.id,
                        textController.text.trim(),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsQuestProvider>();
    final questIndex =
        provider.quests.indexWhere((q) => q.id == widget.questId);
    if (questIndex == -1) {
      return const Scaffold(body: Center(child: Text('Quest not found.')));
    }
    final quest = provider.quests[questIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(quest.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Manage participants',
            onPressed: _loadingPersons
                ? null
                : () => _showParticipantsSheet(provider, quest.participantIds),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(provider, quest.participantIds),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: _loadingPersons
          ? const Center(child: CircularProgressIndicator())
          : quest.tasks.isEmpty
              ? const Center(
                  child: Text(
                    'No tasks yet. Add one with the + button.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: quest.tasks.length,
                  itemBuilder: (_, i) {
                    final task = quest.tasks[i];
                    return QuestTaskTile(
                      task: task,
                      personMap: _personMap,
                      onEdit: () => _showEditTaskDialog(provider, task),
                      onDelete: () =>
                          provider.deleteTask(_userId, widget.questId, task.id),
                    );
                  },
                ),
    );
  }
}
