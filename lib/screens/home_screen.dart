import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/themes/theme_extensions.dart';
import 'package:sous_chef/widgets/home_screen/map_viewer.dart';
import 'package:sous_chef/widgets/home_screen/address_display.dart';
import 'package:sous_chef/widgets/home_screen/distance_selector.dart';
import 'package:sous_chef/widgets/restaurant_list_tile.dart';
import 'package:sous_chef/widgets/navigation_tabbar.dart';
import 'package:sous_chef/providers/user_provider.dart';
import 'package:sous_chef/providers/restaurant_provider.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/services/orientation_manager.dart';

import '../transition_type.dart';
import '../widgets/home_screen/chat_icon_with_badge.dart';

// Enum per identificare i tipi di layout possibili
enum LayoutType { mobile, tabletVertical, tabletHorizontal }

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

    // Determina il tipo di layout da utilizzare
    final layoutType = _getLayoutType(context);

    // Layout speciale per tablet in orizzontale
    if (layoutType == LayoutType.tabletHorizontal) {
      return _buildTabletHorizontalLayout(context);
    }

    // Layout normale per mobile e tablet verticale
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
          ChatIconWithBadge(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
              child: Row(
                children: [
                  // AddressDisplay - 3/4 dello schermo
                  Expanded(flex: 9, child: const AddressDisplay()),
                  const SizedBox(width: 8),
                  // DistanceSelector - 1/4 dello schermo
                  Expanded(
                    flex: 4,
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
                ],
              ),
            ),
          ),

          // Toggle tra List e Map usando NavigationTabbar (solo per mobile e tablet verticale)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: layoutType == LayoutType.tabletVertical ? 100 : 16,
              vertical: 8,
            ),
            child: NavigationTabbar(
              tabCount: 2,
              tabLabels: const ['List', 'Map'],
              height: layoutType == LayoutType.tabletVertical ? 35.0 : 40.0,
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
            child:
                _isMapView
                    ? _buildMapView()
                    : _buildListView(context, layoutType: layoutType),
          ),
        ],
      ),
    );
  }

  /// Costruisce il layout per tablet in orizzontale (lista + mappa affiancate)
  Widget _buildTabletHorizontalLayout(BuildContext context) {
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
          ChatIconWithBadge(
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
          // Row con AddressDisplay e DistanceSelector
          SizedBox(
            height: 125,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
              child: Row(
                children: [
                  // AddressDisplay - 3/4 dello schermo
                  Expanded(flex: 9, child: const AddressDisplay()),
                  const SizedBox(width: 8),
                  // DistanceSelector - 1/4 dello schermo
                  Expanded(
                    flex: 4,
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
                ],
              ),
            ),
          ),

          // Lista e Mappa affiancate
          Expanded(
            child: Row(
              children: [
                // Lista dei ristoranti (1/2 dello schermo)
                Expanded(
                  flex: 1,
                  child: _buildListView(
                    context,
                    layoutType: LayoutType.tabletHorizontal,
                  ),
                ),
                // Mappa (1/2 dello schermo) con bordo grigio
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: _buildMapContent(
                        Provider.of<UserProvider>(
                          context,
                          listen: false,
                        ).userData,
                        showAppBar: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Costruisce la vista lista (default)
  Widget _buildListView(
    BuildContext context, {
    LayoutType layoutType = LayoutType.mobile,
  }) {
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

    // Per tablet orizzontale: mostra header "Results found" + lista
    if (layoutType == LayoutType.tabletHorizontal) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header "Results found"
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 5),
            child: Text(
              'Results found (${_nearbyRestaurants!.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Divider(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              thickness: 1,
            ),
          ),

          // Lista dei ristoranti
          Expanded(
            child: ListView.builder(
              itemCount: _nearbyRestaurants!.length,
              padding: const EdgeInsets.only(top: 0, bottom: 16),
              itemBuilder: (context, index) {
                final restaurant = _nearbyRestaurants![index];
                return RestaurantListTile(restaurant: restaurant);
              },
            ),
          ),
        ],
      );
    }

    // Per tablet verticale: mostra 2 colonne con stessa altezza del mobile
    if (layoutType == LayoutType.tabletVertical) {
      // Raggruppa i ristoranti in coppie
      final List<List<Restaurant>> pairedRestaurants = [];
      for (var i = 0; i < _nearbyRestaurants!.length; i += 2) {
        if (i + 1 < _nearbyRestaurants!.length) {
          pairedRestaurants.add([
            _nearbyRestaurants![i],
            _nearbyRestaurants![i + 1],
          ]);
        } else {
          pairedRestaurants.add([_nearbyRestaurants![i]]);
        }
      }

      return ListView.builder(
        itemCount: pairedRestaurants.length,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemBuilder: (context, index) {
          final pair = pairedRestaurants[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: RestaurantListTile(restaurant: pair[0])),
              if (pair.length > 1)
                Expanded(child: RestaurantListTile(restaurant: pair[1]))
              else
                const Expanded(child: SizedBox()), // Placeholder vuoto
            ],
          );
        },
      );
    }

    // Mostra la lista dei ristoranti (mobile e tablet orizzontale)
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

    // Padding per la mappa in tutte le modalità
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: _buildMapContent(userData),
      ),
    );
  }

  /// Costruisce il contenuto della mappa
  Widget _buildMapContent(dynamic userData, {bool showAppBar = true}) {
    // Se l'utente ha un indirizzo salvato con coordinate, centra sulla sua posizione
    if (userData?.latitude != null && userData?.longitude != null) {
      return MapViewer(
        latitude: userData!.latitude!,
        longitude: userData.longitude!,
        zoom: 14.0,
        markerTitle: userData.savedAddress ?? 'La tua posizione',
        nearbyRestaurants: _nearbyRestaurants,
        showAppBar: showAppBar,
      );
    }

    // Altrimenti mostra tutta l'Italia
    return MapViewer(
      latitude: 41.8719, // Centro dell'Italia (Roma)
      longitude: 12.5674,
      zoom: 6.0,
      markerTitle: null,
      nearbyRestaurants: _nearbyRestaurants,
      showAppBar: showAppBar,
    );
  }
}
