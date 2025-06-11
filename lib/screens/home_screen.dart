import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/providers/auth_provider.dart';

import '../transition_type.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Carrello',
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/cart',
                arguments: {'transitionType': TransitionType.slideRight},
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to the Home Screen!',
          style: TextStyle(
            fontSize: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}