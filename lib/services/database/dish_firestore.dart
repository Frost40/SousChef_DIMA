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

  /// Get all special dishes for a specific username across all restaurants
  Future<List<Map<String, dynamic>>> getSpecialDishesByUsername(String username) async {
    final List<Map<String, dynamic>> specialDishes = [];

    // Get all restaurants
    final QuerySnapshot restaurantsSnapshot = await _restaurantTable.get();

    // For each restaurant, query special dishes with the given username
    for (var restaurantDoc in restaurantsSnapshot.docs) {
      final QuerySnapshot dishesSnapshot = await _restaurantTable
          .doc(restaurantDoc.id)
          .collection('dishes')
          .where('is_special', isEqualTo: true)
          .where('user_username', isEqualTo: username)
          .get();

      for (var dishDoc in dishesSnapshot.docs) {
        specialDishes.add({
          'restaurantId': restaurantDoc.id,
          'dishId': dishDoc.id,
          'dish': Dish.fromFirestore(dishDoc),
        });
      }
    }

    return specialDishes;
  }

  /// Update username for all special dishes of a user (transactional)
  Future<void> updateUsernameForSpecialDishes({
    required String oldUsername,
    required String newUsername,
  }) async {
    // Use a batch write for atomicity
    final WriteBatch batch = _firestore.batch();

    // Get all special dishes with the old username
    final specialDishes = await getSpecialDishesByUsername(oldUsername);

    // Add all updates to the batch
    for (var dishData in specialDishes) {
      final String restaurantId = dishData['restaurantId'];
      final String dishId = dishData['dishId'];

      final DocumentReference dishRef = _restaurantTable
          .doc(restaurantId)
          .collection('dishes')
          .doc(dishId);

      batch.update(dishRef, {'user_username': newUsername});
    }

    // Commit all updates atomically
    await batch.commit();
  }
}