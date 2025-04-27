import 'package:flutter/material.dart';

class RestaurantInfo extends StatelessWidget {
  final String restaurantImageUrl;
  final List<String> workingSlots;

  const RestaurantInfo({
    super.key,
    required this.restaurantImageUrl,
    required this.workingSlots,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Restaurant image with circular border
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
              ),
              child: restaurantImageUrl.isNotEmpty
                  ? Image.network(
                      restaurantImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.restaurant,
                        size: 50,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    )
                  : Icon(
                      Icons.restaurant,
                      size: 50,
                      color: colorScheme.primary,
                    ),
            ),
          ),

          const SizedBox(width: 16),

          // Right side - Restaurant name and working slots
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  'Working Slots',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),

                Divider(
                  thickness: 1,
                  color: colorScheme.surfaceContainerHighest,
                ),

                const SizedBox(height: 4),

                // Working slots list
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: workingSlots.isNotEmpty
                      ? workingSlots.map((slot) => Text(
                          slot,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )).toList()
                      : [
                          Text(
                            'No working slots available',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}