import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/widgets/auth/animated_button.dart';
import 'package:sous_chef/widgets/personalized_button.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/themes/theme_provider.dart';
import 'package:sous_chef/widgets/theme_switch.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access providers
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          // Theme switch in app bar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ThemeSwitch(
              radius: 15.0,
              width: 60.0,
              height: 30.0,
              lightModeIcon: Icon(
                Icons.wb_sunny,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              darkModeIcon: Icon(
                Icons.nightlight_round,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Screen title
          Center(
            child: Text(
              'Account Screen',
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Logout button with animation
          AnimatedButton(
            onTap: () async {
              // Sign out the user through auth provider
              await authProvider.signOut();
              // Navigate to login screen after successful logout
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true)
                    .pushReplacementNamed('/login');
              }
            },
            child: PersonalizedButton(
              text: "Logout",
              onPressed: null
            ),
          )
        ],
      ),
    );
  }
}