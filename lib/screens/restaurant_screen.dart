import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/themes/theme_extensions.dart';
import 'package:sous_chef/widgets/navigation_tabbar.dart';
import 'package:sous_chef/screens/dish_screen.dart';
import 'package:sous_chef/widgets/dish_popup_dialog.dart';
import '../models/dish.dart';
import '../providers/dish_provider.dart';
import '../providers/order_provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/auth_provider.dart';
import '../transition_type.dart';
import '../widgets/animated_button.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/circular_button.dart';
import '../widgets/restaurant_screen/menu_item.dart';
import '../widgets/restaurant_screen/restaurant_info.dart';
import '../widgets/responsive_layout.dart';
import '../services/orientation_manager.dart';
import '../widgets/favorite_icon_button.dart';
import '../providers/chat_provider.dart';
import '../screens/chat_screen.dart';

// Enum per identificare i tipi di layout possibili
enum LayoutType { mobile, tabletVertical, tabletHorizontal }

class RestaurantScreen extends StatefulWidget {
  final String restaurantId;
  final bool showBackButton;

  const RestaurantScreen({
    super.key,
    required this.restaurantId,
    this.showBackButton = false,
  });

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  int _selectedTabIndex = 0;

  // Metodo per determinare il tipo di layout basato sulle dimensioni dello schermo
  LayoutType _getLayoutType(BuildContext context) {
    final orientationManager = OrientationManager();
    final bool isTablet = orientationManager.isTablet(context);
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (!isTablet) {
      return LayoutType.mobile;
    } else if (isLandscape) {
      return LayoutType.tabletHorizontal;
    } else {
      return LayoutType.tabletVertical;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the widget is still mounted before accessing context
      if (mounted) {
        Provider.of<RestaurantProvider>(
          context,
          listen: false,
        ).fetchCompleteRestaurantData(widget.restaurantId);
      }

      // Separately fetch restaurant menu
      Provider.of<DishProvider>(
        context,
        listen: false,
      ).fetchDishes(widget.restaurantId);
    });
  }

  // Metodo helper per aprire il DishScreen in modo diverso a seconda del dispositivo
  void _openDishScreen({
    required bool isEditable,
    String? dishId,
    String? heroTag,
    bool isNew = false,
    bool isSpecial = false,
    Function(bool)? onAvailabilityChanged,
  }) {
    ResponsiveLayout(
      builder: (context, isTablet) {
        if (isTablet) {
          // Mostra il DishScreen come popup per tablet
          showDialog(
            context: context,
            barrierColor: Colors.black54, // Sfondo semi-trasparente
            builder:
                (context) => DishPopupDialog(
                  heroTag: heroTag,
                  dishId: dishId,
                  isEditable: isEditable,
                  isNew: isNew,
                  isSpecial: isSpecial,
                  onAvailabilityChanged: onAvailabilityChanged,
                ),
          );
        } else {
          // Mostra il DishScreen come pagina separata per smartphone
          Navigator.of(context).push(
            CustomPageRoute(
              page: DishScreen(
                heroTag: heroTag,
                dishId: dishId,
                isEditable: isEditable,
                isNew: isNew,
                isSpecial: isSpecial,
                onAvailabilityChanged: onAvailabilityChanged,
              ),
              transitionType: TransitionType.slideRight,
            ),
          );
        }
        return const SizedBox(); // Placeholder, non verrà mai renderizzato
      },
    ).builder(context, MediaQuery.of(context).size.shortestSide >= 600);
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  Future<void> _openChat(
    BuildContext context,
    String restaurantOwnerId,
    String restaurantName,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Wait for AuthProvider to initialize if user is null
    if (authProvider.user == null) {
      await authProvider.init();
    }

    // Check if user is authenticated
    if (authProvider.user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to be logged in to chat'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Check if user is trying to chat with themselves
    if (authProvider.user!.id == restaurantOwnerId) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You cannot chat with yourself'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Ensure ChatProvider has the current user ID
    chatProvider.setCurrentUserId(authProvider.user!.id);

    String? chatId;
    bool isNewChat = false;

    // Check if chat already exists first (no loading needed for this)
    chatId = chatProvider.findExistingChat(restaurantOwnerId);

    if (chatId == null) {
      // Only show loading if we need to create a new chat
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Create temporary chat
        chatId = await chatProvider.createChat(restaurantOwnerId);
        isNewChat = true;
      } catch (e) {
        // Close loading indicator
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (chatId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open chat. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Small delay to ensure any dialog is closed
    await Future.delayed(const Duration(milliseconds: 50));

    if (!context.mounted) return;

    final String finalChatId = chatId;

    // Navigate to chat screen
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              chatId: finalChatId,
              otherUserName: restaurantName,
              otherUserId: restaurantOwnerId,
            ),
      ),
    );

    // After returning from chat, check if we need to delete the chat
    if (isNewChat && context.mounted) {
      final hasMessages = await chatProvider.chatHasMessages(finalChatId);
      if (!hasMessages) {
        // Delete the chat if no messages were sent
        debugPrint('Deleting empty chat: $finalChatId');
        await chatProvider.deleteChat(finalChatId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    final bool isOwner =
        restaurantProvider.restaurant != null &&
        authProvider.user?.id == restaurantProvider.restaurant!.ownerId;

    // Handle potential null restaurant during initial load
    final Restaurant? restaurant = restaurantProvider.restaurant;
    if (restaurant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Determina il tipo di layout da utilizzare
    final layoutType = _getLayoutType(context);

    // Layout speciale per tablet in orizzontale
    if (layoutType == LayoutType.tabletHorizontal) {
      return _buildTabletHorizontalLayout(context, restaurant, isOwner);
    }

    // Layout normale per mobile e tablet verticale (il layout originale)
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        // No AppBar here, it's moved inside CustomScrollView
        body: CustomScrollView(
          slivers: <Widget>[
            // --- 1. SliverAppBar ---
            // This app bar will shrink and stick to the top
            SliverAppBar(
              backgroundColor: colorScheme.darkGrayBackground,
              title:
                  isOwner
                      ? InkWell(
                        onTap:
                            () => _showEditNameDialog(context, restaurant.name),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(restaurant.name),
                            const SizedBox(width: 4),
                            const Icon(Icons.edit, size: 16),
                          ],
                        ),
                      )
                      : Align(
                        alignment: Alignment.centerLeft,
                        child: Text(restaurant.name),
                      ),
              centerTitle: isOwner,
              pinned: true, // Makes the AppBar stick at the top
              floating:
                  false, // AppBar doesn't reappear on scrolling down slightly
              snap: false, // Doesn't snap into view
              automaticallyImplyLeading: widget.showBackButton,
              actions:
                  isOwner
                      ? const []
                      : [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: const Icon(Icons.mail_rounded),
                            onPressed:
                                () => _openChat(
                                  context,
                                  restaurant.ownerId,
                                  restaurant.name,
                                ),
                          ),
                        ),
                        FavoriteIconButton(
                          restaurantId: restaurant.id,
                          restaurantName: restaurant.name,
                        ),
                      ],
            ),

            // --- 2. Restaurant Info Section ---
            // This is regular content that scrolls away
            SliverToBoxAdapter(
              child: RestaurantInfo(
                // Assume restaurant is non-null based on the check above
                restaurantImageUrl:
                    restaurant.imageUrl ??
                    '', // Provide actual URL if available
                isOpen: restaurant.isOpen,
                isFixedMenu: restaurant.hasRestaurantType(
                  RestaurantType.fixedMenu,
                ),
                isOnRequest: restaurant.hasRestaurantType(
                  RestaurantType.onRequest,
                ),
                address: restaurant.address,
                isEditable: isOwner,

                // Callbacks (unchanged)
                onOpenStatusChanged:
                    isOwner
                        ? (isOpen) {
                          restaurantProvider.updateRestaurantOpenStatus(
                            widget.restaurantId,
                            isOpen,
                          );
                        }
                        : null,
                onFixedMenuToggled:
                    isOwner
                        ? (isEnabled) {
                          restaurantProvider.updateRestaurantType(
                            widget.restaurantId,
                            RestaurantType.fixedMenu,
                          );
                        }
                        : null,
                onOnRequestToggled:
                    isOwner
                        ? (isEnabled) {
                          restaurantProvider.updateRestaurantType(
                            widget.restaurantId,
                            RestaurantType.onRequest,
                          );
                        }
                        : null,
                onAddressChanged:
                    isOwner
                        ? (newAddress, lat, lng) {
                          debugPrint(
                            "New address: $newAddress (lat: $lat, lng: $lng)",
                          );
                          final orderProvider = Provider.of<OrderProvider>(
                            context,
                            listen: false,
                          );
                          restaurantProvider.updateRestaurantAddress(
                            widget.restaurantId,
                            newAddress,
                            lat,
                            lng,
                            orderProvider: orderProvider,
                          );
                        }
                        : null,
                onImageUploadPressed:
                    isOwner
                        ? (File? imageFile) {
                          if (imageFile != null) {
                            restaurantProvider.updateRestaurantImage(
                              widget.restaurantId,
                              imageFile,
                            );
                          }
                        }
                        : null,
                onImageUrlChanged:
                    isOwner
                        ? (String? imageUrl) {
                          if (imageUrl != null && imageUrl.isNotEmpty) {
                            restaurantProvider.updateRestaurantImageUrl(
                              widget.restaurantId,
                              imageUrl,
                            );
                          }
                        }
                        : null,
              ),
            ),

            // --- 3. Scrollable Space ---
            // This SizedBox adds vertical space that scrolls away with RestaurantInfo
            const SliverToBoxAdapter(
              child: SizedBox(height: 10.0), // Adjust height as needed
            ),

            // --- 4. Sticky TabBar ---
            // This header persists below the AppBar
            SliverPersistentHeader(
              pinned: true, // Make the tab bar stick
              delegate: _StickyTabBarDelegate(
                // Pass necessary data and callbacks to the delegate
                tabBar: NavigationTabbar(
                  tabCount: 2,
                  tabLabels: const ['Fixed menu', 'On Request'],
                  height: 40.0, // Adjust height as needed
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0,
                  ),
                  radius: 25.0,
                  initialIndex: _selectedTabIndex, // Pass current index
                  onTabSelected: (index) {
                    // Update state when tab changes
                    setState(() {
                      _selectedTabIndex = index;
                    });
                    debugPrint('Selected tab $index');
                  },
                ),
                backgroundColor:
                    colorScheme.surface, // Background for the tab bar area
                padding: EdgeInsets.symmetric(
                  // Tablet verticale usa un padding medio, smartphone usa padding standard
                  horizontal:
                      layoutType == LayoutType.tabletVertical ? 120.0 : 50.0,
                  vertical: 8.0,
                ),
                isOwner: isOwner,
                actionButton: CircularButton(
                  icon: Icons.add,
                  onPressed: () {
                    _openDishScreen(
                      isEditable: isOwner,
                      isNew: true,
                      isSpecial: _selectedTabIndex == 1,
                    );
                  },
                ),
              ),
            ),

            // --- 5. Menu List ---
            // This is the main scrollable content area below the sticky tab bar
            _buildSliverMenuList(
              _selectedTabIndex == 0,
              isOwner,
              layoutType: layoutType,
            ),
          ],
        ),
      ),
    );
  }

  // Nuovo metodo per costruire il layout specifico per tablet in orizzontale
  Widget _buildTabletHorizontalLayout(
    BuildContext context,
    Restaurant restaurant,
    bool isOwner,
  ) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          title: Text(restaurant.name),
          centerTitle: true,
          automaticallyImplyLeading: widget.showBackButton,
          actions:
              isOwner
                  ? const []
                  : [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.mail_rounded),
                        onPressed:
                            () => _openChat(
                              context,
                              restaurant.ownerId,
                              restaurant.name,
                            ),
                      ),
                    ),
                    FavoriteIconButton(
                      restaurantId: restaurant.id,
                      restaurantName: restaurant.name,
                    ),
                  ],
        ),
        body: Row(
          children: [
            // Pannello laterale sinistro (1/3 dello schermo) con info ristorante e nome
            Container(
              width: MediaQuery.of(context).size.width / 3,
              color:
                  colorScheme
                      .darkGrayBackground, // Colore di sfondo uniforme per tutta la colonna
              child: Center(
                // Centra verticalmente tutto il contenuto
                child: SingleChildScrollView(
                  // Permette lo scrolling solo se necessario
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centrato verticalmente
                    children: [
                      // Informazioni ristorante
                      RestaurantInfo(
                        restaurantImageUrl: restaurant.imageUrl ?? '',
                        isOpen: restaurant.isOpen,
                        isFixedMenu: restaurant.hasRestaurantType(
                          RestaurantType.fixedMenu,
                        ),
                        isOnRequest: restaurant.hasRestaurantType(
                          RestaurantType.onRequest,
                        ),
                        address: restaurant.address,
                        isEditable: isOwner,

                        onOpenStatusChanged:
                            isOwner
                                ? (isOpen) {
                                  restaurantProvider.updateRestaurantOpenStatus(
                                    widget.restaurantId,
                                    isOpen,
                                  );
                                }
                                : null,
                        onFixedMenuToggled:
                            isOwner
                                ? (isEnabled) {
                                  restaurantProvider.updateRestaurantType(
                                    widget.restaurantId,
                                    RestaurantType.fixedMenu,
                                  );
                                }
                                : null,
                        onOnRequestToggled:
                            isOwner
                                ? (isEnabled) {
                                  restaurantProvider.updateRestaurantType(
                                    widget.restaurantId,
                                    RestaurantType.onRequest,
                                  );
                                }
                                : null,
                        onAddressChanged:
                            isOwner
                                ? (newAddress, lat, lng) {
                                  final orderProvider =
                                      Provider.of<OrderProvider>(
                                        context,
                                        listen: false,
                                      );
                                  restaurantProvider.updateRestaurantAddress(
                                    widget.restaurantId,
                                    newAddress,
                                    lat,
                                    lng,
                                    orderProvider: orderProvider,
                                  );
                                }
                                : null,
                        onImageUploadPressed:
                            isOwner
                                ? (File? imageFile) {
                                  if (imageFile != null) {
                                    restaurantProvider.updateRestaurantImage(
                                      widget.restaurantId,
                                      imageFile,
                                    );
                                  }
                                }
                                : null,
                        onImageUrlChanged:
                            isOwner
                                ? (String? imageUrl) {
                                  if (imageUrl != null && imageUrl.isNotEmpty) {
                                    restaurantProvider.updateRestaurantImageUrl(
                                      widget.restaurantId,
                                      imageUrl,
                                    );
                                  }
                                }
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pannello destro (2/3 dello schermo) con menu
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 20.0,
                    ), // Space between header and menu
                  ),

                  // Sticky TabBar in alto
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyTabBarDelegate(
                      tabBar: NavigationTabbar(
                        tabCount: 2,
                        tabLabels: const ['Fixed menu', 'On Request'],
                        height: 40.0,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        ),
                        radius: 25.0,
                        initialIndex: _selectedTabIndex,
                        onTabSelected: (index) {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                      ),
                      backgroundColor: colorScheme.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50.0,
                        vertical: 16.0,
                      ),
                      isOwner: isOwner,
                      actionButton: CircularButton(
                        icon: Icons.add,
                        onPressed: () {
                          _openDishScreen(
                            isEditable: isOwner,
                            isNew: true,
                            isSpecial: _selectedTabIndex == 1,
                          );
                        },
                      ),
                    ),
                  ),

                  // Menu in visualizzazione a singola colonna
                  _buildSliverMenuList(
                    _selectedTabIndex == 0,
                    isOwner,
                    layoutType: LayoutType.tabletHorizontal,
                    forceColumnView: true, // Forza vista a colonna singola
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modified function to return a SliverList
  // Helper method to get course name in a readable format
  String _getCourseDisplayName(Course course) {
    switch (course) {
      case Course.appetizer:
        return 'Appetizers';
      case Course.pastaDish:
        return 'Pasta Dishes';
      case Course.mainDish:
        return 'Main Courses';
      case Course.side:
        return 'Side Dishes';
      case Course.dessert:
        return 'Desserts';
      case Course.drink:
        return 'Drinks';
      case Course.other:
      default:
        return 'Other Dishes';
    }
  }

  // Modified function to return a SliverList grouped by course
  Widget _buildSliverMenuList(
    bool isFixedMenu,
    bool isEditable, {
    LayoutType? layoutType,
    bool forceColumnView = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final dishProvider = Provider.of<DishProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUsername = authProvider.user?.username;

    // Check if data is loading
    if (dishProvider.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Check if there's an error
    if (dishProvider.errorMessage != null) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'Error loading dishes: ${dishProvider.errorMessage}',
            style: TextStyle(color: colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Filter dishes based on menu type and user permissions
    final List<Dish> dishes;

    if (isFixedMenu) {
      // For fixed menu show all non special dishes
      dishes = dishProvider.dishes.where((dish) => !dish.isSpecial).toList();
    } else {
      if (isEditable) {
        // For menu on request show all special dishes if the user is the owner of the restaurant
        dishes = dishProvider.dishes.where((dish) => dish.isSpecial).toList();
      } else {
        // In case the user is not the owner show all special dishes with his username
        dishes =
            dishProvider.dishes
                .where(
                  (dish) =>
                      dish.isSpecial && dish.userUsername == currentUsername,
                )
                .toList();
      }
    }

    if (dishes.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'No dishes available',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    Map<Course, List<Dish>> groupedItems = {};

    // Initialize all categories to ensure consistent order
    for (var course in Course.values) {
      groupedItems[course] = [];
    }

    // Group dishes by category
    for (var dish in dishes) {
      Course course = dish.course ?? Course.other;
      groupedItems[course]!.add(dish);
    }

    groupedItems.forEach((course, dishList) {
      dishList.sort((a, b) => a.name.compareTo(b.name));
    });

    // Remove empty categories
    groupedItems.removeWhere((key, value) => value.isEmpty);

    // Convert into a flat list with headers for SliverList
    List<Widget> sliverItems = [];

    groupedItems.forEach((course, items) {
      // Aggiungiamo l'intestazione della categoria
      sliverItems.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 25, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getCourseDisplayName(course),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Divider(height: 1, thickness: 1, color: colorScheme.primary),
            ],
          ),
        ),
      );

      // Determiniamo il layout da utilizzare in base ai parametri
      Widget dishesLayout;

      // Se forceColumnView è true, utilizziamo sempre il layout a colonna singola
      if (forceColumnView) {
        dishesLayout = _buildSingleColumnLayout(
          items,
          isEditable,
          dishProvider,
        );
      } else {
        // Altrimenti usiamo ResponsiveLayout per decidere in base al tipo di dispositivo
        dishesLayout = ResponsiveLayout(
          builder: (context, isTablet) {
            if (isTablet && layoutType != LayoutType.tabletHorizontal) {
              // Layout a due colonne per i tablet in verticale
              return _buildTwoColumnLayout(items, isEditable, dishProvider);
            } else {
              // Layout a singola colonna per gli smartphone e tablet orizzontali
              return _buildSingleColumnLayout(items, isEditable, dishProvider);
            }
          },
        ).builder(context, MediaQuery.of(context).size.shortestSide >= 600);
      }

      sliverItems.add(dishesLayout);

      // Add divider after each section (except the last)
      if (course != groupedItems.keys.last) {
        sliverItems.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        );
      }
    });

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return sliverItems[index];
        }, childCount: sliverItems.length),
      ),
    );
  }

  // Layout a due colonne per tablet
  Widget _buildTwoColumnLayout(
    List<Dish> items,
    bool isEditable,
    DishProvider dishProvider,
  ) {
    // Creiamo una lista di righe, ognuna contenente fino a due elementi
    List<Widget> rows = [];

    for (var i = 0; i < items.length; i += 2) {
      final List<Widget> rowItems = [];

      // Primo piatto nella riga
      rowItems.add(
        Expanded(child: _buildMenuItem(items[i], isEditable, dishProvider)),
      );

      // Secondo piatto nella riga (se presente)
      if (i + 1 < items.length) {
        rowItems.add(
          Expanded(
            child: _buildMenuItem(items[i + 1], isEditable, dishProvider),
          ),
        );
      } else {
        // Placeholder vuoto per mantenere l'allineamento
        rowItems.add(const Expanded(child: SizedBox()));
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowItems,
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  // Layout a singola colonna per smartphone
  Widget _buildSingleColumnLayout(
    List<Dish> items,
    bool isEditable,
    DishProvider dishProvider,
  ) {
    return Column(
      children:
          items
              .map((dish) => _buildMenuItem(dish, isEditable, dishProvider))
              .toList(),
    );
  }

  // Helper method to build menu item widget
  Widget _buildMenuItem(Dish dish, bool isEditable, DishProvider dishProvider) {
    return MenuItem(
      dishId: dish.id,
      dishName: dish.name,
      description: dish.description ?? '',
      imageUrl: dish.imageUrl ?? '',
      isEditable: isEditable,
      price: dish.price,
      isAvailable: dish.isAvailable ?? true,
      course: dish.course ?? Course.other,
      cuisine: dish.cuisine ?? Cuisine.other,
      onDelete:
          isEditable
              ? () {
                dishProvider.deleteDish(
                  dishProvider.currentRestaurantId!,
                  dish.id,
                );
              }
              : null,
      onEdit:
          isEditable
              ? (
                newName,
                newDescription,
                newPrice,
                newCourse,
                newCuisine, {
                imageFile,
                imageUrl,
                isAvailable,
              }) {
                debugPrint('Image url: ${imageUrl ?? 'No image URL'}');
                dishProvider.updateDish(
                  restaurantId: dishProvider.currentRestaurantId!,
                  dishId: dish.id,
                  name: newName,
                  description: newDescription,
                  price: newPrice,
                  course: newCourse,
                  cuisine: newCuisine,
                  imageFile: imageFile,
                  imageUrl: imageUrl,
                );
              }
              : null,
      onAvailabilityChanged:
          isEditable
              ? (newAvailability) {
                debugPrint('Change availability for dish: ${dish.name}');
                dishProvider.updateDishAvailability(
                  dishProvider.currentRestaurantId!,
                  dish.id,
                  newAvailability,
                );
              }
              : null,
      onDishSelected: ({
        required isEditable,
        dishId,
        heroTag,
        isNew = false,
        isSpecial = false,
        onAvailabilityChanged,
      }) {
        _openDishScreen(
          isEditable: isEditable,
          dishId: dishId,
          heroTag: heroTag,
          isNew: isNew,
          isSpecial:
              dish.isSpecial, // Passiamo il valore corretto per isSpecial dal dish
          onAvailabilityChanged: onAvailabilityChanged,
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Modify Name'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Restaurant Name'),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final newName = nameController.text.trim();
                  if (newName.isNotEmpty) {
                    await restaurantProvider.updateRestaurantName(
                      widget.restaurantId,
                      newName,
                      orderProvider: orderProvider,
                    );

                    Navigator.of(dialogContext).pop();

                    // Check for errors after update
                    if (restaurantProvider.errorMessage != null) {
                      CustomAlertDialog.showInfoDialog(
                        context: context,
                        title: 'Error',
                        message: restaurantProvider.errorMessage!,
                        icon: Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      );
                    } else if (orderProvider.errorMessage != null) {
                      CustomAlertDialog.showInfoDialog(
                        context: context,
                        title: 'Error updating the orders',
                        message: orderProvider.errorMessage!,
                        icon: Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}

// --- Custom Delegate for the Sticky TabBar ---
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  // The tab bar widget itself
  final NavigationTabbar tabBar;
  // Background color for the delegate area
  final Color backgroundColor;
  // Padding around the content (tab bar and button)
  final EdgeInsets padding;
  // Flag indicating if the current user is the owner
  final bool isOwner;
  // Optional action button (e.g., add button)
  final CircularButton? actionButton;

  const _StickyTabBarDelegate({
    required this.tabBar,
    required this.backgroundColor,
    required this.padding,
    required this.isOwner,
    this.actionButton,
  });

  // Calculate minimum extent based on tab bar height and vertical padding
  @override
  double get minExtent => tabBar.height + padding.vertical;
  // Calculate maximum extent based on tab bar height and vertical padding
  @override
  double get maxExtent => tabBar.height + padding.vertical;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Provide a background color for the area behind the tab bar and button
    return Container(
      color: backgroundColor, // Use the passed background color
      padding: padding, // Apply the specified padding
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center items vertically
        children: [
          // TabBar takes up available space
          Expanded(
            child: NavigationTabbar(
              // Rebuild tab bar without margin, as padding is handled by the delegate
              key: tabBar.key,
              tabCount: tabBar.tabCount,
              tabLabels: tabBar.tabLabels,
              height: tabBar.height,
              margin:
                  EdgeInsets.zero, // Margin is handled by delegate's padding
              radius: tabBar.radius,
              onTabSelected: tabBar.onTabSelected,
              initialIndex: tabBar.initialIndex,
            ),
          ),
          // Conditionally display the button next to the tab bar if the user is the owner
          if (isOwner && actionButton != null) ...[
            const SizedBox(width: 10), // Spacing between tab bar and button
            AnimatedButton(
              onTap:
                  actionButton!.onPressed ??
                  () {
                    debugPrint('Button pressed');
                  },
              child: actionButton!,
            ),
          ],
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    // Rebuild if any of the properties change
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor ||
        padding != oldDelegate.padding ||
        isOwner != oldDelegate.isOwner ||
        actionButton != oldDelegate.actionButton;
  }
}
