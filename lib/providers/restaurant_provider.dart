import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_storage.dart';
import '../models/restaurant.dart';
import '../services/database/restaurant_firestore.dart';
import 'order_provider.dart';

/// Provider that manages user data operations using the UserFirestore service.
/// Implements ChangeNotifier to notify dependent widgets when user data changes.
class RestaurantProvider with ChangeNotifier {
  final RestaurantFirestore _restaurantFirestore;
  final FirebaseStorage _firebaseStorage;

  /// Constructor with dependency injection for testability
  /// In production, defaults to real service instances
  RestaurantProvider({
    RestaurantFirestore? restaurantFirestore,
    FirebaseStorage? firebaseStorage,
  })  : _restaurantFirestore = restaurantFirestore ?? RestaurantFirestore(),
        _firebaseStorage = firebaseStorage ?? FirebaseStorage();

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
      _restaurant = await _restaurantFirestore.getRestaurant(restaurantId);

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

  Future<List<Restaurant>> fetchFavoriteRestaurantsByIds(
    List<String> restaurantIds,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (restaurantIds.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return [];
      }
      final List<Restaurant> restaurants = [];
      final futures = restaurantIds.map(
        (id) => _restaurantFirestore.getFavouriteInfo(id),
      );
      final results = await Future.wait(futures);
      for (final result in results) {
        if (result != null) {
          restaurants.add(result);
        }
      }
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return restaurants;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error while recovering favourite restaurants: $e';
      notifyListeners();
      return [];
    }
  }

  /// Fetches restaurants within a specified distance from a given location
  Future<List<Restaurant>> fetchNearbyRestaurants({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) async {
    try {
      final restaurants = await _restaurantFirestore.getRestaurantsNearLocation(
        latitude: latitude,
        longitude: longitude,
        radiusInKm: radiusInKm,
      );
      return restaurants;
    } catch (e) {
      debugPrint('Error fetching nearby restaurants: $e');
      return [];
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

  /// Updates the restaurant's open status
  Future<void> updateRestaurantOpenStatus(
    String restaurantId,
    bool isOpen,
  ) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      await _restaurantFirestore.updateRestaurantOpenStatus(
        restaurantId,
        isOpen,
      );

      // Update local restaurant model
      if (_restaurant != null && _restaurant!.id == restaurantId) {
        _restaurant = Restaurant(
          id: _restaurant!.id,
          name: _restaurant!.name,
          address: _restaurant!.address,
          isOpen: isOpen,
          restaurantTypes: _restaurant!.restaurantTypes,
          ownerId: _restaurant!.ownerId,
          location: _restaurant!.location,
          imageUrl: _restaurant!.imageUrl,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Updates the restaurant's name
  Future<void> updateRestaurantName(
    String restaurantId,
    String name, {
    required OrderProvider orderProvider,
  }) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      await _restaurantFirestore.updateRestaurantName(restaurantId, name);

      // Update local restaurant model
      if (_restaurant != null && _restaurant!.id == restaurantId) {
        _restaurant = Restaurant(
          id: _restaurant!.id,
          name: name,
          address: _restaurant!.address,
          isOpen: _restaurant!.isOpen,
          restaurantTypes: _restaurant!.restaurantTypes,
          ownerId: _restaurant!.ownerId,
          location: _restaurant!.location,
          imageUrl: _restaurant!.imageUrl,
        );
      }

      // Propagate the name modification to non completed orders via OrderProvider
      await orderProvider.updateRestaurantNameInOrders(restaurantId, name);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Updates the restaurant's address and coordinates
  Future<void> updateRestaurantAddress(
    String restaurantId,
    String address,
    double latitude,
    double longitude, {
    required OrderProvider orderProvider,
  }) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      await _restaurantFirestore.updateRestaurantAddress(
        restaurantId,
        address,
        latitude,
        longitude,
      );

      // Update address in orders with specific statuses
      await orderProvider.updateRestaurantAddressInOrders(
        restaurantId,
        address,
        GeoPoint(latitude, longitude),
      );

      // Update local restaurant model
      if (_restaurant != null && _restaurant!.id == restaurantId) {
        _restaurant = Restaurant(
          id: _restaurant!.id,
          name: _restaurant!.name,
          address: address,
          isOpen: _restaurant!.isOpen,
          restaurantTypes: _restaurant!.restaurantTypes,
          ownerId: _restaurant!.ownerId,
          location: GeoPoint(latitude, longitude),
          imageUrl: _restaurant!.imageUrl,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Updates the restaurant's type
  Future<void> updateRestaurantType(
    String restaurantId,
    RestaurantType type,
  ) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      // Check if restaurant is loaded and matches the ID
      if (_restaurant != null && _restaurant!.id == restaurantId) {
        // Get updated restaurant with toggled type
        Restaurant updatedRestaurant = _restaurant!.toggleRestaurantType(type);

        // Update in Firestore
        await _restaurantFirestore.updateRestaurantType(
          restaurantId,
          updatedRestaurant.restaurantTypes,
        );

        // Update local model
        _restaurant = updatedRestaurant;
      } else {
        // If restaurant isn't loaded, fetch it first
        final restaurant = await _restaurantFirestore.getRestaurant(
          restaurantId,
        );
        Restaurant updatedRestaurant = restaurant.toggleRestaurantType(type);

        await _restaurantFirestore.updateRestaurantType(
          restaurantId,
          updatedRestaurant.restaurantTypes,
        );

        _restaurant = updatedRestaurant;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Updates the restaurant's image
  Future<void> updateRestaurantImage(
    String restaurantId,
    File imageFile,
  ) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      // Update the image in Firebase Storage and retrieve the URL
      final String? imageUrl = await _firebaseStorage.uploadRestaurantImage(
        restaurantId,
        imageFile,
      );

      if (imageUrl != null) {
        // Update the image URL in Firestore
        await _restaurantFirestore.updateRestaurantImage(
          restaurantId,
          imageUrl,
        );

        // Updating local restaurant model
        if (_restaurant != null && _restaurant!.id == restaurantId) {
          _restaurant = _restaurant!.copyWith(imageUrl: imageUrl);
        }
      } else {
        _errorMessage = "Impossible to upload the image. Please try again.";
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Updates the restaurant's image URL directly in Firestore
  Future<void> updateRestaurantImageUrl(
    String restaurantId,
    String imageUrl,
  ) async {
    _isLoading = true;
    clearErrors();
    notifyListeners();

    try {
      await _restaurantFirestore.updateRestaurantImage(restaurantId, imageUrl);

      // Updating local restaurant model
      if (_restaurant != null && _restaurant!.id == restaurantId) {
        _restaurant = _restaurant!.copyWith(imageUrl: imageUrl);
      }

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
