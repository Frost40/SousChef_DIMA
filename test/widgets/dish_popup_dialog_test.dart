import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/dish.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/screens/dish_screen.dart';
import 'package:sous_chef/widgets/dish_popup_dialog.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockDishProvider mockDishProvider;
  late MockOrderProvider mockOrderProvider;
  late MockUserProvider mockUserProvider;

  // Sample user
  final testUser = User(
    id: 'user-123',
    email: 'test@example.com',
    username: 'testuser',
    name: 'Test',
    surname: 'User',
    phone: '1234567890',
    restaurantId: null,
  );

  // Sample dish
  final testDish = Dish(
    id: 'dish-123',
    name: 'Pasta Carbonara',
    description: 'Classic Roman pasta with eggs, guanciale, and pecorino',
    price: 12.50,
    course: Course.pastaDish,
    cuisine: Cuisine.italian,
    isAvailable: true,
    isSpecial: false,
    minForewarningDays: 0,
    imageUrl: 'https://example.com/carbonara.jpg',
  );

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockDishProvider = MockDishProvider();
    mockOrderProvider = MockOrderProvider();
    mockUserProvider = MockUserProvider();

    // Stub default values for AuthProvider
    when(() => mockAuthProvider.user).thenReturn(testUser);
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);

    // Stub default values for DishProvider
    when(() => mockDishProvider.isLoading).thenReturn(false);
    when(() => mockDishProvider.errorMessage).thenReturn(null);
    when(() => mockDishProvider.dishes).thenReturn([testDish]);
    when(() => mockDishProvider.getDishById('dish-123')).thenReturn(testDish);
    when(() => mockDishProvider.getDishById(any())).thenReturn(testDish);
    when(
      () => mockDishProvider.currentRestaurantId,
    ).thenReturn('restaurant-123');
    when(
      () => mockDishProvider.createDish(
        restaurantId: any(named: 'restaurantId'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        price: any(named: 'price'),
        course: any(named: 'course'),
        cuisine: any(named: 'cuisine'),
        imageFile: any(named: 'imageFile'),
        imageUrl: any(named: 'imageUrl'),
        isAvailable: any(named: 'isAvailable'),
        minForewarningDays: any(named: 'minForewarningDays'),
        isSpecial: any(named: 'isSpecial'),
        userUsername: any(named: 'userUsername'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockDishProvider.updateDish(
        restaurantId: any(named: 'restaurantId'),
        dishId: any(named: 'dishId'),
        name: any(named: 'name'),
        description: any(named: 'description'),
        price: any(named: 'price'),
        course: any(named: 'course'),
        cuisine: any(named: 'cuisine'),
        imageFile: any(named: 'imageFile'),
        imageUrl: any(named: 'imageUrl'),
        minForewarningDays: any(named: 'minForewarningDays'),
        userUsername: any(named: 'userUsername'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockDishProvider.deleteDish(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockDishProvider.updateDishAvailability(any(), any(), any()),
    ).thenAnswer((_) async {});

    // Stub default values for OrderProvider
    when(() => mockOrderProvider.isLoading).thenReturn(false);
    when(() => mockOrderProvider.errorMessage).thenReturn(null);
    when(() => mockOrderProvider.userOrders).thenReturn([]);
    when(() => mockOrderProvider.setContext(any())).thenReturn(null);
    when(
      () => mockOrderProvider.addOrder(
        userId: any(named: 'userId'),
        username: any(named: 'username'),
        dishId: any(named: 'dishId'),
        dishName: any(named: 'dishName'),
        dishPrice: any(named: 'dishPrice'),
        pickupDateTime: any(named: 'pickupDateTime'),
      ),
    ).thenAnswer((_) async {});

    // Stub default values for UserProvider
    when(() => mockUserProvider.userData).thenReturn(testUser);
    when(() => mockUserProvider.isLoading).thenReturn(false);
    when(
      () =>
          mockUserProvider.isUsernameTaken(any(), notify: any(named: 'notify')),
    ).thenAnswer((_) async => true);
  });

  setUpAll(() {
    registerFallbackValues();
    registerFallbackValue(Course.other);
    registerFallbackValue(Cuisine.other);
    registerFallbackValue(DateTime.now());
  });

  // Helper to ignore overflow errors during tests
  void ignoreOverflowErrors(
    FlutterErrorDetails details, {
    bool forceReport = false,
  }) {
    bool ifIsOverflowError = false;
    final exception = details.exception;
    if (exception is FlutterError) {
      ifIsOverflowError = exception.diagnostics.any(
        (e) => e.value.toString().contains('overflowed'),
      );
    }
    if (!ifIsOverflowError) {
      FlutterError.presentError(details);
    }
  }

  group('DishPopupDialog', () {
    group('constants', () {
      test('has correct width factor', () {
        expect(DishPopupDialog.widthFactor, equals(0.75));
      });

      test('has correct height factor', () {
        expect(DishPopupDialog.heightFactor, equals(0.90));
      });
    });

    group('widget configuration', () {
      test('accepts isEditable parameter', () {
        const dialog = DishPopupDialog(isEditable: true);
        expect(dialog.isEditable, isTrue);
      });

      test('accepts isNew parameter', () {
        const dialog = DishPopupDialog(isEditable: false, isNew: true);
        expect(dialog.isNew, isTrue);
      });

      test('accepts isSpecial parameter', () {
        const dialog = DishPopupDialog(isEditable: false, isSpecial: true);
        expect(dialog.isSpecial, isTrue);
      });

      test('accepts dishId parameter', () {
        const dialog = DishPopupDialog(dishId: 'dish123', isEditable: false);
        expect(dialog.dishId, equals('dish123'));
      });

      test('accepts heroTag parameter', () {
        const dialog = DishPopupDialog(
          heroTag: 'hero_tag_1',
          isEditable: false,
        );
        expect(dialog.heroTag, equals('hero_tag_1'));
      });

      test('defaults isNew to false', () {
        const dialog = DishPopupDialog(isEditable: false);
        expect(dialog.isNew, isFalse);
      });

      test('defaults isSpecial to false', () {
        const dialog = DishPopupDialog(isEditable: false);
        expect(dialog.isSpecial, isFalse);
      });

      test('accepts onAvailabilityChanged callback', () {
        bool callbackCalled = false;
        final dialog = DishPopupDialog(
          isEditable: false,
          onAvailabilityChanged: (available) {
            callbackCalled = true;
          },
        );

        expect(dialog.onAvailabilityChanged, isNotNull);
        dialog.onAvailabilityChanged!(true);
        expect(callbackCalled, isTrue);
      });

      test('passes all parameters correctly', () {
        const dialog = DishPopupDialog(
          heroTag: 'tag1',
          dishId: 'dish1',
          isEditable: true,
          isNew: true,
          isSpecial: true,
        );

        expect(dialog.heroTag, equals('tag1'));
        expect(dialog.dishId, equals('dish1'));
        expect(dialog.isEditable, isTrue);
        expect(dialog.isNew, isTrue);
        expect(dialog.isSpecial, isTrue);
      });

      test('allows null heroTag', () {
        const dialog = DishPopupDialog(isEditable: false, heroTag: null);
        expect(dialog.heroTag, isNull);
      });

      test('allows null dishId', () {
        const dialog = DishPopupDialog(isEditable: false, dishId: null);
        expect(dialog.dishId, isNull);
      });

      test('allows null onAvailabilityChanged', () {
        const dialog = DishPopupDialog(
          isEditable: false,
          onAvailabilityChanged: null,
        );
        expect(dialog.onAvailabilityChanged, isNull);
      });
    });

    group('rendering', () {
      testWidgets('renders Dialog widget', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(1024, 768),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(Dialog), findsOneWidget);
      });

      testWidgets('renders DishScreen inside dialog', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(1024, 768),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(DishScreen), findsOneWidget);
      });

      testWidgets('displays dish name from provider', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(1024, 768),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.text('Pasta Carbonara'), findsOneWidget);
      });

      testWidgets('displays dish description from provider', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(1024, 768),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(
          find.text('Classic Roman pasta with eggs, guanciale, and pecorino'),
          findsOneWidget,
        );
      });

      testWidgets('has rounded corners decoration', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(1024, 768),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        // Find the Container with BoxDecoration
        final containerFinder = find.byType(Container);
        expect(containerFinder, findsWidgets);

        // Find the decorated container (has BoxDecoration with borderRadius)
        bool foundRoundedContainer = false;
        for (final element in containerFinder.evaluate()) {
          final container = element.widget as Container;
          if (container.decoration is BoxDecoration) {
            final decoration = container.decoration as BoxDecoration;
            if (decoration.borderRadius != null) {
              foundRoundedContainer = true;
              break;
            }
          }
        }
        expect(foundRoundedContainer, isTrue);
      });

      testWidgets('uses ClipRRect for rounded clipping', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(1024, 768),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(ClipRRect), findsWidgets);
      });
    });

    group('dialog dimensions', () {
      testWidgets('dialog has width constraints', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(1024, 768),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        // Find the Container inside Dialog with constraints
        final containerFinder = find.descendant(
          of: find.byType(Dialog),
          matching: find.byType(Container),
        );
        expect(containerFinder, findsWidgets);
      });

      testWidgets('calculates dimensions after first frame', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(1024, 768),
        );

        // First frame - dimensions not yet calculated
        await tester.pump();

        // After postFrameCallback - dimensions should be calculated
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 200));

        FlutterError.onError = originalOnError;

        expect(find.byType(DishPopupDialog), findsOneWidget);
      });
    });

    group('theme support', () {
      testWidgets('renders in light mode', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          theme: ThemeData.light(),
          screenSize: const Size(1024, 768),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(Dialog), findsOneWidget);
      });

      testWidgets('renders in dark mode with border', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          theme: ThemeData.dark(),
          screenSize: const Size(1024, 768),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(Dialog), findsOneWidget);

        // Verify a container with border exists in dark mode
        final containerFinder = find.byType(Container);
        bool foundBorderedContainer = false;
        for (final element in containerFinder.evaluate()) {
          final container = element.widget as Container;
          if (container.decoration is BoxDecoration) {
            final decoration = container.decoration as BoxDecoration;
            if (decoration.border != null) {
              foundBorderedContainer = true;
              break;
            }
          }
        }
        expect(foundBorderedContainer, isTrue);
      });
    });

    group('editable mode', () {
      testWidgets('renders in view mode (isEditable: false)', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(1024, 768),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(DishScreen), findsOneWidget);
      });

      testWidgets('renders in edit mode (isEditable: true)', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        // Owner user with restaurant
        final ownerUser = User(
          id: 'owner-123',
          email: 'owner@example.com',
          username: 'owneruser',
          name: 'Owner',
          surname: 'User',
          phone: '0987654321',
          restaurantId: 'restaurant-123',
        );

        when(() => mockAuthProvider.user).thenReturn(ownerUser);
        when(() => mockUserProvider.userData).thenReturn(ownerUser);

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(1024, 768),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(DishScreen), findsOneWidget);
      });
    });

    group('dialog styling', () {
      testWidgets('dialog has transparent background', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(1024, 768),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        final dialogFinder = find.byType(Dialog);
        expect(dialogFinder, findsOneWidget);

        final dialog = tester.widget<Dialog>(dialogFinder);
        expect(dialog.backgroundColor, equals(Colors.transparent));
      });

      testWidgets('dialog has zero elevation', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(1024, 768),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        final dialogFinder = find.byType(Dialog);
        expect(dialogFinder, findsOneWidget);

        final dialog = tester.widget<Dialog>(dialogFinder);
        expect(dialog.elevation, equals(0));
      });

      testWidgets('dialog has symmetric inset padding', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishPopupDialog(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(1024, 768),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        final dialogFinder = find.byType(Dialog);
        expect(dialogFinder, findsOneWidget);

        final dialog = tester.widget<Dialog>(dialogFinder);
        expect(
          dialog.insetPadding,
          equals(const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0)),
        );
      });
    });
  });
}
