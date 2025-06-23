import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/order_card.dart';

class PastOrdersScreen extends StatefulWidget {
  const PastOrdersScreen({super.key});

  @override
  State<PastOrdersScreen> createState() => _PastOrdersScreenState();
}

class _PastOrdersScreenState extends State<PastOrdersScreen> {
  late Future<List<Order>> _ordersFuture;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompletedOrders();
    });
  }

  void _loadCompletedOrders() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _ordersFuture = orderProvider.fetchUserCompletedOrders(authProvider.user!.id);
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordini Completati'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // Consumer to react to changes in OrderProvider
              child: Consumer<OrderProvider>(
                builder: (context, orderProvider, child) {
                  // Manage error state from the provider
                  if (orderProvider.errorMessage != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      CustomAlertDialog.showInfoDialog(
                        context: context,
                        title: 'Error',
                        message: orderProvider.errorMessage!,
                        icon: const Icon(Icons.error, color: Colors.red),
                      );
                    });
                  }

                  // Manage loading state from the provider
                  if (orderProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // FutureBuilder to manage the future of completed orders
                  return FutureBuilder<List<Order>>(
                    future: _ordersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          CustomAlertDialog.showInfoDialog(
                            context: context,
                            title: 'Error',
                            message: orderProvider.errorMessage ?? 'Impossible to fetch completed orders',
                            icon: const Icon(Icons.error, color: Colors.red),
                          );
                        });
                        return const Center(child: Text('An error occurred while fetching orders'));
                      }

                      final orders = snapshot.data ?? [];

                      if (orders.isEmpty) {
                        return const Center(
                          child: Text('There are no completed orders yet',
                            style: TextStyle(fontSize: 16)),
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
                                restaurantAddress: order.restaurantAddress,
                                price: order.total,
                              );
                            }),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}