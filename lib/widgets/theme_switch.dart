import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/themes/theme_provider.dart';

class ThemeSwitch extends StatefulWidget {
  final double radius;
  final double thumbRadius;
  final Widget? activeChild;
  final Widget? inactiveChild;

  const ThemeSwitch({
    super.key,
    this.radius = 40,
    this.thumbRadius = 100,
    this.activeChild,
    this.inactiveChild
  });

  @override
  State<ThemeSwitch> createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  // Controller for the switch state
  late final ValueNotifier<bool> _controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller with current theme mode
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _controller = ValueNotifier<bool>(themeProvider.isDarkMode);

    // Add listener to toggle theme when switch changes
    _controller.addListener(() {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      themeProvider.toggleTheme();
    });
  }

  @override
  void dispose() {
    // Clean up controller when widget is disposed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update controller when theme changes externally
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    if (_controller.value != isDarkMode) {
      _controller.value = isDarkMode;
    }

    // Return the AdvancedSwitch with customized properties
    return AdvancedSwitch(
      // Background colors based on theme
      activeColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      inactiveColor: Theme.of(context).colorScheme.surfaceContainerHighest,

      // Icons for each state
      activeChild: widget.activeChild ?? Icon(
        Icons.nightlight_round,
        size: 18,
        color: Theme.of(context).colorScheme.primary,
      ),
      inactiveChild: widget.inactiveChild ?? Icon(
        Icons.wb_sunny,
        size: 18,
        color: Theme.of(context).colorScheme.primary,
      ),

      // Border radius for the switch
      borderRadius: BorderRadius.all(Radius.circular(widget.radius)),

      // Size customization
      width: 60, // Smaller width
      height: 30, // Smaller height

      // Customized thumb (the moving part)
      thumb: Container(
        margin: const EdgeInsets.all(3), // Smaller margin
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.thumbRadius)
        ),
      ),

      // Controller to manage the state
      controller: _controller,
    );
  }
}