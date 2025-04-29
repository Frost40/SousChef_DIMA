import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/dish.dart';

class DishFirestore {
  // Firestore collection reference
  final CollectionReference _restaurantTable =
  FirebaseFirestore.instance.collection('restaurants');

  /// Retrieves all dishes for a specific restaurant
  Future<List<Dish>> getRestaurantDishes(String restaurantId) async {
    final QuerySnapshot dishesSnapshot = await _restaurantTable
        .doc(restaurantId)
        .collection('dishes')
        .get();

    if (dishesSnapshot.docs.isEmpty) {
      return []; // Return empty list if no dishes found
    }

    return dishesSnapshot.docs
        .map((doc) => Dish.fromFirestore(doc))
        .toList();
  }
}