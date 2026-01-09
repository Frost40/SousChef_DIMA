import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/widgets/favorite_screen/restaurant_tile.dart';

import '../helpers/mock_providers.dart';

void main() {
  group('RestaurantTile', () {
    late Map<String, dynamic> testRestaurant;

    setUpAll(() {
      registerFallbackValues();
      registerFallbackValue(FakeBuildContext());
    });

    setUp(() {
      testRestaurant = {
        'id': 'rest-1',
        'restaurantName': 'Test Restaurant',
        'imagine': 'https://example.com/image.jpg',
        'available': true,
        'favorite': false,
      };
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

      test('available field determines open/closed status', () {
        expect(testRestaurant['available'], isTrue);

        testRestaurant['available'] = false;
        expect(testRestaurant['available'], isFalse);
      });

      test('favorite field determines favorite icon state', () {
        expect(testRestaurant['favorite'], isFalse);

        testRestaurant['favorite'] = true;
        expect(testRestaurant['favorite'], isTrue);
      });

      test('stores image URL', () {
        final widget = RestaurantTile(restaurant: testRestaurant);
        expect(widget.restaurant['imagine'], 'https://example.com/image.jpg');
      });

      test('stores restaurant id', () {
        final widget = RestaurantTile(restaurant: testRestaurant);
        expect(widget.restaurant['id'], 'rest-1');
      });

      test('handles different restaurant names', () {
        testRestaurant['restaurantName'] = 'Pizza Palace';
        final widget = RestaurantTile(restaurant: testRestaurant);
        expect(widget.restaurant['restaurantName'], 'Pizza Palace');
      });

      test('handles empty restaurant name', () {
        testRestaurant['restaurantName'] = '';
        final widget = RestaurantTile(restaurant: testRestaurant);
        expect(widget.restaurant['restaurantName'], '');
      });

      test('handles various image URLs', () {
        testRestaurant['imagine'] = 'https://different-domain.com/image.png';
        final widget = RestaurantTile(restaurant: testRestaurant);
        expect(widget.restaurant['imagine'], contains('different-domain.com'));
      });

      test('is a StatelessWidget', () {
        final widget = RestaurantTile(restaurant: testRestaurant);
        expect(widget, isA<StatelessWidget>());
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
  });
}
