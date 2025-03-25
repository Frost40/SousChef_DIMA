import 'package:flutter/material.dart';

        class PersonalizedButton extends StatelessWidget {
          final String text;
          final Function()? onPressed;

          const PersonalizedButton({
            super.key,
            required this.text,
            required this.onPressed,
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
                child: Center(
                  child: Text(
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