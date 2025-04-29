import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../services/database/dish_firestore.dart';
import '../services/database/restaurant_firestore.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantFirestore _restaurantFirestore = RestaurantFirestore();
  final DishFirestore _dishFirestore = DishFirestore();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  Restaurant? _restaurant;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Restaurant? get restaurant => _restaurant;
  bool get hasError => _errorMessage != null;

  /// Retrieves restaurant information and dishes for a given restaurant ID
  /// Returns a complete Restaurant object with all dishes included
  Future<void> fetchCompleteRestaurantData(String restaurantId) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      // Get restaurant data
      final restaurantData = await _restaurantFirestore.getRestaurant(restaurantId);

      try {
        // Get dishes data for the restaurant
        final dishes = await _dishFirestore.getRestaurantDishes(restaurantId);

        // Combine restaurant with dishes using the copyWithDishes method
        _restaurant = restaurantData.copyWithDishes(dishes);
      } catch (dishError) {
        // Specific separate error handling for dish retrieval
        _errorMessage = "Impossible to retieve the dishes: ${_getErrorMessage(dishError)}";
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Retrieves only restaurant information without dishes
  Future<void> fetchRestaurantOnly(String restaurantId) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      _restaurant = await _restaurantFirestore.getRestaurant(restaurantId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Creates a new restaurant with the given name and owner ID
  Future<String?> createRestaurant({
    required String restaurantName,
    required String ownerId,
  }) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      final restaurantId = await _restaurantFirestore.createRestaurant(
        restaurantName: restaurantName,
        ownerId: ownerId,
      );

      _isLoading = false;
      notifyListeners();
      return restaurantId;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Clears all errors and optionally resets restaurant data
  void clearErrors({bool clearData = false}) {
    _errorMessage = null;
    if (clearData) {
      _restaurant = null;
    }
    notifyListeners();
  }

  /// Converts errors into user-friendly messages
  String _getErrorMessage(dynamic error) {
    String errorMessage = error.toString();

    if (errorMessage.contains('Restaurant not found')) {
      return 'Restaurant not found. Please check the restaurant ID.';
    } else if (errorMessage.contains('permission-denied')) {
      return 'You do not have permission to access this restaurant.';
    } else if (errorMessage.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }

    return 'An error occurred: $errorMessage';
  }
}