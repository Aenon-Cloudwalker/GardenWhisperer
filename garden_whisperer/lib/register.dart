import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:profanity_filter/profanity_filter.dart';

// Function to upload the profile picture to Firebase Storage
Future<String> uploadProfilePicture(File imageFile) async {
  // Check file size

  int fileSize = await imageFile.length();
  const int maxSizeInBytes = 5 * 1024 * 1024; // 5MB
  if (fileSize > maxSizeInBytes) {
    throw Exception('File size exceeds the limit.');
  }
  String fileName = path.basename(imageFile.path);
  // Check file type
  List<String> allowedExtensions = ['.jpg', '.jpeg', '.png'];
  String fileExtension = path.extension(fileName).toLowerCase();
  if (!allowedExtensions.contains(fileExtension)) {
    throw Exception(
        'Invalid file type. Only JPG, JPEG, and PNG files are allowed.');
  }

  firebase_storage.Reference reference =
      firebase_storage.FirebaseStorage.instance.ref().child(fileName);
  firebase_storage.UploadTask uploadTask = reference.putFile(imageFile);
  firebase_storage.TaskSnapshot storageTaskSnapshot = await uploadTask;
  String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
  return downloadUrl;
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  XFile? _imageFile;
  late String imageUrl;
  String? _imageError;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _displayName = TextEditingController();
  late bool emailExists;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Reset emailExists value when email address changes

  // Reset emailExists value when email address changes

// Email validation method
  bool isValidEmail(String email) {
    // Regular expression pattern for email validation
    final pattern = r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$';
    final regExp = RegExp(pattern);

    return regExp.hasMatch(email);
  }

  void _registerUser() async {
    // Validate the form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show snackbar to indicate registration in progress
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registering user...'),
        duration: Duration(seconds: 2),
      ),
    );
    print('Email: ${_emailController.text.trim()}');
    print('Password: ${_passwordController.text.trim()}');
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.toString())
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Email already registered.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      // Register user with Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String imageUrl = await uploadProfilePicture(File(_imageFile!.path));
      // Get the registered user's ID
      String userId = userCredential.user!.uid;

      // Create user profile in Firestore

      await createUserProfile(_emailController.text.trim(),
          _displayName.text.trim(), imageUrl, userId);

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration successful!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Clear form fields and navigate to home screen
      _emailController.clear();
      _passwordController.clear();
      _displayName.clear();
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (e is FirebaseAuthException) {
        // Authentication error occurred, print the error message
        String errorMessage = 'Sign-up failed: ${e.message}';
        print(errorMessage);

        // Show error snackbar with the authentication error message
        if (e.toString() ==
            "[firebase_auth/email-already-in-use] The email address is already in use by another account.") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "The email address is already in use by another account."),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              duration: Duration(seconds: 2),
            ),
          );
        }

        print(e.toString());
      }
    }
  }

  @override
  void initState() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset(0, -0.45), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    // Listen to changes in the email text field

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 3.0),
            duration: Duration(seconds: 5),
            builder: (BuildContext context, double blur, Widget? child) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/backgroundtwoc.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Container(
                    color: Colors.black.withOpacity(0.32),
                  ),
                ),
              );
            },
          ),
          ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 100),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Image.asset('assets/logotwo.png'),
                        ),
                      ),
                      SizedBox(height: 16),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Text(
                            "Create an Account",
                            style: GoogleFonts.zcoolXiaoWei(
                              textStyle: TextStyle(
                                color: Color.fromARGB(255, 254, 255, 255),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        controller: _emailController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          }
                          // Email validation
                          bool emailValid =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value.trim());
                          if (!emailValid) {
                            return 'Please enter a valid email address';
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        obscureText: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Display Name',
                          labelStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        controller: _displayName,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your display name';
                          }
                          ProfanityFilter filter = ProfanityFilter();
                          List<String> wordsFound =
                              filter.getAllProfanity(value);

                          if (filter.hasProfanity(value)) {
                            return 'The name contains the words: $wordsFound';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Profile Picture',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery);

                          setState(() {
                            _imageFile = pickedFile;
                            _imageError = null; // Clear the error message
                          });

                          // Perform image validation
                          if (_imageFile != null) {
                            File image = File(_imageFile!.path);

                            // Check file size
                            int fileSize = await image.length();
                            const int maxSizeInBytes = 5 * 1024 * 1024; // 5MB
                            if (fileSize > maxSizeInBytes) {
                              setState(() {
                                _imageError = 'File size exceeds the limit.';
                              });
                              return;
                            }

                            // Check file type
                            List<String> allowedExtensions = [
                              '.jpg',
                              '.jpeg',
                              '.png'
                            ];
                            String fileExtension =
                                path.extension(image.path).toLowerCase();
                            if (!allowedExtensions.contains(fileExtension)) {
                              setState(() {
                                _imageError =
                                    'Invalid file type. Only JPG, JPEG, and PNG files are allowed.';
                              });
                              return;
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: _imageFile != null
                                ? CircleAvatar(
                                    radius: 37.0,
                                    backgroundImage:
                                        FileImage(File(_imageFile!.path)),
                                  )
                                : Icon(
                                    Icons.camera_alt,
                                    color: Colors.green,
                                    size: 74.0,
                                  ),
                          ),
                        ),
                      ),
                      _imageError != null
                          ? // Display the error message if exists
                          Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                _imageError!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.0,
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Photo upload not required",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 250, 249, 248),
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () async {
                          _registerUser();
                        },
                        child: Text('Register'),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // Handle login button press

                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text('Already have an account?'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
