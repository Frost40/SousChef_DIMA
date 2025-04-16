import 'package:flutter/material.dart';
import '../widgets/favorite_screen/slider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        automaticallyImplyLeading: false,
      ),
      body: FavoritesList(),
    );
  }
}
