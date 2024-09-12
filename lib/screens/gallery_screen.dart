import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/MyAuthProvider.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<String> imageUrls = [];
  bool isLoading = false;
  bool hasMore = true;
  String? lastFile; // Used to paginate
  int limit = 9; // Number of images to load per page

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    User? currentUser = MyAuthProvider().currentUser;
    Reference storageRef =
        FirebaseStorage.instance.ref('${currentUser?.uid}/generated_images');

    ListResult result;

    if (lastFile == null) {
      // Initial load
      result = await storageRef.list(ListOptions(maxResults: limit));
    } else {
      // Paginate - continue from the last loaded file
      result = await storageRef
          .list(ListOptions(maxResults: limit, pageToken: lastFile));
    }

    if (result.items.isNotEmpty) {
      List<String> newImageUrls = [];
      for (var item in result.items) {
        String downloadUrl = await item.getDownloadURL();
        newImageUrls.add(downloadUrl);
      }

      setState(() {
        imageUrls.addAll(newImageUrls);
        lastFile = result.nextPageToken; // For pagination
        if (newImageUrls.length < limit) {
          hasMore =
              false; // If fewer images than the limit are loaded, stop loading
        }
      });
    } else {
      setState(() {
        hasMore = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201D1D),
      appBar: AppBar(
        title: Text(
          'Gallery',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF201D1D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: imageUrls.length + (hasMore ? 1 : 0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 images per row
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            if (index == imageUrls.length) {
              // Show loading indicator at the bottom
              _loadImages();
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}
