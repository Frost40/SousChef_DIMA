import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/widgets/account_screen/account_field.dart';
import 'package:sous_chef/widgets/animated_button.dart';
import 'package:sous_chef/widgets/personalized_button.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/themes/theme_provider.dart';
import 'package:sous_chef/widgets/account_screen/theme_switch.dart';

import '../transition_type.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access providers
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar inside the safe area
            Container(
              height: kToolbarHeight,
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: Stack(
                children: [
                  // Centered title (centered in full width)
                  const Center(
                    child: Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                  // Right-aligned theme switch
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            AccountField(
              leftIcon: Icons.settings,
              text: "Account Settings",
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/account-settings',
                  arguments: {'transitionType': TransitionType.slideRight},
                );
              },
            ),

            const SizedBox(height: 20),

            AccountField(
              leftIcon: Icons.receipt_long_rounded,
              text: "Past Orders",
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/past-orders',
                  arguments: {'transitionType': TransitionType.slideRight},
                );
              },
            ),

            const SizedBox(height: 60),

            // Logout button with animation
            AnimatedButton(
              onTap: () async {
                // Get chat provider to clear chats on logout
                final chatProvider = Provider.of<ChatProvider>(
                  context,
                  listen: false,
                );

                // Sign out the user through auth provider
                await authProvider.signOut(
                  onSignOut: () => chatProvider.clearAllChats(),
                );

                // Navigate to login screen after successful logout
                if (context.mounted) {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushReplacementNamed('/login');
                }
              },
              child: PersonalizedButton(text: "Logout", onPressed: null),
            ),
          ],
        ),
      ),
    );
  }
}
