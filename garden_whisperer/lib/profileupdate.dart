import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profanity_filter/profanity_filter.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool newImageSelected = false;
  late String imageUrl = "";
  late NetworkImage _image;
  late File selectedImage;
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _currentPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  //loads user profile from firestore
  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic> data = snapshot.data()!;

      setState(() {
        _displayNameController.text = data['displayName'];
        _emailController.text = data['email'];
        imageUrl = data['photoUrl'];
      });
    }
  }

  //reauthenticates user so that he can change sensitive data.
  Future<void> reauthenticateUser(String password) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        await user.reauthenticateWithCredential(credential);
        print('User reauthenticated successfully.');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reauthenticate user.'),
            duration: Duration(seconds: 2),
          ),
        );
        print('Failed to reauthenticate user: $e');
      }
    }
  }

  //updates user data
  //updates user data
  Future<void> updateUserData() async {
    User? user = _auth.currentUser;
    String? userUid;
    if (user != null) {
      userUid = user.uid.toString();
    }
    // Validate the form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (user != null) {
      try {
        //updates image data
        String filePath = 'profileImages/$userUid.jpg';
        Reference ref = FirebaseStorage.instance.ref().child(filePath);

        // Upload the new image file
        if (newImageSelected) {
          await ref.putFile(selectedImage);
          // Get the download URL of the newly uploaded image
          String newImageUrl = await ref.getDownloadURL();

          // Update the user's image URL in Firestore
          DocumentReference userRef =
              FirebaseFirestore.instance.collection('users').doc(userUid);
          Map<String, dynamic> dataToUpdate = {
            'photoUrl': newImageUrl,
          };
          await userRef.update(dataToUpdate);

          setState(() {
            imageUrl = newImageUrl;
          });
        }

        //updates authenticator
        print(_displayNameController.text);
        await user.updateDisplayName(_displayNameController.text);
        await user.updateEmail(_emailController.text);

        if (_currentPasswordController.text.isNotEmpty) {
          await reauthenticateUser(_currentPasswordController.text);
          await user.updatePassword(_newPasswordController.text);
        }

        //updates firestore
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(userUid);
        Map<String, dynamic> dataToUpdate = {
          'displayName': _displayNameController.text,
          'email': _emailController.text,
        };
        await userRef.update(dataToUpdate);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User data updated successfully.'),
            duration: Duration(seconds: 2),
          ),
        );
        print('User data updated successfully.');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: Duration(seconds: 2),
          ),
        );
        print('Failed to update user data: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
        newImageSelected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        title: Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 75,
                  backgroundImage: (newImageSelected == true)
                      ? FileImage(File(selectedImage.path))
                      : (imageUrl.isNotEmpty)
                          ? NetworkImage(imageUrl)
                          : AssetImage('assets/logonotextthree.jpg')
                              as ImageProvider<Object>?,
                ),
                SizedBox(height: 16),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your display name';
                    }
                    ProfanityFilter filter = ProfanityFilter();
                    List<String> wordsFound = filter.getAllProfanity(value);

                    if (filter.hasProfanity(value)) {
                      return 'The name contains the words: $wordsFound';
                    }
                    return null;
                  },
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
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
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    updateUserData();
                  },
                  child: Text('Update Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
