import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.deepOrange,   // Main orange
    secondary: Color(0xFFFF8026), // Lighter orange
    tertiary: Color(0xFFFFB34F),
    surface: Colors.white,        // Dialogs/sheets
    surfaceContainerHighest: Color(0xFF9E9E9E), // Light grey for standout items
    onPrimary: Colors.white,      // Text/icons on orange
    onSurface: Colors.black87,   // Secondary text
    error: Colors.red,            // Errors
  ),
);