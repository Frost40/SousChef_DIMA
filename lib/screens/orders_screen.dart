import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/order_screen/order.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order>? _userOrders;
  List<Order>? _restaurantReceivedOrders;
  bool _isInitialized = false;
  bool _isRestaurant = false;
  bool _showReceivedOrders = true;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    debugPrint('OrdersScreen: Loading orders...');

    // Wait for user to be loaded if it's null
    var user = authProvider.user;
    if (user == null) {
      debugPrint('OrdersScreen: User is null, waiting for it to load...');
      await authProvider.init();
      user = authProvider.user;
    }

    debugPrint(
      'OrdersScreen: User is ${user == null ? "NULL" : "loaded (${user.id})"}',
    );

    if (user == null) {
      debugPrint('OrdersScreen: User is still null after init, setting error');
      setState(() {
        _isLoading = false;
        _isInitialized = true;
        _errorMessage = 'User not found. Please try logging out and back in.';
      });
      return;
    }

    _isRestaurant = user.restaurantId != null && user.restaurantId!.isNotEmpty;
    debugPrint('OrdersScreen: Is restaurant: $_isRestaurant');

    try {
      if (_isRestaurant) {
        debugPrint('OrdersScreen: Fetching restaurant orders...');
        // For restaurants, load both received and placed orders
        final results = await Future.wait([
          orderProvider.fetchRestaurantReceivedOrders(user.restaurantId!),
          orderProvider.fetchUserPaidOrders(user.id),
        ]);

        debugPrint(
          'OrdersScreen: Received orders: ${results[0].length}, User orders: ${results[1].length}',
        );

        if (mounted) {
          setState(() {
            _restaurantReceivedOrders = results[0];
            _userOrders = results[1];
            _isInitialized = true;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('OrdersScreen: Fetching user orders...');
        // For normal users, load only their paid orders
        final orders = await orderProvider.fetchUserPaidOrders(user.id);
        debugPrint('OrdersScreen: Fetched ${orders.length} orders');

        if (mounted) {
          setState(() {
            _userOrders = orders;
            _isInitialized = true;
            _isLoading = false;
          });
        }
      }
      debugPrint('OrdersScreen: Orders loaded successfully');
    } catch (e) {
      debugPrint('OrdersScreen: Error loading orders: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isInitialized = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        automaticallyImplyLeading: false,
      ),
      body:
          !_isInitialized
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Slider for restaurants only
                    if (_isRestaurant) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showReceivedOrders = true;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        _showReceivedOrders
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Received Orders',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _showReceivedOrders
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.onPrimary
                                              : Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showReceivedOrders = false;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        !_showReceivedOrders
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'My Orders',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          !_showReceivedOrders
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.onPrimary
                                              : Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Orders list
                    Expanded(
                      child:
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _errorMessage != null
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error: $_errorMessage',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                              : _buildOrdersList(),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildOrdersList() {
    final orders =
        _isRestaurant && _showReceivedOrders
            ? _restaurantReceivedOrders ?? []
            : _userOrders ?? [];

    if (orders.isEmpty) {
      return Center(
        child: Text(
          _isRestaurant && _showReceivedOrders
              ? 'No incoming orders yet'
              : 'No orders yet',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          ...orders.map((order) {
            return OrderCard(
              restaurantName: order.restaurantName,
              dishes: order.dishes,
              dateTime: order.pickupDateTime,
              restaurantAddress:
                  (_isRestaurant && _showReceivedOrders)
                      ? null
                      : order.restaurantAddress,
              price: order.total,
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
