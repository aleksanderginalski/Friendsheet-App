import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication service handling Google Sign-In with Firebase

class AuthService {
  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Get current authenticated user
  /// Returns null if no user is signed in

  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  /// Emits a new User whenever sign-in state changes
  ///
 
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get user's display name (from Google account)
  /// Returns null if not signed in or name not available
  String? get userDisplayName => _auth.currentUser?.displayName;

  /// Get user's email (from Google account)
  /// Returns null if not signed in
  String? get userEmail => _auth.currentUser?.email;

  /// Get user's photo URL (from Google account)
  /// Returns null if not signed in or photo not available
  String? get userPhotoUrl => _auth.currentUser?.photoURL;

  /// Sign in with Google
  ///
  /// Returns User if successful, null if cancelled or failed

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
      // Error will be handled by UI layer
      return null;
    }
  }

  /// Sign out from both Google and Firebase
  ///

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