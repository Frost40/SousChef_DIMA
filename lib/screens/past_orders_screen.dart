import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/order_card.dart';
import '../services/orientation_manager.dart';

enum LayoutType { mobile, tabletVertical, tabletHorizontal }

class PastOrdersScreen extends StatefulWidget {
  final bool isEmbedded;

  const PastOrdersScreen({super.key, this.isEmbedded = false});

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
      _ordersFuture = orderProvider.fetchUserCompletedOrders(
        authProvider.user!.id,
      );
      _isInitialized = true;
    });
  }

  LayoutType _getLayoutType(BuildContext context) {
    final orientationManager = OrientationManager();
    final isTablet = orientationManager.isTablet(context);
    if (!isTablet) return LayoutType.mobile;

    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? LayoutType.tabletVertical
        : LayoutType.tabletHorizontal;
  }

  @override
  Widget build(BuildContext context) {
    final layoutType = _getLayoutType(context);

    return Scaffold(
      appBar:
          widget.isEmbedded
              ? null
              : AppBar(
                title: const Text('Orders completed'),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
      body:
          !_isInitialized
              ? const Center(child: CircularProgressIndicator())
              : layoutType == LayoutType.tabletHorizontal
              ? Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 600,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildOrdersContent(),
                  ),
                ),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildOrdersContent(),
              ),
    );
  }

  Widget _buildOrdersContent() {
    return Consumer<OrderProvider>(
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
                  message:
                      orderProvider.errorMessage ??
                      'Impossible to fetch completed orders',
                  icon: const Icon(Icons.error, color: Colors.red),
                );
              });
              return const Center(
                child: Text('An error occurred while fetching orders'),
              );
            }

            final orders = snapshot.data ?? [];

            if (orders.isEmpty) {
              return const Center(
                child: Text(
                  'There are no completed orders yet',
                  style: TextStyle(fontSize: 16),
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
    );
  }
}
