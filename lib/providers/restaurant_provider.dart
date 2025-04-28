import 'package:flutter/material.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/services/database/restaurant_firestore.dart';

/// Provider that manages user data operations using the UserFirestore service.
/// Implements ChangeNotifier to notify dependent widgets when user data changes.
class RestaurantProvider with ChangeNotifier {
  // UserFirestore service instance used to interact with Firestore
  final RestaurantFirestore _restaurantFirestore = RestaurantFirestore();

  // Restaurant data
  Restaurant? _restaurantData;

  // Flag indicating if a data operation is in progress
  bool _isLoading = false;

  // Error message from the last operation
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Restaurant? get restaurantData => _restaurantData;

  /// Clears all error states and messages
  void clearErrors() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<List<Restaurant>> fetchFavoriteRestaurantsByIds(List<String> restaurantIds) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (restaurantIds.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return [];
      }
      final List<Restaurant> restaurants = [];
      final futures = restaurantIds.map((id) => _restaurantFirestore.getFavouriteInfo(id));
      final results = await Future.wait(futures);
      for (final result in results) {
        if (result != null) {
          restaurants.add(result);
        }
      }
      _isLoading = false;
      _errorMessage = null; // Clear the error message on success
      notifyListeners();
      return restaurants;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Errore nel recupero dei ristoranti preferiti: $e';
      notifyListeners();
      return [];
    }
  }
}
