import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sous_chef/models/dish.dart';
import 'package:sous_chef/themes/theme_extensions.dart';
import 'package:sous_chef/widgets/restaurant_screen/price_tag.dart';

import '../../transition_type.dart';
import 'dish_availability_button.dart';
import '../../screens/dish_screen.dart';

class MenuItem extends StatelessWidget {
  final String dishId;
  final String dishName;
  final String description;
  final String? imageUrl;
  final bool isEditable;
  final VoidCallback? onDelete;
  final double price;
  final bool isAvailable;
  final Course course;
  final Cuisine cuisine;
  final Function(String, String, double, Course, Cuisine, {File? imageFile, String? imageUrl, bool? isAvailable})? onEdit;
  final Function(bool)? onAvailabilityChanged;
  final Function({required bool isEditable, String? dishId, String? heroTag, bool isNew, bool isSpecial, Function(bool)? onAvailabilityChanged})? onDishSelected;

  const MenuItem({
    super.key,
    required this.dishName,
    required this.description,
    this.imageUrl,
    this.isEditable = false,
    this.onDelete,
    required this.price,
    required this.course,
    required this.cuisine,
    this.isAvailable = false,
    this.onEdit,
    this.onAvailabilityChanged,
    required this.dishId,
    this.onDishSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final String heroTag = 'dish-${dishName.hashCode}';

    return GestureDetector(
      onTap: () => _showDishDetailDialog(context, heroTag, colorScheme),
      child: Card(
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
                  Hero(
                    tag: heroTag,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: colorScheme.surfaceContainerHighest,
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
                  ),
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: DishAvailabilityButton(
                        initialValue: isAvailable,
                        isEditable: isEditable,
                        onToggle: isEditable ? (value) {
                          onAvailabilityChanged?.call(value);
                        } : null,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

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

              PriceTag(price: price, fontSize: 14,),

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
      ),
    );
  }

  // Modification of _showDishDetailDialog method in MenuItem
  void _showDishDetailDialog(BuildContext context, String heroTag, ColorScheme colorScheme) {
    if (onDishSelected != null) {
      onDishSelected!(
        isEditable: isEditable,
        dishId: dishId,
        heroTag: heroTag,
        isNew: false,
        isSpecial: false, // This value could be determined elsewhere
        onAvailabilityChanged: onAvailabilityChanged,
      );
    } else {
      Navigator.of(context).push(
        CustomPageRoute(
          page: DishScreen(
            heroTag: heroTag,
            isEditable: isEditable,
            dishId: dishId,
            onAvailabilityChanged: onAvailabilityChanged,
          ),
          transitionType: TransitionType.slideRight,
        ),
      );
    }
  }
}
