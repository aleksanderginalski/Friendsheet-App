import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/meeting.dart';
import '../../data/models/pending_meeting_package.dart';
import '../providers/shared_package_inbox_provider.dart';
import 'package_activities_screen.dart';
import 'package_persons_screen.dart';
import 'share_import_success_screen.dart';

part 'package_conflict_screen_tiles.dart';

/// Shows all meetings in a received package and allows the user to resolve
/// date conflicts before proceeding. Non-conflicting meetings are shown as
/// simple tiles; conflicting ones require a Merge / Add as new / Skip choice.
class PackageConflictScreen extends StatefulWidget {
  final PendingMeetingPackage package;
  final String userId;

  const PackageConflictScreen({
    super.key,
    required this.package,
    required this.userId,
  });

  @override
  State<PackageConflictScreen> createState() => _PackageConflictScreenState();
}

class _PackageConflictScreenState extends State<PackageConflictScreen> {
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SharedPackageInboxProvider>();
    final conflicts = provider.conflictsFor(widget.package.id);
    final senderName =
        '${widget.package.senderFirstName} ${widget.package.senderLastName}'
        '${widget.package.senderNickname != null ? ' (${widget.package.senderNickname})' : ''}';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review Package'),
            Text(
              'From $senderName',
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.package.meetings.length,
              itemBuilder: (context, index) {
                final sharedMeeting = widget.package.meetings[index];
                final existingMeeting = conflicts[index];
                if (existingMeeting != null) {
                  return _MeetingConflictCard(
                    package: widget.package,
                    meetingIndex: index,
                    sharedMeeting: sharedMeeting,
                    existingMeeting: existingMeeting,
                  );
                }
                return _NonConflictTile(sharedMeeting: sharedMeeting);
              },
            ),
          ),
          _buildContinueButton(context, provider),
        ],
      ),
    );
  }

  Widget _buildContinueButton(
      BuildContext context, SharedPackageInboxProvider provider) {
    final canProceed = provider.canProceed(widget.package.id) && !_isImporting;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canProceed ? () => _onContinue(context, provider) : null,
            child: _isImporting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continue'),
          ),
        ),
      ),
    );
  }

  Future<void> _onContinue(
      BuildContext context, SharedPackageInboxProvider provider) async {
    final packageId = widget.package.id;
    final hasActivities = provider.uniqueActivityNamesFor(packageId).isNotEmpty;
    final hasPersons = provider.uniquePersonsFor(packageId).isNotEmpty;

    if (hasActivities) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: PackageActivitiesScreen(
              package: widget.package,
              userId: widget.userId,
            ),
          ),
        ),
      );
    } else if (hasPersons) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: PackagePersonsScreen(
              package: widget.package,
              userId: widget.userId,
            ),
          ),
        ),
      );
    } else {
      // No activities or persons — import directly.
      setState(() => _isImporting = true);
      final nav = Navigator.of(context);
      try {
        final summary = await provider.importPackage(packageId, widget.userId);
        if (!mounted) return;
        nav.pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => ShareImportSuccessScreen(summary: summary),
          ),
        );
      } finally {
        if (mounted) setState(() => _isImporting = false);
      }
    }
  }
}
