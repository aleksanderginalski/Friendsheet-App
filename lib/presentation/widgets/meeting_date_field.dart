import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/add_meeting_provider.dart';

/// Date field widget for selecting the meeting date.
/// Opens a date picker dialog on tap.
class MeetingDateField extends StatelessWidget {
  const MeetingDateField({super.key});

  Future<void> _pickDate(BuildContext context, DateTime currentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && context.mounted) {
      context.read<AddMeetingProvider>().setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = context.select<AddMeetingProvider, DateTime>(
      (p) => p.date,
    );

    final formattedDate = DateFormat('dd/MM/yyyy').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meeting Date *',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickDate(context, date),
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(formattedDate),
          ),
        ),
      ],
    );
  }
}
