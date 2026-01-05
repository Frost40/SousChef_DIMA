import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/providers/user_provider.dart';
import 'package:sous_chef/widgets/favorite_icon_button.dart';

import '../helpers/mock_providers.dart';
import '../mocks/mock_models.dart';

/// Fake BuildContext for mocktail registration
class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  group('FavoriteIconButton', () {
    late MockUserProvider mockUserProvider;

    setUp(() {
      mockUserProvider = MockUserProvider();
    });

    Widget buildTestWidget({
      required String restaurantId,
      required String restaurantName,
    }) {
      return ChangeNotifierProvider<UserProvider>.value(
        value: mockUserProvider,
        child: MaterialApp(
          home: Scaffold(
            body: FavoriteIconButton(
              restaurantId: restaurantId,
              restaurantName: restaurantName,
            ),
          ),
        ),
      );
    }

    group('rendering', () {
      testWidgets('displays filled heart when restaurant is favorite', (
        tester,
      ) async {
        // Arrange
        final user = MockModels.createMockUser(favourites: ['restaurant123']);
        when(() => mockUserProvider.userData).thenReturn(user);

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            restaurantId: 'restaurant123',
            restaurantName: 'Test Restaurant',
          ),
        );

        // Assert
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsNothing);
      });

      testWidgets('displays outline heart when restaurant is not favorite', (
        tester,
      ) async {
        // Arrange
        final user = MockModels.createMockUser(favourites: []);
        when(() => mockUserProvider.userData).thenReturn(user);

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            restaurantId: 'restaurant123',
            restaurantName: 'Test Restaurant',
          ),
        );

        // Assert
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsNothing);
      });

      testWidgets('displays outline heart when userData is null', (
        tester,
      ) async {
        // Arrange
        when(() => mockUserProvider.userData).thenReturn(null);

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            restaurantId: 'restaurant123',
            restaurantName: 'Test Restaurant',
          ),
        );

        // Assert
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      });

      testWidgets('favorite icon is red color', (tester) async {
        // Arrange
        final user = MockModels.createMockUser(favourites: ['restaurant123']);
        when(() => mockUserProvider.userData).thenReturn(user);

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            restaurantId: 'restaurant123',
            restaurantName: 'Test Restaurant',
          ),
        );

        // Assert
        final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
        expect(icon.color, equals(Colors.red));
      });

      testWidgets('renders as IconButton', (tester) async {
        // Arrange
        when(() => mockUserProvider.userData).thenReturn(null);

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            restaurantId: 'restaurant123',
            restaurantName: 'Test Restaurant',
          ),
        );

        // Assert
        expect(find.byType(IconButton), findsOneWidget);
      });
    });

    group('interaction', () {
      testWidgets('calls toggleFavorite when favorite is tapped', (
        tester,
      ) async {
        // Arrange
        final user = MockModels.createMockUser(favourites: ['restaurant123']);
        when(() => mockUserProvider.userData).thenReturn(user);
        when(
          () => mockUserProvider.toggleFavorite(any(), any(), any()),
        ).thenAnswer((_) async {});

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            restaurantId: 'restaurant123',
            restaurantName: 'Test Restaurant',
          ),
        );
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // Assert
        verify(
          () => mockUserProvider.toggleFavorite(
            any(),
            'restaurant123',
            'Test Restaurant',
          ),
        ).called(1);
      });

      testWidgets('calls addToFavorites when non-favorite is tapped', (
        tester,
      ) async {
        // Arrange
        final user = MockModels.createMockUser(favourites: []);
        when(() => mockUserProvider.userData).thenReturn(user);
        when(
          () => mockUserProvider.addToFavorites(any(), any(), any()),
        ).thenAnswer((_) async {});

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            restaurantId: 'restaurant123',
            restaurantName: 'Test Restaurant',
          ),
        );
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // Assert
        verify(
          () => mockUserProvider.addToFavorites(
            any(),
            'restaurant123',
            'Test Restaurant',
          ),
        ).called(1);
      });
    });

    group('edge cases', () {
      testWidgets('handles restaurant in middle of favorites list', (
        tester,
      ) async {
        // Arrange
        final user = MockModels.createMockUser(
          favourites: ['other1', 'restaurant123', 'other2'],
        );
        when(() => mockUserProvider.userData).thenReturn(user);

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            restaurantId: 'restaurant123',
            restaurantName: 'Test Restaurant',
          ),
        );

        // Assert - should show as favorite
        expect(find.byIcon(Icons.favorite), findsOneWidget);
      });

      testWidgets('handles empty restaurantId', (tester) async {
        // Arrange
        final user = MockModels.createMockUser(favourites: []);
        when(() => mockUserProvider.userData).thenReturn(user);

        // Act
        await tester.pumpWidget(
          buildTestWidget(restaurantId: '', restaurantName: 'Test Restaurant'),
        );

        // Assert - should not crash and show not favorite
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      });
    });
  });
}
