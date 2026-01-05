import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/widgets/dish_popup_dialog.dart';

void main() {
  group('DishPopupDialog', () {
    group('constants', () {
      testWidgets('has correct width factor', (tester) async {
        // Assert
        expect(DishPopupDialog.widthFactor, equals(0.75));
      });

      testWidgets('has correct height factor', (tester) async {
        // Assert
        expect(DishPopupDialog.heightFactor, equals(0.90));
      });
    });

    group('widget configuration', () {
      testWidgets('accepts isEditable parameter', (tester) async {
        // This just tests the widget can be constructed - not rendered
        // because DishScreen requires complex provider setup
        const dialog = DishPopupDialog(isEditable: true);
        expect(dialog.isEditable, isTrue);
      });

      testWidgets('accepts isNew parameter', (tester) async {
        const dialog = DishPopupDialog(isEditable: false, isNew: true);
        expect(dialog.isNew, isTrue);
      });

      testWidgets('accepts isSpecial parameter', (tester) async {
        const dialog = DishPopupDialog(isEditable: false, isSpecial: true);
        expect(dialog.isSpecial, isTrue);
      });

      testWidgets('accepts dishId parameter', (tester) async {
        const dialog = DishPopupDialog(dishId: 'dish123', isEditable: false);
        expect(dialog.dishId, equals('dish123'));
      });

      testWidgets('accepts heroTag parameter', (tester) async {
        const dialog = DishPopupDialog(
          heroTag: 'hero_tag_1',
          isEditable: false,
        );
        expect(dialog.heroTag, equals('hero_tag_1'));
      });

      testWidgets('defaults isNew to false', (tester) async {
        const dialog = DishPopupDialog(isEditable: false);
        expect(dialog.isNew, isFalse);
      });

      testWidgets('defaults isSpecial to false', (tester) async {
        const dialog = DishPopupDialog(isEditable: false);
        expect(dialog.isSpecial, isFalse);
      });
    });
  });
}
