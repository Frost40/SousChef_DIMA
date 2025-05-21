import 'package:flutter/material.dart';

class PriceTag extends StatelessWidget {
  final double price;
  final double fontSize;
  final bool showCurrency;
  final String currencySymbol;
  final double? height;
  final double? width;

  const PriceTag({
    super.key,
    required this.price,
    this.fontSize = 18,
    this.showCurrency = true,
    this.currencySymbol = '€',
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: showCurrency
          ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currencySymbol,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                    Text(
                      price.toStringAsFixed(2),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                ],
              ),
            )
          : Text(
              price.toStringAsFixed(2),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
    );
  }
}