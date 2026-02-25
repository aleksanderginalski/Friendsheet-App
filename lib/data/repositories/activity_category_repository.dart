import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_category.dart';

class ActivityCategoryRepository {
  final FirebaseFirestore _firestore;

  ActivityCategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Subcollection for user-created categories (legacy path).
  CollectionReference _categoriesRef(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('activity_categories');

  // Top-level collection used by the global library and user copies (US-020).
  CollectionReference get _globalLibraryRef =>
      _firestore.collection('activity_categories');

  // Returns a live stream of all activity categories for the given user.
  Stream<List<ActivityCategory>> getCategories(String userId) {
    return _categoriesRef(userId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ActivityCategory.fromFirestore(doc))
              .toList(),
        );
  }

  // Adds a new category. Throws if adding would exceed the 2-level depth limit.
  Future<void> addCategory(ActivityCategory category) async {
    await _validateDepth(category.userId, category);
    await _categoriesRef(category.userId).add(category.toFirestore());
  }

  // Updates an existing category. Throws if the new parent would exceed depth 2.
  Future<void> updateCategory(ActivityCategory category) async {
    await _validateDepth(category.userId, category);
    await _categoriesRef(category.userId)
        .doc(category.id)
        .update(category.toFirestore());
  }

  // Deletes the category document for the given user and categoryId.
  Future<void> deleteCategory(String userId, String categoryId) async {
    await _categoriesRef(userId).doc(categoryId).delete();
  }

  // Returns all user-private selectable categories from the global library
  // (isGlobal: false, userId: userId, isSelectableAsActivity: true).
  Future<List<ActivityCategory>> getSelectableCategories(String userId) async {
    final snapshot = await _globalLibraryRef
        .where('isGlobal', isEqualTo: false)
        .where('userId', isEqualTo: userId)
        .where('isSelectableAsActivity', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => ActivityCategory.fromFirestore(doc))
        .toList();
  }

  // Walks up the parentCategoryId chain for the given category and returns
  // all ancestor IDs including categoryId itself.
  // Operates on the user's private copies (isGlobal: false, userId: userId).
  // Guard: max 3 iterations to match the maximum supported depth.
  Future<List<String>> getAncestorIds(String categoryId, String userId) async {
    final result = <String>[];
    var currentId = categoryId;

    for (var i = 0; i < 3; i++) {
      final doc = await _globalLibraryRef.doc(currentId).get();
      if (!doc.exists) break;

      final data = doc.data() as Map<String, dynamic>;
      // Safety: only follow ancestors within the user's own copies.
      if (data['isGlobal'] == true || data['userId'] != userId) break;

      // Add after ownership check so a wrong-user parent is never included.
      result.add(currentId);

      final parentId = data['parentCategoryId'] as String?;
      if (parentId == null) break;

      currentId = parentId;
    }

    return result;
  }

  // Returns all documents from the user's private activity_categories subcollection.
  Future<List<ActivityCategory>> getAllCategories(String userId) async {
    final snapshot = await _categoriesRef(userId).get();
    return snapshot.docs
        .map((doc) => ActivityCategory.fromFirestore(doc))
        .toList();
  }

  // Returns categories matching the given IDs from the user's private collection.
  Future<List<ActivityCategory>> getCategoriesByIds(
      List<String> ids, String userId) async {
    if (ids.isEmpty) return [];
    final snapshot = await _globalLibraryRef
        .where(FieldPath.documentId, whereIn: ids)
        .where('isGlobal', isEqualTo: false)
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => ActivityCategory.fromFirestore(doc))
        .toList();
  }

  // Validates that the category does not exceed 2 levels of hierarchy.
  // Depth 1: parentCategoryId == null (root).
  // Depth 2: parent is a root category (parent.parentCategoryId == null).
  // Depth 3+: not allowed — throws Exception.
  Future<void> _validateDepth(String userId, ActivityCategory category) async {
    if (category.parentCategoryId == null) {
      // Root category — always valid.
      return;
    }

    final parentDoc =
        await _categoriesRef(userId).doc(category.parentCategoryId).get();
    if (!parentDoc.exists) {
      throw Exception('Parent category not found');
    }

    final parentData = parentDoc.data() as Map<String, dynamic>;
    if (parentData['parentCategoryId'] != null) {
      // Parent is already a subcategory — adding a child would be depth 3.
      throw Exception('Max category depth exceeded');
    }
  }
}
