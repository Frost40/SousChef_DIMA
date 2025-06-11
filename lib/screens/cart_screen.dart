import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/providers/user_provider.dart';
import 'package:sous_chef/widgets/navigation_tabbar.dart';

import '../providers/auth_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    final bool isRestaurantOwner = userProvider.userData?.restaurantId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (isRestaurantOwner) ...[
            const SizedBox(height: 16),
            NavigationTabbar(
              tabCount: 2,
              tabLabels: const ['Orders Made', 'Orders Received'],
              height: 40.0,
              margin: const EdgeInsets.symmetric(horizontal: 48.0),
              radius: 25.0,
              initialIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
            const SizedBox(height: 24),
          ],
          Expanded(
            child: isRestaurantOwner && _selectedTabIndex == 1
                ? _buildOrdersReceived()
                : _buildOrdersMade(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersMade() {
    return Center(
      child: Text(
        'No active orders made!',
        style: TextStyle(
          fontSize: 24,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildOrdersReceived() {
    return Center(
      child: Text(
        'No orders received!',
        style: TextStyle(
          fontSize: 24,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}