// lib/presentation/meetings/meeting_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/meeting.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../screens/add_meeting_screen.dart';
import 'meeting_detail_provider.dart';

/// Displays full details of a single meeting.
/// Stores meeting in state so the view reflects updates from the edit screen.
class MeetingDetailScreen extends StatefulWidget {
  final Meeting meeting;

  const MeetingDetailScreen({super.key, required this.meeting});

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  late Meeting _meeting;

  @override
  void initState() {
    super.initState();
    _meeting = widget.meeting;
  }

  // Updates displayed meeting data when returning from the edit screen
  void _onMeetingUpdated(Meeting updated) {
    setState(() => _meeting = updated);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MeetingDetailProvider(
        personRepository: PersonRepository(),
        activityRepository: ActivityRepository(),
      )..initialize(_meeting),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meeting Detail'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            // Passes current meeting state back to caller on back navigation
            onPressed: () => Navigator.pop(context, _meeting),
          ),
          actions: [
            _DeleteButton(meeting: _meeting),
          ],
        ),
        body: _MeetingDetailBody(
          meeting: _meeting,
          onMeetingUpdated: _onMeetingUpdated,
        ),
      ),
    );
  }
}

class _MeetingDetailBody extends StatelessWidget {
  final Meeting meeting;
  final void Function(Meeting) onMeetingUpdated;

  const _MeetingDetailBody({
    required this.meeting,
    required this.onMeetingUpdated,
  });

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
          _EditButton(meeting: meeting, onMeetingUpdated: onMeetingUpdated),
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
  final void Function(Meeting) onMeetingUpdated;

  const _EditButton({required this.meeting, required this.onMeetingUpdated});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleEdit(context),
        icon: const Icon(Icons.edit),
        label: const Text('Edit Meeting'),
      ),
    );
  }

  Future<void> _handleEdit(BuildContext context) async {
    final updated = await Navigator.push<Meeting>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMeetingScreen(initialMeeting: meeting),
      ),
    );

    if (updated is Meeting && context.mounted) {
      // Refresh participant and activity display with updated meeting data
      context.read<MeetingDetailProvider>().initialize(updated);
      onMeetingUpdated(updated);
      // User stays on detail screen — updated meeting passed back on back navigation
    }
  }
}

class _DeleteButton extends StatefulWidget {
  final Meeting meeting;

  const _DeleteButton({required this.meeting});

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    if (_isDeleting) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

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

    setState(() => _isDeleting = true);

    try {
      await MeetingRepository().deleteMeeting(widget.meeting.id);
      if (context.mounted) Navigator.of(context).pop('deleted');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete meeting. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }
}
