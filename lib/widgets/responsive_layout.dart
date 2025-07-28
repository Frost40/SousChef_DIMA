import 'package:flutter/material.dart';
import 'package:sous_chef/services/orientation_manager.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget Function(BuildContext, bool) builder;
  final bool enforceOrientations;

  const ResponsiveLayout({
    super.key,
    required this.builder,
    this.enforceOrientations = false,
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  bool _isTablet = false;
  final OrientationManager _orientationManager = OrientationManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determineDeviceType();
    });
  }

  void _determineDeviceType() {
    setState(() {
      _isTablet = _orientationManager.isTablet(context);

      if (widget.enforceOrientations) {
        _orientationManager.enforceOrientations(context);
      }
    });
  }

  @override
  void dispose() {
    // Do not reset orientations here: let OrientationManager handle them
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _isTablet);
  }
}