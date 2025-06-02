import 'package:firebase_auth/firebase_auth.dart';

class AuthInteractor {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign up a new user
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in an existing user
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user!;
  }

  /// Send a password reset email
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Update the current user's display name
  Future<void> updateProfile({required String displayName}) async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(
      code: 'no-user',
      message: 'No user is currently signed in',
    );
    await user.updateDisplayName(displayName);
    await user.reload();
  }

  /// Get the currently signed in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

