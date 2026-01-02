import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/widgets/account_screen/account_field.dart';
import 'package:sous_chef/widgets/animated_button.dart';
import 'package:sous_chef/widgets/personalized_button.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/widgets/account_screen/theme_switch.dart';
import 'package:sous_chef/services/orientation_manager.dart';

import '../transition_type.dart';

enum LayoutType { mobile, tabletVertical, tabletHorizontal }

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  LayoutType _getLayoutType(BuildContext context) {
    final orientationManager = OrientationManager();
    final isTablet = orientationManager.isTablet(context);
    if (!isTablet) return LayoutType.mobile;

    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? LayoutType.tabletVertical
        : LayoutType.tabletHorizontal;
  }

  @override
  Widget build(BuildContext context) {
    // Access providers
    final authProvider = Provider.of<AuthProvider>(context);

    final layoutType = _getLayoutType(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Stack(
          children: [
            layoutType == LayoutType.tabletHorizontal
                ? Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 900,
                    child: _buildContent(context, authProvider, layoutType),
                  ),
                )
                : _buildContent(context, authProvider, layoutType),
            // Theme switch always at the extreme right
            Positioned(
              top: 0,
              right: 16.0,
              child: SizedBox(
                height: kToolbarHeight,
                child: Center(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AuthProvider authProvider,
    LayoutType layoutType,
  ) {
    return Column(
      children: [
        // AppBar inside the safe area
        Container(
          height: kToolbarHeight,
          color: Theme.of(context).appBarTheme.backgroundColor,
          child: const Center(
            child: Text('Account', style: TextStyle(fontSize: 22)),
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
    );
  }
}
