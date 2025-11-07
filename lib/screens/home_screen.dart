import 'package:flutter/material.dart';
import 'package:sous_chef/widgets/home_screen/map_viewer.dart';
import 'package:sous_chef/widgets/home_screen/address_display.dart';
import 'package:sous_chef/widgets/home_screen/distance_selector.dart';
import 'package:sous_chef/widgets/navigation_tabbar.dart';

import '../transition_type.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isMapView = false;

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
                        initialDistance: 3,
                        onDistanceChanged: (distance) {
                          // TODO: Utilizza la distanza selezionata per filtrare i risultati
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
    return const MapViewer(
      latitude: 45.4642, // Milano
      longitude: 9.1900,
      zoom: 12.0,
      markerTitle: 'Milano',
    );
  }
}
