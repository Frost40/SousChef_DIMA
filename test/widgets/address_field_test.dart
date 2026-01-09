import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/restaurant_screen/address_field.dart';

import '../helpers/pump_app.dart';

void main() {
  group('AddressField', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpAppWithScaffold(const AddressField());

      expect(find.byType(AddressField), findsOneWidget);
    });

    testWidgets('displays empty message when no address', (tester) async {
      await tester.pumpAppWithScaffold(const AddressField());

      expect(find.text('No current address'), findsOneWidget);
    });

    testWidgets('displays custom empty message', (tester) async {
      await tester.pumpAppWithScaffold(
        const AddressField(emptyMessage: 'Please select an address'),
      );

      expect(find.text('Please select an address'), findsOneWidget);
    });

    testWidgets('displays provided address', (tester) async {
      await tester.pumpAppWithScaffold(
        const AddressField(address: 'Via Roma 1, Milano, Italy'),
      );

      // Widget extracts first two parts
      expect(find.textContaining('Via Roma'), findsOneWidget);
    });

    testWidgets('is not editable by default', (tester) async {
      const widget = AddressField();

      expect(widget.isEditable, isFalse);
    });

    testWidgets('can be set as editable', (tester) async {
      const widget = AddressField(isEditable: true);

      expect(widget.isEditable, isTrue);
    });

    testWidgets('contains Container', (tester) async {
      await tester.pumpAppWithScaffold(const AddressField());

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('contains edit icon when editable', (tester) async {
      await tester.pumpAppWithScaffold(const AddressField(isEditable: true));

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });
}
