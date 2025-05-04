import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final VoidCallback? onPressed;
  final double? elevation;

  const CircularButton({
    super.key,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.size = 40.0,
    this.onPressed,
    this.elevation = 2,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use the default color scheme if no color is provided
    final Color effectiveIconColor = iconColor ?? colorScheme.onPrimary;
    final Color effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        elevation: elevation ?? 2,
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.none,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Ink(
            decoration: BoxDecoration(
              // Button background color
              color: effectiveBackgroundColor,
              shape: BoxShape.circle,
            ),
            width: size,
            height: size,
            child: Center(
              child: Icon(
                icon,
                // Icon color
                color: effectiveIconColor,
                size: size * 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}