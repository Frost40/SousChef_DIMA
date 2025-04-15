import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:sous_chef/models/user.dart';

class FirestoreServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user ID
  String? get _uid => firebase_auth.FirebaseAuth.instance.currentUser?.uid;

  /// Updates user phone number in Firestore
  Future<void> updatePhone(String phone) async {
    if (_uid == null) {
      throw Exception('No authenticated user');
    }

    await _db.collection('users').doc(_uid).update({'phone': phone});
  }

  /// Updates user name in Firestore
  /// Replacement for updateFirstName method
  Future<void> updateName(String name) async {
    if (_uid == null) {
      throw Exception('No authenticated user');
    }

    await _db.collection('users').doc(_uid).update({'name': name});
  }

  /// Updates user surname in Firestore
  /// Replacement for updateLastName method
  Future<void> updateSurname(String surname) async {
    if (_uid == null) {
      throw Exception('No authenticated user');
    }

    await _db.collection('users').doc(_uid).update({'surname': surname});
  }

  /// Updates multiple user profile fields at once
  /// This is more efficient when updating several fields
  Future<void> updateUserProfile({
    String? username,
    String? name,
    String? surname,
    String? phone,
  }) async {
    if (_uid == null) {
      throw Exception('No authenticated user');
    }

    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (name != null) updates['name'] = name;
    if (surname != null) updates['surname'] = surname;
    if (phone != null) updates['phone'] = phone;

    if (updates.isEmpty) return;

    // Update data in Firestore
    await _db.collection('users').doc(_uid).update(updates);

    // Update relevant data in Firebase Auth
    final authUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      if (username != null) await authUser.updateDisplayName(username);
    }
  }

  /// Deletes user data from Firestore
  /// This should be called when deleting a user account
  Future<void> deleteUserData() async {
    if (_uid == null) {
      throw Exception('No authenticated user');
    }

    await _db.collection('users').doc(_uid).delete();
  }

  /// Gets complete user data from Firestore and returns it as a User model
  Future<User?> getUserData() async {
    if (_uid == null) return null;

    final doc = await _db.collection('users').doc(_uid).get();
    if (!doc.exists) return null;
    return User.fromFirestore(doc);
  }

  //Function to check in the database if an other user with that username already exists
  Future<bool> isUsernameTaken(String username) async {
    final result =
        await _db
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();
    return result.docs.isNotEmpty;
  }

  //Function to check in the database if an other user with that Restaurant name already exists
  Future<bool> isRestaurantNameTaken(String restaurantName) async {
    final result =
        await _db
            .collection('users')
            .where('restaurantName', isEqualTo: restaurantName)
            .limit(1)
            .get();
    return result.docs.isNotEmpty;
  }
}
