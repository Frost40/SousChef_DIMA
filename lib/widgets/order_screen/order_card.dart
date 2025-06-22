import 'package:flutter/material.dart';
import 'package:sous_chef/models/order.dart';
import 'package:sous_chef/themes/theme_extensions.dart';
import 'package:sous_chef/widgets/circular_button.dart';
import 'package:sous_chef/widgets/restaurant_screen/price_tag.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final String restaurantName;
  final List<OrderItem> dishes;
  final DateTime dateTime;
  final double price;

  const OrderCard({
    super.key,
    required this.restaurantName,
    required this.dishes,
    required this.dateTime,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.darkGrayBackground,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Pickup • ${DateFormat('MMM d, yyyy').format(dateTime.toLocal())} at ${DateFormat('HH:mm').format(dateTime.toLocal())}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),

                CircularButton(
                  icon: Icons.remove_circle_outline_rounded,
                  iconColor: colorScheme.error,
                  backgroundColor: colorScheme.errorContainer.withOpacity(0.3),
                  onPressed: () {

                  },
                )
              ],
            ),


            const SizedBox(height: 8),

            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.onSurface,
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 85, // altezza fissa uguale in entrambi i casi
              child: dishes.length <= 3
                ? Column(
                    children: dishes.map((dish) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text(
                              '${dish.quantity}x',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dish.name,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '€${dish.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: dishes.length,
                    itemBuilder: (context, index) {
                      final dish = dishes[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text(
                              '${dish.quantity}x',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dish.name,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '€${dish.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),

            const SizedBox(height: 8),
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.onSurface,
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Totale:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                PriceTag(price: price),
              ],
            ),
          ],
        )
      ),
    );
  }
}