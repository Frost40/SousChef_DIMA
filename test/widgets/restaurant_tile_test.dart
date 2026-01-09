import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/widgets/favorite_screen/restaurant_tile.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

/// Mock HttpClient to prevent NetworkImage from making real HTTP requests
class _MockHttpClient extends Mock implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest extends Mock implements HttpClientRequest {
  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }
}

class _MockHttpHeaders extends Mock implements HttpHeaders {}

class _MockHttpClientResponse extends Mock implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

// 1x1 transparent PNG image bytes
final List<int> _transparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

void main() {
  group('RestaurantTile', () {
    late Map<String, dynamic> testRestaurant;
    late MockUserProvider mockUserProvider;

    setUpAll(() {
      registerFallbackValues();
      registerFallbackValue(FakeBuildContext());
      HttpOverrides.global = _TestHttpOverrides();
    });

    tearDownAll(() {
      HttpOverrides.global = null;
    });

    setUp(() {
      testRestaurant = {
        'id': 'rest-1',
        'restaurantName': 'Test Restaurant',
        'imagine': 'https://example.com/image.jpg',
        'available': true,
        'favorite': false,
      };
      mockUserProvider = MockUserProvider();
    });

    group('widget instantiation', () {
      test('can be instantiated with required restaurant map', () {
        final widget = RestaurantTile(restaurant: testRestaurant);

        expect(widget.restaurant['id'], 'rest-1');
        expect(widget.restaurant['restaurantName'], 'Test Restaurant');
      });

      test('restaurant map contains required fields', () {
        final widget = RestaurantTile(restaurant: testRestaurant);

        expect(widget.restaurant.containsKey('id'), isTrue);
        expect(widget.restaurant.containsKey('restaurantName'), isTrue);
        expect(widget.restaurant.containsKey('imagine'), isTrue);
        expect(widget.restaurant.containsKey('available'), isTrue);
        expect(widget.restaurant.containsKey('favorite'), isTrue);
      });

      test('is a StatelessWidget', () {
        final widget = RestaurantTile(restaurant: testRestaurant);
        expect(widget, isA<StatelessWidget>());
      });
    });

    group('UI rendering', () {
      testWidgets('renders ListTile correctly', (tester) async {
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        expect(find.byType(ListTile), findsOneWidget);
        expect(find.byType(RestaurantTile), findsOneWidget);
      });

      testWidgets('displays restaurant name', (tester) async {
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        expect(find.text('Test Restaurant'), findsOneWidget);
      });

      testWidgets('displays different restaurant names', (tester) async {
        testRestaurant['restaurantName'] = 'Pizza Palace';
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        expect(find.text('Pizza Palace'), findsOneWidget);
      });

      testWidgets('displays Open when restaurant is available', (tester) async {
        testRestaurant['available'] = true;
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        expect(find.text('Open'), findsOneWidget);
        expect(find.text('Closed'), findsNothing);
      });

      testWidgets('displays Closed when restaurant is not available', (tester) async {
        testRestaurant['available'] = false;
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        expect(find.text('Closed'), findsOneWidget);
        expect(find.text('Open'), findsNothing);
      });

      testWidgets('Open text has green color when available', (tester) async {
        testRestaurant['available'] = true;
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        final textWidget = tester.widget<Text>(find.text('Open'));
        expect(textWidget.style?.color, Colors.green);
      });

      testWidgets('Closed text has red color when not available', (tester) async {
        testRestaurant['available'] = false;
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        final textWidget = tester.widget<Text>(find.text('Closed'));
        expect(textWidget.style?.color, Colors.red);
      });

      testWidgets('renders CircleAvatar with correct radius', (tester) async {
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
        expect(circleAvatar.radius, 30.0);
      });

      testWidgets('renders CircleAvatar with NetworkImage', (tester) async {
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
        expect(circleAvatar.backgroundImage, isA<NetworkImage>());
        expect(
          (circleAvatar.backgroundImage as NetworkImage).url,
          'https://example.com/image.jpg',
        );
      });

      testWidgets('handles empty restaurant name gracefully', (tester) async {
        testRestaurant['restaurantName'] = '';
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        expect(find.byType(RestaurantTile), findsOneWidget);
      });
    });

    group('favorite icon', () {
      testWidgets('shows favorite_border icon when not favorited', (tester) async {
        testRestaurant['favorite'] = false;
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsNothing);
      });

      testWidgets('shows filled favorite icon when favorited', (tester) async {
        testRestaurant['favorite'] = true;
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsNothing);
      });

      testWidgets('favorite icon is red', (tester) async {
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        final icon = iconButton.icon as Icon;
        expect(icon.color, Colors.red);
      });

      testWidgets('favorite icon is inside IconButton', (tester) async {
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        expect(find.byType(IconButton), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(IconButton),
            matching: find.byIcon(Icons.favorite_border),
          ),
          findsOneWidget,
        );
      });
    });

    group('favorite toggle interaction', () {
      testWidgets('calls toggleFavorite on UserProvider when tapped', (tester) async {
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        await tester.tap(find.byType(IconButton));
        await tester.pump();

        verify(
          () => mockUserProvider.toggleFavorite(
            any(),
            'rest-1',
            'Test Restaurant',
          ),
        ).called(1);
      });

      testWidgets('passes correct restaurant id to toggleFavorite', (tester) async {
        testRestaurant['id'] = 'special-restaurant-123';
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        await tester.tap(find.byType(IconButton));
        await tester.pump();

        verify(
          () => mockUserProvider.toggleFavorite(
            any(),
            'special-restaurant-123',
            any(),
          ),
        ).called(1);
      });

      testWidgets('passes correct restaurant name to toggleFavorite', (tester) async {
        testRestaurant['restaurantName'] = 'Ristorante Italiano';
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        await tester.tap(find.byType(IconButton));
        await tester.pump();

        verify(
          () => mockUserProvider.toggleFavorite(
            any(),
            any(),
            'Ristorante Italiano',
          ),
        ).called(1);
      });
    });

    group('ListTile structure', () {
      testWidgets('has CircleAvatar as leading widget', (tester) async {
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        final listTile = tester.widget<ListTile>(find.byType(ListTile));
        expect(listTile.leading, isA<CircleAvatar>());
      });

      testWidgets('has IconButton as trailing widget', (tester) async {
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        final listTile = tester.widget<ListTile>(find.byType(ListTile));
        expect(listTile.trailing, isA<IconButton>());
      });

      testWidgets('has restaurant name as title', (tester) async {
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        final listTile = tester.widget<ListTile>(find.byType(ListTile));
        expect(listTile.title, isA<Text>());
        expect((listTile.title as Text).data, 'Test Restaurant');
      });

      testWidgets('has availability status as subtitle', (tester) async {
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        final listTile = tester.widget<ListTile>(find.byType(ListTile));
        expect(listTile.subtitle, isA<Text>());
      });
    });

    group('data model', () {
      test('available can be toggled', () {
        expect(testRestaurant['available'], isTrue);
        testRestaurant['available'] = false;
        expect(testRestaurant['available'], isFalse);
        testRestaurant['available'] = true;
        expect(testRestaurant['available'], isTrue);
      });

      test('favorite can be toggled', () {
        expect(testRestaurant['favorite'], isFalse);
        testRestaurant['favorite'] = true;
        expect(testRestaurant['favorite'], isTrue);
        testRestaurant['favorite'] = false;
        expect(testRestaurant['favorite'], isFalse);
      });

      test('restaurant data is a Map', () {
        final widget = RestaurantTile(restaurant: testRestaurant);
        expect(widget.restaurant, isA<Map<String, dynamic>>());
      });
    });

    group('edge cases', () {
      testWidgets('handles long restaurant names', (tester) async {
        testRestaurant['restaurantName'] = 
            'A Very Long Restaurant Name That Might Overflow The Available Space';
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        expect(find.byType(RestaurantTile), findsOneWidget);
        expect(
          find.text('A Very Long Restaurant Name That Might Overflow The Available Space'),
          findsOneWidget,
        );
      });

      testWidgets('handles special characters in restaurant name', (tester) async {
        testRestaurant['restaurantName'] = 'Café & Brasserie "Le Petit"';
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        expect(find.text('Café & Brasserie "Le Petit"'), findsOneWidget);
      });

      testWidgets('handles unicode in restaurant name', (tester) async {
        testRestaurant['restaurantName'] = '寿司レストラン 🍣';
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        expect(find.text('寿司レストラン 🍣'), findsOneWidget);
      });

      testWidgets('widget can be rendered inside ListView', (tester) async {
        await tester.pumpApp(
          Scaffold(
            body: ListView(
              children: [
                RestaurantTile(restaurant: testRestaurant),
              ],
            ),
          ),
          userProvider: mockUserProvider,
        );

        expect(find.byType(RestaurantTile), findsOneWidget);
      });

      testWidgets('multiple RestaurantTiles can be rendered', (tester) async {
        final restaurant2 = {
          'id': 'rest-2',
          'restaurantName': 'Second Restaurant',
          'imagine': 'https://example.com/image2.jpg',
          'available': false,
          'favorite': true,
        };

        await tester.pumpApp(
          Scaffold(
            body: ListView(
              children: [
                RestaurantTile(restaurant: testRestaurant),
                RestaurantTile(restaurant: restaurant2),
              ],
            ),
          ),
          userProvider: mockUserProvider,
        );

        expect(find.byType(RestaurantTile), findsNWidgets(2));
        expect(find.text('Test Restaurant'), findsOneWidget);
        expect(find.text('Second Restaurant'), findsOneWidget);
      });
    });

    group('accessibility', () {
      testWidgets('IconButton is tappable', (tester) async {
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        final iconButtonFinder = find.byType(IconButton);
        expect(iconButtonFinder, findsOneWidget);
        
        // Verify the button can be found and tapped
        await tester.tap(iconButtonFinder);
        await tester.pump();
        
        // Verify the interaction occurred
        verify(() => mockUserProvider.toggleFavorite(any(), any(), any())).called(1);
      });

      testWidgets('has sufficient tap target size for IconButton', (tester) async {
        await tester.pumpApp(
          Scaffold(body: RestaurantTile(restaurant: testRestaurant)),
          userProvider: mockUserProvider,
        );

        final iconButtonBox = tester.getSize(find.byType(IconButton));
        // IconButton has minimum touch target of 48x48
        expect(iconButtonBox.width, greaterThanOrEqualTo(48.0));
        expect(iconButtonBox.height, greaterThanOrEqualTo(48.0));
      });
    });
  });
}
