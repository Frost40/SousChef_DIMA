import 'package:flutter/material.dart';
import 'package:sous_chef/providers/restaurant_provider.dart';
import 'package:sous_chef/widgets/restaurant_list_tile.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/services/orientation_manager.dart';

// Enum per identificare i tipi di layout possibili
enum LayoutType { mobile, tabletVertical, tabletHorizontal }

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Restaurant> _favouriteRestaurants = [];
  bool _isLoading = false;
  List<String> _lastFavoriteIds = [];
  bool _isInitialized = false;

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
    // Ritarda il caricamento fino a dopo il primo build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadFavorites();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Salta il primo controllo (durante l'inizializzazione)
    if (!_isInitialized) {
      _isInitialized = true;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.userData != null) {
        _lastFavoriteIds = List.from(userProvider.userData!.favourites);
      }
      return;
    }

    // Controlla se i preferiti sono cambiati
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userData != null) {
      final currentFavoriteIds = userProvider.userData!.favourites;

      // Se i preferiti sono cambiati, ricarica
      if (_lastFavoriteIds.length != currentFavoriteIds.length ||
          !_lastFavoriteIds.every((id) => currentFavoriteIds.contains(id))) {
        _lastFavoriteIds = List.from(currentFavoriteIds);
        // Usa addPostFrameCallback per evitare chiamate durante il build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _loadFavorites();
          }
        });
      }
    }
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );

    await userProvider.fetchUserData();

    if (!mounted) return;

    if (userProvider.userData != null &&
        userProvider.userData!.favourites.isNotEmpty) {
      _favouriteRestaurants = await restaurantProvider
          .fetchFavoriteRestaurantsByIds(userProvider.userData!.favourites);
    } else {
      _favouriteRestaurants = [];
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void deactivate() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.syncPendingChanges();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final layoutType = _getLayoutType(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading || restaurantProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (restaurantProvider.errorMessage != null) {
            return Center(
              child: Text('Error: ${restaurantProvider.errorMessage}'),
            );
          } else if (_favouriteRestaurants.isEmpty) {
            return const Center(
              child: Text("No favorite yet!", style: TextStyle(fontSize: 25)),
            );
          } else {
            // Per tablet orizzontale: mostra 2 colonne
            if (layoutType == LayoutType.tabletHorizontal) {
              // Raggruppa i ristoranti in coppie
              final List<List<Restaurant>> pairedRestaurants = [];
              for (var i = 0; i < _favouriteRestaurants.length; i += 2) {
                if (i + 1 < _favouriteRestaurants.length) {
                  pairedRestaurants.add([
                    _favouriteRestaurants[i],
                    _favouriteRestaurants[i + 1],
                  ]);
                } else {
                  pairedRestaurants.add([_favouriteRestaurants[i]]);
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

            // Layout normale per mobile e tablet verticale
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: _favouriteRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _favouriteRestaurants[index];
                return RestaurantListTile(restaurant: restaurant);
              },
            );
          }
        },
      ),
    );
  }
}
