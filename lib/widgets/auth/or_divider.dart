import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  const DividerWithText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 1,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            'or',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}