import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/widgets/order_card.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/animated_button.dart';
import '../widgets/circular_button.dart';
import '../widgets/personalized_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  void _loadOrders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    orderProvider.setContext(context);

    // Forced fetch user orders only if the user is authenticated
    if (authProvider.user != null) {
      orderProvider.fetchUserOrders(
          authProvider.user!.id,
          forceRefresh: true
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: orderProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : orderProvider.userOrders.isEmpty
                ? Center(
                    child: Text(
                      'No orders received!',
                      style: TextStyle(
                        fontSize: 24,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        ...orderProvider.userOrders
                            .where((order) => order.status == 'pending')
                            .map((order) {
                          return OrderCard(
                            restaurantName: order.restaurantName,
                            dishes: order.dishes,
                            dateTime: order.pickupDateTime,
                            price: order.total,
                            initiallyExpanded: true,
                            pageSpecificWidget: CircularButton(
                              icon: Icons.remove_circle_outline_rounded,
                              iconColor: colorScheme.error,
                              backgroundColor:
                                  colorScheme.errorContainer.withOpacity(0.3),
                              onPressed: () {
                                // Deleting the order
                                orderProvider.deleteOrder(order.id);
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        AnimatedButton(
                          onTap: () async {
                            // TODO: Implement checkout functionality
                          },
                          child: PersonalizedButton(
                              text: "Checkout", onPressed: null),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }
}