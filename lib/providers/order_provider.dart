import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/providers/restaurant_provider.dart';
import '../models/order.dart';
import '../services/database/order_firestore.dart';

class OrderProvider extends ChangeNotifier {
  final OrderFirestore _orderFirestore = OrderFirestore();
  RestaurantProvider? _restaurantProvider;

  void setContext(BuildContext context) {
    _restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
  }

  /// Local state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _ordersLoaded = false;
  bool get ordersLoaded => _ordersLoaded;

  // Dishes of the currently selected restaurant
  List<Order> _userOrders = [];
  List<Order> get userOrders => _userOrders;

  /// Clears all errors
  void clearErrors({bool clearData = false}) {
    _errorMessage = null;
    notifyListeners();
  }

  /// Retrieves all orders for the user
  /// The fetchUserOrders function supports caching and only calls the Firestore
  /// service if the orders are not already loaded or if a forced refresh is requested.
  Future<void> fetchUserOrders(String userId, {bool forceRefresh = false}) async {
    // If orders are already loaded and not forced to refresh, return early
    if (_ordersLoaded && !forceRefresh && _userOrders.isNotEmpty) {
      return;
    }
    try {
      _isLoading = true;
      clearErrors();
      notifyListeners();

      _userOrders = await _orderFirestore.getUserOrders(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  // Recovers an order from the local list by its ID
  Order? getOrderById(String orderId) {
    try {
      return _userOrders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  /// Depending on the (restaurantId, pickupDateTime) tuple:
  /// - adds a dish to an existing order
  /// - creates a new order
  Future<void> addOrder({
    required String userId,
    required String dishId,
    required String dishName,
    required double dishPrice,
    required DateTime pickupDateTime,
  }) async {
    try {
      _isLoading = true;
      clearErrors();
      notifyListeners();

      // Updates the local list of orders for the user
      await fetchUserOrders(userId);
      Restaurant? currentRestaurant = _restaurantProvider?.restaurant;

      if (currentRestaurant == null) {
        throw Exception('Restaurant not found');
      }

      Map<String, int> orderDishesCount = {};
       for (final order in _userOrders) {
          orderDishesCount[order.id] = order.dishes.length;
      }
      debugPrint('Dettagli ordini: ${_userOrders.length} ordini, conteggio piatti per ordine: $orderDishesCount');      int? orderIndex = await hasPendingOrderDateTime(
          currentRestaurant.id, pickupDateTime);

      if (orderIndex != null) {
        // If an order already exists for the restaurant and date, add the dish to that order
        Order existingOrder = _userOrders[orderIndex];

        // Check if the dish is already in the order
        OrderItem? existingDish;
        try {
          existingDish = existingOrder.dishes.firstWhere(
                (item) => item.dishId == dishId,
          );
        } catch (e) {
          existingDish = null;
        }

        if (existingDish != null) {
          // If the dish is already in the order, increase its quantity and update the total price
          await _orderFirestore.updateOrder(
            orderId: existingOrder.id,
            dishId: dishId,
            newQuantity: existingDish.quantity + 1,
            dishPrice: dishPrice,
          );

          // Update the local order with the new total and quantity
          _userOrders[orderIndex] = existingOrder.copyWith(
              total: existingOrder.total + dishPrice,
              updatedDishes: {
                dishId: OrderItem(
                    dishId: existingDish.dishId,
                    name: existingDish.name,
                    quantity: existingDish.quantity + 1,
                    price: existingDish.price
                )
              }
          );
        } else {
          // If the dish is not in the order, add it
          OrderItem newDish = OrderItem(
            dishId: dishId,
            name: dishName,
            quantity: 1, // Initial quantity
            price: dishPrice,
          );

          await _orderFirestore.addDishToOrder(
            orderId: existingOrder.id,
            orderItem: newDish
          );

          existingOrder.dishes.add(newDish);

          // Update the total price of the order
          existingOrder.copyWith(total: existingOrder.total + dishPrice);
        }
      } else {
        // If no pending order exists, create a new one
        Order newOrder = Order(
          id: '',
          // ID will be generated by Firestore
          userId: userId,
          restaurantName: currentRestaurant.name,
          restaurantId: currentRestaurant.id,
          dateTime: pickupDateTime,
          status: 'pending',
          total: dishPrice,
          // Initial total with one dish
          restaurantAddress: currentRestaurant.address,
          restaurantLocation: currentRestaurant.location,
          dishes: [
            OrderItem(
              dishId: dishId,
              name: dishName,
              quantity: 1, // Initial quantity
              price: dishPrice,
            ),
          ],
        );

        final newOrderId = await _orderFirestore.createNewOrder(order: newOrder);
        if (newOrderId.isEmpty) {
          throw Exception('Failed to create new order');
        }
        _userOrders.add(newOrder.copyWith(id: newOrderId));
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  // Updates the order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      _isLoading = true;
      clearErrors();
      notifyListeners();

      await _orderFirestore.updateOrderStatus(orderId, status);


      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  // Checks if a pending order exists for a restaurant at the specified pickup date
  Future<int?> hasPendingOrderDateTime(String restaurantId,
      DateTime pickupDateTime) async {
      // Checks if the order is already in the local list
      for (int i = 0; i < _userOrders.length; i++) {
        Order order = _userOrders[i];
        if (order.restaurantId == restaurantId &&
            order.status == 'pending' &&
            _isSameDateTime(order.dateTime, pickupDateTime)) {
          return i; // Returns the index of the order in the local list
        }
      }

      return null;
  }

  // Helper method to compare dates ignoring seconds and milliseconds
  bool _isSameDateTime(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day &&
        date1.hour == date2.hour &&
        date1.minute == date2.minute;
  }

  /// Converts technical errors into user-friendly messages
  String _getErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();

    if (errorString.contains('permission-denied') ||
        errorString.contains('permission')) {
      return 'You do not have permission to complete this operation.';
    } else if (errorString.contains('not-found') || errorString.contains('no such')) {
      return 'The requested order was not found.';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Connection error. Please check your internet connection.';
    } else if (errorString.contains('timeout')) {
      return 'Operation timed out. Please try again later.';
    } else if (errorString.contains('invalid') || errorString.contains('validation')) {
      return 'The order data is not valid.';
    } else if (errorString.contains('unauthenticated') ||
        errorString.contains('unauthorized')) {
      return 'Session expired. Please log in again.';
    } else if (errorString.contains('unavailable') ||
        errorString.contains('not-available')) {
      return 'The service is currently unavailable. Please try again later.';
    } else if (errorString.contains('already-exists')) {
      return 'This order already exists in the system.';
    } else if (errorString.contains('out-of-stock')) {
      return 'One or more products are not available.';
    } else if (errorString.contains('cancelled')) {
      return 'The operation was cancelled.';
    } else if (errorString.contains('date') || errorString.contains('time')) {
      return 'The selected date or time is not valid.';
    } else if (errorString.contains('payment') ||
        errorString.contains('transaction')) {
      return 'There was an error during payment.';
    }

    return 'An error occurred: $errorMessage';
  }
}