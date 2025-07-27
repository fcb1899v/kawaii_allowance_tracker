import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Check login status
  static bool get isLoggedIn => currentUser != null;

  /// Get current user ID
  static String? get currentUserId => currentUser?.uid;

  /// Get current user email
  static String? get currentUserEmail => currentUser?.email;


  /// Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
    String? languageCode,
  }) async {
    if (languageCode != null) {
      _auth.setLanguageCode(languageCode);
    }
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Create user with email and password
  static Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? languageCode,
  }) async {
    if (languageCode != null) {
      _auth.setLanguageCode(languageCode);
    }
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail({
    required String email,
    String? languageCode,
  }) async {
    if (languageCode != null) {
      _auth.setLanguageCode(languageCode);
    }
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Send email verification
  static Future<void> sendEmailVerification() async {
    User? user = currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Sign out
  static Future<void> signOut() async => await _auth.signOut();

  /// Delete account
  static Future<void> deleteAccount() async {
    User? user = currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Listen to authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Listen to user changes
  static Stream<User?> get userChanges => _auth.userChanges();

}