import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sous_chef/models/dish.dart';

class Restaurant {
  final String id;
  final String name;
  final String address;
  final bool isOpen;
  final List<RestaurantType> restaurantTypes;
  final String ownerId;
  final GeoPoint location;
  final String? imageUrl;
  final List<Dish> dishes;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.isOpen,
    required this.restaurantTypes,
    required this.ownerId,
    required this.location,
    required this.imageUrl,
    this.dishes = const [],
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Convert restaurant_type from string to enum
    List<RestaurantType> restaurantTypes = [];
    final List<dynamic>? typesArray = data['restaurant_types'] as List<dynamic>?;

    if (typesArray != null && typesArray.isNotEmpty) {
      for (String type in typesArray.cast<String>()) {
        if (type == 'fixedMenu') {
          restaurantTypes.add(RestaurantType.fixedMenu);
        } else if (type == 'onRequest') {
          restaurantTypes.add(RestaurantType.onRequest);
        }
      }
    }

    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      isOpen: data['isOpen'] ?? false,
      restaurantTypes: restaurantTypes,
      ownerId: data['ownerId'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    // Convert restaurant_type from enum to string for Firestore
    List<String> restaurantTypesStrings = restaurantTypes.map((type) {
      return type == RestaurantType.fixedMenu ? 'fixedMenu' : 'onRequest';
    }).toList();

    return {
      'name': name,
      'address': address,
      'isOpen': isOpen,
      'restaurant_types': restaurantTypesStrings,
      'ownerId': ownerId,
      'location': location,
    };
  }

  // Creates a new Restaurant instance with updated dishes
  Restaurant copyWithDishes(List<Dish> dishes) {
    return Restaurant(
      id: this.id,
      name: this.name,
      address: this.address,
      isOpen: this.isOpen,
      restaurantTypes: this.restaurantTypes,
      ownerId: this.ownerId,
      location: this.location,
      imageUrl: this.imageUrl,
      dishes: dishes,
    );
  }

  /// Helping methods for restaurant types
  // Verify if the restaurant has a specific type
  bool hasRestaurantType(RestaurantType type) {
    return restaurantTypes.contains(type);
  }

  // Add or remove a restaurant type
  Restaurant toggleRestaurantType(RestaurantType type) {
    List<RestaurantType> newTypes = List.from(restaurantTypes);

    if (newTypes.contains(type)) {
      newTypes.remove(type);
    } else {
      // Add the type only if there are less than 2 types
      if (newTypes.length < 2) {
        newTypes.add(type);
      }
    }

    return Restaurant(
      id: this.id,
      name: this.name,
      address: this.address,
      isOpen: this.isOpen,
      restaurantTypes: newTypes,
      ownerId: this.ownerId,
      location: this.location,
      imageUrl: this.imageUrl,
      dishes: this.dishes,
    );
  }
}

enum RestaurantType { fixedMenu, onRequest }