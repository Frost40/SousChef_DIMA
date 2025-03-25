import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sous_chef/widgets/auth/animated_button.dart';

class CustomSocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final String icon;
  final double? margin;
  const CustomSocialButton({
    required this.onTap,
    required this.text,
    required this.icon,
    this.margin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: AnimatedButton (
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          margin: EdgeInsets.symmetric(horizontal: margin ?? 25),
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
              SvgPicture.asset(icon),
              const Spacer(),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}