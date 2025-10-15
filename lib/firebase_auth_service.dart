import 'package:firebase_auth/firebase_auth.dart';
import 'package:geominder/auth_result.dart'; // Make sure this path is correct
import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- GETTERS ---

  /// Provides a stream to listen for authentication changes (login/logout).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Returns the full Firebase User object if logged in, null otherwise.
  User? get currentUser => _auth.currentUser;

  /// Returns the current user's unique ID (uid) from Firebase.
  String? get currentUserId => _auth.currentUser?.uid;


  // --- METHODS ---

  /// Signs up a new user with email and password.
  Future<AuthResult> signUp({required String email, required String password}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // The user object is non-null on success for this method.
      return AuthResult.success(
        userId: userCredential.user!.uid,
        email: userCredential.user!.email!,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: e.message ?? 'An unknown sign up error occurred.');
    } catch (e) {
      return AuthResult.error(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Signs in an existing user with email and password.
  Future<AuthResult> signIn({required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // The user object is non-null on success for this method.
      return AuthResult.success(
        userId: userCredential.user!.uid,
        email: userCredential.user!.email!,
      );
    } on FirebaseAuthException catch (e) {
      // Handles specific Firebase errors like 'invalid-credential'
      return AuthResult.error(message: e.message ?? 'An unknown sign in error occurred.');
    } catch (e) {
      return AuthResult.error(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // Add this method inside your FirebaseAuthService class

Future<void> resetPassword({required String email}) async {
  // This will throw a FirebaseAuthException on failure, which we can catch in AppState.
  await _auth.sendPasswordResetEmail(email: email);
}

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      // Generally, we don't need to throw here. The UI will react to the authStateChange.
    }
  }
}