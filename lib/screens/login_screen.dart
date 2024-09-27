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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0x00201d1d),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.8,
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
              "assets/bottom_shadow.png",
              fit: BoxFit.cover,
              height: screenHeight * 1.5, // Relative to screen height
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05), // Horizontal padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: screenWidth * 0.5, // Relative to screen width
                    child: Image.asset("assets/logo.png"),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "M y ",
                          style: GoogleFonts.dongle(
                            fontSize: screenWidth * 0.12, // Relative font size
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "A v a t a r",
                          style: GoogleFonts.dongle(
                            fontSize: screenWidth * 0.12,
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
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "AI Portraits!",
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.08), // Dynamic spacing
                  Text(
                    "Login / Signup",
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.05, // Dynamic font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // TODO to uncomment this and solve google sign-in method
                      try {
                        UserCredential userCredential =
                        await MyAuthProvider().signInWithGoogle();

                        print("CurrentUser===");
                        print("CurrentUser=== ${MyAuthProvider().currentUser}");

                        Get.offNamed(AppRoutes.home); // Navigate to the home screen
                      } catch (e) {
                        print("Error signing in with Google: $e");
                      }

                   /*   // TODO to remove this and solve google sign-in method
                      Get.offNamed(AppRoutes.home);*/
                    },
                    icon: Image.asset('assets/google_logo.webp',
                        width: screenWidth * 0.06, height: screenWidth * 0.06),
                    label: Text(
                      "Continue with Google",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0x00BEBEBE),
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                          horizontal: screenWidth * 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add your Apple Sign-In logic here
                    },
                    icon: Icon(Icons.apple, color: Colors.white, size: screenWidth * 0.06),
                    label: Text(
                      "Continue with Apple",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0x00BEBEBE),
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                          horizontal: screenWidth * 0.09),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "By continuing, you accept our ",
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.03,
                                color: Colors.white54,
                              ),
                            ),
                            TextSpan(
                              text: "Terms & Conditions",
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: " and ",
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.03,
                                color: Colors.white54,
                              ),
                            ),
                            TextSpan(
                              text: " acknowledge receipt of our ",
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.03,
                                color: Colors.white54,
                              ),
                            ),
                            TextSpan(
                              text: "Privacy & Cookie Policy.",
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.03,
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
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
