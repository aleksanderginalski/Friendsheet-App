// lib/data/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/hive_service.dart';

/// Authentication service handling Google Sign-In with Firebase
class AuthService {
  // Singleton pattern - only one instance of AuthService exists
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }
  AuthService._internal() {
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _googleSignIn = GoogleSignIn();
  }

  // Named constructor for testing: injects a fake Firestore instance.
  // _auth and _googleSignIn are intentionally left uninitialized — only
  // Firestore-related methods are tested via this constructor.
  @visibleForTesting
  AuthService.withFirestore(FirebaseFirestore firestore) {
    _firestore = firestore;
  }

  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _auth;
  late final GoogleSignIn _googleSignIn;

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get user's display name (from Google account)
  String? get userDisplayName => _auth.currentUser?.displayName;

  /// Get user's email (from Google account)
  String? get userEmail => _auth.currentUser?.email;

  /// Get user's photo URL (from Google account)
  String? get userPhotoUrl => _auth.currentUser?.photoURL;

  /// Get current user's UID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Step 1: Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user cancelled sign-in, return null
      if (googleUser == null) {
        return null;
      }

      // Step 2: Obtain auth details from Google account
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 3: Create Firebase credential from Google credentials
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase with Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        // Step 5: Ensure the user has their private category library.
        // Copies global categories on first login; no-op on subsequent logins.
        await _copyGlobalCategoriesToUser(user.uid);
      }

      return user;
    } catch (e) {
      return null;
    }
  }

  /// Sign out from both Google and Firebase
  Future<void> signOut() async {
    try {
      // Clear Hive statistics cache before sign-out so that the next user
      // session does not see stale data from the previous user.
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await HiveService.clearUserData(userId);
      }

      // Sign out from Google Sign-In
      await _googleSignIn.signOut();

      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      // Re-throw error to be handled by UI layer
      rethrow;
    }
  }

  // Copies all global categories to the user's private collection on first login.
  // Uses onboardingCompletedAt on users/{uid} as an idempotent guard so that
  // re-login and re-install do not duplicate categories.
  // parentCategoryId values are remapped to point to the new user-copy IDs.
  Future<void> _copyGlobalCategoriesToUser(String userId) async {
    try {
      // 1. Check if onboarding has already been completed for this user.
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.data()?['onboardingCompletedAt'] != null) {
        // Already onboarded — skip batch-copy.
        return;
      }

      // 2. Fetch all global categories.
      final globalSnapshot = await _firestore
          .collection('activity_categories')
          .where('isGlobal', isEqualTo: true)
          .get();

      if (globalSnapshot.docs.isEmpty) {
        return;
      }

      // 3. Pre-create document references to get new IDs before the batch write.
      final newRefs = List.generate(
        globalSnapshot.docs.length,
        (_) => _firestore
            .collection('users')
            .doc(userId)
            .collection('activity_categories')
            .doc(),
      );

      // Build mapping: globalId → newId for parentCategoryId remapping.
      final globalToNewId = <String, String>{};
      for (var i = 0; i < globalSnapshot.docs.length; i++) {
        globalToNewId[globalSnapshot.docs[i].id] = newRefs[i].id;
      }

      // 4. Batch write user copies with remapped parentCategoryIds.
      final batch = _firestore.batch();
      for (var i = 0; i < globalSnapshot.docs.length; i++) {
        final globalDoc = globalSnapshot.docs[i];
        final globalData = globalDoc.data();

        final globalParentId = globalData['parentCategoryId'] as String?;
        final newParentId =
            globalParentId != null ? globalToNewId[globalParentId] : null;

        batch.set(newRefs[i], {
          'userId': userId,
          'name': globalData['name'],
          'iconIdentifier': globalData['iconIdentifier'] ?? '',
          'isGlobal': false,
          'isSelectableAsActivity':
              globalData['isSelectableAsActivity'] ?? false,
          'parentCategoryId': newParentId,
          'copiedFromId': globalDoc.id,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();

      // 5. Mark onboarding as complete so this guard fires on subsequent logins.
      await _firestore.collection('users').doc(userId).set(
        {'onboardingCompletedAt': Timestamp.now()},
        SetOptions(merge: true),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Runs onboarding for the given user if it has not been completed yet.
  /// Safe to call on every app launch — the onboardingCompletedAt guard
  /// ensures the batch-copy executes only once per user.
  Future<void> runOnboardingIfNeeded(String userId) async {
    try {
      await _copyGlobalCategoriesToUser(userId);
    } catch (e) {
      // Onboarding failure is non-fatal — the user can still proceed.
    }
  }

  // Exposed for unit-testing the guard logic without triggering Google Sign-In.
  @visibleForTesting
  Future<void> copyGlobalCategoriesToUserForTest(String userId) =>
      _copyGlobalCategoriesToUser(userId);
}
