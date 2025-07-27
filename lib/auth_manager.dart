import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:sweet_easy_pocket/extension.dart';

class AuthManager {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BuildContext context;

  AuthManager(this.context);

  /// Get current user
  User? get currentUser => _auth.currentUser;
  /// Check login status
  bool get isLoggedIn => currentUser != null;
  /// Get current user ID
  String? get currentUserId => currentUser?.uid;

  /// Set Language Code
  Future<void> setLanguageCode() async {
    await _auth.setLanguageCode(context.lang());
    if (context.mounted) "languageCode: ${context.lang()}".debugPrint();
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await setLanguageCode();
    "signInWithEmailAndPassword".debugPrint();
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await setLanguageCode();
    "createUserWithEmailAndPassword".debugPrint();
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    "sendPasswordResetEmail".debugPrint();
    await setLanguageCode();
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Send email verification
  Future<void> sendEmailVerification(User? user) async {
    "sendEmailVerification".debugPrint();
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    "signOut".debugPrint();
    await _auth.signOut();
  }

  /// Delete account
  Future<void> deleteAccount() async {
    User? user = currentUser;
    if (user != null) {
      "deleteAccount".debugPrint();
      await user.delete();
    }
  }
}