import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import 'package:my_avatar/data/MyAuthProvider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/MyAuthProvider.dart';
import '../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

/*  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // FirebaseAuth firebaseAuth = await FirebaseAuth.instance;

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // User? currentUser = firebaseAuth.currentUser;

    print("userCredential == $userCredential");
    // print("userCredential2 == $currentUser");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    return userCredential;
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x00201d1d),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/login_background.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bottom_shadow.png", // Your gradient image asset
              fit: BoxFit.cover,
              height: 1600.0,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 250.0,
                  child: Image.asset("assets/logo.png"),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "M y ",
                        style: GoogleFonts.dongle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: "A v a t a r",
                        style: GoogleFonts.dongle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Generate Stunning ",
                        style: GoogleFonts.poppins(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: "AI Portraits!",
                        style: GoogleFonts.poppins(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 124.0),
                Text(
                  "Login / Signup",
                  style: GoogleFonts.poppins(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      UserCredential userCredential =
                          await MyAuthProvider().signInWithGoogle();

                      print( "CurrentUser===");
                      print( "CurrentUser=== ${MyAuthProvider().currentUser}");
                      Get.offNamed(
                          AppRoutes.home); // Navigate to the home screen
                    } catch (e) {
                      print("Error signing in with Google: $e");
                    }
                  },
                  icon: Image.asset('assets/google_logo.webp',
                      width: 24, height: 24),
                  label: Text(
                    "Continue with Google",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0x00BEBEBE),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 30.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
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
                    backgroundColor: const Color(0x00BEBEBE),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 36.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "By continuing, you accept our ",
                            style: GoogleFonts.poppins(
                              fontSize: 13.0,
                              color: Colors.white54,
                            ),
                          ),
                          TextSpan(
                            text: "Terms & Conditions",
                            style: GoogleFonts.poppins(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: " and ",
                            style: GoogleFonts.poppins(
                              fontSize: 13.0,
                              color: Colors.white54,
                            ),
                          ),
                          TextSpan(
                            text: " acknowledge receipt of our ",
                            style: GoogleFonts.poppins(
                              fontSize: 13.0,
                              color: Colors.white54,
                            ),
                          ),
                          TextSpan(
                            text: "Privacy & Cookie Policy.",
                            style: GoogleFonts.poppins(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 45.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
