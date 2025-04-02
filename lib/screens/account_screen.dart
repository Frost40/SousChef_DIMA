import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/widgets/auth/animated_button.dart';
import 'package:sous_chef/widgets/personalized_button.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/themes/theme_provider.dart'; // Add this import

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context); // Add this

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          // Add theme toggle with sun/moon icon
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ThemeModeToggle(
              isDarkMode: themeProvider.isDarkMode,
              onToggle: () => themeProvider.toggleTheme(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Text(
              'Account Screen',
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          const SizedBox(width: 20),

          AnimatedButton(
            onTap: () async{
              await authProvider.signOut();
                // Naviga alla schermata di login dopo il logout
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true)
                      .pushReplacementNamed('/login');
                }
              },
            child: PersonalizedButton(
              text: "Logout", 
              onPressed: null),
          )
        ],
      ),
    );
  }
}

// ...existing code...

// Custom theme toggle widget with sun/moon icon
class ThemeModeToggle extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const ThemeModeToggle({
    Key? key,
    required this.isDarkMode,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isDarkMode 
              ? Colors.blueGrey[800]
              : colorScheme.tertiary.withOpacity(0.5),
        ),
        child: Stack(
          children: [
            // Sun icon (fixed on the left)
            Positioned(
              left: 8,
              top: 6,
              child: Icon(
                Icons.wb_sunny,
                size: 18,
                color: isDarkMode ? Colors.grey : Colors.amber,
              ),
            ),
            
            // Moon icon (fixed on the right)
            Positioned(
              right: 8,
              top: 6,
              child: Icon(
                Icons.nightlight_round,
                size: 18,
                color: isDarkMode ? Colors.white : Colors.grey,
              ),
            ),
            
            // Sliding indicator
            AnimatedPositioned(
              duration: Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              left: isDarkMode ? 30 : 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode 
                      ? colorScheme.primary.withOpacity(0.8)
                      : colorScheme.primary.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}