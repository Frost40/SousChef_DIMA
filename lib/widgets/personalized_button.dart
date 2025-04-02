import 'package:flutter/material.dart';

class PersonalizedButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final Widget? centralWidget; // Optional widget parameter

  const PersonalizedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.centralWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(25.0)
        ),

        // Use the centralWidget if provided, otherwise use the text
        child: Center(
          child: centralWidget ?? Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}