import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_group.freezed.dart';
part 'friend_group.g.dart';

@freezed
class FriendGroup with _$FriendGroup {
  const FriendGroup._();

  const factory FriendGroup({
    required String id,
    required String name,
    String? iconIdentifier,
    @Default([]) List<String> personIds,
    DateTime? createdAt,
  }) = _FriendGroup;

  factory FriendGroup.fromJson(Map<String, dynamic> json) =>
      _$FriendGroupFromJson(json);

  factory FriendGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendGroup(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      iconIdentifier: data['iconIdentifier'] as String?,
      personIds: (data['personIds'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'iconIdentifier': iconIdentifier,
        'personIds': personIds,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      };
}
