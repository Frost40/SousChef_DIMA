import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String dishId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.dishId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      dishId: map['dishId'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dishId': dishId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final String id;
  final String userId;
  final String restaurantName;
  final DateTime dateTime;
  final int verificationCode;
  final String status;
  final double total;
  final String restaurantAddress;
  final GeoPoint restaurantLocation;
  final List<OrderItem> dishes;

  Order({
    required this.id,
    required this.userId,
    required this.restaurantName,
    required this.dateTime,
    required this.verificationCode,
    required this.status,
    required this.total,
    required this.restaurantAddress,
    required this.restaurantLocation,
    required this.dishes,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<OrderItem> orderItems = [];
    if (data['dishes'] != null) {
      orderItems = List<Map<String, dynamic>>.from(data['dishes'])
          .map((item) => OrderItem.fromMap(item))
          .toList();
    }

    return Order(
      id: doc.id,
      userId: data['user_id'] ?? '',
      restaurantName: data['restaurant_name'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      verificationCode: data['verification_code'] ?? 0,
      status: data['status'] ?? '',
      total: (data['total'] ?? 0.0).toDouble(),
      restaurantAddress: data['restaurant_address'] ?? '',
      restaurantLocation: data['restaurant_location'] ?? const GeoPoint(0, 0),
      dishes: orderItems,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'restaurant_name': restaurantName,
      'dateTime': Timestamp.fromDate(dateTime),
      'verification_code': verificationCode,
      'status': status,
      'total': total,
      'restaurant_address': restaurantAddress,
      'restaurant_location': restaurantLocation,
      'dishes': dishes.map((item) => item.toMap()).toList(),
    };
  }
}