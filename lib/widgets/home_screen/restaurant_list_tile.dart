import 'package:flutter/material.dart';
import '../../models/restaurant.dart';
import 'favorite_icon_button.dart';

/// Widget che mostra un ristorante nella lista della home screen
class RestaurantListTile extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantListTile({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Naviga alla schermata del ristorante
          Navigator.of(context).pushNamed(
            '/restaurant',
            arguments: {'restaurantId': restaurant.id},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Immagine del profilo del ristorante
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    restaurant.imageUrl != null &&
                            restaurant.imageUrl!.isNotEmpty
                        ? Image.network(
                          restaurant.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                        : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 12),

              // Nome e stato del ristorante
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          restaurant.isOpen ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: restaurant.isOpen ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.isOpen ? 'Open' : 'Closed',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                restaurant.isOpen ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Icona cuore per i preferiti
              FavoriteIconButton(
                restaurantId: restaurant.id,
                restaurantName: restaurant.name,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Costruisce un'immagine placeholder quando non c'è l'immagine del ristorante
  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.restaurant, size: 30, color: Colors.grey[600]),
    );
  }
}
