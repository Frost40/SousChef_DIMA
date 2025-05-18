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

  // Crea un nuovo piatto
  Future<void> createDish({
    required String restaurantId,
    required String name,
    required String description,
    required double price,
    required Course course,
    required bool isAvailable,
    required Cuisine cuisine,
    int? minForewarningDays,
    File? imageFile,
  }) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      String? imageUrl;

      // Crea l'oggetto Dish con i dati
      Dish newDish = Dish(
        id: 'temp-id',
        name: name,
        description: description,
        price: price,
        isSpecial: false,
        isAvailable: isAvailable,
        course: course,
        cuisine: cuisine,
        minForewarningDays: minForewarningDays,
        imageUrl: '',
      );

      // Crea un nuovo piatto sul database
      final String dishId = await _dishFirestore.createDish(
        restaurantId: restaurantId,
        name: name,
        description: description,
        price: price,
        isSpecial: false,
        isAvailable: isAvailable,
        course: course,
        cuisine: cuisine,
        minForewarningDays: minForewarningDays,
      );

      if (imageFile != null) {
        imageUrl = await _firebaseStorage.uploadDishImage(restaurantId, dishId, imageFile);
        // Aggiorna il piatto con l'URL dell'immagine
        await _dishFirestore.updateDish(
          restaurantId: restaurantId,
          dishId: dishId,
          imageUrl: imageUrl,
        );
      }

      newDish = newDish.copyWith(id: dishId, imageUrl: imageUrl);

      // Aggiorna lo stato locale
      _dishes.add(newDish);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  // Aggiorna un piatto esistente
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
  }) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      // Trova l'indice del piatto nell'array locale
      final index = _dishes.indexWhere((dish) => dish.id == dishId);
      if (index == -1) {
        throw Exception('Dish not found in local state');
      }

      String? imageUrl = _dishes[index].imageUrl;

      // Carica una nuova immagine se fornita
      if (imageFile != null) {
        imageUrl = await _firebaseStorage.uploadDishImage(restaurantId, dishId, imageFile);
      }

      // Aggiorna il documento nel database
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
        imageUrl: imageUrl,
      );

      // Aggiorna lo stato locale
      _dishes[index] = _dishes[index].copyWith(
        name: name,
        description: description,
        price: price,
        course: course,
        cuisine: cuisine,
        isAvailable: isAvailable,
        minForewarningDays: minForewarningDays,
        imageUrl: imageUrl,
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

