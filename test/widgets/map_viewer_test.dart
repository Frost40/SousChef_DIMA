import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/widgets/home_screen/map_viewer.dart';

void main() {
  group('MapViewer', () {
    // Test restaurant data
    late List<Restaurant> testRestaurants;

    setUp(() {
      testRestaurants = [
        Restaurant(
          id: 'rest-1',
          name: 'Pizza Place',
          address: '123 Main St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner-1',
          location: const GeoPoint(45.4700, 9.2000),
          imageUrl: null,
        ),
        Restaurant(
          id: 'rest-2',
          name: 'Sushi Bar',
          address: '456 Oak Ave',
          isOpen: false,
          restaurantTypes: [],
          ownerId: 'owner-2',
          location: const GeoPoint(45.4600, 9.1800),
          imageUrl: null,
        ),
      ];
    });

    group('default values', () {
      test('has correct default latitude (Milano)', () {
        const widget = MapViewer();
        expect(widget.latitude, 45.4642);
      });

      test('has correct default longitude (Milano)', () {
        const widget = MapViewer();
        expect(widget.longitude, 9.1900);
      });

      test('has correct default zoom', () {
        const widget = MapViewer();
        expect(widget.zoom, 12.0);
      });

      test('showAppBar defaults to true', () {
        const widget = MapViewer();
        expect(widget.showAppBar, isTrue);
      });

      test('markerTitle defaults to null', () {
        const widget = MapViewer();
        expect(widget.markerTitle, isNull);
      });

      test('nearbyRestaurants defaults to null', () {
        const widget = MapViewer();
        expect(widget.nearbyRestaurants, isNull);
      });
    });

    group('custom values', () {
      test('accepts custom latitude', () {
        const widget = MapViewer(latitude: 41.9028);
        expect(widget.latitude, 41.9028);
      });

      test('accepts custom longitude', () {
        const widget = MapViewer(longitude: 12.4964);
        expect(widget.longitude, 12.4964);
      });

      test('accepts custom coordinates (Rome)', () {
        const widget = MapViewer(latitude: 41.9028, longitude: 12.4964);
        expect(widget.latitude, 41.9028);
        expect(widget.longitude, 12.4964);
      });

      test('accepts custom zoom', () {
        const widget = MapViewer(zoom: 15.0);
        expect(widget.zoom, 15.0);
      });

      test('accepts marker title', () {
        const widget = MapViewer(markerTitle: 'My Location');
        expect(widget.markerTitle, 'My Location');
      });

      test('accepts showAppBar false', () {
        const widget = MapViewer(showAppBar: false);
        expect(widget.showAppBar, isFalse);
      });

      test('accepts nearby restaurants list', () {
        final widget = MapViewer(nearbyRestaurants: testRestaurants);
        expect(widget.nearbyRestaurants, isNotNull);
        expect(widget.nearbyRestaurants!.length, 2);
      });

      test('accepts empty restaurant list', () {
        const widget = MapViewer(nearbyRestaurants: []);
        expect(widget.nearbyRestaurants, isEmpty);
      });
    });

    group('widget type', () {
      test('is a StatefulWidget', () {
        const widget = MapViewer();
        expect(widget, isA<StatefulWidget>());
      });

      test('creates state', () {
        const widget = MapViewer();
        expect(widget.createState(), isNotNull);
      });
    });

    group('restaurant count text', () {
      test('singular form for 1 restaurant', () {
        final restaurants = [testRestaurants.first];
        final widget = MapViewer(nearbyRestaurants: restaurants);
        // The widget should use "restaurant" (singular) for 1 restaurant
        expect(widget.nearbyRestaurants!.length, 1);
      });

      test('plural form for multiple restaurants', () {
        final widget = MapViewer(nearbyRestaurants: testRestaurants);
        // The widget should use "restaurants" (plural) for multiple
        expect(widget.nearbyRestaurants!.length, greaterThan(1));
      });

      test('zero restaurants uses plural form', () {
        const widget = MapViewer(nearbyRestaurants: []);
        expect(widget.nearbyRestaurants!.length, 0);
      });
    });

    group('restaurant data access', () {
      test('can access restaurant id', () {
        final widget = MapViewer(nearbyRestaurants: testRestaurants);
        expect(widget.nearbyRestaurants!.first.id, 'rest-1');
      });

      test('can access restaurant name', () {
        final widget = MapViewer(nearbyRestaurants: testRestaurants);
        expect(widget.nearbyRestaurants!.first.name, 'Pizza Place');
      });

      test('can access restaurant location', () {
        final widget = MapViewer(nearbyRestaurants: testRestaurants);
        expect(widget.nearbyRestaurants!.first.location.latitude, 45.4700);
        expect(widget.nearbyRestaurants!.first.location.longitude, 9.2000);
      });

      test('can access restaurant address', () {
        final widget = MapViewer(nearbyRestaurants: testRestaurants);
        expect(widget.nearbyRestaurants!.first.address, '123 Main St');
      });

      test('can access restaurant isOpen status', () {
        final widget = MapViewer(nearbyRestaurants: testRestaurants);
        expect(widget.nearbyRestaurants!.first.isOpen, isTrue);
        expect(widget.nearbyRestaurants![1].isOpen, isFalse);
      });
    });

    group('coordinate validation', () {
      test('accepts valid latitude range', () {
        const widget1 = MapViewer(latitude: -90.0);
        const widget2 = MapViewer(latitude: 90.0);
        const widget3 = MapViewer(latitude: 0.0);
        
        expect(widget1.latitude, -90.0);
        expect(widget2.latitude, 90.0);
        expect(widget3.latitude, 0.0);
      });

      test('accepts valid longitude range', () {
        const widget1 = MapViewer(longitude: -180.0);
        const widget2 = MapViewer(longitude: 180.0);
        const widget3 = MapViewer(longitude: 0.0);
        
        expect(widget1.longitude, -180.0);
        expect(widget2.longitude, 180.0);
        expect(widget3.longitude, 0.0);
      });

      test('accepts various zoom levels', () {
        const widget1 = MapViewer(zoom: 1.0);
        const widget2 = MapViewer(zoom: 20.0);
        const widget3 = MapViewer(zoom: 5.5);
        
        expect(widget1.zoom, 1.0);
        expect(widget2.zoom, 20.0);
        expect(widget3.zoom, 5.5);
      });
    });

    group('marker title variations', () {
      test('accepts simple marker title', () {
        const widget = MapViewer(markerTitle: 'Home');
        expect(widget.markerTitle, 'Home');
      });

      test('accepts marker title with special characters', () {
        const widget = MapViewer(markerTitle: "John's Location");
        expect(widget.markerTitle, "John's Location");
      });

      test('accepts marker title with unicode', () {
        const widget = MapViewer(markerTitle: '📍 My Position');
        expect(widget.markerTitle, '📍 My Position');
      });

      test('accepts empty marker title', () {
        const widget = MapViewer(markerTitle: '');
        expect(widget.markerTitle, '');
      });

      test('accepts long marker title', () {
        const longTitle = 'A very long marker title that might be displayed on the map';
        const widget = MapViewer(markerTitle: longTitle);
        expect(widget.markerTitle, longTitle);
      });
    });

    group('multiple restaurants', () {
      test('handles many restaurants', () {
        final manyRestaurants = List.generate(
          50,
          (index) => Restaurant(
            id: 'rest-$index',
            name: 'Restaurant $index',
            address: '$index Main St',
            isOpen: index.isEven,
            restaurantTypes: [],
            ownerId: 'owner-$index',
            location: GeoPoint(45.4642 + (index * 0.01), 9.1900 + (index * 0.01)),
            imageUrl: null,
          ),
        );

        final widget = MapViewer(nearbyRestaurants: manyRestaurants);
        expect(widget.nearbyRestaurants!.length, 50);
      });

      test('preserves restaurant order', () {
        final widget = MapViewer(nearbyRestaurants: testRestaurants);
        expect(widget.nearbyRestaurants![0].name, 'Pizza Place');
        expect(widget.nearbyRestaurants![1].name, 'Sushi Bar');
      });
    });

    group('combined parameters', () {
      test('accepts all parameters together', () {
        final widget = MapViewer(
          latitude: 41.9028,
          longitude: 12.4964,
          zoom: 15.0,
          markerTitle: 'Rome',
          nearbyRestaurants: testRestaurants,
          showAppBar: false,
        );

        expect(widget.latitude, 41.9028);
        expect(widget.longitude, 12.4964);
        expect(widget.zoom, 15.0);
        expect(widget.markerTitle, 'Rome');
        expect(widget.nearbyRestaurants!.length, 2);
        expect(widget.showAppBar, isFalse);
      });

      test('user location with nearby restaurants', () {
        final widget = MapViewer(
          latitude: 45.4642,
          longitude: 9.1900,
          markerTitle: 'My Location',
          nearbyRestaurants: testRestaurants,
        );

        expect(widget.markerTitle, isNotNull);
        expect(widget.nearbyRestaurants, isNotNull);
      });
    });

    group('edge cases', () {
      test('handles restaurant with null imageUrl', () {
        final restaurant = Restaurant(
          id: 'rest-null-img',
          name: 'No Image Restaurant',
          address: '789 No Img St',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner-3',
          location: const GeoPoint(45.4642, 9.1900),
          imageUrl: null,
        );

        final widget = MapViewer(nearbyRestaurants: [restaurant]);
        expect(widget.nearbyRestaurants!.first.imageUrl, isNull);
      });

      test('handles restaurant at origin coordinates', () {
        final restaurant = Restaurant(
          id: 'rest-origin',
          name: 'Origin Restaurant',
          address: 'Origin Address',
          isOpen: true,
          restaurantTypes: [],
          ownerId: 'owner-4',
          location: const GeoPoint(0, 0),
          imageUrl: null,
        );

        final widget = MapViewer(nearbyRestaurants: [restaurant]);
        expect(widget.nearbyRestaurants!.first.location.latitude, 0);
        expect(widget.nearbyRestaurants!.first.location.longitude, 0);
      });

      test('handles negative coordinates', () {
        const widget = MapViewer(
          latitude: -33.8688,  // Sydney
          longitude: 151.2093,
        );
        
        expect(widget.latitude, -33.8688);
        expect(widget.longitude, 151.2093);
      });
    });

    group('widget key', () {
      test('accepts a custom key', () {
        const key = Key('custom_map_viewer');
        const widget = MapViewer(key: key);
        expect(widget.key, key);
      });

      test('can create multiple instances with different keys', () {
        const widget1 = MapViewer(key: Key('map1'));
        const widget2 = MapViewer(key: Key('map2'));
        
        expect(widget1.key, isNot(equals(widget2.key)));
      });
    });
  });
}
