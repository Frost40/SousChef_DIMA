import 'package:flutter/material.dart';
import 'package:sous_chef/widgets/auth/shake_widget_state.dart';

class ShakeWidget extends StatefulWidget {
  const ShakeWidget({
    required this.child,
    required this.shakeOffset,
    super.key,
    this.shakeCount = 3,
    this.shakeDuration = const Duration(milliseconds: 400),
  });
  final Widget child;
  final double shakeOffset;
  final int shakeCount;
  final Duration shakeDuration;

  @override
  // ignore: no_logic_in_create_state
  ShakeWidgetState createState() => ShakeWidgetState(shakeDuration);
}