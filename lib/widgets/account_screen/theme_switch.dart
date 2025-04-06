import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/themes/theme_provider.dart';

class ThemeSwitch extends StatelessWidget {
  final double radius;
  final Widget lightModeIcon;
  final Widget darkModeIcon;
  final double width;
  final double height;

  const ThemeSwitch({
    super.key,
    this.radius = 15.0,
    this.width = 60.0,
    this.height = 30.0,
    Widget? lightModeIcon,
    Widget? darkModeIcon,
  }) :
    lightModeIcon = lightModeIcon ?? const Icon(
      Icons.wb_sunny,
      size: 16,
      color: Colors.amber,
    ),
    darkModeIcon = darkModeIcon ?? const Icon(
      Icons.nightlight_round,
      size: 16,
      color: Colors.indigo,
    );

  @override
  Widget build(BuildContext context) {
    // Get theme information from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = Theme.of(context).colorScheme.surface;
    final thumbColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius + 2),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          width: 1.0,
        ),
      ),
      child: GestureDetector(
        onTap: () => themeProvider.toggleTheme(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Light mode icon (Sun)
              Positioned(
                right: 5,
                top: 0,
                bottom: 0,
                child: Center(child: lightModeIcon),
              ),

              // Dark mode icon (Moon)
              Positioned(
                left: 5,
                top: 0,
                bottom: 0,
                child: Center(child: darkModeIcon),
              ),

              // Sliding thumb indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: isDarkMode ? (width / 2) : 3,
                top: 3,
                child: Container(
                  width: (width / 2) - 6,
                  height: height - 6,
                  decoration: BoxDecoration(
                    color: thumbColor,
                    borderRadius: BorderRadius.circular(radius - 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}