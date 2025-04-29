import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/restaurant_screen/restaurant_info.dart';

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

  @override
  void initState() {
    super.initState();
    // Load user data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(context, listen: false).fetchCompleteRestaurantData(widget.restaurantId);
    });
  }

  @override
  void dispose() {
    // It's good practice to unfocus when the screen is disposed
    // in case the keyboard is still open.
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Title stays in the center
        title: const Text('Restaurant'),
        automaticallyImplyLeading: false,
        actions: const [
          // Space for future actions
        ],
      ),
      // Wrap the main body content with GestureDetector
      body: GestureDetector(
        // onTap is called when the user taps anywhere within the area
        // of this GestureDetector that is not handled by another widget.
        onTap: () {
          // This line tells the current focus node to lose focus,
          // effectively dismissing the keyboard.
          FocusScope.of(context).unfocus();
        },
        // HitTestBehavior.opaque ensures that the GestureDetector
        // catches taps in its entire area, even if there are no visible
        // widgets there, preventing taps from falling through.
        behavior: HitTestBehavior.opaque,
        child: Column( // The original Column that holds your content
          children: [
            // Upper section
            RestaurantInfo(
              restaurantImageUrl: "",
              workingSlots: [
                "Monday - Friday: 12:00 - 15:00",
                "Monday - Friday: 19:00 - 23:00",
                "Saturday - Sunday: 12:00 - 23:00",
                "Closed on public holidays"
              ],
              // You will need to pass the address and update callback here
              // from your RestaurantProvider or State.
              // Example:
              // restaurantAddress: restaurantProvider.currentRestaurant.address,
              // onAddressChanged: (newAddress) {
              //   restaurantProvider.updateRestaurantAddress(newAddress);
              // },
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.surfaceContainerHighest,
            ),

            // lower section
            Expanded( // Occupies the remaining space
              child: Container(
                width: double.infinity,
                color: colorScheme.surface,
                child: Center(
                  child: Text(
                    'Restaurant ID: ${widget.restaurantId}',
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}