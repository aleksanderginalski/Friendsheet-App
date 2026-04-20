import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/friends_quest_task.dart';
import '../../data/models/person.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/services/auth_service.dart';
import 'friends_quest_provider.dart';
import 'meeting_picker_sheet.dart';
import 'quest_add_task_dialog.dart';
import 'quest_participants_section.dart';
import 'quest_task_tile.dart';

enum _CompleteChoice { withoutNotes, selectMeeting }

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
  String? _linkedMeetingName;

  @override
  void initState() {
    super.initState();
    _userId = AuthService().currentUserId ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPersons();
      _loadLinkedMeetingName();
    });
  }

  Future<void> _loadPersons() async {
    final quest = context.read<FriendsQuestProvider>().quests.firstWhere(
        (q) => q.id == widget.questId,
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

  Future<void> _loadLinkedMeetingName() async {
    final quest = context.read<FriendsQuestProvider>().quests.firstWhere(
        (q) => q.id == widget.questId,
        orElse: () => throw StateError('Quest not found'));
    if (quest.linkedMeetingId == null) return;
    final meetings = await MeetingRepository().getAllMeetings(_userId);
    final matches = meetings.where((m) => m.id == quest.linkedMeetingId);
    if (mounted) {
      setState(() =>
          _linkedMeetingName = matches.isNotEmpty ? matches.first.name : null);
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

  Future<void> _showMeetingPickerSheet(FriendsQuestProvider provider) async {
    final meetings = await MeetingRepository().getAllMeetings(_userId);
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MeetingPickerSheet(
        meetings: meetings,
        onSelected: (m) async {
          await provider.linkToMeeting(_userId, widget.questId, m.id);
          if (mounted) setState(() => _linkedMeetingName = m.name);
        },
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

  Future<void> _onCompleteQuestTapped(FriendsQuestProvider provider) async {
    final quest = provider.quests.firstWhere((q) => q.id == widget.questId);
    if (quest.linkedMeetingId != null) {
      await provider.completeQuest(_userId, widget.questId);
      if (mounted) Navigator.pop(context);
      return;
    }
    final choice = await showDialog<_CompleteChoice>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Complete Quest'),
        content: const Text(
          'This quest is not linked to a meeting. '
          'Complete without saving notes, or select a meeting first?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _CompleteChoice.withoutNotes),
            child: const Text('WITHOUT NOTES'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _CompleteChoice.selectMeeting),
            child: const Text('SELECT MEETING'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (choice == _CompleteChoice.withoutNotes) {
      await provider.completeQuest(_userId, widget.questId);
      if (mounted) Navigator.pop(context);
    } else if (choice == _CompleteChoice.selectMeeting) {
      await _showMeetingPickerSheet(provider);
      if (!mounted) return;
      final updated = provider.quests.firstWhere((q) => q.id == widget.questId);
      if (updated.linkedMeetingId != null) {
        await provider.completeQuest(_userId, widget.questId);
        if (mounted) Navigator.pop(context);
      }
    }
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
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Complete quest',
            onPressed: () => _onCompleteQuestTapped(provider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showQuestAddTaskDialog(
          context,
          provider: provider,
          userId: _userId,
          questId: widget.questId,
          personMap: _personMap,
          participantIds: quest.participantIds,
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: _loadingPersons
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: quest.linkedMeetingId == null
                      ? TextButton.icon(
                          onPressed: () => _showMeetingPickerSheet(provider),
                          icon: const Icon(Icons.link),
                          label: const Text('Link to meeting'),
                        )
                      : ListTile(
                          dense: true,
                          leading:
                              const Icon(Icons.link, color: Color(0xFF4CAF50)),
                          title: Text(_linkedMeetingName ?? 'Meeting linked'),
                          subtitle: const Text('Tap to change'),
                          onTap: () => _showMeetingPickerSheet(provider),
                        ),
                ),
                Expanded(
                  child: quest.tasks.isEmpty
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
                              onComplete: () => provider.completeTask(
                                  _userId, widget.questId, task.id),
                              onEdit: () => _showEditTaskDialog(provider, task),
                              onDelete: () => provider.deleteTask(
                                  _userId, widget.questId, task.id),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
