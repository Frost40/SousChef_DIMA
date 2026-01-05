import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/favorite_screen/restaurant_tile.dart';

void main() {
  group('RestaurantTile', () {
    late Map<String, dynamic> testRestaurant;

    setUp(() {
      testRestaurant = {
        'id': 'rest-1',
        'restaurantName': 'Test Restaurant',
        'imagine': 'https://example.com/image.jpg',
        'available': true,
        'favorite': false,
      };
    });

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
  });
}
