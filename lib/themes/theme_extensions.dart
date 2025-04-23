import 'package:flutter/material.dart';

extension CustomColorScheme on ColorScheme {
  Color get darkGrayBackground {
    // Return different colors based on the brightness
    return brightness == Brightness.dark
        ? const Color(0xFF252525)                // Dark mode color
        : const Color.fromARGB(255, 171, 171, 171); // Light mode color
  }
}
