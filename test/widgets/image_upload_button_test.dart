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
    });
  });
}
