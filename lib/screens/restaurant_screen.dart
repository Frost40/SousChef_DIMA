import 'package:flutter/material.dart';
import 'package:sous_chef/widgets/restaurant_screen/restaurant_info.dart';

class RestaurantScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Title stays in the center
        title: const Text('Restaurant'),
        automaticallyImplyLeading: false,
        actions: const [
          // Space for future actions
        ],
      ),
      body: Column(
        children: [
          // Upper section
          RestaurantInfo(
            restaurantImageUrl: "",
            workingSlots: [
              "Monday - Friday: 12:00 - 15:00",
              "Monday - Friday: 19:00 - 23:00",
              "Saturday - Sunday: 12:00 - 23:00",
              "Closed on public holidays"
            ],
          ),

          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.surfaceContainerHighest,
          ),

          // lower section
          Expanded( // Occupies the remaining space
            child: Container(
              width: double.infinity,
              color: colorScheme.surface,
              child: Center(
                child: Text(
                  'Restaurant ID: ${widget.restaurantId}',
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}