import 'package:flutter/material.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/themes/theme_extensions.dart';
import 'package:sous_chef/widgets/restaurant_screen/address_field.dart';
import 'package:sous_chef/widgets/restaurant_screen/open_close_button.dart';
import 'package:sous_chef/widgets/restaurant_screen/service_type.dart';

class RestaurantInfo extends StatelessWidget {
  final String restaurantImageUrl;
  final bool isOpen;
  final bool isFixedMenu;
  final bool isOnRequest;
  final String address;
  final bool isEditable;

  // Additional callbacks for handling changes
  final Function(bool)? onOpenStatusChanged;
  final Function(bool)? onFixedMenuToggled;
  final Function(bool)? onOnRequestToggled;
  final Function(String)? onAddressChanged;

  const RestaurantInfo({
    super.key,
    required this.restaurantImageUrl,
    required this.isOpen,
    required this.isFixedMenu,
    required this.isOnRequest,
    required this.address,
    required this.isEditable,

    this.onOpenStatusChanged,
    this.onFixedMenuToggled,
    this.onOnRequestToggled,
    this.onAddressChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
        decoration: BoxDecoration(
        color: colorScheme.darkGrayBackground,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 25.0, top: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
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
                initialValue: isOpen,
                isEditable: isEditable,
                onToggle: onOpenStatusChanged,
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


                Row(
                  children: [
                    Expanded(child: ServiceType(
                        initialValue: isFixedMenu,
                        serviceType: "Fixed Menu",
                        isEditable: isEditable,
                        onToggle: onFixedMenuToggled,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: ServiceType(
                        initialValue: isOnRequest,
                        serviceType: "On Request",
                        isEditable: isEditable,
                        onToggle: onOnRequestToggled,
                    )),
                  ],
                ),

                const SizedBox(height: 20),

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

                AddressField(
                  isEditable: isEditable,
                  address: address,
                  onAddressChanged: onAddressChanged,
                ),

              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}