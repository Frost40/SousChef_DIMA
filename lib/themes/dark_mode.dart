import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Color(0xFFFF6B00),      // Keep the same orange as primary
    secondary: Color(0xFFFFA726),    // Same lighter orange
    surface: Color(0xFF121212),      // Dark surface color
    surfaceContainerHighest: Colors.grey.shade600, // Dark grey for standout items
    onPrimary: Colors.white,         // Text/icons on orange
    onSurface: Colors.white,         // Text on dark surface
    error: Colors.redAccent,         // Brighter red for better visibility
    brightness: Brightness.dark,
  ),
);