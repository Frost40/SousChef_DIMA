import 'package:flutter/material.dart';
import 'package:sous_chef/widgets/restaurant_screen/address_field.dart';
import 'package:sous_chef/widgets/restaurant_screen/open_close_button.dart';

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
      padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 25.0, top: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 80,
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

              const SizedBox(height: 10),

              OpenCloseButton(
                initialValue: true,
                isEditable: true,
                onToggle: (newValue) {

                  // restaurantProvider.updateOpenStatus(newValue);
                },
              ),
            ],
          ),


          const SizedBox(width: 25),

          // Right side - Restaurant name and working slots
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Offered Services:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),

                Divider(
                  thickness: 1,
                  color: colorScheme.surfaceContainerHighest,
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 2.0),
                  child: Text(
                    'Address:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),

                Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.onSurface,
                ),

                const SizedBox(height: 10),

                AddressField(isEditable: true),

              ],
            ),
          ),
        ],
      ),
    );
  }
}