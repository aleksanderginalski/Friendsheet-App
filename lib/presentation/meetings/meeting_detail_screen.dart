import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/meeting.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/person_repository.dart';
import 'meeting_detail_provider.dart';

/// Displays full details of a single meeting.
/// Receives a Meeting object via constructor — no additional Firestore fetch needed.
class MeetingDetailScreen extends StatelessWidget {
  final Meeting meeting;

  const MeetingDetailScreen({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MeetingDetailProvider(
        personRepository: PersonRepository(),
        activityRepository: ActivityRepository(),
      )..initialize(meeting),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meeting Detail'),
          actions: [
            _DeleteButton(meeting: meeting),
          ],
        ),
        body: _MeetingDetailBody(meeting: meeting),
      ),
    );
  }
}

class _MeetingDetailBody extends StatelessWidget {
  final Meeting meeting;

  const _MeetingDetailBody({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeetingDetailProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(child: Text(provider.errorMessage!));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MeetingHeader(meeting: meeting),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Participants'),
          const SizedBox(height: 8),
          _ParticipantList(provider: provider),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Activities'),
          const SizedBox(height: 8),
          _ActivityList(provider: provider),
          const SizedBox(height: 32),
          _EditButton(meeting: meeting),
        ],
      ),
    );
  }
}

class _MeetingHeader extends StatelessWidget {
  final Meeting meeting;

  const _MeetingHeader({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${meeting.date.day}.${meeting.date.month}.${meeting.date.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meeting.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '$formattedDate  ·  ⚖️ ${meeting.weight}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _ParticipantList extends StatelessWidget {
  final MeetingDetailProvider provider;

  const _ParticipantList({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.participants.isEmpty) {
      return const Text('No participants.');
    }

    return Column(
      children: provider.participants
          .map((p) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(p.fullName),
              ))
          .toList(),
    );
  }
}

class _ActivityList extends StatelessWidget {
  final MeetingDetailProvider provider;

  const _ActivityList({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.activities.isEmpty) {
      return const Text('No activities.');
    }

    return Column(
      children: provider.activities
          .map((a) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.local_activity_outlined),
                title: Text(a.name),
              ))
          .toList(),
    );
  }
}

class _EditButton extends StatelessWidget {
  final Meeting meeting;

  const _EditButton({required this.meeting});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigation to EditMeetingScreen — implemented in US-023
        },
        icon: const Icon(Icons.edit),
        label: const Text('Edit Meeting'),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final Meeting meeting;

  const _DeleteButton({required this.meeting});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      onPressed: () => _confirmDelete(context),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Meeting'),
        content: const Text(
            'Are you sure you want to delete this meeting? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Delete logic — uses MeetingRepository via provider (US-023 scope)
    // For now navigates back
    if (context.mounted) Navigator.of(context).pop();
  }
}
