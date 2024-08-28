import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';


class CustomCameraScreen extends StatefulWidget {
  const CustomCameraScreen({super.key});

  @override
  _CustomCameraScreenState createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  int selectedCameraIndex = 0;
  XFile? imageFile;

  var logger = Logger();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Check and request camera permission
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      // If permission is not granted, show a message and exit
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Camera permission is required to use this feature.')),
      );
      Navigator.pop(context); // Close the screen if permission is denied
      return;
    }

    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _setupCamera(selectedCameraIndex);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cameras found on this device.')),
        );
      }
    } catch (e) {
      print('Error initializing cameras: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing camera: $e')),
      );
    }
  }

  Future<void> _setupCamera(int index) async {
    if (cameras == null || cameras!.isEmpty) return;

    _cameraController = CameraController(
      cameras![index],
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(FlashMode.off);
      setState(() {});
    } catch (e) {
      print('Error setting up camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting up camera: $e')),
      );
    }
  }

  void _switchCamera() {
    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;
    _setupCamera(selectedCameraIndex);
  }

  Future<void> _captureImage() async {
    if (_cameraController!.value.isInitialized) {
      try {
        imageFile = await _cameraController!.takePicture();
        setState(() {});
        print('Captured image path: ${imageFile!.path}');
        logger.d('Captured image path: ${imageFile!.path}');
      } catch (e) {
        print('Error capturing image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = XFile(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
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
            Navigator.pop(context);
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
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Full-screen camera preview
                Positioned.fill(
                  child: CameraPreview(_cameraController!),
                ),
                // Positioned buttons at the bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25.0, horizontal: 55.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRoundedButton(
                          icon: Icons.file_upload_outlined,
                          onPressed: _pickImageFromGallery,
                          size: 70.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          // Add more padding to the middle button
                          child: _buildRoundedButton(
                            icon: Icons.camera_alt,
                            onPressed: _captureImage,
                            size: 80.0, // Larger button in the middle
                          ),
                        ),
                        _buildRoundedButton(
                          icon: Icons.cameraswitch_outlined,
                          onPressed: _switchCamera,
                          size: 70.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRoundedButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 60.0,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }
}
