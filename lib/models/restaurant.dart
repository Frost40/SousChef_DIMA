import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sous_chef/models/dish.dart';

class Restaurant {
  final String id;
  final String name;
  final String address;
  final bool isOpen;
  final RestaurantType restaurantType;
  final double rating;
  final int numRatings;
  final String ownerId;
  final GeoPoint location;
  final List<Dish> dishes;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.isOpen,
    required this.restaurantType,
    required this.rating,
    required this.numRatings,
    required this.ownerId,
    required this.location,
    this.dishes = const [],
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Convert restaurant_type from string to enum
    RestaurantType restaurantType;
    final String? typeString = data['restaurant_type'] as String?;
    switch(typeString) {
      case 'menuOnly':
        restaurantType = RestaurantType.menuOnly;
        break;
      case 'personalizedOnly':
        restaurantType = RestaurantType.personalizedOnly;
        break;
      case 'menuAndPersonalized':
        restaurantType = RestaurantType.menuAndPersonalized;
        break;
      default:
        restaurantType = RestaurantType.menuOnly; // default value
    }

    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      isOpen: data['isOpen'] ?? false,
      restaurantType: restaurantType,
      rating: (data['rating'] ?? 0.0).toDouble(),
      numRatings: data['numRatings'] ?? 0,
      ownerId: data['ownerId'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'isOpen': isOpen,
      'restaurant_type': restaurantType,
      'rating': rating,
      'numRatings': numRatings,
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
      restaurantType: this.restaurantType,
      rating: this.rating,
      numRatings: this.numRatings,
      ownerId: this.ownerId,
      location: this.location,
      dishes: dishes,
    );
  }
}

enum RestaurantType { menuOnly, personalizedOnly, menuAndPersonalized }