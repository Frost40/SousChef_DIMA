import 'package:cloud_firestore/cloud_firestore.dart';

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
        .update({'isAvailable': isAvailable});
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
    String? name,
    String? description,
    double? price,
    Course? course,
    Cuisine? cuisine,
    bool? isAvailable,
    int? minForewarningDays,
    String? imageUrl,
  }) async {
    // Create a map only with the fields to update
    final updates = <String, dynamic>{};

    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (price != null) updates['price'] = price;

    if (course != null) {
      updates['course'] = course.toString().split('.').last;
    }

    if (cuisine != null) {
      updates['cuisine'] = cuisine.toString().split('.').last;
    }

    if (isAvailable != null) {
      updates['is_available'] = isAvailable;
    }

    if (minForewarningDays != null) {
      updates['min_forewarning_days'] = minForewarningDays;
    }

    if (imageUrl != null) {
      updates['image'] = imageUrl;
    }

    // If there are no updates, return
    if (updates.isEmpty) return;

    // Execute the update only for the modified fields
    await _restaurantTable
        .doc(restaurantId)
        .collection('dishes')
        .doc(dishId)
        .update(updates);
  }
}