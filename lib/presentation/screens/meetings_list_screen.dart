import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/meeting.dart';
import '../../data/services/auth_service.dart';
import '../../l10n/app_localizations.dart';
import '../meetings/meeting_detail_screen.dart';
import '../providers/meetings_list_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/meeting_card.dart';
import '../widgets/shared_search_bar.dart';

/// Screen that displays all meetings for the current user, grouped by year
/// then by month. Provides and owns [MeetingsListProvider] scoped to this screen.
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
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    if (_ownsProvider) {
      _provider.dispose();
    }
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        _provider.setSearchQuery('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<MeetingsListProvider>(
        builder: (context, provider, _) {
          final hasMeetings = !provider.isLoading &&
              provider.error == null &&
              provider.meetingsByYear.isNotEmpty;

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.meetingsListTitle),
              actions: [
                if (provider.hasPendingWrites)
                  Tooltip(
                    message: l10n.meetingsListSyncing,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.sync, size: 18),
                    ),
                  ),
                if (hasMeetings)
                  IconButton(
                    icon: Icon(
                      _isSearchActive ? Icons.search_off : Icons.search,
                    ),
                    tooltip: _isSearchActive
                        ? l10n.meetingsListSearchClose
                        : l10n.meetingsListSearch,
                    onPressed: _toggleSearch,
                  ),
              ],
            ),
            body: Column(
              children: [
                if (_isSearchActive)
                  SharedSearchBar(
                    controller: _searchController,
                    hintText: l10n.meetingsListSearchHint,
                    onChanged: provider.setSearchQuery,
                  ),
                Expanded(child: _buildContent(context, provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, MeetingsListProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text(provider.error!));
    }

    final baseMap = provider.meetingsByYear;
    if (baseMap.isEmpty) {
      return EmptyStateWidget(
        imagePath: 'assets/images/empty_state_meetings.png',
        message: l10n.meetingsListEmpty,
      );
    }

    if (provider.isSearchActive) {
      return _buildFlatSearchResults(provider.filteredMeetings, l10n);
    }

    final filteredMap = provider.meetingsByYearAndMonth;
    if (filteredMap.isEmpty) {
      return EmptyStateWidget(
        imagePath: 'assets/images/empty_state_meetings.png',
        message: l10n.meetingsListNoResults(provider.searchQuery),
      );
    }

    final locale = Localizations.localeOf(context).languageCode;
    return ListView(
      children: [
        for (final yearEntry in filteredMap.entries) ...[
          // Year section header — tapping toggles expand/collapse.
          ListTile(
            title: Text(
              yearEntry.key.toString(),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              provider.isYearExpanded(yearEntry.key)
                  ? Icons.expand_less
                  : Icons.expand_more,
            ),
            onTap: () => provider.toggleYear(yearEntry.key),
          ),
          if (provider.isYearExpanded(yearEntry.key))
            for (final monthEntry in yearEntry.value.entries) ...[
              // Month section header — indented, shows meeting count.
              _MonthHeader(
                year: yearEntry.key,
                month: monthEntry.key,
                meetingCount: monthEntry.value.length,
                provider: provider,
                locale: locale,
              ),
              if (provider.isMonthExpanded(
                '${yearEntry.key}-${monthEntry.key.toString().padLeft(2, '0')}',
              ))
                for (final meeting in monthEntry.value)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 32,
                      right: 8,
                      top: 2,
                      bottom: 2,
                    ),
                    child: MeetingCard(
                      meeting: meeting,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MeetingDetailScreen(meeting: meeting),
                          ),
                        );
                      },
                    ),
                  ),
            ],
        ],
      ],
    );
  }

  // Renders a flat scrollable list of meetings for active search queries.
  // Shows an inline message when no meetings match the query.
  Widget _buildFlatSearchResults(
      List<Meeting> meetings, AppLocalizations l10n) {
    if (meetings.isEmpty) {
      return EmptyStateWidget(
        imagePath: 'assets/images/empty_state_meetings.png',
        message: l10n.meetingsListNoResults(_provider.searchQuery),
      );
    }
    return ListView.builder(
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        return MeetingCard(
          meeting: meeting,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MeetingDetailScreen(meeting: meeting),
              ),
            );
          },
        );
      },
    );
  }
}

// Month section header with meeting count and expand/collapse icon.
// Indented 16dp relative to year headers.
class _MonthHeader extends StatelessWidget {
  final int year;
  final int month;
  final int meetingCount;
  final MeetingsListProvider provider;
  final String locale;

  const _MonthHeader({
    required this.year,
    required this.month,
    required this.meetingCount,
    required this.provider,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final monthKey = '$year-${month.toString().padLeft(2, '0')}';
    final isExpanded = provider.isMonthExpanded(monthKey);
    final monthName = DateFormat('MMMM', locale).format(DateTime(year, month));
    final l10n = AppLocalizations.of(context)!;
    final label =
        '$monthName $year · ${l10n.meetingsListMeetingCount(meetingCount)}';

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ListTile(
        title: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        trailing: Icon(
          isExpanded ? Icons.expand_more : Icons.chevron_right,
        ),
        onTap: () => provider.toggleMonth(year, month),
      ),
    );
  }
}
