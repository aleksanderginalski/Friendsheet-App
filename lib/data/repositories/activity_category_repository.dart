import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_category.dart';
import '../services/local_cache_service.dart';
import 'cache_invalidator.dart';

class ActivityCategoryRepository {
  final FirebaseFirestore _firestore;

  /// Optional invalidator — when set, cleared after any write so that
  /// statistics caches reflect the latest category data.
  CacheInvalidator? cacheInvalidator;

  ActivityCategoryRepository({
    FirebaseFirestore? firestore,
    this.cacheInvalidator,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Subcollection for user-created categories.
  CollectionReference _categoriesRef(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('activity_categories');

  // Returns a live stream of all activity categories for the given user.
  // Firestore-primary: stream-based — cache-first migration planned in US-111.
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
    final docRef =
        await _categoriesRef(category.userId).add(category.toFirestore());
    await cacheInvalidator?.invalidateCategoriesCache();
    // Write-through: add the persisted category (with generated ID) to local cache.
    final persisted = category.copyWith(id: docRef.id);
    await LocalCacheService().upsertCategory(category.userId, persisted);
  }

  // Updates an existing category. Throws if the new parent would exceed depth 2.
  Future<void> updateCategory(ActivityCategory category) async {
    await _validateDepth(category.userId, category);
    await _categoriesRef(category.userId)
        .doc(category.id)
        .update(category.toFirestore());
    await cacheInvalidator?.invalidateCategoriesCache();
    // Write-through: update the cached category entry.
    await LocalCacheService().upsertCategory(category.userId, category);
  }

  // Deletes the category document for the given user and categoryId.
  Future<void> deleteCategory(String userId, String categoryId) async {
    await _categoriesRef(userId).doc(categoryId).delete();
    await cacheInvalidator?.invalidateCategoriesCache();
    // Write-through: remove the category from local cache.
    await LocalCacheService().removeCategory(userId, categoryId);
  }

  // Deletes the category and all its direct children atomically.
  // Uses WriteBatch to ensure no orphaned records remain in Firestore.
  Future<void> deleteWithChildren(String userId, String categoryId) async {
    final batch = _firestore.batch();

    // Delete the parent document.
    batch.delete(_categoriesRef(userId).doc(categoryId));

    // Find and delete all direct children.
    // Write-helper: must read live Firestore state before cascade delete — not a candidate for cache.
    final childrenSnapshot = await _categoriesRef(userId)
        .where('parentCategoryId', isEqualTo: categoryId)
        .get();
    final childIds = childrenSnapshot.docs.map((doc) => doc.id).toList();
    for (final doc in childrenSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    await cacheInvalidator?.invalidateCategoriesCache();
    // Write-through: remove parent and all children from local cache.
    await LocalCacheService()
        .removeCategoriesByIds(userId, [categoryId, ...childIds]);
  }

  // Creates a new root selectable category in the user's subcollection and
  // returns the persisted ActivityCategory with its generated Firestore ID.
  Future<ActivityCategory> createSelectableCategory({
    required String name,
    required String userId,
  }) async {
    final docRef = await _categoriesRef(userId).add({
      'userId': userId,
      'name': name,
      'iconIdentifier': 'category',
      'isGlobal': false,
      'isSelectableAsActivity': true,
      'createdAt': Timestamp.now(),
    });
    await cacheInvalidator?.invalidateCategoriesCache();
    final doc = await docRef.get();
    final category = ActivityCategory.fromFirestore(doc);
    // Write-through: add the persisted category to local cache.
    await LocalCacheService().upsertCategory(userId, category);
    return category;
  }

  /// Returns selectable leaf categories from the user's subcollection
  /// (isSelectableAsActivity: true). Reads from local cache; falls back to Firestore.
  Future<List<ActivityCategory>> getSelectableCategories(String userId) async {
    final cached = await LocalCacheService().getAllCategories(userId);
    if (cached.isNotEmpty) {
      return cached.where((c) => c.isSelectableAsActivity).toList();
    }
    // Firestore fallback — used on first run before cache is populated.
    final snapshot = await _categoriesRef(userId)
        .where('isSelectableAsActivity', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => ActivityCategory.fromFirestore(doc))
        .toList();
  }

  // Walks up the parentCategoryId chain for the given category and returns
  // all ancestor IDs including categoryId itself.
  // Operates on the user's subcollection (users/{uid}/activity_categories).
  // Guard: max 3 iterations to match the maximum supported depth.
  // Write-helper: must read live Firestore state for hierarchy traversal — not a candidate for cache.
  Future<List<String>> getAncestorIds(String categoryId, String userId) async {
    final result = <String>[];
    var currentId = categoryId;

    for (var i = 0; i < 3; i++) {
      final doc = await _categoriesRef(userId).doc(currentId).get();
      if (!doc.exists) break;

      result.add(currentId);

      final data = doc.data() as Map<String, dynamic>;
      final parentId = data['parentCategoryId'] as String?;
      if (parentId == null) break;

      currentId = parentId;
    }

    return result;
  }

  /// Returns all categories for the given user.
  /// Reads from local cache; falls back to Firestore when cache is cold.
  Future<List<ActivityCategory>> getAllCategories(String userId) async {
    final cached = await LocalCacheService().getAllCategories(userId);
    if (cached.isNotEmpty) return cached;
    // Firestore fallback — used on first run before cache is populated.
    final snapshot = await _categoriesRef(userId).get();
    return snapshot.docs
        .map((doc) => ActivityCategory.fromFirestore(doc))
        .toList();
  }

  /// Returns categories matching the given IDs from the user's subcollection.
  /// Reads from local cache; falls back to Firestore when cache is cold.
  Future<List<ActivityCategory>> getCategoriesByIds(
      List<String> ids, String userId) async {
    if (ids.isEmpty) return [];
    final cached = await LocalCacheService().getAllCategories(userId);
    if (cached.isNotEmpty) {
      return cached.where((c) => ids.contains(c.id)).toList();
    }
    // Firestore fallback — used on first run before cache is populated.
    final snapshot = await _categoriesRef(userId)
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return snapshot.docs
        .map((doc) => ActivityCategory.fromFirestore(doc))
        .toList();
  }

  // Validates that the category does not exceed 2 levels of hierarchy.
  // Depth 1: parentCategoryId == null (root).
  // Depth 2: parent is a root category (parent.parentCategoryId == null).
  // Depth 3+: not allowed — throws Exception.
  // Write-helper: must read live Firestore state for depth validation — not a candidate for cache.
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
