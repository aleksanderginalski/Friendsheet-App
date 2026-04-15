import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'catch_up_topic.freezed.dart';
part 'catch_up_topic.g.dart';

@freezed
class CatchUpTopic with _$CatchUpTopic {
  const CatchUpTopic._();

  const factory CatchUpTopic({
    required String id,
    required String text,
    // Optional label indicating when to return to this topic, e.g. "Lipiec 2026".
    String? contextLabel,
    required DateTime createdAt,
    @Default(false) bool isArchived,
    DateTime? archivedAt,
  }) = _CatchUpTopic;

  factory CatchUpTopic.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CatchUpTopic(
      id: doc.id,
      text: (data['text'] ?? '') as String,
      contextLabel: data['contextLabel'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      isArchived: (data['isArchived'] as bool?) ?? false,
      archivedAt: data['archivedAt'] != null
          ? (data['archivedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory CatchUpTopic.fromJson(Map<String, dynamic> json) =>
      _$CatchUpTopicFromJson(json);

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      if (contextLabel != null) 'contextLabel': contextLabel,
      'createdAt': Timestamp.fromDate(createdAt),
      'isArchived': isArchived,
      if (archivedAt != null) 'archivedAt': Timestamp.fromDate(archivedAt!),
    };
  }
}
