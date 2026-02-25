import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_category.freezed.dart';
part 'activity_category.g.dart';

/// Represents a category that groups activities.
/// Categories support up to 2 levels of hierarchy via parentCategoryId.
///
/// Categories can be private (isGlobal: false) — created by individual users,
/// or global (isGlobal: true) — managed separately (see US-020).
/// isSelectableAsActivity marks categories that can be used directly as
/// activity tags when adding a meeting (leaf-selectable categories).
@freezed
class ActivityCategory with _$ActivityCategory {
  const ActivityCategory._();

  const factory ActivityCategory({
    required String id,
    required String userId,
    required String name,
    required String iconIdentifier,
    required bool isGlobal,
    required bool isSelectableAsActivity,
    String? parentCategoryId,
    required DateTime createdAt,
  }) = _ActivityCategory;

  factory ActivityCategory.fromJson(Map<String, dynamic> json) =>
      _$ActivityCategoryFromJson(json);

  /// Creates an ActivityCategory from a Firestore document.
  factory ActivityCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityCategory(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      name: (data['name'] ?? '') as String,
      iconIdentifier: (data['iconIdentifier'] ?? '') as String,
      isGlobal: (data['isGlobal'] ?? false) as bool,
      isSelectableAsActivity: (data['isSelectableAsActivity'] ?? false) as bool,
      parentCategoryId: data['parentCategoryId'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Converts ActivityCategory to a map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'iconIdentifier': iconIdentifier,
      'isGlobal': isGlobal,
      'isSelectableAsActivity': isSelectableAsActivity,
      if (parentCategoryId != null) 'parentCategoryId': parentCategoryId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
