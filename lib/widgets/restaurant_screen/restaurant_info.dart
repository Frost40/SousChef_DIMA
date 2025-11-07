import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sous_chef/themes/theme_extensions.dart';
import 'package:sous_chef/widgets/restaurant_screen/address_field.dart';
import 'package:sous_chef/widgets/restaurant_screen/open_close_button.dart';
import 'package:sous_chef/widgets/restaurant_screen/service_type.dart';

import '../image_upload_button.dart';

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
  final Function(String, double, double)? onAddressChanged;
  final Function(File)? onImageUploadPressed;
  final Function(String?)? onImageUrlChanged;

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
    this.onImageUploadPressed,
    this.onImageUrlChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Local notifier to temporarily manage image state
    final tempImageFile = ValueNotifier<File?>(null);
    final tempImageUrl = ValueNotifier<String?>(null);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.darkGrayBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 25.0,
          right: 25.0,
          bottom: 25.0,
          top: 15.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ValueListenableBuilder<File?>(
                        valueListenable: tempImageFile,
                        builder: (context, fileValue, _) {
                          return ValueListenableBuilder<String?>(
                            valueListenable: tempImageUrl,
                            builder: (context, urlValue, _) {
                              // Priority: temp file > temp URL > original URL
                              if (fileValue != null) {
                                return Image.file(
                                  fileValue,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                );
                              } else if (urlValue != null &&
                                  urlValue.isNotEmpty) {
                                return Image.network(
                                  urlValue,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                        color: colorScheme.primary,
                                      ),
                                    );
                                  },
                                  errorBuilder:
                                      (context, error, stackTrace) => Icon(
                                        Icons.restaurant,
                                        size: 50,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                );
                              } else if (restaurantImageUrl.isNotEmpty) {
                                return Image.network(
                                  restaurantImageUrl,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                        color: colorScheme.primary,
                                      ),
                                    );
                                  },
                                  errorBuilder:
                                      (context, error, stackTrace) => Icon(
                                        Icons.restaurant,
                                        size: 50,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                );
                              } else {
                                return Icon(
                                  Icons.restaurant,
                                  size: 50,
                                  color: colorScheme.primary,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),

                    // Removed onImageUploadPressed != null check to always show the button when isEditable
                    if (isEditable)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: ImageUploadButton(
                          size: 40,
                          onImageSelected: (File? file) {
                            if (file != null) {
                              // Immediately update the UI with the uploaded image
                              tempImageFile.value = file;

                              // Start background synchronization with Firebase
                              if (onImageUploadPressed != null) {
                                onImageUploadPressed!(file);
                              }
                            }
                          },
                          onUrlSelected: (String url) {
                            if (url.isNotEmpty) {
                              // Immediately update the UI with the new URL
                              tempImageUrl.value = url;

                              // Here you could add logic to handle the URL
                            }
                          },
                          currentImageUrl:
                              tempImageUrl.value ?? restaurantImageUrl,
                        ),
                      ),
                  ],
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
                      Expanded(
                        child: ServiceType(
                          initialValue: isFixedMenu,
                          serviceType: "Fixed Menu",
                          isEditable: isEditable,
                          onToggle: onFixedMenuToggled,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ServiceType(
                          initialValue: isOnRequest,
                          serviceType: "On Request",
                          isEditable: isEditable,
                          onToggle: onOnRequestToggled,
                        ),
                      ),
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
                    onAddressWithCoordinatesChanged: onAddressChanged,
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
