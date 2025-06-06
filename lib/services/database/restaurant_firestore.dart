import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/restaurant.dart';

class RestaurantFirestore {

  // Restaurants collection reference
  final CollectionReference _restaurantsTable = FirebaseFirestore.instance
      .collection('restaurants');

  /// Function to add a restaurant to Firestore
  /// This function creates a new restaurant document in the Firestore
  /// collection when a new user that own a restaurant signs up
  /// Returns the ID of the newly created restaurant document
  Future<String> createRestaurant({
    required String restaurantName,
    required String ownerId,
  }) async {
    // Create a new restaurant document
    final DocumentReference restaurantDoc = await _restaurantsTable.add({
      'name': restaurantName,
      'owner_id': ownerId,
    });

    // Return the ID of the newly created restaurant
    return restaurantDoc.id;
  }

  /// Retrieves restaurant information from Firestore given the restaurant ID
  /// Returns a Restaurant object with all the restaurant data
  Future<Restaurant> getRestaurant(String restaurantId) async {
    final DocumentSnapshot restaurantDoc = await _restaurantsTable.doc(restaurantId).get();

    if (!restaurantDoc.exists) {
      throw Exception('Restaurant not found');
    }

    return Restaurant.fromFirestore(restaurantDoc);
  }

  /// Recover all user data from Firestore and return it as a User model
  Future<Restaurant?> getFavouriteInfo(String restaurantId) async {
    try {
      final docSnapshot = await _restaurantsTable
          .doc(restaurantId)
          .get(GetOptions(source: Source.server));
      if (!docSnapshot.exists) return null;
      return Restaurant.fromFirestore(docSnapshot);
    } catch (e) {
      debugPrint('Error while retrieving restaurant\'s data: $e');
      return null;
    }
  }

  // Method to update restaurant's open status
  Future<void> updateRestaurantOpenStatus(String restaurantId, bool isOpen) async {
    await _restaurantsTable.doc(restaurantId).update({
      'is_open': isOpen
    });
  }

  // Method to update restaurant's name
  Future<void> updateRestaurantName(String restaurantId, String name) async {
    await _restaurantsTable.doc(restaurantId).update({
      'name': name
    });
  }

  // Method to update restaurant's address
  Future<void> updateRestaurantAddress(String restaurantId, String address) async {
    await _restaurantsTable.doc(restaurantId).update({
      'address': address
    });
  }

  // Method to update restaurant's types
  Future<void> updateRestaurantType(String restaurantId, List<RestaurantType> restaurantTypes) async {
    // Convert restaurant types from enum to strings
    List<String> restaurantTypesStrings = restaurantTypes.map((type) {
      return type == RestaurantType.fixedMenu ? 'fixed_menu' : 'on_request';
    }).toList();

    await _restaurantsTable.doc(restaurantId).update({
      'restaurant_types': restaurantTypesStrings
    });
  }

  // Method to update restaurant's image URL
  Future<void> updateRestaurantImage(String restaurantId, String imageUrl) async {
    await _restaurantsTable.doc(restaurantId).update({
      'image_url': imageUrl
    });
  }
}