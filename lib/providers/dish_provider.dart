import 'dart:io';
import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../services/database/dish_firestore.dart';
import '../services/firebase_storage.dart';

class DishProvider with ChangeNotifier {
  final DishFirestore _dishFirestore = DishFirestore();
  final FirebaseStorage _firebaseStorage = FirebaseStorage();

  // Local state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Dishes of the currently selected restaurant
  List<Dish> _dishes = [];

  List<Dish> get dishes => _dishes;

  // Current restaurant ID
  String? _currentRestaurantId;

  String? get currentRestaurantId => _currentRestaurantId;

  /// Clears all errors and optionally resets restaurant data
  void clearErrors({bool clearData = false}) {
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch all dishes from a restaurant
  Future<void> fetchDishes(String restaurantId) async {
    _isLoading = true;
    clearErrors();
    _currentRestaurantId = restaurantId;
    notifyListeners();

    try {
      _dishes = await _dishFirestore.getRestaurantDishes(restaurantId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Deletes a dish from the restaurant
  Future<void> deleteDish(String restaurantId, String dishId) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {

      final dish = _dishes.firstWhere(
            (dish) => dish.id == dishId,
        orElse: () => throw Exception('Dish not found in local state'),
      );

      // Delete teh image from firebase storage if it exists
      if (dish.imageUrl != null && dish.imageUrl!.isNotEmpty) {
        try {
          await _firebaseStorage.deleteDishImage(restaurantId, dishId);
        } catch (storageError) {
          debugPrint('Error while deleting the image: $storageError');
        }
      }

      await _dishFirestore.deleteDish(restaurantId, dishId);

      // Update local state
      _dishes.removeWhere((dish) => dish.id == dishId);

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  // Update dish availability
  Future<void> updateDishAvailability(String restaurantId, String dishId, bool isAvailable) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      await _dishFirestore.updateDishAvailability(restaurantId, dishId, isAvailable);

      // Update local state
      final index = _dishes.indexWhere((dish) => dish.id == dishId);
      if (index != -1) {
        _dishes[index] = _dishes[index].copyWith(isAvailable: isAvailable);
      }

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  // Create a new dish
  Future<void> createDish({
    required String restaurantId,
    required String name,
    required String description,
    required double price,
    required Course course,
    required bool isAvailable,
    required Cuisine cuisine,
    bool isSpecial = false,
    int? minForewarningDays,
    File? imageFile,
    String? imageUrl,
  }) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      // Create the Dish object with provided data
      Dish newDish = Dish(
        id: 'temp-id',
        name: name,
        description: description,
        price: price,
        isSpecial: isSpecial,
        isAvailable: isAvailable,
        course: course,
        cuisine: cuisine,
        minForewarningDays: minForewarningDays,
        imageUrl: imageUrl ?? '',
      );

      // Create a new dish in the database
      final String dishId = await _dishFirestore.createDish(
        restaurantId: restaurantId,
        dish: newDish,
      );

      newDish = newDish.copyWith(id: dishId);

      if (imageFile != null) {
        final newImageUrl = await _firebaseStorage.uploadDishImage(restaurantId, dishId, imageFile);
        // Update the dish with the new image URL
        await _dishFirestore.updateDish(
          restaurantId: restaurantId,
          dishId: dishId,
          imageUrl: newImageUrl,
        );

        newDish = newDish.copyWith(imageUrl: newImageUrl);
      }

      // Update local state
      _dishes.add(newDish);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  // Update an existing dish
  Future<void> updateDish({
    required String restaurantId,
    required String dishId,
    required String name,
    required String description,
    required double price,
    Course? course,
    Cuisine? cuisine,
    bool? isAvailable,
    int? minForewarningDays,
    File? imageFile,
    String? imageUrl,
  }) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      // Find the index of the dish in the local list
      final index = _dishes.indexWhere((dish) => dish.id == dishId);
      if (index == -1) {
        throw Exception('Dish not found in local state');
      }

      // If no new image URL is provided, use the existing one
      String? newImageUrl = imageUrl ?? _dishes[index].imageUrl;

      // Upload a new image if provided
      if (imageFile != null) {
        newImageUrl = await _firebaseStorage.uploadDishImage(restaurantId, dishId, imageFile);
      }

      // Update the document in the database
      await _dishFirestore.updateDish(
        restaurantId: restaurantId,
        dishId: dishId,
        name: name,
        description: description,
        price: price,
        course: course ?? _dishes[index].course,
        cuisine: cuisine ?? _dishes[index].cuisine,
        isAvailable: isAvailable ?? _dishes[index].isAvailable,
        minForewarningDays: minForewarningDays ?? _dishes[index].minForewarningDays,
        imageUrl: newImageUrl,
      );

      // Update local state
      _dishes[index] = _dishes[index].copyWith(
        name: name,
        description: description,
        price: price,
        course: course,
        cuisine: cuisine,
        isAvailable: isAvailable,
        minForewarningDays: minForewarningDays,
        imageUrl: newImageUrl,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Converts errors into user-friendly messages
  String _getErrorMessage(dynamic error) {
    String errorMessage = error.toString();

    if (errorMessage.contains('Dish not found')) {
      return 'Dish not found. Check the dish ID.';
    } else if (errorMessage.contains('permission-denied')) {
      return 'You do not have permission to access this dish.';
    } else if (errorMessage.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }

    return 'An error occurred: $errorMessage';
  }
}

