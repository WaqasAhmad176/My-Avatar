import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

          // Logo and text content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 160.0, // Set the desired width for the logo
                child: Image.asset("assets/logo.png"),
              ),
              const SizedBox(height: 16.0),
              const Text(
                "MyAvatar",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                "Generate Stunning AI Portraits!",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          // "Powered by" text at the bottom
          const Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Powered by Musavir.ai",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
