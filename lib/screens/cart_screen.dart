import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/widgets/order_card.dart';
import '../providers/auth_provider.dart' as sous_chef_auth;
import '../providers/order_provider.dart';
import '../providers/stripe_provider.dart';
import '../widgets/animated_button.dart';
import '../widgets/circular_button.dart';
import '../widgets/custom_alert_dialog.dart';
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
    final authProvider = Provider.of<sous_chef_auth.AuthProvider>(
      context,
      listen: false,
    );
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    orderProvider.setContext(context);

    // Forced fetch user orders only if the user is authenticated
    if (authProvider.user != null) {
      orderProvider.fetchUserOrders(authProvider.user!.id, forceRefresh: true);
    }
  }

  Future<void> _handleCheckout(
    StripeProvider stripeProvider,
    ColorScheme colorScheme,
  ) async {
    final authProvider = Provider.of<sous_chef_auth.AuthProvider>(
      context,
      listen: false,
    );
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    try {
      // 1. Get the current user directly from FirebaseAuth
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        // This is the most reliable check for authentication.
        throw 'User is not logged in.';
      }

      // 2. Call getIdToken() on the firebaseUser object (notice the camelCase)
      await firebaseUser.getIdToken(true);
      print('✅ Firebase ID Token successfully refreshed.');
    } catch (e) {
      print('Auth token refresh failed: $e');
      if (mounted) {
        CustomAlertDialog.showInfoDialog(
          context: context,
          title: 'Authentication Expired',
          message:
              'Your session has expired. Please log in again to continue.',
          icon: Icon(
            Icons.login,
            color: colorScheme.primary,
          ),
        );
      }
      return;
    }

    final ordersToCheckout = orderProvider.userOrders
        .where((order) => order.status == 'ready_for_checkout')
        .toList();

    if (ordersToCheckout.isEmpty) {
      if (mounted) {
        CustomAlertDialog.showInfoDialog(
          context: context,
          title: 'No Orders',
          message: 'There are no orders to process',
          icon: Icon(
            Icons.info_outline,
            color: colorScheme.primary,
          ),
        );
      }
      return;
    }

    // Calculate checkout amount
    final totalAmount = ordersToCheckout.fold<double>(
      0,
      (sum, order) => sum + order.total,
    );

    // Prepare items to send to Stripe
    final List<Map<String, dynamic>> items = ordersToCheckout.map((order) {
      return {
        'id': order.id,
        'restaurantId': order.restaurantId,
        'restaurantName': order.restaurantName,
        'amount': order.total,
      };
    }).toList();

    // Show confirmation dialog before processing payment
    if (!mounted) return;
    final confirmCheckout =
        await CustomAlertDialog.showConfirmationDialog(
      context: context,
      title: 'Confirm Checkout',
      message: 'Proceed with payment of \€${totalAmount.toStringAsFixed(2)}?',
      confirmText: 'Proceed',
      icon: Icon(
        Icons.shopping_cart_checkout,
        color: colorScheme.primary,
      ),
    );

    if (!confirmCheckout) return;

    // Payment processing
    // The backend (payment.js) will update status to 'pending'
    // The webhook will update to 'paid' when payment is confirmed
    if (!mounted) return;
    final success = await stripeProvider.processPayment(
      context: context,
      amount: totalAmount,
      items: items,
    );

    if (success) {
      // Payment was successful
      // Backend has updated orders to 'pending'
      // Webhook will update them to 'paid' when confirmed

      // Fetch updated orders to reflect new status
      orderProvider.fetchUserOrders(
        authProvider.user!.id,
        forceRefresh: true,
      );

      if (mounted) {
        await CustomAlertDialog.showInfoDialog(
          context: context,
          title: 'Success',
          message: 'Payment completed successfully!',
          icon: Icon(
            Icons.check_circle_outline,
            color: colorScheme.primary,
          ),
        );
      }
    } else {
      // Payment failed or was cancelled
      // Orders remain in 'ready_for_checkout' (backend validation failed)
      // OR backend already updated to 'pending' but payment sheet was cancelled
      if (stripeProvider.errorMessage != null && mounted) {
        await CustomAlertDialog.showInfoDialog(
          context: context,
          title: 'Payment Failed',
          message: stripeProvider.errorMessage!,
          icon: Icon(
            Icons.error_outline,
            color: colorScheme.error,
          ),
        );
      }

      // Refresh orders to show correct status
      orderProvider.fetchUserOrders(
        authProvider.user!.id,
        forceRefresh: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child:
            orderProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : orderProvider.userOrders
                    .where((order) => order.status == 'ready_for_checkout')
                    .isEmpty
                ? Center(
                  child: Text(
                    'No orders in the cart!',
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
                          .where(
                            (order) => order.status == 'ready_for_checkout',
                          )
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
                                backgroundColor: colorScheme.errorContainer
                                    .withOpacity(0.3),
                                onPressed: () {
                                  // Confirm order deletion using CustomAlertDialog
                                  CustomAlertDialog.showConfirmationDialog(
                                    context: context,
                                    title: 'Remove Order',
                                    message:
                                        'Are you sure you want to remove this order?',
                                    confirmText: 'Remove',
                                    cancelText: 'Cancel',
                                    confirmColor: colorScheme.error,
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: colorScheme.error,
                                    ),
                                  ).then((confirmed) {
                                    if (confirmed) {
                                      // Deleting the order
                                      orderProvider.deleteOrder(order.id);
                                    }
                                  });
                                },
                              ),
                            );
                          }),
                      const SizedBox(height: 20),
                      Consumer<StripeProvider>(
                        builder: (context, stripeProvider, child) {
                          return AnimatedButton(
                            onTap: stripeProvider.isLoading
                                ? () {} // Do nothing when loading
                                : () {
                                    _handleCheckout(stripeProvider, colorScheme);
                                  },
                            child: PersonalizedButton(
                              text: "Checkout",
                              onPressed: null,
                              centralWidget:
                              stripeProvider.isLoading
                                  ? LoadingAnimationWidget.staggeredDotsWave(
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 30,
                              )
                                  : null,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
      ),
    );
  }
}
