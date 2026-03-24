import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/meeting.dart';
import '../../data/models/person.dart';
import '../../data/services/auth_service.dart';
import '../meetings/meeting_detail_screen.dart';
import '../providers/person_meetings_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/meeting_card.dart';

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

/// Screen displaying all meetings where [person] is a participant,
/// grouped by year and month. Navigated to from PersonDetailScreen.
class PersonMeetingsScreen extends StatefulWidget {
  final Person person;

  const PersonMeetingsScreen({super.key, required this.person});

  @override
  State<PersonMeetingsScreen> createState() => _PersonMeetingsScreenState();
}

class _PersonMeetingsScreenState extends State<PersonMeetingsScreen> {
  late final PersonMeetingsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = PersonMeetingsProvider();
    // Load after first frame so the provider is attached to the widget tree.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = AuthService().currentUserId;
      if (userId != null) {
        _provider.loadMeetings(userId, widget.person.id);
      }
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  // Navigates to MeetingDetailScreen and reloads the list on return.
  // Reload is required because the user may have deleted or edited the meeting.
  void _openMeetingDetail(BuildContext context, Meeting meeting) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingDetailScreen(meeting: meeting),
      ),
    ).then((_) {
      if (!mounted) return;
      final userId = AuthService().currentUserId;
      if (userId != null) {
        _provider.loadMeetings(userId, widget.person.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lastName = widget.person.lastName;
    final title = lastName != null && lastName.isNotEmpty
        ? '${widget.person.firstName} $lastName'
        : widget.person.firstName;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<PersonMeetingsProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: _buildContent(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, PersonMeetingsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text(provider.error!));
    }

    if (provider.meetings.isEmpty) {
      return EmptyStateWidget(
        imagePath: 'assets/images/empty_state_meetings.png',
        message: 'No meetings with ${widget.person.firstName} yet.',
      );
    }

    return ListView(
      children: [
        for (final yearEntry in provider.meetingsByYearAndMonth.entries) ...[
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
                      onTap: () => _openMeetingDetail(context, meeting),
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
  final PersonMeetingsProvider provider;

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
        title: Text(label, style: Theme.of(context).textTheme.titleSmall),
        trailing: Icon(
          isExpanded ? Icons.expand_more : Icons.chevron_right,
        ),
        onTap: () => provider.toggleMonth(year, month),
      ),
    );
  }
}
