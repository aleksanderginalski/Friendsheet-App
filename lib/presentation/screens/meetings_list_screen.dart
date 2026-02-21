import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../providers/meetings_list_provider.dart';
import '../widgets/meeting_card.dart';

/// Screen that displays all meetings for the current user, grouped by year.
/// Provides and owns [MeetingsListProvider] scoped to this screen.
class MeetingsListScreen extends StatefulWidget {
  const MeetingsListScreen({super.key});

  @override
  State<MeetingsListScreen> createState() => _MeetingsListScreenState();
}

class _MeetingsListScreenState extends State<MeetingsListScreen> {
  late final MeetingsListProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = MeetingsListProvider();
    final userId = AuthService().currentUser?.uid;
    if (userId != null) {
      _provider.initialize(userId);
    }
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Meetings'),
        ),
        body: Consumer<MeetingsListProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }

            final meetingsByYear = provider.meetingsByYear;

            if (meetingsByYear.isEmpty) {
              return _EmptyState();
            }

            return ListView(
              children: [
                for (final entry in meetingsByYear.entries) ...[
                  // Year section header
                  ListTile(
                    title: Text(
                      entry.key.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    trailing: Icon(
                      provider.isYearExpanded(entry.key)
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                    onTap: () => provider.toggleYear(entry.key),
                  ),
                  // Meeting cards shown only when the year is expanded
                  if (provider.isYearExpanded(entry.key))
                    for (final meeting in entry.value)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: MeetingCard(
                          meeting: meeting,
                          onTap: null, // Navigation to detail screen (US-022)
                        ),
                      ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Shown when the user has no meetings yet.
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No meetings yet!'),
          SizedBox(height: 4),
          Text('Tap + to add your first meeting.'),
        ],
      ),
    );
  }
}