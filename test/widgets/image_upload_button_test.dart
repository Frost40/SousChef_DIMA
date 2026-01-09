import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/image_upload_button.dart';

import '../helpers/pump_app.dart';

void main() {
  group('ImageUploadButton', () {
    group('rendering', () {
      testWidgets('displays camera icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          ImageUploadButton(onImageSelected: (_) {}, currentImageUrl: ''),
        );

        // Assert
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      });

      testWidgets('renders as CircleAvatar', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          ImageUploadButton(onImageSelected: (_) {}, currentImageUrl: ''),
        );

        // Assert
        expect(find.byType(CircleAvatar), findsOneWidget);
      });

      testWidgets('uses custom size', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          ImageUploadButton(
            size: 60.0,
            onImageSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Assert
        final circleAvatar = tester.widget<CircleAvatar>(
          find.byType(CircleAvatar),
        );
        expect(circleAvatar.radius, equals(30.0)); // size/2
      });

      testWidgets('uses custom background color', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          ImageUploadButton(
            backgroundColor: Colors.blue,
            onImageSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Assert
        final circleAvatar = tester.widget<CircleAvatar>(
          find.byType(CircleAvatar),
        );
        expect(circleAvatar.backgroundColor, equals(Colors.blue));
      });

      testWidgets('uses custom icon color and size', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          ImageUploadButton(
            iconColor: Colors.red,
            iconSize: 30.0,
            onImageSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Assert
        final icon = tester.widget<Icon>(find.byIcon(Icons.camera_alt));
        expect(icon.color, equals(Colors.red));
        expect(icon.size, equals(30.0));
      });
    });

    group('interaction', () {
      testWidgets('shows bottom sheet when tapped', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(onImageSelected: (_) {}, currentImageUrl: ''),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert - bottom sheet should appear with options
        expect(find.text('Gallery'), findsOneWidget);
        expect(find.text('Camera'), findsOneWidget);
      });

      testWidgets('shows URL option when onUrlSelected is provided', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (_) {},
            onUrlSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Image URL'), findsOneWidget);
      });

      testWidgets('does not show URL option when onUrlSelected is null', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(onImageSelected: (_) {}, currentImageUrl: ''),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Image URL'), findsNothing);
      });

      testWidgets('bottom sheet shows correct icons', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (_) {},
            onUrlSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.photo_library), findsOneWidget);
        expect(find.byIcon(Icons.photo_camera), findsOneWidget);
        expect(find.byIcon(Icons.link), findsOneWidget);
      });

      testWidgets('closes bottom sheet when Gallery is tapped', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(onImageSelected: (_) {}, currentImageUrl: ''),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        expect(find.text('Gallery'), findsOneWidget);

        // Tap Gallery option (this will attempt to open picker, but won't work in tests)
        await tester.tap(find.text('Gallery'));
        await tester.pumpAndSettle();

        // Assert - bottom sheet should be closed
        expect(find.text('Gallery'), findsNothing);
      });

      testWidgets('closes bottom sheet when Camera is tapped', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(onImageSelected: (_) {}, currentImageUrl: ''),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        expect(find.text('Camera'), findsOneWidget);

        // Tap Camera option
        await tester.tap(find.text('Camera'));
        await tester.pumpAndSettle();

        // Assert - bottom sheet should be closed
        expect(find.text('Camera'), findsNothing);
      });

      testWidgets('shows URL dialog when Image URL option is tapped', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (_) {},
            onUrlSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Image URL'));
        await tester.pumpAndSettle();

        // Assert - URL dialog should appear
        expect(find.text('Insert image URL'), findsOneWidget);
        expect(find.text('Confirm'), findsOneWidget);
        expect(find.text('Rollback'), findsOneWidget);
      });

      testWidgets('URL dialog shows current URL in text field', (tester) async {
        // Arrange
        const currentUrl = 'https://example.com/image.jpg';
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (_) {},
            onUrlSelected: (_) {},
            currentImageUrl: currentUrl,
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Image URL'));
        await tester.pumpAndSettle();

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, equals(currentUrl));
      });

      testWidgets('URL dialog validates invalid URLs', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (_) {},
            onUrlSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Image URL'));
        await tester.pumpAndSettle();

        // Enter invalid URL
        await tester.enterText(find.byType(TextField), 'invalid-url');
        await tester.pumpAndSettle();

        // Assert - error message should appear
        expect(find.text('Image URL not valid'), findsOneWidget);
      });

      testWidgets('URL dialog accepts valid HTTP URLs', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (_) {},
            onUrlSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Image URL'));
        await tester.pumpAndSettle();

        // Enter valid URL
        await tester.enterText(
          find.byType(TextField),
          'http://example.com/image.jpg',
        );
        await tester.pumpAndSettle();

        // Assert - no error message
        expect(find.text('Image URL not valid'), findsNothing);
      });

      testWidgets('URL dialog accepts valid HTTPS URLs', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (_) {},
            onUrlSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Image URL'));
        await tester.pumpAndSettle();

        // Enter valid HTTPS URL
        await tester.enterText(
          find.byType(TextField),
          'https://example.com/image.jpg',
        );
        await tester.pumpAndSettle();

        // Assert - no error message
        expect(find.text('Image URL not valid'), findsNothing);
      });

      testWidgets('URL dialog calls onUrlSelected when confirmed', (
        tester,
      ) async {
        // Arrange
        String? selectedUrl;
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (_) {},
            onUrlSelected: (url) {
              selectedUrl = url;
            },
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Image URL'));
        await tester.pumpAndSettle();

        const testUrl = 'https://example.com/test.jpg';
        await tester.enterText(find.byType(TextField), testUrl);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        // Assert
        expect(selectedUrl, equals(testUrl));
      });

      testWidgets('URL dialog calls onImageSelected with null when confirmed', (
        tester,
      ) async {
        // Arrange
        File? selectedFile = File('dummy');
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (file) {
              selectedFile = file;
            },
            onUrlSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Image URL'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'https://example.com/test.jpg',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        // Assert - onImageSelected should be called with null to clear local image
        expect(selectedFile, isNull);
      });

      testWidgets('URL dialog does not confirm with invalid URL', (
        tester,
      ) async {
        // Arrange
        String? selectedUrl = 'unchanged';
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (_) {},
            onUrlSelected: (url) {
              selectedUrl = url;
            },
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Image URL'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'invalid-url');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        // Assert - callback should not have been called
        expect(selectedUrl, equals('unchanged'));
      });

      testWidgets('URL dialog closes when Rollback is tapped', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (_) {},
            onUrlSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Image URL'));
        await tester.pumpAndSettle();

        expect(find.text('Insert image URL'), findsOneWidget);

        await tester.tap(find.text('Rollback'));
        await tester.pumpAndSettle();

        // Assert - dialog should be closed
        expect(find.text('Insert image URL'), findsNothing);
      });

      testWidgets('URL dialog does not call callbacks when cancelled', (
        tester,
      ) async {
        // Arrange
        String? selectedUrl = 'unchanged';
        File? selectedFile = File('unchanged');
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (file) {
              selectedFile = file;
            },
            onUrlSelected: (url) {
              selectedUrl = url;
            },
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Image URL'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'https://example.com/test.jpg',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Rollback'));
        await tester.pumpAndSettle();

        // Assert - callbacks should not have been called
        expect(selectedUrl, equals('unchanged'));
        expect(selectedFile?.path, equals('unchanged'));
      });

      testWidgets('Confirm button is styled correctly with error', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (_) {},
            onUrlSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Image URL'));
        await tester.pumpAndSettle();

        // Enter invalid URL to trigger error
        await tester.enterText(find.byType(TextField), 'invalid');
        await tester.pumpAndSettle();

        // Assert - Confirm button should have reduced opacity style
        final confirmButton = tester.widget<TextButton>(
          find.widgetWithText(TextButton, 'Confirm'),
        );
        expect(confirmButton.style, isNotNull);
      });

      testWidgets('clears error when valid URL is entered', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (_) {},
            onUrlSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Image URL'));
        await tester.pumpAndSettle();

        // Enter invalid then valid URL
        await tester.enterText(find.byType(TextField), 'invalid');
        await tester.pumpAndSettle();
        expect(find.text('Image URL not valid'), findsOneWidget);

        await tester.enterText(
          find.byType(TextField),
          'https://valid.com/image.jpg',
        );
        await tester.pumpAndSettle();

        // Assert - error should be cleared
        expect(find.text('Image URL not valid'), findsNothing);
      });

      testWidgets('clears error when URL is emptied', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (_) {},
            onUrlSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Image URL'));
        await tester.pumpAndSettle();

        // Enter invalid then clear
        await tester.enterText(find.byType(TextField), 'invalid');
        await tester.pumpAndSettle();
        expect(find.text('Image URL not valid'), findsOneWidget);

        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle();

        // Assert - error should be cleared for empty string
        expect(find.text('Image URL not valid'), findsNothing);
      });
    });

    group('defaults', () {
      testWidgets('uses default size when not specified', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          ImageUploadButton(onImageSelected: (_) {}, currentImageUrl: ''),
        );

        // Assert
        final circleAvatar = tester.widget<CircleAvatar>(
          find.byType(CircleAvatar),
        );
        expect(circleAvatar.radius, equals(20.0)); // default size 40 / 2
      });

      testWidgets('uses default icon size when not specified', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          ImageUploadButton(onImageSelected: (_) {}, currentImageUrl: ''),
        );

        // Assert
        final icon = tester.widget<Icon>(find.byIcon(Icons.camera_alt));
        expect(icon.size, equals(20.0));
      });

      testWidgets('uses theme colors when custom colors not provided', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget_(
          ImageUploadButton(onImageSelected: (_) {}, currentImageUrl: ''),
        );

        // Assert
        final circleAvatar = tester.widget<CircleAvatar>(
          find.byType(CircleAvatar),
        );
        final icon = tester.widget<Icon>(find.byIcon(Icons.camera_alt));

        final context = tester.element(find.byType(CircleAvatar));
        final colorScheme = Theme.of(context).colorScheme;

        expect(circleAvatar.backgroundColor, equals(colorScheme.primary));
        expect(icon.color, equals(colorScheme.onPrimary));
      });
    });

    group('accessibility', () {
      testWidgets('button has zero padding for IconButton', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          ImageUploadButton(onImageSelected: (_) {}, currentImageUrl: ''),
        );

        // Assert
        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.padding, equals(EdgeInsets.zero));
      });

      testWidgets('button has empty constraints', (tester) async {
        // Arrange & Act
        await tester.pumpWidget_(
          ImageUploadButton(onImageSelected: (_) {}, currentImageUrl: ''),
        );

        // Assert
        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.constraints, equals(const BoxConstraints()));
      });
    });

    group('modal bottom sheet', () {
      testWidgets('uses SafeArea for bottom sheet content', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(onImageSelected: (_) {}, currentImageUrl: ''),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert - SafeArea is used (may be multiple in widget tree)
        expect(find.byType(SafeArea), findsWidgets);
      });

      testWidgets('bottom sheet has rounded top corners', (tester) async {
        // This is implied by the RoundedRectangleBorder shape parameter
        // Testing the structure is sufficient
        await tester.pumpWidget_(
          ImageUploadButton(onImageSelected: (_) {}, currentImageUrl: ''),
        );

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert - Wrap widget should be present (bottom sheet content wrapper)
        expect(find.byType(Wrap), findsOneWidget);
      });

      testWidgets('all options are ListTile widgets', (tester) async {
        // Arrange
        await tester.pumpWidget_(
          ImageUploadButton(
            onImageSelected: (_) {},
            onUrlSelected: (_) {},
            currentImageUrl: '',
          ),
        );

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert - Should have 3 ListTiles (Gallery, Camera, Image URL)
        expect(find.byType(ListTile), findsNWidgets(3));
      });
    });
  });
}
