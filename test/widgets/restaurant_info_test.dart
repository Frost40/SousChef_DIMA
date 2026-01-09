import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/restaurant_screen/restaurant_info.dart';

void main() {
  group('RestaurantInfo', () {
    test('can be instantiated with required parameters', () {
      const widget = RestaurantInfo(
        restaurantImageUrl: 'https://example.com/image.jpg',
        isOpen: true,
        isFixedMenu: true,
        isOnRequest: false,
        address: 'Via Roma 1, Milano',
        isEditable: false,
      );

      expect(widget.restaurantImageUrl, 'https://example.com/image.jpg');
      expect(widget.isOpen, isTrue);
      expect(widget.isFixedMenu, isTrue);
      expect(widget.isOnRequest, isFalse);
      expect(widget.address, 'Via Roma 1, Milano');
      expect(widget.isEditable, isFalse);
    });

    test('has null callbacks by default', () {
      const widget = RestaurantInfo(
        restaurantImageUrl: '',
        isOpen: true,
        isFixedMenu: true,
        isOnRequest: false,
        address: 'Test Address',
        isEditable: false,
      );

      expect(widget.onOpenStatusChanged, isNull);
      expect(widget.onFixedMenuToggled, isNull);
      expect(widget.onOnRequestToggled, isNull);
      expect(widget.onAddressChanged, isNull);
      expect(widget.onImageUploadPressed, isNull);
      expect(widget.onImageUrlChanged, isNull);
    });

    test('isEditable controls edit mode', () {
      const editableWidget = RestaurantInfo(
        restaurantImageUrl: '',
        isOpen: true,
        isFixedMenu: true,
        isOnRequest: false,
        address: 'Test Address',
        isEditable: true,
      );

      const nonEditableWidget = RestaurantInfo(
        restaurantImageUrl: '',
        isOpen: true,
        isFixedMenu: true,
        isOnRequest: false,
        address: 'Test Address',
        isEditable: false,
      );

      expect(editableWidget.isEditable, isTrue);
      expect(nonEditableWidget.isEditable, isFalse);
    });

    test('stores service type flags correctly', () {
      const widget = RestaurantInfo(
        restaurantImageUrl: '',
        isOpen: false,
        isFixedMenu: false,
        isOnRequest: true,
        address: 'Test Address',
        isEditable: false,
      );

      expect(widget.isOpen, isFalse);
      expect(widget.isFixedMenu, isFalse);
      expect(widget.isOnRequest, isTrue);
    });
  });
}
