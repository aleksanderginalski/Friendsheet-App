import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/import_candidate.dart';
import '../../data/models/pending_meeting_package.dart';
import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/services/auth_service.dart';
import '../providers/inbox_item_edit_provider.dart';
import '../providers/meeting_inbox_provider.dart';
import '../providers/shared_package_inbox_provider.dart';
import 'import_success_screen.dart';
import 'inbox_item_edit_screen.dart';
import 'package_conflict_screen.dart';

/// Displays pending ImportCandidates (calendar/photos) and received shared packages.
/// Both [MeetingInboxProvider] and [SharedPackageInboxProvider] must be provided
/// above this screen at the call-site.
class MeetingInboxScreen extends StatelessWidget {
  const MeetingInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeetingInboxProvider>();
    final packageProvider = context.watch<SharedPackageInboxProvider>();
    final total = provider.candidates.length + provider.confirmedCount;
    final reviewed = provider.confirmedCount;

    // No calendar candidates, no packages, nothing confirmed yet — empty state.
    if (provider.isEmpty &&
        !packageProvider.hasPackages &&
        provider.confirmedCount == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pending Meetings')),
        body: _buildEmptyState(context),
      );
    }

    // All calendar candidates processed — navigate to success screen.
    // Only triggered when calendar flow is complete and no packages remain.
    if (provider.isEmpty &&
        provider.confirmedCount > 0 &&
        !packageProvider.hasPackages) {
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
          // Calendar import progress header — only shown when candidates exist.
          if (provider.candidates.isNotEmpty)
            _buildProgressHeader(context, reviewed, total),
          // Shared packages section — shown above calendar candidates.
          if (packageProvider.hasPackages)
            _buildPackagesSection(context, packageProvider),
          // Calendar/photos candidates list.
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
            Image.asset(
              'assets/images/waiting_room.png',
              height: 160,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            const Text(
              'No pending meetings',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Import events from your calendar or receive shared meetings '
              'from a friend to get started.',
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

  // Builds the shared packages section with a header and package cards.
  Widget _buildPackagesSection(
      BuildContext context, SharedPackageInboxProvider packageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Shared by friends',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ...packageProvider.packages.map(
          (pkg) => _SharedPackageCard(
            package: pkg,
            conflictCount: packageProvider.conflictsFor(pkg.id).length,
            canProceed: packageProvider.canProceed(pkg.id),
            onTap: () => _openConflictScreen(context, pkg, packageProvider),
          ),
        ),
        const Divider(),
      ],
    );
  }

  // Navigates to PackageConflictScreen, passing the provider into the new route.
  // Method on widget (not closure) to avoid stale-context issues.
  void _openConflictScreen(
    BuildContext context,
    PendingMeetingPackage pkg,
    SharedPackageInboxProvider packageProvider,
  ) {
    final userId = AuthService().currentUserId ?? '';
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: packageProvider,
          child: PackageConflictScreen(package: pkg, userId: userId),
        ),
      ),
    );
  }

  Widget _buildCandidateList(
    BuildContext context,
    MeetingInboxProvider provider,
  ) {
    final items = provider.candidates;
    return ListView.builder(
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Image.asset(
                'assets/images/waiting_room.png',
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
          );
        }
        final candidate = items[index];
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

class _SharedPackageCard extends StatelessWidget {
  final PendingMeetingPackage package;
  final int conflictCount;
  final bool canProceed;
  final VoidCallback onTap;

  const _SharedPackageCard({
    required this.package,
    required this.conflictCount,
    required this.canProceed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    final senderName = '${package.senderFirstName} ${package.senderLastName}'
        '${package.senderNickname != null ? ' (${package.senderNickname})' : ''}';

    Widget trailing;
    if (conflictCount > 0) {
      trailing = Text(
        '⚠️ $conflictCount conflict(s)',
        style: const TextStyle(color: Colors.orange),
      );
    } else if (canProceed) {
      trailing = const Icon(Icons.check_circle, color: Colors.green);
    } else {
      trailing = const Icon(Icons.arrow_forward_ios);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        title: Text(senderName),
        subtitle: Text(
          '${package.meetings.length} meetings · '
          'sent ${fmt.format(package.sentAt)}',
        ),
        trailing: trailing,
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
