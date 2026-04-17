import 'package:flutter/material.dart';

import '../../data/models/person.dart';

/// Displays couple link status on PersonDetailScreen.
/// Shows "Link as couple" tile when unlinked, partner name + Unlink button when linked.
class CoupleLinkSection extends StatelessWidget {
  final Person person;

  /// Resolved partner Person object; null when unlinked or not yet loaded.
  final Person? partnerPerson;

  /// Called when the user taps "Link as couple". Opens the link flow.
  final VoidCallback onLinkTap;

  /// Called when the user taps "Unlink". Opens the separation flow.
  final VoidCallback? onUnlinkTap;

  const CoupleLinkSection({
    super.key,
    required this.person,
    required this.partnerPerson,
    required this.onLinkTap,
    this.onUnlinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLinked = person.partnerId != null;

    return ListTile(
      leading: const Icon(Icons.favorite_border),
      title: Text(isLinked ? 'Couple' : 'Link as couple'),
      subtitle: isLinked && partnerPerson != null
          ? Text('Linked with ${partnerPerson!.fullName}')
          : null,
      // Tile tap is only active when unlinked; unlink is triggered via trailing button.
      onTap: isLinked ? null : onLinkTap,
      trailing: isLinked
          ? TextButton(
              onPressed: onUnlinkTap,
              child: const Text('Unlink'),
            )
          : null,
    );
  }
}
