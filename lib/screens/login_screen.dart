import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Save login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    return userCredential;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/splash_background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo
              SizedBox(
                width: 120.0,
                child: Image.asset("assets/logo.png"),
              ),
              const SizedBox(height: 16.0),
              // Title and Subtitle
              Text(
                "MyAvatar",
                style: GoogleFonts.dongle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                "Generate Stunning AI Portraits!",
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32.0),
              // Google Sign-In Button
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    UserCredential userCredential = await signInWithGoogle();
                    Get.offNamed(AppRoutes
                        .home); // Navigate to Home Screen upon successful login
                  } catch (e) {
                    print("Error signing in with Google: $e");
                  }
                },
                icon: const Icon(Icons.login, color: Colors.white),
                label: Text(
                  "Continue with Google",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Apple Sign-In Button
              ElevatedButton.icon(
                onPressed: () {
                  // Add your Apple Sign-In logic here
                },
                icon: const Icon(Icons.apple, color: Colors.white),
                label: Text(
                  "Continue with Apple",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Terms & Conditions Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: Text(
                    "By continuing, you accept our Terms & Conditions and acknowledge receipt of our Privacy & Cookies Policy.",
                    style: GoogleFonts.poppins(
                      fontSize: 12.0,
                      color: Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
