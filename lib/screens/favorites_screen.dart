import 'package:flutter/material.dart';
import 'package:sous_chef/providers/restaurant_provider.dart';
import '../widgets/favorite_screen/restaurant_tile.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:sous_chef/models/restaurant.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Restaurant> _favouriteRestaurants = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData().then((_) async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
        if (!mounted) return;

        _favouriteRestaurants = await restaurantProvider.fetchFavoriteRestaurantsByIds(userProvider.userData!.favourites);

        if (userProvider.userData != null &&
            userProvider.userData!.favourites.isNotEmpty) {
          _favouriteRestaurants = await restaurantProvider
              .fetchFavoriteRestaurantsByIds(userProvider.userData!.favourites);
        } else {
          _favouriteRestaurants = [];
        }
      });
    });
  }


  void _clearErrors() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.clearErrors();
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );
    restaurantProvider.clearErrors();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        automaticallyImplyLeading: false,
      ),
      body: Builder(
        builder: (context) {
          if (userProvider.isLoading || restaurantProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (restaurantProvider.errorMessage != null) {
            return Center(
              child: Text('Error: ${restaurantProvider.errorMessage}'),
            );
          } else if (_favouriteRestaurants.isEmpty) {
            return const Center(child: Text("You have no favorite yet"));
          } else {
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              itemCount: _favouriteRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _favouriteRestaurants[index];
                // Mock data for now, replace with actual data
                final mockRestaurantData = {
                  'immagine': "https://i.pravatar.cc/150?img=5",
                  'nomeRistorante': restaurant.name,
                  'modalitaOrdini': 'Aperto',
                  'preferito': true,
                };
                return RestaurantTile(ristorante: mockRestaurantData);
              },
              separatorBuilder:
                  (context, index) =>
                      const Divider(color: Colors.grey, thickness: 1.0),
            );
          }
        },
      ),
    );
  }
}
