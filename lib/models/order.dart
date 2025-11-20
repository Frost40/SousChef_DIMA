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
      dishId: map['dish_id'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dish_id': dishId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final String id;
  final String userId;
  final String username;
  final String restaurantName;
  final String restaurantId;
  final DateTime pickupDateTime;
  final String verificationCode;
  final String status;
  final double total;
  final String restaurantAddress;
  final GeoPoint restaurantLocation;
  final List<OrderItem> dishes;

  Order({
    required this.id,
    required this.userId,
    required this.username,
    required this.restaurantName,
    required this.restaurantId,
    required this.pickupDateTime,
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
      orderItems =
          List<Map<String, dynamic>>.from(
            data['dishes'],
          ).map((item) => OrderItem.fromMap(item)).toList();
    }

    return Order(
      id: doc.id,
      userId: data['user_id'] ?? '',
      username: data['username'] ?? '',
      restaurantName: data['restaurant_name'] ?? '',
      restaurantId: data['restaurant_id'] ?? '',
      pickupDateTime: (data['pickup_date_time'] as Timestamp).toDate(),
      verificationCode: data['verification_code']?.toString() ?? '',
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
      'username': username,
      'restaurant_name': restaurantName,
      'restaurant_id': restaurantId,
      'pickup_date_time': Timestamp.fromDate(pickupDateTime),
      'verification_code': verificationCode,
      'status': status,
      'total': total,
      'restaurant_address': restaurantAddress,
      'restaurant_location': restaurantLocation,
      'dishes': dishes.map((item) => item.toMap()).toList(),
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    String? username,
    String? restaurantName,
    String? restaurantId,
    DateTime? pickupDateTime,
    String? verificationCode,
    String? status,
    double? total,
    String? restaurantAddress,
    GeoPoint? restaurantLocation,
    List<OrderItem>? dishes,
    Map<String, OrderItem>? updatedDishes,
  }) {
    // If updated dishes are provided, modify the existing dishes
    // Initialize updatedDishList only if updatedDishes is provided
    List<OrderItem> updatedDishList = this.dishes;

    if (updatedDishes != null && updatedDishes.isNotEmpty) {
      updatedDishList = List.from(this.dishes);
      for (int i = 0; i < updatedDishList.length; i++) {
        String dishId = updatedDishList[i].dishId;
        if (updatedDishes.containsKey(dishId)) {
          updatedDishList[i] = updatedDishes[dishId]!;
        }
      }
    }

    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantId: restaurantId ?? this.restaurantId,
      pickupDateTime: pickupDateTime ?? this.pickupDateTime,
      verificationCode: verificationCode ?? this.verificationCode,
      status: status ?? this.status,
      total: total ?? this.total,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      restaurantLocation: restaurantLocation ?? this.restaurantLocation,
      dishes: dishes ?? updatedDishList,
    );
  }
}
