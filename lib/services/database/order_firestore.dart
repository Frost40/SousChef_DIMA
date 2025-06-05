import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../../models/order.dart';

class OrderFirestore {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;

  // Reference to the orders collection
  firestore.CollectionReference get _ordersTable => _firestore.collection('orders');

  // Get an order by ID
  Future<Order?> getOrderById(String orderId) async {
    firestore.DocumentSnapshot doc = await _ordersTable.doc(orderId).get();
    if (doc.exists) {
      return Order.fromFirestore(doc);
    }
    return null;
  }

  // Get all orders for a user
  Future<List<Order>> getUserOrders(String userId) async {
    firestore.QuerySnapshot snapshot = await _ordersTable
        .where('user_id', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Order.fromFirestore(doc))
        .toList();
  }

  /// Create a new order in the database
  /// @param order - The order to create
  /// @returns Future<String> - The ID of the newly created order
  Future<String> createNewOrder({
    required Order order,
  }) async {

    final firestore.DocumentReference restaurantDoc = await _ordersTable.add(order.toFirestore());

    // Return the ID of the newly created restaurant
    return restaurantDoc.id;
  }

  /// Updates an existing dish in an order
  /// @param orderId - ID of the order to update
  /// @param dishId - ID of the dish to update
  /// @param newQuantity - New quantity of the dish
  /// @param dishPrice - Price of a single dish unit
  /// @returns Future<void>
  Future<void> updateOrder({
    required String orderId,
    required String dishId,
    required int newQuantity,
    required double dishPrice,
  }) async {
    // Get current order document
    final orderDoc = await _ordersTable.doc(orderId).get();

    if (!orderDoc.exists) {
      throw Exception('Order not found');
    }

    // Extract dishes array and find the specific dish
    List<dynamic> dishes = orderDoc['dishes'];
    Map<String, dynamic>? targetDish;
    int oldQuantity = 0;

    for (var dish in dishes) {
      if (dish['dish_id'] == dishId) {
        targetDish = Map<String, dynamic>.from(dish);
        oldQuantity = dish['quantity'];
        break;
      }
    }

    if (targetDish == null) {
      throw Exception('Dish not found in order');
    }

    // Update in a single transaction
    await _firestore.runTransaction((transaction) async {
      // Remove old dish entry
      transaction.update(
          _ordersTable.doc(orderId),
          {
            'dishes': firestore.FieldValue.arrayRemove([targetDish])
          }
      );

      // Add dish with quantity incremented by 1
      targetDish!['quantity'] = oldQuantity + 1;
      transaction.update(
          _ordersTable.doc(orderId),
          {
            'dishes': firestore.FieldValue.arrayUnion([targetDish]),
            // Increment total price by the dish price
            'total': firestore.FieldValue.increment(dishPrice)
          }
      );
    });
  }

  /// Adds a new dish to an existing order
  /// @param orderId - ID of the order to update
  /// @param orderItem - The new dish to add to the order
  /// @returns Future<void>
  Future<void> addDishToOrder({
    required String orderId,
    required OrderItem orderItem,
  }) async {

    // Add new dish to the order and update total in a single operation
    await _ordersTable.doc(orderId).update({
      'dishes': firestore.FieldValue.arrayUnion([
        {
          'dish_id': orderItem.dishId,
          'name': orderItem.name,
          'quantity': orderItem.quantity,
          'price': orderItem.price,
        }
      ]),
      'total': firestore.FieldValue.increment(orderItem.price)
    });
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _ordersTable.doc(orderId).update({'status': status});
  }
}