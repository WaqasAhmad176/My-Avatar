import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_avatar/controllers/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize SplashController
    final splashController = Get.put(SplashController());

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

          // Gradient overlay image at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/bottom_shadow.png", // Your gradient image asset
              fit: BoxFit.cover,
              height: 500.0,
            ),
          ),

          // Logo and text content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 250.0, // Set the desired width for the logo
                child: Image.asset("assets/logo.png"),
              ),
              RichText(
                text: TextSpan(
                  text: 'M y ',
                  style: GoogleFonts.dongle(
                    fontSize: 50.0,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'A v a t a r ',
                      style: GoogleFonts.dongle(
                        fontSize: 50.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Generate Stunning AI Portraits! text with Poppins font
              RichText(
                text: TextSpan(
                  text: 'Generate Stunning',
                  style: GoogleFonts.poppins(
                    fontSize: 24.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w200,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ' AI Portraits!',
                      style: GoogleFonts.poppins(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // "Powered by" text and image at the bottom
          Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Powered ',
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'by',
                        style: GoogleFonts.poppins(
                          fontSize: 18.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  "assets/musavir_logo.png",
                  height: 40.0, // Adjust the height as necessary
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
