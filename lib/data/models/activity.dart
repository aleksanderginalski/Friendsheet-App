import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

/// Represents an activity that can be assigned to a meeting.
/// Examples: Coffee, Walk, Cinema, Board Games.
///
/// Activities can be global (isGlobal: true, userId: null) - managed via
/// Firebase Console and read-only for users, or private (isGlobal: false,
/// userId: String) - created and managed by individual users.
@freezed
class Activity with _$Activity {
  const Activity._();

  const factory Activity({
    required String id,
    required String? userId,
    required String name,
    required bool isGlobal,
    required DateTime createdAt,
    String? categoryId,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  /// Creates an Activity from a Firestore document.
  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      userId: data['userId'] as String?,
      name: (data['name'] ?? '') as String,
      isGlobal: (data['isGlobal'] ?? false) as bool,
      categoryId: data['categoryId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Converts Activity to a map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      if (userId != null) 'userId': userId,
      'name': name,
      'isGlobal': isGlobal,
      if (categoryId != null) 'categoryId': categoryId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Returns true if the activity has valid data.
  bool isValid() {
    return name.trim().isNotEmpty;
  }
}
