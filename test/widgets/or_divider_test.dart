import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/auth/or_divider.dart';

import '../helpers/pump_app.dart';

void main() {
  group('DividerWithText', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpAppWithScaffold(const DividerWithText());

      expect(find.byType(DividerWithText), findsOneWidget);
    });

    testWidgets('displays "or" text', (tester) async {
      await tester.pumpAppWithScaffold(const DividerWithText());

      expect(find.text('or'), findsOneWidget);
    });

    testWidgets('contains two Divider widgets', (tester) async {
      await tester.pumpAppWithScaffold(const DividerWithText());

      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('has horizontal padding', (tester) async {
      await tester.pumpAppWithScaffold(const DividerWithText());

      final padding = tester.widget<Padding>(
        find
            .ancestor(of: find.byType(Row), matching: find.byType(Padding))
            .first,
      );

      expect(padding.padding, const EdgeInsets.symmetric(horizontal: 20));
    });

    testWidgets('uses Row for layout', (tester) async {
      await tester.pumpAppWithScaffold(const DividerWithText());

      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('contains Expanded widgets for dividers', (tester) async {
      await tester.pumpAppWithScaffold(const DividerWithText());

      expect(find.byType(Expanded), findsNWidgets(2));
    });
  });
}
