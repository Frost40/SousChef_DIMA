import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/themes/theme_extensions.dart';
import 'package:sous_chef/widgets/navigation_tabbar.dart';
import 'package:sous_chef/widgets/restaurant_screen/dish_detail_dialog.dart';
import '../models/dish.dart';
import '../providers/dish_provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/animated_button.dart';
import '../widgets/circular_button.dart';
import '../widgets/restaurant_screen/menu_item.dart';
import '../widgets/restaurant_screen/restaurant_info.dart';
// Import commented out as firebase_auth is not directly used in the build method shown
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class RestaurantScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  int _selectedTabIndex = 0;

  // Fixed menu items (unchanged)
  final List<Map<String, dynamic>> _fixedMenuItems = [
    {
      'name': 'Beef Carpaccio',
      'description': 'Thinly sliced raw beef with arugula, capers and parmesan shavings',
      'imageUrl': 'https://example.com/carpaccio.jpg',
      'course': Course.appetizer,
      'price': 12.99,
      'isAvailable': true,
    },
    {
      'name': 'Caprese Salad',
      'description': 'Tomatoes, buffalo mozzarella, fresh basil and olive oil',
      'imageUrl': '',
      'course': Course.appetizer,
      'price': 15.50,
      'isAvailable': true,
    },
    {
      'name': 'Tuscan Bean Soup',
      'description': 'Hearty soup with cannellini beans, vegetables and Tuscan herbs',
      'imageUrl': '',
      'course': Course.appetizer,
      'price': 24.00,
      'isAvailable': true,
    },
    {
      'name': 'Spaghetti Carbonara',
      'description': 'Traditional pasta with eggs, guanciale, pecorino cheese and black pepper',
      'imageUrl': 'https://example.com/carbonara.jpg',
      'course': Course.pastaDish,
      'price': 8.50,
      'isAvailable': true,
    },
    {
      'name': 'Truffle Linguine',
      'description': 'Handmade linguine with black truffle cream and aged parmesan',
      'imageUrl': 'https://example.com/truffle.jpg',
      'course': Course.pastaDish,
      'price': 10.00,
      'isAvailable': true,
    },
    {
      'name': 'Wild Mushroom Ravioli',
      'description': 'Homemade ravioli filled with wild mushrooms in a sage butter sauce',
      'imageUrl': '',
      'course': Course.pastaDish,
      'price': 35.00,
      'isAvailable': true,
    },
    {
      'name': 'Porcini Mushroom Risotto',
      'description': 'Creamy risotto with fresh porcini mushrooms and parmesan cheese',
      'imageUrl': '',
      'course': Course.pastaDish,
      'price': 18.75,
      'isAvailable': true,
    },
    {
      'name': 'Florentine T-bone Steak',
      'description': 'Grilled T-bone beef steak, served rare',
      'imageUrl': 'https://example.com/bistecca.jpg',
      'course': Course.mainDish,
      'price': 22.50,
      'isAvailable': true,
    },
    {
      'name': 'Mediterranean Sea Bass',
      'description': 'Fresh sea bass fillet with herbs, lemon and roasted vegetables',
      'imageUrl': '',
      'course': Course.mainDish,
      'price': 16.00,
      'isAvailable': true,
    },
    {
      'name': 'Osso Buco',
      'description': 'Slow-cooked veal shanks with vegetables and gremolata',
      'imageUrl': 'https://example.com/ossobuco.jpg',
      'course': Course.mainDish,
      'price': 28.00,
      'isAvailable': true,
    },
    {
      'name': 'Veal Saltimbocca',
      'description': 'Thin veal cutlets with prosciutto and sage in wine sauce',
      'imageUrl': 'https://example.com/saltimbocca.jpg',
      'course': Course.mainDish,
      'price': 9.50,
      'isAvailable': true,
    },
    {
      'name': 'Grilled Octopus',
      'description': 'Tender octopus with potatoes, olives and cherry tomatoes',
      'imageUrl': 'https://example.com/octopus.jpg',
      'course': Course.mainDish,
      'price': 11.00,
      'isAvailable': true,
    },
    {
      'name': 'Tiramisu',
      'description': 'Classic Italian dessert with mascarpone, coffee and ladyfingers',
      'imageUrl': 'https://example.com/tiramisu.jpg',
      'course': Course.dessert,
      'price': 26.50,
      'isAvailable': true,
    },
    {
      'name': 'Panna Cotta',
      'description': 'Silky vanilla cream dessert with fresh berry compote',
      'imageUrl': 'https://example.com/pannacotta.jpg',
      'course': Course.dessert,
      'price': 14.00,
      'isAvailable': true,
    },
    {
      'name': 'Pistachio Cheesecake',
      'description': 'Creamy cheesecake with pistachio crust and white chocolate ganache',
      'imageUrl': '',
      'course': Course.dessert,
      'price': 19.50,
      'isAvailable': true,
    },
  ];

  final List<Map<String, dynamic>> _onRequestMenuItems = [
    {
      'name': 'Chef\'s Tasting Menu',
      'description': 'Custom culinary experience based on guest preferences',
      'imageUrl': '',
      'course': Course.other,
      'price': 38.99,
      'isAvailable': true,
    },
    {
      'name': 'Seasonal Special Dish',
      'description': 'Dish prepared with fresh seasonal ingredients',
      'imageUrl': 'https://example.com/seasonal.jpg',
      'course': Course.other,
      'price': 42.50,
      'isAvailable': true,
    },
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the widget is still mounted before accessing context
      if (mounted) {
        Provider.of<RestaurantProvider>(context, listen: false)
            .fetchCompleteRestaurantData(widget.restaurantId);
      }

      // Separately fetch restaurant menu
      Provider.of<DishProvider>(context, listen: false)
          .fetchDishes(widget.restaurantId);
    });
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dishProvider = Provider.of<DishProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final bool isOwner = restaurantProvider.restaurant != null &&
        authProvider.user?.id == restaurantProvider.restaurant!.ownerId;

    // Handle potential null restaurant during initial load
    final Restaurant? restaurant = restaurantProvider.restaurant;
    if (restaurant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Use GestureDetector to dismiss keyboard on tap outside focusable areas
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
              title: const Text('Restaurant'),
              centerTitle: true,
              pinned: true, // Makes the AppBar stick at the top
              floating: false, // AppBar doesn't reappear on scrolling down slightly
              snap: false, // Doesn't snap into view
              automaticallyImplyLeading: false, // Adjust if you need a back button
              actions: const [
                // Space for future actions
              ],
            ),

            // --- 2. Restaurant Info Section ---
            // This is regular content that scrolls away
            SliverToBoxAdapter(
              child: RestaurantInfo(
                // Assume restaurant is non-null based on the check above
                restaurantImageUrl: restaurant.imageUrl ?? '', // Provide actual URL if available
                isOpen: restaurant.isOpen,
                isFixedMenu: restaurant.hasRestaurantType(RestaurantType.fixedMenu),
                isOnRequest: restaurant.hasRestaurantType(RestaurantType.onRequest),
                address: restaurant.address,
                isEditable: isOwner,

                // Callbacks (unchanged)
                onOpenStatusChanged: isOwner ? (isOpen) {
                  debugPrint("New open status: $isOpen");
                  restaurantProvider.updateRestaurantOpenStatus(widget.restaurantId, isOpen);
                } : null,
                onFixedMenuToggled: isOwner ? (isEnabled) {
                  debugPrint("New fixed menu status: $isEnabled");
                  restaurantProvider.updateRestaurantType(
                      widget.restaurantId,
                      RestaurantType.fixedMenu
                  );
                } : null,
                onOnRequestToggled: isOwner ? (isEnabled) {
                  debugPrint("New on request status: $isEnabled");
                   restaurantProvider.updateRestaurantType(
                       widget.restaurantId,
                       RestaurantType.onRequest
                   );
                } : null,
                onAddressChanged: isOwner ? (newAddress) {
                  debugPrint("New address: $newAddress");
                  restaurantProvider.updateRestaurantAddress(widget.restaurantId, newAddress);
                } : null,
                onImageUploadPressed: isOwner ? (File? imageFile) {
                  if (imageFile != null) {
                    debugPrint("New image file: ${imageFile.path}");
                      restaurantProvider.updateRestaurantImage(
                          widget.restaurantId,
                          imageFile
                      );

                  }
                } : null,
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
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0), // Added vertical margin
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
                backgroundColor: colorScheme.surface, // Background for the tab bar area
                padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 8.0),
                isOwner: isOwner,
                actionButton: CircularButton(
                  icon: Icons.add,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => DishDetailDialog(
                        isNew: true,
                        isEditable: isOwner,
                        onSave: (name, description, price, course, cuisine, {imageFile, imageUrl, isAvailable}) {
                          debugPrint('New dish saved');
                          debugPrint(name);
                          debugPrint(description);
                          debugPrint(price.toString());
                          debugPrint(course.toString());
                          debugPrint(cuisine.toString());
                          debugPrint(imageFile?.path ?? 'No image file');
                          debugPrint(imageUrl ?? 'No image URL');
                          debugPrint(isAvailable.toString());
                          dishProvider.createDish(
                            restaurantId: dishProvider.currentRestaurantId!,
                            name: name,
                            description: description,
                            price: price,
                            course: course,
                            cuisine: cuisine,
                            imageFile: imageFile,
                            isAvailable: isAvailable ?? false,
                          );
                        },
                      ),
                    );
                  },
                ),
              )
            ),

            // --- 5. Menu List ---
            // This is the main scrollable content area below the sticky tab bar
            _buildSliverMenuList(
              _selectedTabIndex == 0,
              isOwner,
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
  Widget _buildSliverMenuList(bool isFixedMenu, bool isEditable) {
    final colorScheme = Theme.of(context).colorScheme;
    final dishProvider = Provider.of<DishProvider>(context);

    // Verifica se i dati sono in caricamento
    if (dishProvider.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Verifica se c'è un errore
    if (dishProvider.errorMessage != null) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'Errore nel caricamento dei piatti: ${dishProvider.errorMessage}',
            style: TextStyle(color: colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Filtra i piatti in base al tipo di menu (fisso o su richiesta)
    final dishes = dishProvider.dishes.where((dish) =>
      !dish.isSpecial == isFixedMenu // isFixedMenu = true per menu fisso, false per menu su richiesta
    ).toList();

    if (dishes.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'Nessun piatto disponibile',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    // Raggruppa i piatti per categoria
    Map<Course, List<Dish>> groupedItems = {};

    // Inizializza tutte le categorie per assicurare un ordine coerente
    for (var course in Course.values) {
      groupedItems[course] = [];
    }

    // Raggruppa i piatti per categoria
    for (var dish in dishes) {
      Course course = dish.course ?? Course.other;
      groupedItems[course]!.add(dish);
    }

    // Rimuovi le categorie vuote
    groupedItems.removeWhere((key, value) => value.isEmpty);

    // Converti in una lista piatta con intestazioni per SliverList
    List<Widget> sliverItems = [];

    groupedItems.forEach((course, items) {
      // Aggiungi intestazione di sezione
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
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      );

      // Aggiungi elementi per questa sezione
      for (var dish in items) {
        sliverItems.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            child: MenuItem(
              dishName: dish.name,
              description: dish.description,
              imageUrl: dish.imageUrl ?? '',
              isEditable: isEditable,
              price: dish.price,
              isAvailable: dish.isAvailable ?? true,
              course: dish.course ?? Course.other,
              cuisine: dish.cuisine ?? Cuisine.other,
              onDelete: isEditable
                  ? () {
                      debugPrint('Delete dish: ${dish.name}');
                      dishProvider.deleteDish(
                          dishProvider.currentRestaurantId!,
                          dish.id
                      );
                    }
                  : null,
              onEdit: isEditable
                ? (newName, newDescription, newPrice, newCourse, newCuisine, {imageFile, imageUrl, isAvailable}) {
                  debugPrint('Edit dish: ${dish.name}');
                  dishProvider.updateDish(
                      restaurantId: dishProvider.currentRestaurantId!,
                      dishId: dish.id,
                      name: newName,
                      description: newDescription,
                      price: newPrice,
                      course: newCourse,
                      cuisine: newCuisine,
                      imageFile: imageFile,
                  );
                }
                : null,
              onAvailabilityChanged: isEditable
                ? (newAvailability) {
                  debugPrint('Change availability for dish: ${dish.name}');
                  dishProvider.updateDishAvailability(
                      dishProvider.currentRestaurantId!,
                      dish.id,
                      newAvailability
                  );
                }
                : null,
            ),
          ),
        );
      }

      // Aggiungi divisore dopo ogni sezione (tranne l'ultima)
      if (course != groupedItems.keys.last) {
        sliverItems.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
          ),
        );
      }
    });

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return sliverItems[index];
          },
          childCount: sliverItems.length,
        ),
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
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Provide a background color for the area behind the tab bar and button
    return Container(
      color: backgroundColor, // Use the passed background color
      padding: padding, // Apply the specified padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Center items vertically
        children: [
          // TabBar takes up available space
          Expanded(
            child: NavigationTabbar(
              // Rebuild tab bar without margin, as padding is handled by the delegate
              key: tabBar.key,
              tabCount: tabBar.tabCount,
              tabLabels: tabBar.tabLabels,
              height: tabBar.height,
              margin: EdgeInsets.zero, // Margin is handled by delegate's padding
              radius: tabBar.radius,
              onTabSelected: tabBar.onTabSelected,
              initialIndex: tabBar.initialIndex,
            ),
          ),
          // Conditionally display the button next to the tab bar if the user is the owner
          if (isOwner && actionButton != null) ...[
            const SizedBox(width: 10), // Spacing between tab bar and button
            AnimatedButton(
              onTap: actionButton!.onPressed ?? () {
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