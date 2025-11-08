import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

/// Widget che mostra un'icona cuore per aggiungere/rimuovere dai preferiti
class FavoriteIconButton extends StatelessWidget {
  final String restaurantId;
  final String restaurantName;

  const FavoriteIconButton({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;
    final isFavorite = userData?.favourites.contains(restaurantId) ?? false;

    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color:
            isFavorite
                ? Colors.red
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
      onPressed: () {
        if (isFavorite) {
          // Rimuovi dai preferiti
          userProvider.toggleFavorite(context, restaurantId, restaurantName);
        } else {
          // Aggiungi ai preferiti
          userProvider.addToFavorites(context, restaurantId, restaurantName);
        }
      },
    );
  }
}
