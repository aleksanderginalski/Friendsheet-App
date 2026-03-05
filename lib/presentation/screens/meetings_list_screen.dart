import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../meetings/meeting_detail_screen.dart';
import '../providers/meetings_list_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/meeting_card.dart';

/// Screen that displays all meetings for the current user, grouped by year.
/// Provides and owns [MeetingsListProvider] scoped to this screen.
class MeetingsListScreen extends StatefulWidget {
  // Optional provider injection — when set, the screen uses it directly
  // instead of creating its own. Intended for testing only.
  final MeetingsListProvider? provider;

  const MeetingsListScreen({super.key, this.provider});

  @override
  State<MeetingsListScreen> createState() => _MeetingsListScreenState();
}

class _MeetingsListScreenState extends State<MeetingsListScreen> {
  late final MeetingsListProvider _provider;
  // True when this state created the provider and is responsible for disposing it.
  late final bool _ownsProvider;

  @override
  void initState() {
    super.initState();
    if (widget.provider != null) {
      _provider = widget.provider!;
      _ownsProvider = false;
    } else {
      _provider = MeetingsListProvider();
      _ownsProvider = true;
      final userId = AuthService().currentUser?.uid;
      if (userId != null) {
        _provider.initialize(userId);
      }
    }
  }

  @override
  void dispose() {
    if (_ownsProvider) {
      _provider.dispose();
    }
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
            final filtered = provider.filteredMeetingsByYear;

            // No meetings at all — prompt to create the first one.
            if (meetingsByYear.isEmpty) {
              return const EmptyStateWidget(
                imagePath: 'assets/images/empty_state_meetings.png',
                message: 'No meetings yet — tap + to add your first one!',
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search meetings...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: provider.setSearchQuery,
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyStateWidget(
                          imagePath: 'assets/images/empty_state_meetings.png',
                          message: 'No results for "${provider.searchQuery}"',
                        )
                      : ListView(
                          children: [
                            for (final entry in filtered.entries) ...[
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
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MeetingDetailScreen(
                                                    meeting: meeting),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                            ],
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
