import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Manages the device orientation based on the device type
/// Singleton to persist settings during navigation
class OrientationManager {
  // Singleton instance
  static final OrientationManager _instance = OrientationManager._internal();

  factory OrientationManager() {
    return _instance;
  }

  OrientationManager._internal();

  /// Determines if the device is a tablet and applies the appropriate orientations
  void enforceOrientations(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;
    final double shortestSide = min(screenSize.width, screenSize.height);

    final bool isTablet = shortestSide >= 600;

    if (isTablet) {
      // For tablets: allow all orientations
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // For phones: portrait orientation only
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

  }

  /// Removes all orientation restrictions
  void resetOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

  }

  /// Checks if the device is a tablet
  bool isTablet(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;
    final double shortestSide = min(screenSize.width, screenSize.height);

    return shortestSide >= 600;
  }
}
