import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../data/MyAuthProvider.dart';

class CustomCameraScreen extends StatefulWidget {
  const CustomCameraScreen({super.key, required this.onImageCaptured});

  final void Function(String? imageUrl, String? uuid) onImageCaptured;

  @override
  _CustomCameraScreenState createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  int selectedCameraIndex = 0;
  XFile? imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera(selectedCameraIndex); // Reinitialize the camera if resumed
    }
  }

  Future<void> _initializeCamera() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to use this feature.'),
        ),
      );
      Navigator.pop(context);
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
      if (kDebugMode) {
        print('Error initializing cameras: $e');
      }
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
      setState(() => _isLoading = true);
      try {
        imageFile = await _cameraController!.takePicture();
        print("Captured image path: ${imageFile!.path}");

        String imageUrl = await _uploadImage(imageFile!);
        String uuid = const Uuid().v4();

        widget.onImageCaptured(imageUrl, uuid);
        setState(() => _isLoading = false);
        Navigator.pop(context);
      } catch (e) {
        setState(() => _isLoading = false);
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
      setState(() => _isLoading = true);
      imageFile = XFile(pickedFile.path);
      print("Selected image path: ${imageFile!.path}");

      String imageUrl = await _uploadImage(imageFile!);
      String uuid = const Uuid().v4();

      widget.onImageCaptured(imageUrl, uuid);
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  Future<String> _uploadImage(XFile image) async {
    String fileName = const Uuid().v4();

    User? currentUser = MyAuthProvider().currentUser;
    print( "CurrentUser===1111111 ");
    print( "CurrentUser=== $currentUser");

    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('${currentUser?.uid}/uploaded_images/$fileName.jpg');

    UploadTask uploadTask = firebaseStorageRef.putFile(File(image.path));
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cameraController == null || !_cameraController!.value.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(child: CameraPreview(_cameraController!)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 45.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildRoundedButton(
                            icon: Icons.file_upload_outlined,
                            onPressed: _pickImageFromGallery,
                            size: 65.0,
                          ),
                          _buildRoundedButton(
                            icon: Icons.camera_alt_rounded,
                            onPressed: _captureImage,
                            size: 80.0,
                          ),
                          _buildRoundedButton(
                            icon: Icons.cameraswitch_rounded,
                            onPressed: _switchCamera,
                            size: 65.0,
                          ),
                        ],
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
        icon: Icon(icon, color: Colors.black, size: 35.0),
        onPressed: onPressed,
      ),
    );
  }
}
