import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/restaurant.dart';

class RestaurantFirestore {

  // Restaurants collection reference
  final CollectionReference _restaurantsTable = FirebaseFirestore.instance
      .collection('restaurants');

  
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
  
}
