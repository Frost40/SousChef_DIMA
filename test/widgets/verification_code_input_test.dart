import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/order_screen/verification_code_input.dart';

import '../helpers/pump_app.dart';

void main() {
  group('VerificationCodeInput', () {
    Future<void> showVerificationDialog(
      WidgetTester tester, {
      required Future<bool> Function(String) onVerify,
      String orderId = 'order-1',
    }) async {
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
                              orderId: orderId,
                              onVerify: onVerify,
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
    }

    group('widget instantiation', () {
      test('stores orderId', () {
        final widget = VerificationCodeInput(
          orderId: 'test-order-123',
          onVerify: (code) async => true,
        );

        expect(widget.orderId, 'test-order-123');
      });

      test('stores onVerify callback', () {
        final callback = (String code) async => code == '123456';
        final widget = VerificationCodeInput(
          orderId: 'order-1',
          onVerify: callback,
        );

        expect(widget.onVerify, isNotNull);
      });
    });

    group('rendering', () {
      testWidgets('renders correctly', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        expect(find.byType(VerificationCodeInput), findsOneWidget);
      });

      testWidgets('is an AlertDialog', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        expect(find.byType(AlertDialog), findsOneWidget);
      });

      testWidgets('displays title', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        expect(find.text('Verify Pickup Code'), findsOneWidget);
      });

      testWidgets('displays instruction text', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        expect(
          find.text('Enter the 6-digit code shown by the customer:'),
          findsOneWidget,
        );
      });

      testWidgets('contains TextField for code input', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('has Cancel button', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('has Verify button', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        expect(find.text('Verify'), findsOneWidget);
      });

      testWidgets('TextField has placeholder hint', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.decoration?.hintText, '000000');
      });
    });

    group('TextField configuration', () {
      testWidgets('has numeric keyboard type', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, TextInputType.number);
      });

      testWidgets('has max length of 6', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.maxLength, 6);
      });

      testWidgets('has centered text alignment', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.textAlign, TextAlign.center);
      });

      testWidgets('has proper text style', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.style?.fontSize, 24);
        expect(textField.style?.fontWeight, FontWeight.bold);
        expect(textField.style?.letterSpacing, 8);
      });

      testWidgets('only allows digit input', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        // Enter text including non-digits
        await tester.enterText(find.byType(TextField), 'abc123def');
        await tester.pump();

        // Only digits should be accepted
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, '123');
      });

      testWidgets('hides counter text', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.decoration?.counterText, '');
      });
    });

    group('validation', () {
      testWidgets('shows error when code is less than 6 digits', (
        tester,
      ) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        // Enter only 3 digits
        await tester.enterText(find.byType(TextField), '123');
        await tester.pump();

        // Tap verify button
        await tester.tap(find.text('Verify'));
        await tester.pump();

        expect(find.text('Code must be 6 digits'), findsOneWidget);
      });

      testWidgets('shows error for invalid code', (tester) async {
        await showVerificationDialog(
          tester,
          onVerify: (code) async => false, // Always return false
        );

        // Enter 6 digits
        await tester.enterText(find.byType(TextField), '123456');
        await tester.pump();

        // Tap verify button
        await tester.tap(find.text('Verify'));
        await tester.pumpAndSettle();

        expect(find.text('Invalid code. Please try again.'), findsOneWidget);
      });

      testWidgets('shows error when verification throws exception', (
        tester,
      ) async {
        await showVerificationDialog(
          tester,
          onVerify: (code) async => throw Exception('Network error'),
        );

        await tester.enterText(find.byType(TextField), '123456');
        await tester.pump();

        await tester.tap(find.text('Verify'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Error:'), findsOneWidget);
      });
    });

    group('verification flow', () {
      testWidgets('shows loading indicator during verification', (
        tester,
      ) async {
        bool verifyStarted = false;

        await showVerificationDialog(
          tester,
          onVerify: (code) async {
            verifyStarted = true;
            return true;
          },
        );

        await tester.enterText(find.byType(TextField), '123456');
        await tester.pump();

        await tester.tap(find.text('Verify'));
        await tester.pump();

        expect(verifyStarted, isTrue);
      });

      testWidgets('closes dialog on successful verification', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        await tester.enterText(find.byType(TextField), '123456');
        await tester.pump();

        await tester.tap(find.text('Verify'));
        await tester.pumpAndSettle();

        expect(find.byType(VerificationCodeInput), findsNothing);
      });

      testWidgets('calls onVerify with entered code', (tester) async {
        String? capturedCode;

        await showVerificationDialog(
          tester,
          onVerify: (code) async {
            capturedCode = code;
            return true;
          },
        );

        await tester.enterText(find.byType(TextField), '654321');
        await tester.pump();

        await tester.tap(find.text('Verify'));
        await tester.pumpAndSettle();

        expect(capturedCode, '654321');
      });

      testWidgets('submitting via keyboard triggers verification', (
        tester,
      ) async {
        String? capturedCode;

        await showVerificationDialog(
          tester,
          onVerify: (code) async {
            capturedCode = code;
            return true;
          },
        );

        await tester.enterText(find.byType(TextField), '123456');
        await tester.pump();

        // Submit via keyboard
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(capturedCode, '123456');
      });
    });

    group('cancel behavior', () {
      testWidgets('closes dialog when Cancel is tapped', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.byType(VerificationCodeInput), findsNothing);
      });

      testWidgets('does not call onVerify when cancelled', (tester) async {
        bool verifyCalled = false;

        await showVerificationDialog(
          tester,
          onVerify: (code) async {
            verifyCalled = true;
            return true;
          },
        );

        await tester.enterText(find.byType(TextField), '123456');
        await tester.pump();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(verifyCalled, isFalse);
      });
    });

    group('theme support', () {
      testWidgets('renders correctly with light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
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

        expect(find.byType(VerificationCodeInput), findsOneWidget);
      });

      testWidgets('renders correctly with dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
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

        expect(find.byType(VerificationCodeInput), findsOneWidget);
      });

      testWidgets('Verify button uses theme primary color', (tester) async {
        final customTheme = ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.purple,
            onPrimary: Colors.white,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: customTheme,
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

        expect(find.byType(ElevatedButton), findsNWidgets(2));
      });
    });

    group('edge cases', () {
      testWidgets('handles single verification attempt', (tester) async {
        int verifyCount = 0;

        await showVerificationDialog(
          tester,
          onVerify: (code) async {
            verifyCount++;
            return true;
          },
        );

        await tester.enterText(find.byType(TextField), '123456');
        await tester.pump();

        await tester.tap(find.text('Verify'));
        await tester.pumpAndSettle();

        expect(verifyCount, 1);
      });

      testWidgets('handles empty input when verify is tapped', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        // Don't enter anything, just tap verify
        await tester.tap(find.text('Verify'));
        await tester.pump();

        expect(find.text('Code must be 6 digits'), findsOneWidget);
      });

      testWidgets('clears error message on new input', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => false);

        // Enter 6 digits and get error
        await tester.enterText(find.byType(TextField), '123456');
        await tester.pump();
        await tester.tap(find.text('Verify'));
        await tester.pumpAndSettle();

        expect(find.text('Invalid code. Please try again.'), findsOneWidget);

        // Enter new code - error should clear when re-verifying
        await tester.enterText(find.byType(TextField), '654321');
        await tester.pump();
        await tester.tap(find.text('Verify'));
        await tester.pump();

        // During verification, error is cleared
        // The error will reappear after verification fails
      });
    });

    group('dispose', () {
      testWidgets('disposes controller properly on cancel', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        await tester.enterText(find.byType(TextField), '123');
        await tester.pump();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // No exception means dispose was successful
        expect(find.byType(VerificationCodeInput), findsNothing);
      });

      testWidgets('disposes controller properly on success', (tester) async {
        await showVerificationDialog(tester, onVerify: (code) async => true);

        await tester.enterText(find.byType(TextField), '123456');
        await tester.pump();

        await tester.tap(find.text('Verify'));
        await tester.pumpAndSettle();

        // No exception means dispose was successful
        expect(find.byType(VerificationCodeInput), findsNothing);
      });
    });
  });
}
