import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/import_candidate.dart';
import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../providers/inbox_item_edit_provider.dart';
import '../providers/meeting_inbox_provider.dart';
import 'import_success_screen.dart';
import 'inbox_item_edit_screen.dart';

/// Displays the pending ImportCandidates and lets the user review each one.
/// [MeetingInboxProvider] must be provided above this screen at the call-site.
class MeetingInboxScreen extends StatelessWidget {
  const MeetingInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeetingInboxProvider>();
    final total = provider.candidates.length + provider.confirmedCount;
    final reviewed = provider.confirmedCount;

    // Entered from drawer with no pending candidates — show empty state.
    if (provider.isEmpty && provider.confirmedCount == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pending Meetings')),
        body: _buildEmptyState(context),
      );
    }

    // All candidates processed — navigate to success screen.
    if (provider.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ChangeNotifierProvider.value(
                value: context.read<MeetingInboxProvider>(),
                child: ImportSuccessScreen(
                  confirmedCount: provider.confirmedCount,
                ),
              ),
            ),
          );
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Meetings'),
      ),
      body: Column(
        children: [
          _buildProgressHeader(context, reviewed, total),
          Expanded(
            child: provider.candidates.isEmpty
                ? const SizedBox.shrink()
                : _buildCandidateList(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No pending meetings',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Import events from your calendar to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Import from Calendar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(
    BuildContext context,
    int reviewed,
    int total,
  ) {
    final progress = total > 0 ? reviewed / total : 0.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$reviewed of $total reviewed',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress),
        ],
      ),
    );
  }

  Widget _buildCandidateList(
    BuildContext context,
    MeetingInboxProvider provider,
  ) {
    return ListView.builder(
      itemCount: provider.candidates.length,
      itemBuilder: (context, index) {
        final candidate = provider.candidates[index];
        return _CandidateCard(
          candidate: candidate,
          onTap: () => _openEditScreen(context, candidate),
        );
      },
    );
  }

  void _openEditScreen(BuildContext context, ImportCandidate candidate) {
    final inboxProvider = context.read<MeetingInboxProvider>();
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: inboxProvider),
            ChangeNotifierProvider(
              create: (_) => InboxItemEditProvider(
                meetingRepository: MeetingRepository(),
                personRepository: PersonRepository(),
                categoryRepository: ActivityCategoryRepository(),
              ),
            ),
          ],
          child: InboxItemEditScreen(candidate: candidate),
        ),
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final ImportCandidate candidate;
  final VoidCallback onTap;

  const _CandidateCard({
    required this.candidate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM dd, yyyy');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(candidate.title),
        subtitle: Text(fmt.format(candidate.date)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (candidate.attendeeEmails.isNotEmpty)
              Chip(
                label: Text('${candidate.attendeeEmails.length} attendees'),
                visualDensity: VisualDensity.compact,
              ),
            const SizedBox(width: 4),
            Chip(
              label: Text(candidate.sourceType.name),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
