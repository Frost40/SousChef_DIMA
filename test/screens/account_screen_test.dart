import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/screens/account_screen.dart';
import 'package:sous_chef/screens/account_settings_screen.dart';
import 'package:sous_chef/screens/past_orders_screen.dart';
import 'package:sous_chef/widgets/account_screen/account_field.dart';
import 'package:sous_chef/widgets/account_screen/theme_switch.dart';
import 'package:sous_chef/widgets/personalized_button.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockChatProvider mockChatProvider;

  // Screen sizes for different layouts
  const mobileSize = Size(400, 800);
  const tabletVerticalSize = Size(800, 1200);
  const tabletHorizontalSize = Size(1200, 800);

  // Sample test user
  final testUser = User(
    id: 'test-user-id',
    email: 'test@example.com',
    username: 'testuser',
    name: 'Test',
    surname: 'User',
    phone: '1234567890',
  );

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockChatProvider = MockChatProvider();

    // Stub default values for AuthProvider
    when(() => mockAuthProvider.user).thenReturn(testUser);
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
    when(
      () => mockAuthProvider.signOut(onSignOut: any(named: 'onSignOut')),
    ).thenAnswer((_) async {});

    // Stub default values for ChatProvider
    when(() => mockChatProvider.clearAllChats()).thenReturn(null);
  });

  setUpAll(() {
    registerFallbackValues();
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

  group('AccountScreen', () {
    // =========================================================================
    // RENDERING TESTS
    // =========================================================================

    group('Rendering', () {
      testWidgets('renders Account title', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Account'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders Account Settings field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Account Settings'), findsOneWidget);
        expect(find.byType(AccountField), findsAtLeastNWidgets(1));

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders Past Orders field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Past Orders'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders Logout button', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Logout'), findsOneWidget);
        expect(find.byType(PersonalizedButton), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders ThemeSwitch', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(ThemeSwitch), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders settings icon for Account Settings field', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.settings), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders receipt icon for Past Orders field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // PROVIDER INTERACTION TESTS
    // =========================================================================

    group('Provider Interaction', () {
      testWidgets('renders Logout button that can be tapped', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        // Verify Logout button exists and is tappable
        final logoutButton = find.text('Logout');
        expect(logoutButton, findsOneWidget);

        // Find the AnimatedButton containing the Logout text
        expect(
          find.ancestor(
            of: logoutButton,
            matching: find.byType(GestureDetector),
          ),
          findsWidgets,
        );

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // LAYOUT TESTS - MOBILE
    // =========================================================================

    group('Layout - Mobile', () {
      testWidgets('uses single column layout on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        // On mobile, should NOT have a Row for master-detail layout
        // Should have Column layout with AccountFields
        expect(find.byType(Column), findsWidgets);
        expect(find.byType(AccountField), findsNWidgets(2));

        // Should NOT show embedded screens on mobile
        expect(find.byType(AccountSettingsScreen), findsNothing);
        expect(find.byType(PastOrdersScreen), findsNothing);

        FlutterError.onError = originalOnError;
      });

      testWidgets('does not show detail view placeholder on mobile', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        // The placeholder text should not be visible on mobile
        expect(find.text('Select an option from the menu'), findsNothing);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // LAYOUT TESTS - TABLET VERTICAL
    // =========================================================================

    group('Layout - Tablet Vertical', () {
      testWidgets('uses single column layout on tablet vertical', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletVerticalSize,
        );
        await tester.pumpAndSettle();

        // On tablet vertical, should NOT have a Row for master-detail layout
        expect(find.byType(Column), findsWidgets);
        expect(find.byType(AccountField), findsNWidgets(2));

        // Should NOT show embedded screens
        expect(find.byType(AccountSettingsScreen), findsNothing);
        expect(find.byType(PastOrdersScreen), findsNothing);

        FlutterError.onError = originalOnError;
      });

      testWidgets('does not show detail view placeholder on tablet vertical', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletVerticalSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Select an option from the menu'), findsNothing);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // LAYOUT TESTS - TABLET HORIZONTAL
    // =========================================================================

    group('Layout - Tablet Horizontal', () {
      testWidgets('uses master-detail layout on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        // On tablet horizontal, should have a Row for master-detail layout
        expect(find.byType(Row), findsWidgets);
        // Account fields should be in the left panel
        expect(find.byType(AccountField), findsNWidgets(2));

        FlutterError.onError = originalOnError;
      });

      testWidgets('shows placeholder when no option is selected', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        // Should show placeholder text
        expect(find.text('Select an option from the menu'), findsOneWidget);
        expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets(
        'shows AccountSettingsScreen when Account Settings is tapped',
        (tester) async {
          final originalOnError = FlutterError.onError;
          FlutterError.onError = ignoreOverflowErrors;

          // Need to mock UserProvider for AccountSettingsScreen
          final mockUserProvider = MockUserProvider();
          when(() => mockUserProvider.isLoading).thenReturn(false);
          when(() => mockUserProvider.userData).thenReturn(testUser);
          when(() => mockUserProvider.errorMessage).thenReturn(null);
          when(() => mockUserProvider.fetchUserData()).thenAnswer((_) async {});

          await tester.pumpApp(
            const AccountScreen(),
            authProvider: mockAuthProvider,
            chatProvider: mockChatProvider,
            userProvider: mockUserProvider,
            screenSize: tabletHorizontalSize,
          );
          await tester.pumpAndSettle();

          // Tap Account Settings
          await tester.tap(find.text('Account Settings'));
          await tester.pumpAndSettle();

          // AccountSettingsScreen should now be visible in embedded mode
          expect(find.byType(AccountSettingsScreen), findsOneWidget);
          // Placeholder should be gone
          expect(find.text('Select an option from the menu'), findsNothing);

          FlutterError.onError = originalOnError;
        },
      );

      testWidgets('shows PastOrdersScreen when Past Orders is tapped', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        // Need to mock OrderProvider for PastOrdersScreen
        final mockOrderProvider = MockOrderProvider();
        when(() => mockOrderProvider.isLoading).thenReturn(false);
        when(() => mockOrderProvider.errorMessage).thenReturn(null);
        when(
          () => mockOrderProvider.fetchUserCompletedOrders(any()),
        ).thenAnswer((_) async => []);

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        // Tap Past Orders
        await tester.tap(find.text('Past Orders'));
        await tester.pumpAndSettle();

        // PastOrdersScreen should now be visible in embedded mode
        expect(find.byType(PastOrdersScreen), findsOneWidget);
        // Placeholder should be gone
        expect(find.text('Select an option from the menu'), findsNothing);

        FlutterError.onError = originalOnError;
      });

      testWidgets('has VerticalDivider between master and detail panels', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(VerticalDivider), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('can switch between AccountSettings and PastOrders', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        // Mock both providers
        final mockUserProvider = MockUserProvider();
        when(() => mockUserProvider.isLoading).thenReturn(false);
        when(() => mockUserProvider.userData).thenReturn(testUser);
        when(() => mockUserProvider.errorMessage).thenReturn(null);
        when(() => mockUserProvider.fetchUserData()).thenAnswer((_) async {});

        final mockOrderProvider = MockOrderProvider();
        when(() => mockOrderProvider.isLoading).thenReturn(false);
        when(() => mockOrderProvider.errorMessage).thenReturn(null);
        when(
          () => mockOrderProvider.fetchUserCompletedOrders(any()),
        ).thenAnswer((_) async => []);

        await tester.pumpApp(
          const AccountScreen(),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          orderProvider: mockOrderProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        // Tap Account Settings
        await tester.tap(find.text('Account Settings'));
        await tester.pumpAndSettle();

        expect(find.byType(AccountSettingsScreen), findsOneWidget);
        expect(find.byType(PastOrdersScreen), findsNothing);

        // Tap Past Orders
        await tester.tap(find.text('Past Orders'));
        await tester.pumpAndSettle();

        expect(find.byType(AccountSettingsScreen), findsNothing);
        expect(find.byType(PastOrdersScreen), findsOneWidget);

        FlutterError.onError = originalOnError;
      });
    });
  });
}
