import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/widgets/account_screen/account_field.dart';
import 'package:sous_chef/widgets/animated_button.dart';
import 'package:sous_chef/widgets/personalized_button.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/providers/user_provider.dart';
import 'package:sous_chef/widgets/account_screen/theme_switch.dart';
import 'package:sous_chef/services/orientation_manager.dart';
import 'package:sous_chef/screens/account_settings_screen.dart';
import 'package:sous_chef/screens/past_orders_screen.dart';

import '../transition_type.dart';

enum DetailView { none, accountSettings, pastOrders }

enum LayoutType { mobile, tabletVertical, tabletHorizontal }

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  DetailView _selectedView = DetailView.none;
  LayoutType? _previousLayoutType;

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

    // Se siamo passati a tablet orizzontale e c'era una vista selezionata,
    // manteniamo la selezione nella vista divisa
    if (layoutType == LayoutType.tabletHorizontal &&
        _previousLayoutType != LayoutType.tabletHorizontal &&
        _selectedView == DetailView.none) {
      // La vista verrà impostata quando l'utente clicca su un'opzione
      // o quando torna da una schermata dettaglio in modalità verticale
    }

    // Aggiorna il layout precedente
    _previousLayoutType = layoutType;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child:
            layoutType == LayoutType.tabletHorizontal
                ? _buildMasterDetailLayout(context, authProvider)
                : Stack(
                  children: [
                    _buildContent(context, authProvider, layoutType),
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

  Widget _buildMasterDetailLayout(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return Row(
      children: [
        // Left side - Master view (Account menu)
        SizedBox(
          width: 400,
          child: Stack(
            children: [
              _buildContent(context, authProvider, LayoutType.tabletHorizontal),
              // Theme switch for master view
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
        // Divider
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        // Right side - Detail view
        Expanded(child: _buildDetailView(context)),
      ],
    );
  }

  Widget _buildDetailView(BuildContext context) {
    switch (_selectedView) {
      case DetailView.accountSettings:
        return const AccountSettingsScreen(isEmbedded: true);
      case DetailView.pastOrders:
        return const PastOrdersScreen(isEmbedded: true);
      case DetailView.none:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 100,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
              const SizedBox(height: 20),
              Text(
                'Select an option from the menu',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
    }
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
            if (layoutType == LayoutType.tabletHorizontal) {
              setState(() {
                _selectedView = DetailView.accountSettings;
              });
            } else {
              // Salva la selezione anche per modalità verticale
              setState(() {
                _selectedView = DetailView.accountSettings;
              });
              Navigator.of(context).pushNamed(
                '/account-settings',
                arguments: {'transitionType': TransitionType.slideRight},
              );
            }
          },
        ),

        const SizedBox(height: 20),

        AccountField(
          leftIcon: Icons.receipt_long_rounded,
          text: "Past Orders",
          onTap: () {
            if (layoutType == LayoutType.tabletHorizontal) {
              setState(() {
                _selectedView = DetailView.pastOrders;
              });
            } else {
              // Salva la selezione anche per modalità verticale
              setState(() {
                _selectedView = DetailView.pastOrders;
              });
              Navigator.of(context).pushNamed(
                '/past-orders',
                arguments: {'transitionType': TransitionType.slideRight},
              );
            }
          },
        ),

        const SizedBox(height: 60),

        // Logout button with animation
        AnimatedButton(
          onTap: () async {
            // Get providers to clear data on logout
            final chatProvider = Provider.of<ChatProvider>(
              context,
              listen: false,
            );
            final userProvider = Provider.of<UserProvider>(
              context,
              listen: false,
            );

            // Sign out the user through auth provider
            await authProvider.signOut(
              onSignOut: () {
                chatProvider.clearAllChats();
                userProvider.clearUserData();
              },
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
