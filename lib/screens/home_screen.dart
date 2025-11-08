import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/widgets/home_screen/map_viewer.dart';
import 'package:sous_chef/widgets/home_screen/address_display.dart';
import 'package:sous_chef/widgets/home_screen/distance_selector.dart';
import 'package:sous_chef/widgets/restaurant_list_tile.dart';
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
  double? _lastLatitude;
  double? _lastLongitude;

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
    } else {
      // Se l'utente non ha coordinate, imposta la lista vuota per evitare il loading infinito
      if (mounted) {
        setState(() {
          _nearbyRestaurants = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ascolta i cambiamenti del UserProvider per rilevare modifiche all'indirizzo
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;

    // Se le coordinate dell'utente sono cambiate, ricarica i ristoranti vicini
    if ((userData?.latitude != _lastLatitude ||
            userData?.longitude != _lastLongitude) &&
        userData?.latitude != null &&
        userData?.longitude != null) {
      _lastLatitude = userData!.latitude;
      _lastLongitude = userData.longitude;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadNearbyRestaurants();
      });
    }

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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.userData;

    // Se non ci sono ristoranti caricati
    if (_nearbyRestaurants == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Se non ci sono ristoranti nella zona
    if (_nearbyRestaurants!.isEmpty) {
      // Verifica se l'utente ha impostato un indirizzo
      final hasAddress =
          userData?.latitude != null && userData?.longitude != null;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasAddress ? Icons.restaurant_menu : Icons.location_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              hasAddress ? 'No restaurants found' : 'No address set',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasAddress
                  ? 'Try increasing the distance'
                  : 'Please set your address to find restaurants',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Mostra la lista dei ristoranti
    return ListView.builder(
      itemCount: _nearbyRestaurants!.length,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemBuilder: (context, index) {
        final restaurant = _nearbyRestaurants![index];
        return RestaurantListTile(restaurant: restaurant);
      },
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
