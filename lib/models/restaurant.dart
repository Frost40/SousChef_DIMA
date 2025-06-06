import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String id;
  final String name;
  final String address;
  final bool isOpen;
  final List<RestaurantType> restaurantTypes;
  final String ownerId;
  final GeoPoint location;
  final String? imageUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.isOpen,
    required this.restaurantTypes,
    required this.ownerId,
    required this.location,
    required this.imageUrl,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Convert restaurant_type from string to enum
    List<RestaurantType> restaurantTypes = [];
    final List<dynamic>? typesArray = data['restaurant_types'] as List<dynamic>?;

    if (typesArray != null && typesArray.isNotEmpty) {
      for (String type in typesArray.cast<String>()) {
        if (type == 'fixed_menu') {
          restaurantTypes.add(RestaurantType.fixedMenu);
        } else if (type == 'on_request') {
          restaurantTypes.add(RestaurantType.onRequest);
        }
      }
    }

    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      isOpen: data['is_open'] ?? false,
      restaurantTypes: restaurantTypes,
      ownerId: data['owner_id'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      imageUrl: data['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    // Convert restaurant_type from enum to string for Firestore
    List<String> restaurantTypesStrings = restaurantTypes.map((type) {
      return type == RestaurantType.fixedMenu ? 'fixed_menu' : 'on_request';
    }).toList();

    return {
      'name': name,
      'address': address,
      'is_open': isOpen,
      'restaurant_types': restaurantTypesStrings,
      'owner_id': ownerId,
      'location': location,
    };
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
      id: id,
      name: name,
      address: address,
      isOpen: isOpen,
      restaurantTypes: newTypes,
      ownerId: ownerId,
      location: location,
      imageUrl: imageUrl,
    );
  }

  /// Creates a copy of this Restaurant with the given fields replaced with new values
  Restaurant copyWith({
    String? id,
    String? name,
    String? address,
    bool? isOpen,
    List<RestaurantType>? restaurantTypes,
    String? ownerId,
    GeoPoint? location,
    String? imageUrl,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      isOpen: isOpen ?? this.isOpen,
      restaurantTypes: restaurantTypes ?? this.restaurantTypes,
      ownerId: ownerId ?? this.ownerId,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

enum RestaurantType { fixedMenu, onRequest }