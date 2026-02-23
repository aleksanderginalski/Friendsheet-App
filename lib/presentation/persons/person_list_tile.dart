import 'package:flutter/material.dart';

import '../../data/models/person.dart';

// Displays a single person row with initials avatar and a chevron.
class PersonListTile extends StatelessWidget {
  final Person person;
  final VoidCallback onTap;

  const PersonListTile({
    super.key,
    required this.person,
    required this.onTap,
  });

  // Returns initials: first letter of firstName + first letter of lastName (if present).
  String get _initials {
    final first = person.firstName.isNotEmpty ? person.firstName[0] : '';
    final last = (person.lastName != null && person.lastName!.isNotEmpty)
        ? person.lastName![0]
        : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(_initials),
      ),
      title: Text(person.fullName),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
