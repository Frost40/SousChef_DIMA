import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/dish.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/screens/dish_screen.dart';
import 'package:sous_chef/widgets/circular_button.dart';
import 'package:sous_chef/widgets/circular_number_input.dart';
import 'package:sous_chef/widgets/custom_dropdown_menu.dart';
import 'package:sous_chef/widgets/dish_screen/calendar_widget.dart';
import 'package:sous_chef/widgets/image_upload_button.dart';
import 'package:sous_chef/widgets/restaurant_screen/dish_availability_button.dart';
import 'package:sous_chef/widgets/restaurant_screen/price_tag.dart';

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

  // Sample owner user
  final testOwnerUser = User(
    id: 'owner-123',
    email: 'owner@example.com',
    username: 'owneruser',
    name: 'Owner',
    surname: 'User',
    phone: '0987654321',
    restaurantId: 'restaurant-123',
  );

  // Sample regular dish
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

  // Sample unavailable dish
  final testUnavailableDish = Dish(
    id: 'dish-unavailable',
    name: 'Seasonal Special',
    description: 'Currently not available',
    price: 18.00,
    course: Course.mainDish,
    cuisine: Cuisine.italian,
    isAvailable: false,
    isSpecial: false,
    minForewarningDays: 0,
  );

  // Sample special dish (on request)
  final testSpecialDish = Dish(
    id: 'dish-special',
    name: 'Chef Special Menu',
    description: 'Personalized menu for special occasions',
    price: 50.00,
    course: Course.other,
    cuisine: Cuisine.italian,
    isAvailable: null,
    isSpecial: true,
    minForewarningDays: 3,
    userUsername: 'specialuser',
  );

  // Sample dish with forewarning
  final testForewarningDish = Dish(
    id: 'dish-forewarning',
    name: 'Pre-Order Dish',
    description: 'Requires advance notice',
    price: 25.00,
    course: Course.mainDish,
    cuisine: Cuisine.french,
    isAvailable: true,
    isSpecial: false,
    minForewarningDays: 2,
  );

  // Sample dish without image
  final testDishNoImage = Dish(
    id: 'dish-no-image',
    name: 'Simple Salad',
    description: 'Fresh garden salad',
    price: 8.00,
    course: Course.side,
    cuisine: Cuisine.american,
    isAvailable: true,
    isSpecial: false,
    minForewarningDays: 0,
    imageUrl: null,
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
    when(
      () => mockDishProvider.getDishById('dish-unavailable'),
    ).thenReturn(testUnavailableDish);
    when(
      () => mockDishProvider.getDishById('dish-special'),
    ).thenReturn(testSpecialDish);
    when(
      () => mockDishProvider.getDishById('dish-forewarning'),
    ).thenReturn(testForewarningDish);
    when(
      () => mockDishProvider.getDishById('dish-no-image'),
    ).thenReturn(testDishNoImage);
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

  group('DishScreen', () {
    // =========================================================================
    // VIEW MODE TESTS (isEditable = false)
    // =========================================================================

    group('View Mode (Customer)', () {
      testWidgets('renders dish name', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.text('Pasta Carbonara'), findsOneWidget);
      });

      testWidgets('renders dish description', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(
          find.text('Classic Roman pasta with eggs, guanciale, and pecorino'),
          findsOneWidget,
        );
      });

      testWidgets('renders PriceTag with correct price', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(PriceTag), findsOneWidget);
      });

      testWidgets('renders DishAvailabilityButton for regular dish', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(DishAvailabilityButton), findsOneWidget);
      });

      testWidgets('renders DateTimePickerWidget for ordering', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(DateTimePickerWidget), findsOneWidget);
        expect(find.text('Select pickup date and time:'), findsOneWidget);
      });

      testWidgets('renders add to cart button', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        // Find the CircularButton with add icon
        final addButtons = find.byWidgetPredicate(
          (widget) => widget is CircularButton && widget.icon == Icons.add,
        );
        expect(addButtons, findsOneWidget);
      });

      testWidgets('displays Description label', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.text('Description:'), findsOneWidget);
      });

      testWidgets('displays Course & Cuisine label', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.text('Course & Cuisine:'), findsOneWidget);
      });

      testWidgets('renders dropdown menus for course and cuisine', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        // Should find CustomDropdownMenu widgets
        expect(find.byType(CustomDropdownMenu<Course>), findsOneWidget);
        expect(find.byType(CustomDropdownMenu<Cuisine>), findsOneWidget);
      });

      testWidgets('renders back button or close icon in AppBar', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        // Either back arrow or close icon should be present
        final hasBackOrClose =
            find.byIcon(Icons.arrow_back).evaluate().isNotEmpty ||
            find.byIcon(Icons.close).evaluate().isNotEmpty;
        expect(hasBackOrClose, isTrue);
      });

      testWidgets('renders dish image when imageUrl is provided', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(CircleAvatar), findsOneWidget);
      });

      testWidgets('renders placeholder icon when no image', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-no-image', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
      });
    });

    // =========================================================================
    // EDIT MODE TESTS (isEditable = true)
    // =========================================================================

    group('Edit Mode (Restaurant Owner)', () {
      testWidgets('renders editable name field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        // Should have a TextField with the dish name
        final textFields = find.byType(TextField);
        expect(textFields, findsWidgets);
      });

      testWidgets('renders delete button for existing dish', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: true, isNew: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        // Find the CircularButton with delete icon
        final deleteButtons = find.byWidgetPredicate(
          (widget) => widget is CircularButton && widget.icon == Icons.delete,
        );
        expect(deleteButtons, findsOneWidget);
      });

      testWidgets('renders ImageUploadButton for image editing', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(ImageUploadButton), findsOneWidget);
      });

      testWidgets('renders DishAvailabilityButton as editable', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        final availabilityButton = find.byType(DishAvailabilityButton);
        expect(availabilityButton, findsOneWidget);
      });

      testWidgets('renders CircularNumberInput for min forewarning days', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(CircularNumberInput), findsOneWidget);
      });

      testWidgets('does not render DateTimePickerWidget in edit mode', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(DateTimePickerWidget), findsNothing);
      });

      testWidgets('does not render add to cart button in edit mode', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        // Should not find add button
        final addButtons = find.byWidgetPredicate(
          (widget) => widget is CircularButton && widget.icon == Icons.add,
        );
        expect(addButtons, findsNothing);
      });

      testWidgets('renders editable price field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        // Should find euro symbol indicating editable price
        expect(find.text('€'), findsOneWidget);
      });
    });

    // =========================================================================
    // NEW DISH MODE TESTS
    // =========================================================================

    group('New Dish Mode', () {
      testWidgets('renders empty fields for new dish', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(isEditable: true, isNew: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        // Should have TextField widgets for input
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('does not render delete button for new dish', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(isEditable: true, isNew: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        // Should not find delete button
        final deleteButtons = find.byWidgetPredicate(
          (widget) => widget is CircularButton && widget.icon == Icons.delete,
        );
        expect(deleteButtons, findsNothing);
      });

      testWidgets('renders ImageUploadButton for new dish', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(isEditable: true, isNew: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(ImageUploadButton), findsOneWidget);
      });

      testWidgets('renders course and cuisine dropdowns for new dish', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(isEditable: true, isNew: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(CustomDropdownMenu<Course>), findsOneWidget);
        expect(find.byType(CustomDropdownMenu<Cuisine>), findsOneWidget);
      });
    });

    // =========================================================================
    // SPECIAL DISH TESTS
    // =========================================================================

    group('Special Dish Mode', () {
      testWidgets('renders username field for special dish in edit mode', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(
            dishId: 'dish-special',
            isEditable: true,
            isSpecial: true,
          ),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.text('Select the username:'), findsOneWidget);
      });

      testWidgets('does not render availability button for special dish', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(
            dishId: 'dish-special',
            isEditable: false,
            isSpecial: true,
          ),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        // Special dishes don't have availability button
        expect(find.byType(DishAvailabilityButton), findsNothing);
      });

      testWidgets('renders info text for special dish username', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(
            dishId: 'dish-special',
            isEditable: true,
            isSpecial: true,
          ),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(
          find.text(
            'Enter the username of the user for whom the dish is created.',
          ),
          findsOneWidget,
        );
      });
    });

    // =========================================================================
    // HERO ANIMATION TESTS
    // =========================================================================

    group('Hero Animation', () {
      testWidgets('renders Hero widget when heroTag is provided', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(
            dishId: 'dish-123',
            isEditable: false,
            heroTag: 'dish-hero-123',
          ),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(Hero), findsOneWidget);
      });

      testWidgets('does not render Hero when heroTag is null', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(
            dishId: 'dish-123',
            isEditable: false,
            heroTag: null,
          ),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(Hero), findsNothing);
      });
    });

    // =========================================================================
    // TABLET MODE TESTS
    // =========================================================================

    group('Tablet Mode', () {
      testWidgets('renders close icon instead of back arrow on tablet', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(1024, 768), // Tablet landscape
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.close), findsOneWidget);
      });

      testWidgets('renders back arrow on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          screenSize: const Size(375, 812), // Mobile
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });

    // =========================================================================
    // INTERACTION TESTS
    // =========================================================================

    group('Interactions', () {
      testWidgets('can tap navigation button to navigate back', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        final mockObserver = MockNavigatorObserver();

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
          navigatorObserver: mockObserver,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Find either back or close icon
        final backButton = find.byIcon(Icons.arrow_back);
        final closeButton = find.byIcon(Icons.close);

        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
        } else if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
        }
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        // Navigation should be triggered
        verify(() => mockObserver.didPop(any(), any())).called(1);
      });

      testWidgets('can enter text in name field when editable', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Find the TextField containing the dish name
        final nameField = find.widgetWithText(TextField, 'Pasta Carbonara');
        expect(nameField, findsOneWidget);

        // Clear and enter new text
        await tester.enterText(nameField, 'New Dish Name');
        await tester.pump();

        FlutterError.onError = originalOnError;

        expect(find.text('New Dish Name'), findsOneWidget);
      });

      testWidgets('can enter text in description field when editable', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Find the description TextField (multiline)
        final descField = find.widgetWithText(
          TextField,
          'Classic Roman pasta with eggs, guanciale, and pecorino',
        );
        expect(descField, findsOneWidget);

        // Clear and enter new text
        await tester.enterText(descField, 'New description');
        await tester.pump();

        FlutterError.onError = originalOnError;

        expect(find.text('New description'), findsOneWidget);
      });

      testWidgets('delete button calls deleteDish', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: true, isNew: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Find and tap delete button
        final deleteButton = find.byWidgetPredicate(
          (widget) => widget is CircularButton && widget.icon == Icons.delete,
        );
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;

        verify(
          () => mockDishProvider.deleteDish('restaurant-123', 'dish-123'),
        ).called(1);
      });
    });

    // =========================================================================
    // SCAFFOLD TESTS
    // =========================================================================

    group('Scaffold Configuration', () {
      testWidgets('has transparent AppBar background', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, Colors.transparent);
      });

      testWidgets('uses SingleChildScrollView for content', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('extends body behind AppBar', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: false),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.extendBodyBehindAppBar, isTrue);
      });
    });

    // =========================================================================
    // GESTURE DETECTOR TESTS
    // =========================================================================

    group('GestureDetector', () {
      testWidgets('wraps Scaffold with GestureDetector', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const DishScreen(dishId: 'dish-123', isEditable: true),
          authProvider: mockAuthProvider,
          dishProvider: mockDishProvider,
          orderProvider: mockOrderProvider,
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        FlutterError.onError = originalOnError;

        expect(find.byType(GestureDetector), findsWidgets);
      });
    });
  });
}
