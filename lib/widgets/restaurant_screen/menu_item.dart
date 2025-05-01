import 'package:flutter/material.dart';
import 'package:sous_chef/themes/theme_extensions.dart';

import 'dish_availability_button.dart';

class MenuItem extends StatelessWidget {
  final String dishName;
  final String description;
  final String? imageUrl;
  final bool isEditable;
  final VoidCallback? onDelete;
  final Widget? actionWidget;

  const MenuItem({
    super.key,
    required this.dishName,
    required this.description,
    this.imageUrl,
    this.isEditable = false,
    this.onDelete,
    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.darkGrayBackground,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colorScheme.surfaceVariant,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? ClipOval(
                    child: Image.network(
                      imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.restaurant_menu,
                        size: 30,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                      : Icon(
                    Icons.restaurant_menu,
                    size: 30,
                    color: colorScheme.primary,
                  ),
                ),
                // Bottone di disponibilità posizionato nella parte inferiore dell'immagine
                Positioned(
                  bottom: -5,
                  right: -5,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: DishAvailabilityButton(
                      initialValue: true,
                      isEditable: isEditable,
                      // onToggle: onAvailabilityToggle,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // Colonna con nome del piatto e descrizione
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dishName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Placeholder per widget personalizzato
            if (actionWidget != null) actionWidget!,

            // Icona di eliminazione (visibile solo se isEditable è true)
            if (isEditable)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: colorScheme.error,
                ),
                onPressed: onDelete,
                tooltip: 'Delete item',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
          ],
        ),
      ),
    );
  }
}