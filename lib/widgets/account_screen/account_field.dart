import 'package:flutter/material.dart';
import '../animated_button.dart';

class AccountField extends StatelessWidget {
  final IconData leftIcon;
  final IconData rightIcon;
  final String text;
  final VoidCallback onTap;

  const AccountField({
    required this.leftIcon,
    this.rightIcon = Icons.arrow_forward_ios,
    required this.text,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: AnimatedButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(25.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(leftIcon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Icon(rightIcon, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}