import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RestaurantFirestore {
  // Firestore collection reference
  final CollectionReference _restaurantTable =
      FirebaseFirestore.instance.collection('restaurants');

  /// Function to add a restaurant to Firestore
  /// This function creates a new restaurant document in the Firestore
  /// collection when a new user that own a restaurant signs up
  /// Returns the ID of the newly created restaurant document
  Future<String> createRestaurant({
    required String restaurantName,
    required String ownerId,
  }) async {
    // Create a new restaurant document
    final DocumentReference restaurantDoc = await _restaurantTable.add({
      'restaurantName': restaurantName,
      'ownerId': ownerId,
    });

    // Return the ID of the newly created restaurant
    return restaurantDoc.id;
  }
}