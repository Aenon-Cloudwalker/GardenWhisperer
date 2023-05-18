import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Create a user profile in Firestore
Future<void> createUserProfile(
    String email, String displayName, String photoUrl, userId) async {
  try {
    await _firestore.collection('users').doc(userId).set({
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    });
    print('User profile created for user with ID: $userId');
  } catch (e) {
    print('Error creating user profile: $e');
  }
}
