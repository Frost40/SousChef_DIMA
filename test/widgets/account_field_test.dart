import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/widgets/account_screen/account_field.dart';

import '../helpers/pump_app.dart';
import '../helpers/mock_providers.dart';

void main() {
  group('AccountField', () {
    late MockVoidCallback mockOnTap;

    setUp(() {
      mockOnTap = MockVoidCallback();
    });

    testWidgets('renders correctly', (tester) async {
      await tester.pumpAppWithScaffold(
        AccountField(
          leftIcon: Icons.person,
          text: 'Profile',
          onTap: mockOnTap.call,
        ),
      );

      expect(find.byType(AccountField), findsOneWidget);
    });

    testWidgets('displays text', (tester) async {
      await tester.pumpAppWithScaffold(
        AccountField(
          leftIcon: Icons.person,
          text: 'Account Settings',
          onTap: mockOnTap.call,
        ),
      );

      expect(find.text('Account Settings'), findsOneWidget);
    });

    testWidgets('displays left icon', (tester) async {
      await tester.pumpAppWithScaffold(
        AccountField(
          leftIcon: Icons.settings,
          text: 'Settings',
          onTap: mockOnTap.call,
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('displays default right icon (arrow_forward_ios)', (
      tester,
    ) async {
      await tester.pumpAppWithScaffold(
        AccountField(
          leftIcon: Icons.person,
          text: 'Profile',
          onTap: mockOnTap.call,
        ),
      );

      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('displays custom right icon', (tester) async {
      await tester.pumpAppWithScaffold(
        AccountField(
          leftIcon: Icons.person,
          rightIcon: Icons.chevron_right,
          text: 'Profile',
          onTap: mockOnTap.call,
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      await tester.pumpAppWithScaffold(
        AccountField(
          leftIcon: Icons.person,
          text: 'Profile',
          onTap: mockOnTap.call,
        ),
      );

      await tester.tap(find.byType(AccountField));
      await tester.pumpAndSettle();

      verify(() => mockOnTap.call()).called(1);
    });
  });
}
