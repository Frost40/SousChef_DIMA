import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/themes/theme_extensions.dart';
import 'package:sous_chef/widgets/navigation_tabbar.dart';
import '../providers/restaurant_provider.dart';
import '../providers/auth_provider.dart';
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
      'name': 'Spaghetti Carbonara',
      'description': 'Traditional pasta with eggs, guanciale, pecorino cheese and black pepper',
      'imageUrl': 'https://example.com/carbonara.jpg',
    },
    {
      'name': 'Porcini Mushroom Risotto',
      'description': 'Creamy risotto with fresh porcini mushrooms and parmesan cheese',
      'imageUrl': '',
    },
    {
      'name': 'Florentine T-bone Steak',
      'description': 'Grilled T-bone beef steak, served rare',
      'imageUrl': 'https://example.com/bistecca.jpg',
    },
    {
      'name': 'Tiramisu',
      'description': 'Classic Italian dessert with mascarpone, coffee and ladyfingers',
      'imageUrl': 'https://example.com/tiramisu.jpg',
    },
    {
      'name': 'Caprese Salad',
      'description': 'Tomatoes, buffalo mozzarella, fresh basil and olive oil',
      'imageUrl': '',
    },
    {
      'name': 'Truffle Linguine',
      'description': 'Handmade linguine with black truffle cream and aged parmesan',
      'imageUrl': 'https://example.com/truffle.jpg',
    },
    {
      'name': 'Mediterranean Sea Bass',
      'description': 'Fresh sea bass fillet with herbs, lemon and roasted vegetables',
      'imageUrl': '',
    },
    {
      'name': 'Beef Carpaccio',
      'description': 'Thinly sliced raw beef with arugula, capers and parmesan shavings',
      'imageUrl': 'https://example.com/carpaccio.jpg',
    },
    {
      'name': 'Wild Mushroom Ravioli',
      'description': 'Homemade ravioli filled with wild mushrooms in a sage butter sauce',
      'imageUrl': '',
    },
    {
      'name': 'Osso Buco',
      'description': 'Slow-cooked veal shanks with vegetables and gremolata',
      'imageUrl': 'https://example.com/ossobuco.jpg',
    },
    {
      'name': 'Panna Cotta',
      'description': 'Silky vanilla cream dessert with fresh berry compote',
      'imageUrl': 'https://example.com/pannacotta.jpg',
    },
    {
      'name': 'Tuscan Bean Soup',
      'description': 'Hearty soup with cannellini beans, vegetables and Tuscan herbs',
      'imageUrl': '',
    },
    {
      'name': 'Grilled Octopus',
      'description': 'Tender octopus with potatoes, olives and cherry tomatoes',
      'imageUrl': 'https://example.com/octopus.jpg',
    },
    {
      'name': 'Pistachio Cheesecake',
      'description': 'Creamy cheesecake with pistachio crust and white chocolate ganache',
      'imageUrl': '',
    },
    {
      'name': 'Veal Saltimbocca',
      'description': 'Thin veal cutlets with prosciutto and sage in wine sauce',
      'imageUrl': 'https://example.com/saltimbocca.jpg',
    },
  ];

  // On-request menu items (unchanged)
  final List<Map<String, dynamic>> _onRequestMenuItems = [
    {
      'name': 'Chef\'s Tasting Menu', // Changed to English
      'description': 'Custom culinary experience based on guest preferences', // Changed to English
      'imageUrl': '',
    },
    {
      'name': 'Seasonal Special Dish', // Changed to English
      'description': 'Dish prepared with fresh seasonal ingredients', // Changed to English
      'imageUrl': 'https://example.com/seasonal.jpg',
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
                restaurantImageUrl: "", // Provide actual URL if available
                isOpen: restaurant.isOpen,
                isFixedMenu: restaurant.hasRestaurantType(RestaurantType.fixedMenu),
                isOnRequest: restaurant.hasRestaurantType(RestaurantType.onRequest),
                address: restaurant.address,
                isEditable: isOwner,

                // Callbacks (unchanged)
                onOpenStatusChanged: isOwner ? (isOpen) {
                  debugPrint("New open status: $isOpen");
                  // restaurantProvider.updateRestaurantOpenStatus(widget.restaurantId, isOpen);
                } : null,
                onFixedMenuToggled: isOwner ? (isEnabled) {
                  debugPrint("New fixed menu status: $isEnabled");
                  /*
                  restaurantProvider.updateRestaurantType(
                      widget.restaurantId,
                      RestaurantType.fixedMenu,
                      isEnabled
                  );
                  */
                } : null,
                onOnRequestToggled: isOwner ? (isEnabled) {
                  debugPrint("New on request status: $isEnabled");
                  /*
                   restaurantProvider.updateRestaurantType(
                       widget.restaurantId,
                       RestaurantType.onRequest,
                       isEnabled
                   );
                   */
                } : null,
                onAddressChanged: isOwner ? (newAddress) {
                  debugPrint("New address: $newAddress");
                  // restaurantProvider.updateRestaurantAddress(widget.restaurantId, newAddress);
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
                  margin: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 10.0), // Added vertical margin
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
              ),
            ),

            // --- 5. Menu List ---
            // This is the main scrollable content area below the sticky tab bar
            _buildSliverMenuList(
              _selectedTabIndex == 0 ? _fixedMenuItems : _onRequestMenuItems,
              isOwner,
            ),
          ],
        ),
      ),
    );
  }

  // Modified function to return a SliverList
  Widget _buildSliverMenuList(List<Map<String, dynamic>> menuItems, bool isEditable) {
    if (menuItems.isEmpty) {
      return SliverFillRemaining( // Use SliverFillRemaining to center content when list is empty
        child: Center(
          child: Text(
            'No dishes available', // Changed to English
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 12.0), // Padding for the list itself
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
            final item = menuItems[index];
            // Add padding around each MenuItem if desired
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              child: MenuItem(
                dishName: item['name'],
                description: item['description'],
                imageUrl: item['imageUrl'],
                isEditable: isEditable,
                onDelete: isEditable
                    ? () {
                  debugPrint('Delete dish: ${item['name']}');
                  // Add deletion logic here
                }
                    : null,
                actionWidget: _buildPriceWidget(item['name'], index), // Pass item name for potential keying
              ),
            );
          },
          childCount: menuItems.length,
        ),
      ),
    );
  }

  // Helper for price widget (slightly modified for context)
  Widget _buildPriceWidget(String itemName, int index) {
    // Using a fixed list for demo, consider linking price to actual item data
    final prices = [12.99, 15.50, 24.00, 8.50, 10.00, 35.00, 18.75, 22.50, 16.00, 28.00, 9.50, 11.00, 26.50, 14.00, 19.50]; // Added more prices
    // Use modulo to cycle through prices if menuItems > prices.length
    final price = prices[index % prices.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        // Using € symbol - ensure your font supports it
        '€${price.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// --- Custom Delegate for the Sticky TabBar ---
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate({required this.tabBar, required this.backgroundColor});

  final NavigationTabbar tabBar;
  final Color backgroundColor; // Add background color

  @override
  double get minExtent => tabBar.height + (tabBar.margin?.vertical ?? 0); // Include vertical margin
  @override
  double get maxExtent => tabBar.height + (tabBar.margin?.vertical ?? 0); // Include vertical margin

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Provide a background color for the area behind the tab bar
    return Container(
      color: backgroundColor, // Use the passed background color
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    // Rebuild if the tab bar instance itself changes
    return tabBar != oldDelegate.tabBar || backgroundColor != oldDelegate.backgroundColor;
  }
}