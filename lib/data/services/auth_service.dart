// lib/data/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication service handling Google Sign-In with Firebase
class AuthService {
  // Singleton pattern - only one instance of AuthService exists
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }
  AuthService._internal();

  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

      // Return the authenticated user

      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  /// Sign out from both Google and Firebase
  Future<void> signOut() async {
    try {
      // Sign out from Google Sign-In
      await _googleSignIn.signOut();

      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      // Re-throw error to be handled by UI layer
      rethrow;
    }
  }
}
