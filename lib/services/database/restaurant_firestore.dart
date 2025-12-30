import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/restaurant.dart';

class RestaurantFirestore {
  final FirebaseFirestore _firestore;
  
  // Restaurants collection reference
  late final CollectionReference _restaurantsTable;

  /// Constructor with dependency injection for testability
  /// In production, defaults to real Firestore instance
  RestaurantFirestore({FirebaseFirestore? firestoreInstance})
      : _firestore = firestoreInstance ?? FirebaseFirestore.instance {
    _restaurantsTable = _firestore.collection('restaurants');
  }

  /// Function to add a restaurant to Firestore
  /// This function creates a new restaurant document in the Firestore
  /// collection when a new user that own a restaurant signs up
  /// Returns the ID of the newly created restaurant document
  Future<String> createRestaurant({
    required String restaurantName,
    required String ownerId,
  }) async {
    // Create a new restaurant document
    final DocumentReference restaurantDoc = await _restaurantsTable.add({
      'name': restaurantName,
      'owner_id': ownerId,
    });

    // Return the ID of the newly created restaurant
    return restaurantDoc.id;
  }

  /// Retrieves restaurant information from Firestore given the restaurant ID
  /// Returns a Restaurant object with all the restaurant data
  Future<Restaurant> getRestaurant(String restaurantId) async {
    final DocumentSnapshot restaurantDoc =
        await _restaurantsTable.doc(restaurantId).get();

    if (!restaurantDoc.exists) {
      throw Exception('Restaurant not found');
    }

    return Restaurant.fromFirestore(restaurantDoc);
  }

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

  // Method to update restaurant's open status
  Future<void> updateRestaurantOpenStatus(
    String restaurantId,
    bool isOpen,
  ) async {
    await _restaurantsTable.doc(restaurantId).update({'is_open': isOpen});
  }

  // Method to update restaurant's name
  Future<void> updateRestaurantName(String restaurantId, String name) async {
    await _restaurantsTable.doc(restaurantId).update({'name': name});
  }

  // Method to update restaurant's address and coordinates
  Future<void> updateRestaurantAddress(
    String restaurantId,
    String address,
    double latitude,
    double longitude,
  ) async {
    await _restaurantsTable.doc(restaurantId).update({
      'address': address,
      'location': GeoPoint(latitude, longitude),
    });
  }

  // Method to update restaurant's types
  Future<void> updateRestaurantType(
    String restaurantId,
    List<RestaurantType> restaurantTypes,
  ) async {
    // Convert restaurant types from enum to strings
    List<String> restaurantTypesStrings =
        restaurantTypes.map((type) {
          return type == RestaurantType.fixedMenu ? 'fixed_menu' : 'on_request';
        }).toList();

    await _restaurantsTable.doc(restaurantId).update({
      'restaurant_types': restaurantTypesStrings,
    });
  }

  // Method to update restaurant's image URL
  Future<void> updateRestaurantImage(
    String restaurantId,
    String imageUrl,
  ) async {
    await _restaurantsTable.doc(restaurantId).update({'image_url': imageUrl});
  }

  /// Retrieves all restaurants within a certain distance from a given location
  /// Uses a bounding box approximation for efficient querying
  /// Distance is in kilometers
  Future<List<Restaurant>> getRestaurantsNearLocation({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) async {
    // Approximate degrees per kilometer
    // At equator: 1 degree latitude ≈ 111 km
    // Longitude varies by latitude, but we use a safe approximation
    final double latDegreePerKm = 1 / 111.0;
    final double lonDegreePerKm = 1 / (111.0 * 0.8); // Conservative estimate

    // Calculate bounding box
    final double minLat = latitude - (radiusInKm * latDegreePerKm);
    final double maxLat = latitude + (radiusInKm * latDegreePerKm);
    final double minLon = longitude - (radiusInKm * lonDegreePerKm);
    final double maxLon = longitude + (radiusInKm * lonDegreePerKm);

    try {
      // Query restaurants with location field that exists and is within bounds
      final QuerySnapshot querySnapshot =
          await _restaurantsTable.where('location', isNotEqualTo: null).get();

      List<Restaurant> restaurants = [];

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final GeoPoint? location = data['location'] as GeoPoint?;

          if (location != null) {
            // Check if within bounding box
            if (location.latitude >= minLat &&
                location.latitude <= maxLat &&
                location.longitude >= minLon &&
                location.longitude <= maxLon) {
              // Calculate actual distance using Haversine formula
              final distance = _calculateDistance(
                latitude,
                longitude,
                location.latitude,
                location.longitude,
              );

              if (distance <= radiusInKm) {
                restaurants.add(Restaurant.fromFirestore(doc));
              }
            }
          }
        } catch (e) {
          debugPrint('Error processing restaurant document: $e');
        }
      }

      return restaurants;
    } catch (e) {
      debugPrint('Error fetching nearby restaurants: $e');
      return [];
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
