import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/add_meeting_provider.dart';

/// Text field widget for entering the meeting name.
/// Validates on focus loss and shows character counter.
class MeetingNameField extends StatefulWidget {
  const MeetingNameField({super.key});

  @override
  State<MeetingNameField> createState() => _MeetingNameFieldState();
}

class _MeetingNameFieldState extends State<MeetingNameField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Validate name when user leaves the field
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        context.read<AddMeetingProvider>().validateName();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameError = context.select<AddMeetingProvider, String?>(
      (p) => p.nameError,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meeting Name *',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          maxLength: 50,
          decoration: InputDecoration(
            hintText: 'e.g. Coffee with Anna',
            errorText: nameError,
            border: const OutlineInputBorder(),
            // Hides the default counter – we show maxLength counter via maxLength
            counterText: '',
          ),
          onChanged: (value) {
            context.read<AddMeetingProvider>().setName(value);
            setState(() {}); // rebuild counter
          },
        ),
        // Character counter aligned to the right
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_controller.text.length}/50',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ),
      ],
    );
  }
}
