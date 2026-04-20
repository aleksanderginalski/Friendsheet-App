import 'package:flutter/material.dart';

import '../../data/models/friends_quest.dart';

class FriendsQuestSummaryWidget extends StatelessWidget {
  final List<FriendsQuest> activeQuests;
  final VoidCallback onViewAll;

  const FriendsQuestSummaryWidget({
    super.key,
    required this.activeQuests,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final count = activeQuests.length;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ListTile(
        leading: const Icon(Icons.checklist_rtl, color: Color(0xFF4CAF50)),
        title: Text(
          '$count active quest${count == 1 ? '' : 's'}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: TextButton(
          onPressed: onViewAll,
          child: const Text('View all →'),
        ),
        onTap: onViewAll,
      ),
    );
  }
}
