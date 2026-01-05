import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/home_screen/map_viewer.dart';

void main() {
  group('MapViewer', () {
    testWidgets('has correct default latitude (Milano)', (tester) async {
      const widget = MapViewer();

      expect(widget.latitude, 45.4642);
    });

    testWidgets('has correct default longitude (Milano)', (tester) async {
      const widget = MapViewer();

      expect(widget.longitude, 9.1900);
    });

    testWidgets('has correct default zoom', (tester) async {
      const widget = MapViewer();

      expect(widget.zoom, 12.0);
    });

    testWidgets('has showAppBar default to true', (tester) async {
      const widget = MapViewer();

      expect(widget.showAppBar, isTrue);
    });

    testWidgets('accepts custom coordinates', (tester) async {
      const widget = MapViewer(latitude: 41.9028, longitude: 12.4964);

      expect(widget.latitude, 41.9028);
      expect(widget.longitude, 12.4964);
    });

    testWidgets('accepts custom zoom', (tester) async {
      const widget = MapViewer(zoom: 15.0);

      expect(widget.zoom, 15.0);
    });

    testWidgets('accepts marker title', (tester) async {
      const widget = MapViewer(markerTitle: 'My Location');

      expect(widget.markerTitle, 'My Location');
    });

    testWidgets('accepts showAppBar false', (tester) async {
      const widget = MapViewer(showAppBar: false);

      expect(widget.showAppBar, isFalse);
    });

    testWidgets('nearbyRestaurants defaults to null', (tester) async {
      const widget = MapViewer();

      expect(widget.nearbyRestaurants, isNull);
    });
  });
}
