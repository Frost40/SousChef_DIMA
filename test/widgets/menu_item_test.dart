import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/models/dish.dart';
import 'package:sous_chef/widgets/restaurant_screen/menu_item.dart';

void main() {
  group('MenuItem', () {
    test('can be instantiated with required parameters', () {
      final widget = MenuItem(
        dishId: 'dish-1',
        dishName: 'Margherita Pizza',
        description: 'Classic pizza',
        price: 10.0,
        course: Course.mainDish,
        cuisine: Cuisine.italian,
      );

      expect(widget.dishId, 'dish-1');
      expect(widget.dishName, 'Margherita Pizza');
      expect(widget.description, 'Classic pizza');
      expect(widget.price, 10.0);
    });

    test('has correct default values', () {
      final widget = MenuItem(
        dishId: 'dish-1',
        dishName: 'Test Dish',
        description: 'Test description',
        price: 15.0,
        course: Course.appetizer,
        cuisine: Cuisine.mexican,
      );

      expect(widget.isEditable, isFalse);
      expect(widget.isAvailable, isFalse);
      expect(widget.imageUrl, isNull);
      expect(widget.onDelete, isNull);
    });

    test('accepts imageUrl', () {
      final widget = MenuItem(
        dishId: 'dish-1',
        dishName: 'Test Dish',
        description: 'Test description',
        price: 15.0,
        course: Course.mainDish,
        cuisine: Cuisine.italian,
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(widget.imageUrl, 'https://example.com/image.jpg');
    });

    test('accepts isEditable true', () {
      final widget = MenuItem(
        dishId: 'dish-1',
        dishName: 'Test Dish',
        description: 'Test description',
        price: 15.0,
        course: Course.mainDish,
        cuisine: Cuisine.italian,
        isEditable: true,
      );

      expect(widget.isEditable, isTrue);
    });

    test('accepts isAvailable true', () {
      final widget = MenuItem(
        dishId: 'dish-1',
        dishName: 'Test Dish',
        description: 'Test description',
        price: 15.0,
        course: Course.mainDish,
        cuisine: Cuisine.italian,
        isAvailable: true,
      );

      expect(widget.isAvailable, isTrue);
    });

    test('stores course and cuisine correctly', () {
      final widget = MenuItem(
        dishId: 'dish-1',
        dishName: 'Test Dish',
        description: 'Test description',
        price: 15.0,
        course: Course.dessert,
        cuisine: Cuisine.japanese,
      );

      expect(widget.course, Course.dessert);
      expect(widget.cuisine, Cuisine.japanese);
    });
  });
}
