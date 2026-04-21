import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../l10n/app_localizations.dart';
import 'create_quest_dialog.dart';
import 'friends_quest_detail_screen.dart';
import 'friends_quest_provider.dart';

class FriendsQuestListScreen extends StatefulWidget {
  const FriendsQuestListScreen({super.key});

  @override
  State<FriendsQuestListScreen> createState() => _FriendsQuestListScreenState();
}

class _FriendsQuestListScreenState extends State<FriendsQuestListScreen> {
  late final String _userId;

  @override
  void initState() {
    super.initState();
    _userId = AuthService().currentUserId ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FriendsQuestProvider>().loadQuests(_userId);
      }
    });
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FriendsQuestProvider provider,
    String questId,
    String questName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.questDeleteTitle),
          content: Text(l10n.questDeleteContent(questName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.dialogCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.dialogDelete),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await provider.deleteQuest(_userId, questId);
    }
  }

  void _showCreateDialog(BuildContext context, FriendsQuestProvider provider) {
    showDialog<void>(
      context: context,
      builder: (_) => CreateQuestDialog(
        userId: _userId,
        provider: provider,
      ),
    );
  }

  void _openDetail(
      BuildContext context, FriendsQuestProvider provider, String questId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: FriendsQuestDetailScreen(questId: questId),
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      provider.loadQuests(_userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsQuestProvider>();
    final quests = provider.activeQuests;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.questScreenTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, provider),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: quests.isEmpty
          ? const Center(
              child: Text(
                'No quests yet. Tap + to create one.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: quests.length,
              itemBuilder: (context, index) {
                final quest = quests[index];
                final pending = quest.tasks.where((t) => !t.isCompleted).length;
                final participantCount = quest.participantIds.length;
                return ListTile(
                  title: Text(quest.name),
                  subtitle: Text('$participantCount participants'),
                  onTap: () => _openDetail(context, provider, quest.id),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$pending pending',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(
                          context,
                          provider,
                          quest.id,
                          quest.name,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
