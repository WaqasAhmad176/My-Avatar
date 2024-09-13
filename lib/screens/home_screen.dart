import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For formatting the current time
import 'package:my_avatar/screens/custom_camera_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../api/ApiService.dart';
import '../data/ApiRequest.dart';
import '../data/UserDataClass.dart';
import 'gallery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final UserDataClass userData = UserDataClass();
  final ApiService _apiService = ApiService();

  String? initialImageUrl;
  String? initialAge;
  String? initialSex;
  String? initialBodyType;

  String promptInput = ''; // This will hold the predefined prompt string
  List<String> imageUrls = []; // List to store multiple generated image URLs
  List<Map<String, dynamic>> imagesWithTimestamps = [];
  List<String> assetImageUrls = [
    // Replace with your actual image URLs
    'assets/prompt_1.png',
    'assets/prompt_2.png',
    'assets/prompt_3.png',
    'assets/prompt_4.png',
    'assets/prompt_5.png',
    'assets/prompt_6.png',
    'assets/prompt_7.png',
    'assets/prompt_8.png',
    'assets/prompt_9.png',
  ];

  // List of predefined prompts corresponding to images
  List<String> promptList = [];

  bool isGenerating = false;
  bool hasGenerated = false;
  bool isAgeDropdownEnabled = false;
  bool isSexDropdownEnabled = false;
  bool isBodyTypeDropdownEnabled = false;
  String? imageUrl;
  int selectedIndex = -1;

  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    // Use addPostFrameCallback to ensure the layout is built before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, // Scroll to the end
        duration: const Duration(milliseconds: 500),
        // Set duration for smooth scroll
        curve: Curves.easeInOut, // Scrolling animation curve
      );
    });
  }

  @override
  void dispose() {
    // Dispose of the ScrollController when not in use
    _scrollController.dispose();
    super.dispose();
  }

  void _onGenerateButtonPressed(BuildContext context) async {
    if (userData.imageUrl == null || userData.imageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture or select an image first.'),
        ),
      );
      return;
    }

    final age = userData.age;
    final gender = userData.sex;
    final bodyType = userData.bodyType;

    // Check if any of age, gender, or bodyType is null or empty
    if (age == null ||
        age.isEmpty ||
        gender == null ||
        gender.isEmpty ||
        bodyType == null ||
        bodyType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please provide all user details (age, gender, and body type).'),
        ),
      );
      return;
    }

    // Update the prompt with dynamic values
    final prompt = promptInput
        .replaceAll('\$gender', gender)
        .replaceAll('\$age', age)
        .replaceAll('\$bodyType', bodyType);

    final request = ApiRequest(
      webhook: '', // Fill if required
      input: Input(
        prompt: prompt,
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

    setState(() {
      isGenerating = true;
      hasGenerated = false;
    });

    try {
      final response = await _apiService.generateImage(request);

      print('API Response Status: ${response.status}');
      print('API Response Output: ${response.output.output}');

      if (response.status == 'COMPLETED') {
        final imageUrl = response.output.output.isNotEmpty
            ? response.output.output[0]
            : null;
        if (imageUrl != null) {
          final uploadedImageUrl = await _uploadImageFromUrl(imageUrl);
          setState(() {
            userData.imageUrl = initialImageUrl;
            userData.age = initialAge;
            userData.sex = initialSex;
            userData.bodyType = initialBodyType;
            this.imageUrl = uploadedImageUrl;
            // Add the new image to the list of image URLs
            // imageUrls.add(uploadedImageUrl);
            addImage(uploadedImageUrl);
            isGenerating = false;
            hasGenerated = true;
            isAgeDropdownEnabled = true;
            _scrollToBottom(); // Automatically scroll to bottom on press
          });
        }
      } else {
        setState(() {
          isGenerating = false;
        });
        print('Image generation failed.');
      }
    } catch (e) {
      setState(() {
        isGenerating = false;
      });
      print('API Response Error: $e');
    }
  }

  Future<String> _uploadImageFromUrl(String imageUrl) async {
    // Get a UUID for the file
    String uuid = const Uuid().v4();

    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;
    print("CurrentUser=== $currentUser");

    // Get the current timestamp in a human-readable format (e.g., YYYYMMDD_HHMMSS)
    String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    // Create the file name using the timestamp and UUID
    String fileName = '$timestamp-$uuid';

    // Create a reference to Firebase Storage with the timestamp in the file name
    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('${currentUser?.uid}/generated_images/$fileName.jpg');

    // Download the image from the provided URL
    final http.Response response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      // Get a temporary directory to save the downloaded image
      final Directory tempDir = await getTemporaryDirectory();
      final File file = File('${tempDir.path}/$fileName.jpg');

      // Write the downloaded image bytes to the file
      await file.writeAsBytes(response.bodyBytes);

      // Upload the file to Firebase Storage
      UploadTask uploadTask = firebaseStorageRef.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL after the upload is complete
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Return the download URL
      return downloadUrl;
    } else {
      throw Exception('Failed to download image from URL');
    }
  }

  // When adding a new image, save the URL and the generation time fro scroll view vertical
  void addImage(String url) {
    imagesWithTimestamps.add({
      'url': url,
      'timestamp': DateTime.now(), // Store the generation time
    });
  }

  @override
  void initState() {
    super.initState();
    // Store initial values
    initialImageUrl = userData.imageUrl;
    initialAge = userData.age;
    initialSex = userData.sex;
    initialBodyType = userData.bodyType;

    // Initially disable age, sex, and body type dropdowns
    isAgeDropdownEnabled = false;
    isSexDropdownEnabled = false;
    isBodyTypeDropdownEnabled = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201D1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF201D1D),
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
      // drawer
      endDrawer: Drawer(
        backgroundColor: const Color(0xFF201D1D),
        elevation: 32.0, // Add elevation to the drawer
        width: MediaQuery.of(context).size.width *
            0.6, // Set drawer width to 60% of screen width
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // Ensure items are spaced, with 'Hello' at the bottom
          children: <Widget>[
            ListView(
              shrinkWrap: true, // Wrap content inside the ListView
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height *
                    0.05, // Set padding relative to screen height
              ),
              children: <Widget>[
                // Close button at the top-right corner
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the drawer
                      },
                    ),
                  ],
                ),

                // List tiles with right-aligned text, font sizes made responsive
                ListTile(
                  title: Align(
                    alignment: Alignment.centerRight, // Align text to the right
                    child: Text(
                      'Gallery',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.height *
                            0.020, // Responsive font size
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GalleryScreen()),
                    );
                  },
                ),
                ListTile(
                  title: Align(
                    alignment: Alignment.centerRight, // Align text to the right
                    child: Text(
                      'Subscription',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.height *
                            0.020, // Responsive font size
                      ),
                    ),
                  ),
                  onTap: () {
                    // Handle subscription action
                  },
                ),
                ListTile(
                  title: Align(
                    alignment: Alignment.centerRight, // Align text to the right
                    child: Text(
                      'About Us',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.height *
                            0.020, // Responsive font size
                      ),
                    ),
                  ),
                  onTap: () {
                    // Handle about us action
                  },
                ),
              ],
            ),

            // 'Hello' text at the bottom
            Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              // Add padding to the bottom
              child: Text(
                'All Rights Reserved, MyAvatar by Musavir.AI, 2024',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.height *
                      0.009, // Responsive font size
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // this is for Vertical Images Generated Scroll
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController, // Assign ScrollController here
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      if (!isGenerating && !hasGenerated && imageUrls.isEmpty)
                        Text(
                          "Add all the details, select a theme & hit Generate!",
                          style: GoogleFonts.poppins(
                              fontSize: 16.0, color: Colors.white),
                          textAlign: TextAlign.center,
                        )
                      else if (isGenerating)
                        Column(
                          children: [
                            ...imagesWithTimestamps.map((imageData) {
                              return Column(
                                children: [
                                  // Display the timestamp for the current image
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Text(
                                      DateFormat('kk:mm')
                                          .format(imageData['timestamp']),
                                      // Use the stored timestamp
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Display each image with rounded corners
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 40.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      // Add rounded corners to the image
                                      child: Image.network(
                                        imageData['url'],
                                        // Display each image from the list
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                            Image.asset('assets/loading_placeholder.png'),
                            // Loading image placeholder
                            SizedBox(height: 20),
                          ],
                        )
                      else if (hasGenerated && imageUrls.isNotEmpty)
                        // Display images with time above each image
                        Column(
                          children: [
                            // Map through the imagesWithTimestamps list and display each image with its timestamp
                            ...imagesWithTimestamps.map((imageData) {
                              return Column(
                                children: [
                                  // Display the timestamp for the current image
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Text(
                                      DateFormat('kk:mm')
                                          .format(imageData['timestamp']),
                                      // Use the stored timestamp
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Display each image with rounded corners
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 40.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      // Add rounded corners to the image
                                      child: Image.network(
                                        imageData['url'],
                                        // Display each image from the list
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Horizontal Scroll View for the images
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: assetImageUrls.length,
                itemBuilder: (context, index) {
                  bool isLocked =
                      index >= 2; // Lock images starting from the third one
                  bool isBodyTypeSelected = userData.bodyType != null &&
                      userData.bodyType!.isNotEmpty;

                  // Disable the first two prompts if bodyType is not selected
                  bool isDisabled = index < 2 && !isBodyTypeSelected;

                  return GestureDetector(
                    onTap: () {
                      // Only handle tap if not locked and not disabled
                      if (!isLocked && !isDisabled) {
                        setState(() {
                          selectedIndex = index; // Update the selected index
                          promptInput = promptList[index];
                        });
                        print('Selected prompt: $promptInput');
                      }
                    },
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: AssetImage(assetImageUrls[index]),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                color: selectedIndex == index && !isDisabled
                                    ? Colors.white
                                    : Colors.transparent,
                                // Only add border if it's selected and not disabled
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                        if (isLocked)
                          Positioned.fill(
                            child: Container(
                              color: const Color(0xFF201D1D).withOpacity(0.5),
                              // Apply the overlay shade on locked images
                            ),
                          ),
                        if (!isBodyTypeSelected)
                          Positioned.fill(
                            child: Container(
                              color: const Color(0xFF201D1D).withOpacity(0.4),
                              // Apply the overlay shade on locked images
                            ),
                          ),
                        if (isLocked)
                          Positioned.fill(
                            child: Container(
                              color: const Color(0xFF201D1D).withOpacity(0.2),
                              // Apply lock icon overlay on locked images
                              child: const Center(
                                child: Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Selfie Dropdown
                    Expanded(
                      child: _buildDropdownButton(
                        context,
                        label: userData.imageUrl != null &&
                                userData.imageUrl!.isNotEmpty
                            ? Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(userData.imageUrl!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : "Selfie",
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
                    const SizedBox(width: 8),

                    // Age Dropdown (Enabled after Selfie is selected)
                    Expanded(
                      child: _buildDropdownButton(
                        context,
                        label: userData.age != null && userData.age!.isNotEmpty
                            ? userData.age
                            : "Age",
                        enabled: userData.imageUrl != null &&
                            userData.imageUrl!.isNotEmpty,
                        // Enabled only if selfie is selected
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
                            _generatePrompts();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Sex Dropdown (Enabled after Age is selected)
                    Expanded(
                      child: _buildDropdownButton(
                        context,
                        label: userData.sex != null && userData.sex!.isNotEmpty
                            ? userData.sex!
                            : "Sex",
                        enabled:
                            userData.age != null && userData.age!.isNotEmpty,
                        // Enabled only if age is selected
                        items: const [
                          DropdownMenuItem(
                            value: 'M',
                            child: Text("Male",
                                style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: 'F',
                            child: Text("Female",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            userData.sex = value;
                            _generatePrompts();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Body Type Dropdown (Enabled after Sex is selected)
                    Expanded(
                      child: _buildDropdownButton(
                        context,
                        label: userData.bodyType != null &&
                                userData.bodyType!.isNotEmpty
                            ? userData.bodyType!
                            : "Body",
                        enabled:
                            userData.sex != null && userData.sex!.isNotEmpty,
                        // Enabled only if sex is selected
                        items: const [
                          DropdownMenuItem(
                            value: 'Slim',
                            child: Text("Slim",
                                style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: 'Regular',
                            child: Text("Regular",
                                style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: 'Plus',
                            child: Text("Plus",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            userData.bodyType = value;
                            _generatePrompts();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  // Add margin here
                  child: ElevatedButton(
                    onPressed: () {
                      _onGenerateButtonPressed(context);
                      _scrollToBottom(); // Automatically scroll to bottom on press
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      // Fully transparent background
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 20.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: const BorderSide(
                            color: Colors.transparent,
                            width: 2.0), // Border color and width
                      ),
                      elevation: 0, // Remove any default elevation/shadow
                    ),
                    child: SizedBox(
                      width: 250.0, // Increase button width
                      child: Text(
                        "Generate",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF272727), // Text color
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownButton(
    BuildContext context, {
    required dynamic label,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    bool enabled =
        true, // Add the enabled property with a default value of true
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: DropdownButton<String>(
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: label is String
              ? Text(
                  label,
                  style: GoogleFonts.poppins(color: Colors.white),
                )
              : label,
        ),
        items: enabled ? items : null,
        // Disable items if not enabled
        onChanged: enabled ? onChanged : null,
        // Disable interaction if not enabled
        dropdownColor: Colors.grey[850],
        iconEnabledColor: Colors.white,
        isExpanded: true,
        underline: Container(),
        style: GoogleFonts.poppins(color: Colors.white),
        menuMaxHeight: MediaQuery.of(context).size.height / 2,
        disabledHint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: label is String
              ? Text(
                  label,
                  style: GoogleFonts.poppins(
                      color: Colors.white
                          .withOpacity(0.5)), // Make the text appear disabled
                )
              : label,
        ),
      ),
    );
  }

  void _generatePrompts() {
    final age = userData.age;
    final gender = userData.sex;
    final bodyType = userData.bodyType;

    if (age != null && gender != null && bodyType != null) {
      // Generate multiple prompt variations based on user data
      setState(() {
        promptList = [
          /*Prompt 1 */
          'Ultra Closeup, real photo, portrait of a man super model in grayscale, bright spotlight, high contrast, symmetrical, vintage style, black and white, he is wearing a black highneck sweater, dramatic lighting, thick smoke coming from behind, realistic , a $gender , who is $age year old and has a $bodyType body type',
          /*Prompt 2 */
          'a closeup portrait,  headshot, a cinematic portrait, of a super model, Mixed eclectic beauty in complementary colors Moiré patterns weave, Beauty in high fashions breath, Otherworldly sheathe, starry sky at earthrise, cinematic view, muted cinematic colors, cinematic lighting , a $gender , who is $age year old and has a $bodyType body type',
          /*Prompt 3 */
          'a closeup portrait, headshot, a real photo, taken from LEICA, DSLR, award winning photo, professional photo, a female astronaut from the future, space scene, inside spaceship, spaceship  cinematic lighting, kinetic, smiling with lips closed, fixing the space ship, tools, detailed skin, detailed eyes, beautiful hair floating in space, futuristic space suit. , a $gender , who is $age year old and has a $bodyType body type',
          /*Prompt 4 */
          'a closeup portrait, headshot, a real photo, taken from LEICA, DSLR, award winning photo, professional photo, a male astronaut from the future, space scene, inside spaceship, spaceship  cinematic lighting, kinetic, smiling with lips closed, fixing the space ship, tools, detailed skin, detailed eyes, beautiful hair floating in space, futuristic space suit. , a $gender , who is $age year old and has a $bodyType body type',
          /*Prompt 5 */
          'real closeup portrait photo, headshot, detailed skin, hyperreal, DSLR, LEICA, lens noise, (Intricate details:1.2), (Realistic), (masterpiece), (photograph), Cinema Lighting，jsschnwckcw woman with hair made of fire wearing high-necked shirt ,  glass shards, space fragmentation, rmessy hair, serious, glowing hand, surreal, upper body, dynamic pose, Travel through time and space, silver white theme, ultra highres, sharpness texture, High detail RAW Photo, detailed face , a $gender , who is $age year old and has a $bodyType body type',
          /*Prompt 6 */
          'a closeup portrait, headshot, High fashion symmetrical portrait shoot in an Urban Graffiti of a female supermodel wearing bold reflective glasses, in the style of curved mirrors, ultra realistic, bold, cartoonish lines, neoclassical style, filip hodas, moody color schemes, postmodern bricolage, sculptural aesthetics, anamorphic lens, hyper detailed, rainbow-core, bubblegum , a $gender , who is $age year old and has a $bodyType body type',
          /*Prompt 7 */
          'a closeup portrait, headshot, High fashion symmetrical portrait shoot in an Urban Graffiti of a male supermodel wearing bold reflective glasses, in the style of curved mirrors, ultra realistic, bold, cartoonish lines, neoclassical style, filip hodas, moody color schemes, postmodern bricolage, sculptural aesthetics, anamorphic lens, hyper detailed, rainbow-core, bubblegum , a $gender , who is $age year old and has a $bodyType body type',
          /*Prompt 8 */
          'A nike ad, closeup headshot photo of Alex Morgan (her back to the camera:1.2), smiling, (looking to the right:1.2), wearing red shirt, flash photo, (light flashing on face:1.2), (black background:1.2), studio, looking to the right, sharp, 32k, Nikon Z7, 35mm f/1.4, f/2.8, deep focus, studio photo, LEICA, DSRL, 32 k, depth of field, cinematic color grading, volumetric light, particles, dust, film grain, film noise, movie poster. hdr, dslr, master piece, perfect eyes, detailed lips, detailed hair, detailed skin, , a $gender , who is $age year old and has a $bodyType body type',
          /*Prompt 9 */
          'detailed eyes, detailed face, Editorial Photography | EMOTION: Celestial Canvas | SCENE: A mesmerizing top-down view capturing an expansive canvas of blue and red clouds in a celestial dance, creating a dreamy atmosphere during a cosmic dawn | TAGS: 32k, Nikon Z7, 35mm f/1.4, f/2.8, celestial canvas details, deep focus, dreamlike shading photography, surreal composition shot, cosmic color grading, cosmic lighting, ethereal atmosphere, 2023, modern style, soft textures, fantasy color palette, celestial construction materials, cosmic location, dreamlike objects, ISO 400 and insidecloseup photography handsome man wearing high neck, studio photo, LEICA, DSRL, 32 k, backstage photography in high definition formation, hyperrealistic, photorealistic, in the style of futuristic digital art, blurred, dreamlike atmosphere, minimalist backgrounds, national geographic photo, golden light, slender, faith-inspired art , a $gender , who is $age year old and has a $bodyType body type',
        ];
      });
    } else {
      // Reset promptInput if user data is incomplete
      setState(() {
        promptList = [];
      });
    }
  }
}
