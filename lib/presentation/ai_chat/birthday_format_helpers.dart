import 'package:intl/intl.dart';

import '../../data/models/buddy_context.dart';
import 'buddy_chat_mode.dart';

/// Pure formatting functions for the birthday wishes flow in [AIChatProvider].
/// Extracted to keep [AIChatProvider] under the 300-line limit.

/// Builds the Dart-computed stats message shown as the first auto-message
/// when Buddy generates birthday wishes for [personName].
String formatBirthdayStats(
  PersonContextEntry personEntry,
  String personName,
  int currentYear,
) {
  final previousYear = currentYear - 1;
  final thisYearCount = personEntry.meetingsByYear[currentYear] ?? 0;
  final lastYearCount = personEntry.meetingsByYear[previousYear] ?? 0;
  final topActs = personEntry.topActivities.isEmpty
      ? 'no recorded activities yet'
      : personEntry.topActivities.join(', ');
  final weightLine = personEntry.totalWeight > 0
      ? '\n⭐ Total weight: ${personEntry.totalWeight} pts'
      : '';

  return '📊 Here\'s a quick recap of your time with $personName:'
      '\n\n📅 Meetings: ${personEntry.meetingCount} total'
      '\n   $currentYear: $thisYearCount meeting${thisYearCount != 1 ? 's' : ''}'
      ' (vs $lastYearCount in $previousYear)'
      '$weightLine'
      '\n🎯 Favourite activities: $topActs';
}

/// Builds the greeting for the birthday-list flow.
/// The detailed person list is shown via action buttons — not duplicated here.
String buildBirthdayListGreeting(List<BirthdayPersonInfo> options) {
  if (options.isEmpty) {
    return 'No birthdays found yet. Add birthday dates to your friends\' '
        'profiles to see them here!';
  }
  return 'Here are your friends\' upcoming birthdays! '
      'Tap one to write a birthday message, or just ask me anything.';
}

/// Builds the label shown on an action button for a birthday person.
/// Format: "🎂 [Full Name] — X days — D Mon"
String birthdayActionLabel(BirthdayPersonInfo info) {
  final fmt = DateFormat('d MMM');
  final next = _nextBirthdayDate(info.person.birthDayMonth!);
  final dateStr = fmt.format(next);
  final lastName = info.person.lastName;
  final fullName = (lastName != null && lastName.isNotEmpty)
      ? '${info.person.firstName} $lastName'
      : info.person.firstName;
  final days = info.daysUntil;
  return '🎂 $fullName — $days ${days == 1 ? 'day' : 'days'} — $dateStr';
}

/// Computes the next calendar occurrence of the birthday stored as 'MM-dd'.
DateTime _nextBirthdayDate(String birthDayMonth) {
  final parts = birthDayMonth.split('-');
  final month = int.parse(parts[0]);
  final day = int.parse(parts[1]);
  final today = DateTime.now();
  var next = DateTime(today.year, month, day);
  if (!next.isAfter(today.subtract(const Duration(days: 1)))) {
    next = DateTime(today.year + 1, month, day);
  }
  return next;
}
