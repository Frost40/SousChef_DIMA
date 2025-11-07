import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/widgets/home_screen/map_viewer.dart';
import 'package:sous_chef/widgets/home_screen/address_display.dart';
import 'package:sous_chef/widgets/home_screen/distance_selector.dart';
import 'package:sous_chef/widgets/navigation_tabbar.dart';
import 'package:sous_chef/providers/user_provider.dart';
import 'package:sous_chef/providers/restaurant_provider.dart';
import 'package:sous_chef/models/restaurant.dart';

import '../transition_type.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isMapView = false;
  int _selectedDistance = 3;
  List<Restaurant>? _nearbyRestaurants;

  @override
  void initState() {
    super.initState();
    // Carica i ristoranti vicini all'avvio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNearbyRestaurants();
    });
  }

  /// Carica i ristoranti entro la distanza selezionata
  Future<void> _loadNearbyRestaurants() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );
    final userData = userProvider.userData;

    // Solo se l'utente ha un indirizzo con coordinate
    if (userData?.latitude != null && userData?.longitude != null) {
      final restaurants = await restaurantProvider.fetchNearbyRestaurants(
        latitude: userData!.latitude!,
        longitude: userData.longitude!,
        radiusInKm: _selectedDistance.toDouble(),
      );

      if (mounted) {
        setState(() {
          _nearbyRestaurants = restaurants;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sous Chef',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Shopping Cart',
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/cart',
                arguments: {'transitionType': TransitionType.slideRight},
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.mail_rounded),
            tooltip: 'Messagges',
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/allChats',
                arguments: {'transitionType': TransitionType.slideRight},
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Row con AddressDisplay (3/4) e DistanceSelector (1/4)
          SizedBox(
            height: 125,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
              child: Row(
                children: [
                  // AddressDisplay - 3/4 dello schermo
                  Flexible(
                    flex: 9,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                      child: const AddressDisplay(),
                    ),
                  ),
                  // DistanceSelector - 1/4 dello schermo
                  Flexible(
                    flex: 4,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                      child: DistanceSelector(
                        initialDistance: _selectedDistance,
                        onDistanceChanged: (distance) {
                          setState(() {
                            _selectedDistance = distance;
                          });
                          // Ricarica i ristoranti con la nuova distanza
                          _loadNearbyRestaurants();
                          debugPrint('Distanza selezionata: $distance km');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Toggle tra List e Map usando NavigationTabbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: NavigationTabbar(
              tabCount: 2,
              tabLabels: const ['List', 'Map'],
              height: 40.0,
              radius: 25.0,
              initialIndex: 0,
              onTabSelected: (index) {
                setState(() {
                  _isMapView = index == 1;
                });
              },
            ),
          ),

          // Resto del contenuto
          Expanded(
            child: _isMapView ? _buildMapView() : _buildListView(context),
          ),
        ],
      ),
    );
  }

  /// Costruisce la vista lista (default)
  Widget _buildListView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome to the Home Screen!',
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'List view - Restaurant list will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Costruisce la vista mappa
  Widget _buildMapView() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.userData;

    // Se l'utente ha un indirizzo salvato con coordinate, centra sulla sua posizione
    if (userData?.latitude != null && userData?.longitude != null) {
      return MapViewer(
        latitude: userData!.latitude!,
        longitude: userData.longitude!,
        zoom: 14.0,
        markerTitle: userData.savedAddress ?? 'La tua posizione',
        nearbyRestaurants: _nearbyRestaurants,
      );
    }

    // Altrimenti mostra tutta l'Italia
    return MapViewer(
      latitude: 41.8719, // Centro dell'Italia (Roma)
      longitude: 12.5674,
      zoom: 6.0,
      markerTitle: null,
      nearbyRestaurants: _nearbyRestaurants,
    );
  }
}
