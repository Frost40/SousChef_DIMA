import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await authProvider.signOut();
              // Navigate to login screen after sign out
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
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