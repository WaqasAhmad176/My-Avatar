import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_avatar/screens/custom_camera_screen.dart';

import '../api/ApiService.dart';
import '../data/ApiRequest.dart';
import '../data/UserDataClass.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserDataClass userData = UserDataClass();
  final ApiService _apiService = ApiService();

  void _onGenerateButtonPressed(BuildContext context) async {
    if (userData.imageUrl == null || userData.imageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture or select an image first.'),
        ),
      );
      return;
    }

    // Concatenate user data into a prompt string
    final age = userData.age ?? 'unknown';
    final gender = userData.sex ?? 'unknown';
    final bodyType = userData.bodyType ?? 'unknown';

    final prompt = '$age year old $gender with $bodyType body type';

    final request = ApiRequest(
      webhook: '', // Fill if required
      input: Input(
        prompt: prompt,
        // Use the concatenated string here
        style: 'realistic',
        job_id: 1234,
        image: userData.imageUrl!,
        uuid: userData.uuid ?? '1234',
        task: 'txt2img',
        width: 1024,
        height: 1024,
        adjustment: -0.02,
      ),
    );

    try {
      final response = await _apiService.generateImage(request);

      // Now, response.output should be of type Output
      print('API Response Status: ${response.status}');
      print('API Response Output: ${response.output.output}');

      if (response.status == 'COMPLETED') {
        // Do something with the output URLs, e.g., displaying the first image
        final imageUrl = response.output.output.isNotEmpty
            ? response.output.output[0]
            : null;
        if (imageUrl != null) {
          // Display or process the imageUrl
          print('Generated Image URL: $imageUrl');
        }
      } else {
        print('Image generation failed.');
      }
    } catch (e) {
      // Handle error here
      print('API Response Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Add back button functionality
          },
        ),
        title: Row(
          children: [
            const Icon(Icons.remove_red_eye, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              "120",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey[850],
              ),
              child: Text(
                'Menu',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: Text('Gallery',
                  style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                // Handle gallery action
              },
            ),
            ListTile(
              title: Text('Subscription',
                  style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                // Handle subscription action
              },
            ),
            ListTile(
              title: Text('About Us',
                  style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                // Handle about us action
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(80.0),
              child: Text(
                "Add all the details, select a theme & hit Generate!",
                style: GoogleFonts.poppins(fontSize: 16.0, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildDropdownButton(
                          context,
                          label: "Selfie",
                          items: [
                            const DropdownMenuItem(
                              value: 'camera',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text("Camera"),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == 'camera') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomCameraScreen(
                                    onImageCaptured: (imageUrl, uuid) {
                                      setState(() {
                                        userData.imageUrl = imageUrl;
                                        userData.uuid = uuid;
                                      });
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildDropdownButton(
                          context,
                          label: "Age",
                          items: List.generate(
                            100,
                            (index) => DropdownMenuItem(
                              value: (index + 1).toString(),
                              child: Text(
                                (index + 1).toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              userData.age = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildDropdownButton(
                          context,
                          label: "Sex",
                          items: const [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text("Male",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text("Female",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              userData.sex = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildDropdownButton(
                          context,
                          label: "Body",
                          items: const [
                            DropdownMenuItem(
                              value: 'slim',
                              child: Text("Slim",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            DropdownMenuItem(
                              value: 'regular',
                              child: Text("Regular",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            DropdownMenuItem(
                              value: 'plus',
                              child: Text("Plus",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              userData.bodyType = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _onGenerateButtonPressed(context);
                      print("userData.toJson() Called");
                      print(userData.toJson());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 20.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      "Generate",
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 16.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownButton(
    BuildContext context, {
    required String label,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: DropdownButton<String>(
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
        items: items,
        onChanged: onChanged,
        dropdownColor: Colors.grey[850],
        iconEnabledColor: Colors.white,
        isExpanded: true,
        // Ensure the dropdown takes up the available space
        underline: Container(),
        style: GoogleFonts.poppins(color: Colors.white),
        menuMaxHeight: MediaQuery.of(context).size.height /
            2, // Limit the dropdown height to half the screen
      ),
    );
  }
}
