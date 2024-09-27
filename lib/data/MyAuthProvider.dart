import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

// MyAuthProvider.dart
class MyAuthProvider {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Create a GoogleSignIn instance with specified scopes
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['profile', 'email', 'openid']);

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    // Use the googleSignIn instance to sign in
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    return userCredential;
  }
}
