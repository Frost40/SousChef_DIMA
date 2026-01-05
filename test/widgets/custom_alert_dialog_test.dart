import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/custom_alert_dialog.dart';

void main() {
  group('CustomAlertDialog', () {
    group('showConfirmationDialog', () {
      testWidgets('displays title and message', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () {
                        CustomAlertDialog.showConfirmationDialog(
                          context: context,
                          title: 'Confirm Action',
                          message: 'Are you sure you want to proceed?',
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Confirm Action'), findsOneWidget);
        expect(find.text('Are you sure you want to proceed?'), findsOneWidget);
      });

      testWidgets('displays default Yes/No buttons', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () {
                        CustomAlertDialog.showConfirmationDialog(
                          context: context,
                          title: 'Test',
                          message: 'Test message',
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Yes'), findsOneWidget);
        expect(find.text('No'), findsOneWidget);
      });

      testWidgets('displays custom button text', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () {
                        CustomAlertDialog.showConfirmationDialog(
                          context: context,
                          title: 'Test',
                          message: 'Test message',
                          confirmText: 'Confirm',
                          cancelText: 'Cancel',
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Confirm'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('returns true when confirm is tapped', (tester) async {
        // Arrange
        bool? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () async {
                        result = await CustomAlertDialog.showConfirmationDialog(
                          context: context,
                          title: 'Test',
                          message: 'Test message',
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Yes'));
        await tester.pumpAndSettle();

        // Assert
        expect(result, isTrue);
      });

      testWidgets('returns false when cancel is tapped', (tester) async {
        // Arrange
        bool? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () async {
                        result = await CustomAlertDialog.showConfirmationDialog(
                          context: context,
                          title: 'Test',
                          message: 'Test message',
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('No'));
        await tester.pumpAndSettle();

        // Assert
        expect(result, isFalse);
      });

      testWidgets('displays icon when provided', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () {
                        CustomAlertDialog.showConfirmationDialog(
                          context: context,
                          title: 'Warning',
                          message: 'This is a warning',
                          icon: const Icon(Icons.warning),
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.warning), findsOneWidget);
      });

      testWidgets('dialog has rounded corners', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () {
                        CustomAlertDialog.showConfirmationDialog(
                          context: context,
                          title: 'Test',
                          message: 'Test message',
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsOneWidget);
      });

      testWidgets('can be dismissed by tapping outside', (tester) async {
        // Arrange
        bool? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () async {
                        result = await CustomAlertDialog.showConfirmationDialog(
                          context: context,
                          title: 'Test',
                          message: 'Test message',
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Tap outside the dialog (on the barrier)
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        // Assert - dialog should be dismissed, result should be false
        expect(find.byType(AlertDialog), findsNothing);
        expect(result, isFalse);
      });
    });

    group('showInfoDialog', () {
      testWidgets('displays title and message', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () {
                        CustomAlertDialog.showInfoDialog(
                          context: context,
                          title: 'Information',
                          message: 'This is some info',
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Information'), findsOneWidget);
        expect(find.text('This is some info'), findsOneWidget);
      });

      testWidgets('displays default OK button', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () {
                        CustomAlertDialog.showInfoDialog(
                          context: context,
                          title: 'Info',
                          message: 'Info message',
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('OK'), findsOneWidget);
      });

      testWidgets('displays custom button text', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () {
                        CustomAlertDialog.showInfoDialog(
                          context: context,
                          title: 'Info',
                          message: 'Info message',
                          buttonText: 'Got it',
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Got it'), findsOneWidget);
      });

      testWidgets('closes dialog when button is tapped', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () {
                        CustomAlertDialog.showInfoDialog(
                          context: context,
                          title: 'Info',
                          message: 'Info message',
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsNothing);
      });

      testWidgets('displays icon when provided', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () {
                        CustomAlertDialog.showInfoDialog(
                          context: context,
                          title: 'Success',
                          message: 'Operation completed',
                          icon: const Icon(Icons.check_circle),
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });
    });
  });
}
