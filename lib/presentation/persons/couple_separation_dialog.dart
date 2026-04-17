import 'package:flutter/material.dart';

import '../../data/models/catch_up_topic.dart';
import '../../data/repositories/catch_up_topic_repository.dart';

/// Dialog shown during couple separation to let the user decide what happens
/// to topics that were created after the couple linked (post-link topics).
///
/// Each topic is shown with a 4-state ToggleButtons selector:
/// [personA] | [Shared] | [personB] | [Delete]
///
/// Returns Map<topicId, TopicRedistributionDecision> on confirm, null on cancel.
class CoupleSeparationDialog extends StatefulWidget {
  /// First name of the primary person (Person A).
  final String personAName;

  /// First name of the partner (Person B).
  final String personBName;

  /// Topics created on or after partnerLinkedAt that require user redistribution.
  final List<CatchUpTopic> postLinkTopics;

  const CoupleSeparationDialog({
    super.key,
    required this.personAName,
    required this.personBName,
    required this.postLinkTopics,
  });

  @override
  State<CoupleSeparationDialog> createState() => _CoupleSeparationDialogState();
}

class _CoupleSeparationDialogState extends State<CoupleSeparationDialog> {
  // Keyed by topic.id; all initialized to shared (safe default).
  late final Map<String, TopicRedistributionDecision> _decisions;

  @override
  void initState() {
    super.initState();
    _decisions = {
      for (final t in widget.postLinkTopics)
        t.id: TopicRedistributionDecision.shared,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Redistribute topics'),
      // SizedBox(width: maxFinite) prevents IntrinsicWidth from collapsing the
      // dialog too narrow for the ToggleButtons row.
      content: SizedBox(
        width: double.maxFinite,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose what happens to each shared topic after unlinking.',
                ),
                const SizedBox(height: 12),
                ...widget.postLinkTopics.map(_buildTopicRow),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(Map.of(_decisions)),
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Widget _buildTopicRow(CatchUpTopic topic) {
    final d = _decisions[topic.id]!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          ToggleButtons(
            constraints: const BoxConstraints(minWidth: 60, minHeight: 36),
            isSelected: [
              d == TopicRedistributionDecision.personA,
              d == TopicRedistributionDecision.shared,
              d == TopicRedistributionDecision.personB,
              d == TopicRedistributionDecision.delete,
            ],
            onPressed: (i) => setState(
              () => _decisions[topic.id] =
                  TopicRedistributionDecision.values[i],
            ),
            children: [
              Text(widget.personAName,
                  style: const TextStyle(fontSize: 12)),
              const Text('Shared', style: TextStyle(fontSize: 12)),
              Text(widget.personBName,
                  style: const TextStyle(fontSize: 12)),
              const Text('Delete', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
