import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/calendar_event.dart';

/// List tile representing a single calendar event with a selection checkbox.
class CalendarEventCard extends StatelessWidget {
  const CalendarEventCard({
    super.key,
    required this.event,
    required this.isSelected,
    required this.onTap,
  });

  final CalendarEvent event;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy').format(event.startDate);
    final subtitle = event.isAllDay ? '$dateStr · All-day' : dateStr;
    final attendees = event.attendeeEmails.join(', ');

    return ListTile(
      leading: Checkbox(
        value: isSelected,
        onChanged: (_) => onTap(),
      ),
      title: Text(event.title.isNotEmpty ? event.title : '(No title)'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          if (attendees.isNotEmpty)
            Text(
              attendees,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
