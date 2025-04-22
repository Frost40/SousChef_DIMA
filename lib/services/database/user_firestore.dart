import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';

import '../../models/user.dart';

class UserFirestore {
  // Get current user ID
  String? get _uid => firebase_auth.FirebaseAuth.instance.currentUser?.uid;

  // Get current authenticated user
  firebase_auth.User? get _authUser => firebase_auth.FirebaseAuth.instance.currentUser;

  // Firestore collection reference
  final CollectionReference _userTable =
      FirebaseFirestore.instance.collection('users');

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
    await _userTable.doc(_uid).update(updates);

    // Update relevant data in Firebase Auth
    if (_authUser != null) {
      if (username != null) await _authUser!.updateDisplayName(username);
    }
  }

  /// Function to update the user's email in both Firebase Auth and Firestore
  Future<void> updateUserEmail(String newEmail) async {
    if (_uid == null) {
      throw Exception('No authenticated user');
    }

    if (_authUser == null) {
      throw Exception('User not found');
    }

    // Aggiorna l'email in Firebase Auth
    await _authUser!.updateEmail(newEmail);

    // Updating the email in Firestore
    await _userTable.doc(_uid).update({'email': newEmail});
  }

  /// Function to update the user's password in Firebase Auth
  Future<void> updateUserPassword(String newPassword) async {
    if (_uid == null) {
      throw Exception('Nessun utente autenticato');
    }

    if (_authUser == null) {
      throw Exception('Utente non trovato');
    }

    // Update the password in Firebase Auth
    await _authUser!.updatePassword(newPassword);
  }


  /// Recover all user data from Firestore and return it as a User model
  Future<User?> getFullUserData() async {
    if (_uid == null) return null;

    try {
      final docSnapshot = await _userTable.doc(_uid).get(
          GetOptions(source: Source.server)
      );
      if (!docSnapshot.exists) return null;
      return User.fromFirestore(docSnapshot);
    } catch (e) {
      debugPrint('Error while retrieving user\'s data: $e');
      return null;
    }
  }

  //Function to check in the database if an other user with that username already exists
  Future<bool> isUsernameTaken(String username) async {
    final result =
    await _userTable
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }
}