import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../meetings/meeting_detail_screen.dart';
import '../providers/meetings_list_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/meeting_card.dart';
import '../widgets/shared_search_bar.dart';

// Month name lookup by 1-based index (index 0 unused).
const _monthNames = [
  '',
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

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
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<MeetingsListProvider>(
        builder: (context, provider, _) {
          final hasMeetings = !provider.isLoading &&
              provider.error == null &&
              provider.meetingsByYear.isNotEmpty;

          return Scaffold(
            appBar: AppBar(
              title: const Text('My Meetings'),
              actions: [
                if (hasMeetings)
                  IconButton(
                    icon:
                        Icon(_isSearchActive ? Icons.search_off : Icons.search),
                    tooltip: _isSearchActive ? 'Close search' : 'Search',
                    onPressed: _toggleSearch,
                  ),
              ],
            ),
            body: Column(
              children: [
                if (_isSearchActive)
                  SharedSearchBar(
                    controller: _searchController,
                    hintText: 'Search meetings...',
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
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text(provider.error!));
    }

    final baseMap = provider.meetingsByYear;
    if (baseMap.isEmpty) {
      return const EmptyStateWidget(
        imagePath: 'assets/images/empty_state_meetings.png',
        message: 'No meetings yet — tap + to add your first one!',
      );
    }

    final filteredMap = provider.meetingsByYearAndMonth;
    if (filteredMap.isEmpty) {
      return EmptyStateWidget(
        imagePath: 'assets/images/empty_state_meetings.png',
        message: 'No results for "${provider.searchQuery}"',
      );
    }

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
}

// Month section header with meeting count and expand/collapse icon.
// Indented 16dp relative to year headers.
class _MonthHeader extends StatelessWidget {
  final int year;
  final int month;
  final int meetingCount;
  final MeetingsListProvider provider;

  const _MonthHeader({
    required this.year,
    required this.month,
    required this.meetingCount,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final monthKey = '$year-${month.toString().padLeft(2, '0')}';
    final isExpanded = provider.isMonthExpanded(monthKey);
    final label =
        '${_monthNames[month]} $year · $meetingCount ${meetingCount == 1 ? 'meeting' : 'meetings'}';

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
