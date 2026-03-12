// lib/data/services/account_deletion_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/hive_service.dart';
import 'google_calendar_service.dart';

/// Owns the full account deletion sequence:
/// re-authenticate → delete Firestore data → delete Auth user → clear local storage.
///
/// Not a singleton — injected into [DeleteAccountProvider] as a dependency
/// so it can be mocked in tests.
class AccountDeletionService {
  AccountDeletionService({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
    required GoogleCalendarService calendarService,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn,
        _calendarService = calendarService;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final GoogleCalendarService _calendarService;

  /// Re-authenticates with a fresh Google credential, then deletes all user data.
  /// Throws on any step failure so the caller can show an error and allow retry.
  Future<void> deleteAccount(String uid) async {
    await _reauthenticate();
    await _deleteFirestoreData(uid);
    await _firebaseAuth.currentUser!.delete();
    await _clearLocalData(uid);
  }

  // Obtains a fresh Google credential and re-authenticates the current user.
  // Tries silent sign-in first; falls back to interactive sign-in if needed.
  Future<void> _reauthenticate() async {
    final googleUser =
        await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception(
          'Re-authentication cancelled — no Google account selected');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    await _firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
  }

  // Deletes all subcollections and the user document from Firestore.
  Future<void> _deleteFirestoreData(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);

    await _deleteCollection(userRef.collection('meetings'));
    await _deleteCollection(userRef.collection('persons'));
    await _deleteCollection(userRef.collection('activity_categories'));

    // Delete the user document itself after subcollections are cleared.
    await userRef.delete();
  }

  // Paginates through a collection in batches of 500 and deletes all documents.
  // Repeats until no documents remain, handling collections of any size.
  Future<void> _deleteCollection(CollectionReference ref) async {
    while (true) {
      final snapshot = await ref.limit(500).get();
      if (snapshot.docs.isEmpty) break;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  // Clears all local storage: SharedPreferences, secure storage (via calendar
  // service revoke), and Hive statistics cache.
  Future<void> _clearLocalData(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await _calendarService.revokeAccess();

    await HiveService.clearUserData(uid);
  }
}
