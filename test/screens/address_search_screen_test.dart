import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/screens/address_search_screen.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

// Fake Route for mocktail registerFallbackValue
class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockUserProvider mockUserProvider;

  setUpAll(() async {
    // Register fallback values for mocktail
    registerFallbackValue(FakeRoute());
    // Load dotenv for Google Maps API key
    await dotenv.load(fileName: '.env');
  });

  setUp(() {
    mockUserProvider = MockUserProvider();

    // Stub default values for UserProvider
    when(() => mockUserProvider.userData).thenReturn(null);
    when(() => mockUserProvider.isLoading).thenReturn(false);
    when(() => mockUserProvider.errorMessage).thenReturn(null);
    when(
      () => mockUserProvider.updateUserAddress(
        address: any(named: 'address'),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((_) async {});
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

  group('AddressSearchScreen', () {
    // =========================================================================
    // RENDERING TESTS
    // =========================================================================

    group('Rendering', () {
      testWidgets('renders app bar with title "Search for address"', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Search for address'), findsOneWidget);
      });

      testWidgets('renders back button in app bar', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('renders search text field with hint', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Enter your address...'), findsOneWidget);
      });

      testWidgets('renders search icon in text field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('renders placeholder with location icon', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
      });

      testWidgets('renders "Start typing to search" placeholder text', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Start typing to search'), findsOneWidget);
      });
    });

    // =========================================================================
    // APP BAR TESTS
    // =========================================================================

    group('AppBar', () {
      testWidgets('app bar is centered', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.centerTitle, isTrue);
      });

      testWidgets('back button pops navigator when tapped', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        final mockObserver = MockNavigatorObserver();

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
          navigatorObserver: mockObserver,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;

        // Verify navigator pop was called
        verify(() => mockObserver.didPop(any(), any())).called(greaterThan(0));
      });
    });

    // =========================================================================
    // RESTAURANT MODE TESTS
    // =========================================================================

    group('Restaurant Mode', () {
      testWidgets('renders same UI when isForRestaurant is true', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(isForRestaurant: true),
          userProvider: mockUserProvider,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Search for address'), findsOneWidget);
        expect(find.text('Enter your address...'), findsOneWidget);
      });
    });

    // =========================================================================
    // LAYOUT TESTS - Mobile, Tablet Vertical, Tablet Horizontal
    // =========================================================================
    // Layout detection:
    // - Mobile: shortestSide < 600
    // - Tablet Vertical: shortestSide >= 600 && portrait
    // - Tablet Horizontal: shortestSide >= 600 && landscape
    // =========================================================================

    group('Layout - Mobile (shortestSide < 600)', () {
      // Mobile size: 500x900 (shortestSide = 500 < 600)
      const mobileSize = Size(500, 900);

      testWidgets('renders app bar with title on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Search for address'), findsOneWidget);
      });

      testWidgets('renders search field on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Enter your address...'), findsOneWidget);
      });

      testWidgets('renders placeholder on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Start typing to search'), findsOneWidget);
      });
    });

    group('Layout - Tablet Vertical (shortestSide >= 600, portrait)', () {
      // Tablet vertical size: 700x1000 (shortestSide = 700, portrait)
      const tabletVerticalSize = Size(700, 1000);

      testWidgets('renders app bar with title on tablet vertical', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Search for address'), findsOneWidget);
      });

      testWidgets('renders search field on tablet vertical', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Enter your address...'), findsOneWidget);
      });

      testWidgets('renders placeholder on tablet vertical', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
          screenSize: tabletVerticalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Start typing to search'), findsOneWidget);
      });
    });

    group('Layout - Tablet Horizontal (shortestSide >= 600, landscape)', () {
      // Tablet horizontal size: 1024x700 (shortestSide = 700, landscape)
      const tabletHorizontalSize = Size(1024, 700);

      testWidgets('renders app bar with title on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Search for address'), findsOneWidget);
      });

      testWidgets(
        'renders centered content with limited width on tablet horizontal',
        (tester) async {
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;

          await tester.pumpApp(
            const AddressSearchScreen(),
            userProvider: mockUserProvider,
            screenSize: tabletHorizontalSize,
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          FlutterError.onError = originalOnError;

          // Should have Align widget for centering
          expect(find.byType(Align), findsWidgets);
        },
      );

      testWidgets('tablet horizontal layout uses SizedBox with width 900', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        // Find SizedBox with width 900 for tablet horizontal
        final sizedBoxFinder = find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.width == 900,
        );
        expect(sizedBoxFinder, findsOneWidget);
      });

      testWidgets('renders search field on tablet horizontal', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Enter your address...'), findsOneWidget);
      });

      testWidgets('renders placeholder on tablet horizontal', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AddressSearchScreen(),
          userProvider: mockUserProvider,
          screenSize: tabletHorizontalSize,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        FlutterError.onError = originalOnError;

        expect(find.text('Start typing to search'), findsOneWidget);
      });
    });
  });
}
