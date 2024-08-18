import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: Row(
          children: [
            Icon(Icons.timer, color: Colors.white),
            SizedBox(width: 8),
            Text("120",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Add all the details, select a theme & hit Generate!",
            style: GoogleFonts.poppins(fontSize: 16.0, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.0),
          // The row of icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOption("Selfie", Icons.camera_alt),
              _buildOption("Age", Icons.cake),
              _buildOption("Sex", Icons.wc),
              _buildOption("Body", Icons.fitness_center),
            ],
          ),
          SizedBox(height: 20.0),
          // Generate button
          ElevatedButton(
            onPressed: () {
              // Handle generate action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              "Generate",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32.0),
        SizedBox(height: 8.0),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.0),
        ),
      ],
    );
  }
}
