import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String id;
  final String name;
  final String address;
  final bool isAvailable;
  final RestaurantType restaurantType;
  final double rating;
  final int numRatings;
  final String ownerId;
  final GeoPoint location;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.isAvailable,
    required this.restaurantType,
    required this.rating,
    required this.numRatings,
    required this.ownerId,
    required this.location,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      isAvailable: data['isAvailable'] ?? false,
      restaurantType: data['restaurant_type'] ?? '',
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
      'isAvailable': isAvailable,
      'restaurant_type': restaurantType,
      'rating': rating,
      'numRatings': numRatings,
      'ownerId': ownerId,
      'location': location,
    };
  }
}

enum RestaurantType { menuOnly, personalizedOnly, menuAndPersonalized }
