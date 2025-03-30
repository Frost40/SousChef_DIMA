import 'package:flutter/material.dart';

class RestaurantScreen extends StatelessWidget {
  final String restaurantId;

  const RestaurantScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant $restaurantId'),
      ),
      body: Center(
        child: Text(
          'Details for Restaurant $restaurantId',
          style: TextStyle(
            fontSize: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}