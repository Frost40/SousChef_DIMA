import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/dish.dart';

class DishFirestore {
  final FirebaseFirestore _firestore;
  late final CollectionReference _restaurantTable;

  /// Constructor with dependency injection for testability
  /// In production, defaults to real Firestore instance
  DishFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _restaurantTable = _firestore.collection('restaurants');
  }

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

  /// Remove a dish from a specific restaurant
  Future<void> deleteDish(String restaurantId, String dishId) async {
      await _restaurantTable
          .doc(restaurantId)
          .collection('dishes')
          .doc(dishId)
          .delete();
  }

  /// Update the availability of a dish
  Future<void> updateDishAvailability(String restaurantId, String dishId, bool isAvailable) async {
    await _restaurantTable
        .doc(restaurantId)
        .collection('dishes')
        .doc(dishId)
        .update({'is_available': isAvailable});
  }

  /// Create a new dish for a restaurant
  Future<String> createDish({
    required String restaurantId,
    required Dish dish,
  }) async {
    final docRef = await _restaurantTable
        .doc(restaurantId)
        .collection('dishes')
        .add(dish.toFirestore());

    return docRef.id;
  }

  /// Update an existing dish
  Future<void> updateDish({
    required String restaurantId,
    required String dishId,
    required Map<String, dynamic> updates,
  }) async {
    if (updates.isEmpty) return;

    await _restaurantTable
        .doc(restaurantId)
        .collection('dishes')
        .doc(dishId)
        .update(updates);
  }
}