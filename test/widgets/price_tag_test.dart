import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/restaurant_screen/price_tag.dart';

import '../helpers/pump_app.dart';

void main() {
  group('PriceTag', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpAppWithScaffold(const PriceTag(price: 10.0));

      expect(find.byType(PriceTag), findsOneWidget);
    });

    testWidgets('displays price with two decimal places', (tester) async {
      await tester.pumpAppWithScaffold(const PriceTag(price: 10.5));

      expect(find.text('10.50'), findsOneWidget);
    });

    testWidgets('displays currency symbol by default', (tester) async {
      await tester.pumpAppWithScaffold(const PriceTag(price: 10.0));

      expect(find.text('€'), findsOneWidget);
    });

    testWidgets('hides currency when showCurrency is false', (tester) async {
      await tester.pumpAppWithScaffold(
        const PriceTag(price: 10.0, showCurrency: false),
      );

      expect(find.text('€'), findsNothing);
    });

    testWidgets('accepts custom currency symbol', (tester) async {
      await tester.pumpAppWithScaffold(
        const PriceTag(price: 10.0, currencySymbol: r'$'),
      );

      expect(find.text(r'$'), findsOneWidget);
    });

    testWidgets('has default font size of 18', (tester) async {
      const widget = PriceTag(price: 10.0);

      expect(widget.fontSize, 18);
    });

    testWidgets('accepts custom font size', (tester) async {
      const widget = PriceTag(price: 10.0, fontSize: 24);

      expect(widget.fontSize, 24);
    });

    testWidgets('accepts custom height and width', (tester) async {
      const widget = PriceTag(price: 10.0, height: 50, width: 100);

      expect(widget.height, 50);
      expect(widget.width, 100);
    });

    testWidgets('contains Container', (tester) async {
      await tester.pumpAppWithScaffold(const PriceTag(price: 10.0));

      expect(find.byType(Container), findsWidgets);
    });
  });
}
