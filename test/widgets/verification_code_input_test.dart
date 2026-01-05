import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/order_screen/verification_code_input.dart';

import '../helpers/pump_app.dart';

void main() {
  group('VerificationCodeInput', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => VerificationCodeInput(
                              orderId: 'order-1',
                              onVerify: (code) async => code == '123456',
                            ),
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(VerificationCodeInput), findsOneWidget);
    });

    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => VerificationCodeInput(
                              orderId: 'order-1',
                              onVerify: (code) async => true,
                            ),
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Verify Pickup Code'), findsOneWidget);
    });

    testWidgets('displays instruction text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => VerificationCodeInput(
                              orderId: 'order-1',
                              onVerify: (code) async => true,
                            ),
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter the 6-digit code shown by the customer:'),
        findsOneWidget,
      );
    });

    testWidgets('contains TextField for code input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => VerificationCodeInput(
                              orderId: 'order-1',
                              onVerify: (code) async => true,
                            ),
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('stores orderId', (tester) async {
      final widget = VerificationCodeInput(
        orderId: 'test-order-123',
        onVerify: (code) async => true,
      );

      expect(widget.orderId, 'test-order-123');
    });

    testWidgets('is an AlertDialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => VerificationCodeInput(
                              orderId: 'order-1',
                              onVerify: (code) async => true,
                            ),
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
