import 'package:flutter/material.dart';

class PriceTag extends StatelessWidget {
  final double price;
  final double fontSize;
  final bool showCurrency;
  final String currencySymbol;

  const PriceTag({
    super.key,
    required this.price,
    this.fontSize = 18,
    this.showCurrency = true,
    this.currencySymbol = '€',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        showCurrency
            ? '$currencySymbol${price.toStringAsFixed(2)}'
            : price.toStringAsFixed(2),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}