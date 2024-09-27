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
  int limit = 24; // Number of images to load per page

  final ScrollController _scrollController =
      ScrollController(); // Add scroll controller

  @override
  void initState() {
    super.initState();
    _loadImages();

    // Listen to the scroll position to trigger pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Load more images when scrolled to the bottom
        _loadImages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); // Clean up the controller when the screen is disposed
    super.dispose();
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
      print('lastfile == null');
      result = await storageRef.list(ListOptions(maxResults: limit));
    } else {
      print('lastfile == notnull');

      // Paginate - continue from the last loaded file
      result = await storageRef
          .list(ListOptions(maxResults: limit, pageToken: lastFile));
    }

    print('result1 =++====== ${result}');
    print(result);
    print('last file=== ${result.nextPageToken}');

    if (result.items.isNotEmpty) {
      print('result ======= ${result}');

      List<String> newImageUrls = [];
      for (var item in result.items) {
        String downloadUrl = await item.getDownloadURL();
        newImageUrls.add(downloadUrl);
      }

      setState(() {
        imageUrls.addAll(newImageUrls);
        lastFile = result.nextPageToken; // For pagination
        if (newImageUrls.length < limit) {
          hasMore = false; // No more images to load
        }
      });
    } else {
      setState(() {
        hasMore = false; // No more images available
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
          controller: _scrollController,
          itemCount: imageUrls.length + (hasMore ? 1 : 0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 images per row
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            if (index == imageUrls.length) {
              // Show loading indicator at the bottom
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              // Apply rounded corners
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }
}
