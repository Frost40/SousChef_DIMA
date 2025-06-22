import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/widgets/order_screen/order_card.dart';

import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../widgets/animated_button.dart';
import '../widgets/personalized_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> fakeOrders = [
    {
      'chefName': 'John Doe',
      'plates': [
        OrderItem(dishId: 'dish1', name: 'Pizza Margherita', quantity: 3, price: 12.50),
        OrderItem(dishId: 'dish2', name: 'Caesar Salad', quantity: 1, price: 8.00),
        OrderItem(dishId: 'dish4', name: 'Garlic Bread', quantity: 1, price: 5.00),
        OrderItem(dishId: 'dish3', name: 'Spaghetti Carbonara', quantity: 1, price: 15.00),
      ],
      'dateTime': DateTime(2023, 10, 5, 12, 30),
      'price': 30.50,
    },
    {
      'chefName': 'Jane Smith',
      'plates': [
        OrderItem(dishId: 'dish3', name: 'Spaghetti Carbonara', quantity: 2, price: 15.00),
        OrderItem(dishId: 'dish4', name: 'Garlic Bread', quantity: 1, price: 5.00),
        OrderItem(dishId: 'dish6', name: 'Steamed Vegetables', quantity: 1, price: 15.75),
      ],
      'dateTime': DateTime(2023, 10, 4, 18, 45),
      'price': 30.00,
    },
    {
      'chefName': 'Mike Johnson',
      'plates': [
        OrderItem(dishId: 'dish5', name: 'Grilled Salmon', quantity: 1, price: 25.00),
        OrderItem(dishId: 'dish6', name: 'Steamed Vegetables', quantity: 1, price: 15.75),
      ],
      'dateTime': DateTime(2023, 10, 3, 13, 15),
      'price': 40.75,
    },
    {
      'chefName': 'Emily Clark',
      'plates': [
        OrderItem(dishId: 'dish7', name: 'Beef Burger', quantity: 1, price: 12.99),
        OrderItem(dishId: 'dish8', name: 'French Fries', quantity: 1, price: 9.00),
      ],
      'dateTime': DateTime(2023, 10, 2, 14, 00),
      'price': 22.99,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<AuthProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: fakeOrders.isEmpty
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
                    ...fakeOrders.map((order) {
                      return OrderCard(
                        restaurantName: order['chefName'],
                        dishes: order['plates'],
                        dateTime: order['dateTime'],
                        price: order['price'],
                      );
                    }),

                    const SizedBox(height: 20),

                    AnimatedButton(
                      onTap: () async {
                        // await authProvider.signOut();
                        // Navigate to login screen after successful logout

                      },
                      child: PersonalizedButton(text: "Checkout", onPressed: null),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              )
      ),
    );
  }
}