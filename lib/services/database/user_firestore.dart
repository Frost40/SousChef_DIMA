import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';

import '../../models/user.dart';

class UserFirestore {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  late final CollectionReference _usersTable;

  /// Constructor with dependency injection for testability
  /// In production, defaults to real Firebase instances
  UserFirestore({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _usersTable = _firestore.collection('users');
  }

  // Get current user ID
  String? get _uid => _firebaseAuth.currentUser?.uid;

  // Get current authenticated user
  firebase_auth.User? get _authUser => _firebaseAuth.currentUser;

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
    await _usersTable.doc(_uid).update(updates);

    // Update relevant data in Firebase Auth
    if (_authUser != null) {
      if (username != null) await _authUser!.updateDisplayName(username);
    }
  }

  /// Updates the user's saved address
  Future<void> updateUserAddress({
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    if (_uid == null) {
      throw Exception('No authenticated user');
    }

    final updates = <String, dynamic>{
      'saved_address': address,
      'latitude': latitude,
      'longitude': longitude,
    };

    // Update data in Firestore
    await _usersTable.doc(_uid).update(updates);
  }

  /// Function to request update of the user's email in both Firebase Auth and Firestore
  /// This sends a verification email to the new address that the user must click before the change takes effect
  Future<void> updateUserEmail(String newEmail) async {
    if (_uid == null) {
      throw Exception('No authenticated user');
    }

    if (_authUser == null) {
      throw Exception('User not found');
    }

    // Store the current email to compare later
    final String oldEmail = _authUser!.email!;

    // Send verification email to the new email address
    await _authUser!.verifyBeforeUpdateEmail(newEmail);

    // Set up a listener to detect when the email has been changed
    // This should be called somewhere that persists beyond this function
    _setupEmailChangeListener(oldEmail, newEmail);

    debugPrint(
      'Verification email sent to $newEmail. Please check your inbox and verify to complete the update.',
    );
  }

  /// Sets up a listener to detect when email verification is complete
  /// and updates Firestore accordingly
  void _setupEmailChangeListener(String oldEmail, String newEmail) {
    _firebaseAuth.authStateChanges().listen((user) {
      if (user != null && user.email != oldEmail && user.email == newEmail) {
        // The email has been changed, update Firestore
        _usersTable
            .doc(user.uid)
            .update({'email': newEmail})
            .then((_) {
              debugPrint('Email updated in Firestore to $newEmail');
            })
            .catchError((error) {
              debugPrint('Failed to update email in Firestore: $error');
            });

        // Note: Firebase automatically handles the authentication state
        // The user remains logged in after email change

        // Optional: You might want to refresh the user's ID token
        // This ensures all Firebase services recognize the updated user info
        user.getIdToken(true); // Force token refresh
      }
    });
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
      final docSnapshot = await _usersTable
          .doc(_uid)
          .get(GetOptions(source: Source.server));
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
        await _usersTable.where('username', isEqualTo: username).limit(1).get();
    return result.docs.isNotEmpty;
  }

  /// Get all favorite restaurant IDs for the current user
  Future<List<String>> getFavoriteRestaurantIds() async {
    if (_uid == null) return [];

    try {
      final docSnapshot = await _usersTable
          .doc(_uid)
          .get(GetOptions(source: Source.server));
      if (!docSnapshot.exists) return [];

      // Check if the 'favourites' field exists
      final data = docSnapshot.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('favourites')) return [];

      List<String>.from(data['favourites']);

      // Cast the list to List<String>
      return List<String>.from(data['favourites']);
    } catch (e) {
      debugPrint('Error retrieving favorite restaurants: $e');
      return [];
    }
  }

  /// Deletes all user data from Firestore across all related collections
  Future<void> deleteUserData() async {
    if (_uid == null) {
      throw Exception('No authenticated user');
    }

    final String userId = _uid!;
    final FirebaseFirestore db = _firestore;
    final WriteBatch batch = db.batch();

    try {
      // 1. Check if user owns a restaurant
      final restaurantQuery =
          await db
              .collection('restaurants')
              .where('owner_id', isEqualTo: userId)
              .get();

      // 2. For each restaurant (should be at most 1 per user)
      for (var restaurantDoc in restaurantQuery.docs) {
        final String restaurantId = restaurantDoc.id;

        // 2.1 Delete all dishes in the restaurant
        final dishesQuery =
            await db
                .collection('restaurants')
                .doc(restaurantId)
                .collection('dishes')
                .get();

        for (var dishDoc in dishesQuery.docs) {
          batch.delete(dishDoc.reference);
        }

        // 2.2 Delete the restaurant
        batch.delete(restaurantDoc.reference);
      }

      // 3. Delete special dishes created by the user in other restaurants
      final specialDishesQuery =
          await db
              .collectionGroup('dishes')
              .where('user_id', isEqualTo: userId)
              .where('is_special', isEqualTo: true)
              .get();

      for (var dishDoc in specialDishesQuery.docs) {
        batch.delete(dishDoc.reference);
      }

      // 4. Delete user's orders
      final ordersQuery =
          await db
              .collection('orders')
              .where('user_id', isEqualTo: userId)
              .get();

      for (var orderDoc in ordersQuery.docs) {
        batch.delete(orderDoc.reference);
      }

      // 5. Delete messages sent or received by the user
      final sentMessagesQuery =
          await db
              .collection('messages')
              .where('sender_id', isEqualTo: userId)
              .get();

      for (var messageDoc in sentMessagesQuery.docs) {
        batch.delete(messageDoc.reference);
      }

      final receivedMessagesQuery =
          await db
              .collection('messages')
              .where('receiver_id', isEqualTo: userId)
              .get();

      for (var messageDoc in receivedMessagesQuery.docs) {
        batch.delete(messageDoc.reference);
      }

      // 6. Finally, delete the user document
      batch.delete(_usersTable.doc(userId));

      // Execute all delete operations in a single transaction
      await batch.commit();

      debugPrint('All user data successfully deleted from Firestore');
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      throw Exception('Error deleting data: $e');
    }
  }

  Future<void> removeFromFavorites(String userId, String restaurantId) async {
    try {
      await _usersTable.doc(userId).update({
        'favourites': FieldValue.arrayRemove([restaurantId]),
      });
    } catch (e) {
      debugPrint('Error while removing restaurant from favorites: $e');
      rethrow;
    }
  }

  Future<void> addToFavorites(String userId, String restaurantId) async {
    try {
      await _usersTable.doc(userId).update({
        'favourites': FieldValue.arrayUnion([restaurantId]),
      });
    } catch (e) {
      debugPrint('Error while adding restaurant to favorites: $e');
      rethrow;
    }
  }

  updateUserRestaurant(String id) {
    if (_uid == null) {
      throw Exception('No authenticated user');
    }

    // Update the restaurant ID in the user's document
    _usersTable.doc(_uid).update({'restaurant_id': id});
  }
}
