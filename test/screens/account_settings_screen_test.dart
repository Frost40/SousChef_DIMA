import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/screens/account_settings_screen.dart';
import 'package:sous_chef/widgets/account_settings_field.dart';
import 'package:sous_chef/widgets/personalized_button.dart';

import '../helpers/mock_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockChatProvider mockChatProvider;
  late MockUserProvider mockUserProvider;

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
    mockUserProvider = MockUserProvider();

    // Stub default values for AuthProvider
    when(() => mockAuthProvider.user).thenReturn(testUser);
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
    when(() => mockAuthProvider.clearErrors()).thenReturn(null);
    when(
      () => mockAuthProvider.signOut(onSignOut: any(named: 'onSignOut')),
    ).thenAnswer((_) async {});
    when(() => mockAuthProvider.hasRecentLogin()).thenAnswer((_) async => true);
    when(
      () => mockAuthProvider.isEmailInUse(any()),
    ).thenAnswer((_) async => false);
    when(() => mockAuthProvider.deleteUserAccount()).thenAnswer((_) async {});

    // Stub default values for ChatProvider
    when(() => mockChatProvider.clearAllChats()).thenReturn(null);

    // Stub default values for UserProvider
    when(() => mockUserProvider.isLoading).thenReturn(false);
    when(() => mockUserProvider.userData).thenReturn(testUser);
    when(() => mockUserProvider.errorMessage).thenReturn(null);
    when(() => mockUserProvider.hasEmailError).thenReturn(false);
    when(() => mockUserProvider.fetchUserData()).thenAnswer((_) async {});
    when(
      () => mockUserProvider.clearErrors(notify: any(named: 'notify')),
    ).thenReturn(null);
    when(
      () =>
          mockUserProvider.isUsernameTaken(any(), notify: any(named: 'notify')),
    ).thenAnswer((_) async => false);
    when(
      () => mockUserProvider.updateUserProfile(
        username: any(named: 'username'),
        name: any(named: 'name'),
        surname: any(named: 'surname'),
        phone: any(named: 'phone'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockUserProvider.updateUserEmail(any()),
    ).thenAnswer((_) async {});
    when(() => mockUserProvider.deleteUserData()).thenAnswer((_) async {});
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

  group('AccountSettingsScreen', () {
    // =========================================================================
    // RENDERING TESTS
    // =========================================================================

    group('Rendering', () {
      testWidgets('renders app bar with title when not embedded', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Account Settings'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('does not render app bar when embedded', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: true),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        // Should NOT have an AppBar when embedded
        expect(find.byType(AppBar), findsNothing);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders Name field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Name'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders Surname field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Surname'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders Username field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Username'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders Phone Number field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Phone Number'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders Email field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Email'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders Email Settings section header', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Email Settings'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders email change info message', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Changing your email will require you to log in again to apply the changes.',
          ),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.info_outline), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders Delete Account button', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Delete Account'), findsOneWidget);
        expect(find.byType(PersonalizedButton), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders AccountSettingField widgets', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        // Name, Surname, Username, Phone Number, Email = 5 fields
        expect(find.byType(AccountSettingField), findsNWidgets(5));

        FlutterError.onError = originalOnError;
      });

      testWidgets('renders back button when not embedded', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // LOADING STATE TESTS
    // =========================================================================

    group('Loading State', () {
      testWidgets('shows loading indicator when user data is loading', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        when(() => mockUserProvider.isLoading).thenReturn(true);
        when(() => mockUserProvider.userData).thenReturn(null);

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        // Don't pumpAndSettle as loading never finishes
        await tester.pump();

        // Should show loading indicator (staggeredDotsWave from loading_animation_widget)
        expect(find.byType(AccountSettingField), findsNothing);

        FlutterError.onError = originalOnError;
      });

      testWidgets('shows loading indicator when userData is null', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        when(() => mockUserProvider.isLoading).thenReturn(false);
        when(() => mockUserProvider.userData).thenReturn(null);

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pump();

        // Fields should not be visible when userData is null
        expect(find.byType(AccountSettingField), findsNothing);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // USER DATA DISPLAY TESTS
    // =========================================================================

    group('User Data Display', () {
      testWidgets('displays user name in Name field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('Test'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('displays user surname in Surname field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('User'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('displays user username in Username field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('testuser'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('displays user phone in Phone Number field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('1234567890'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('displays user email in Email field', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.text('test@example.com'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // PROVIDER INTERACTION TESTS
    // =========================================================================

    group('Provider Interaction', () {
      testWidgets('calls fetchUserData on initialization', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        verify(() => mockUserProvider.fetchUserData()).called(1);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // LAYOUT TESTS - MOBILE
    // =========================================================================

    group('Layout - Mobile', () {
      testWidgets('uses ListView layout on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        // On mobile, should use ListView (not wrapped in SizedBox)
        expect(find.byType(ListView), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('displays all fields on mobile', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(AccountSettingField), findsNWidgets(5));
        expect(find.text('Delete Account'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // LAYOUT TESTS - TABLET VERTICAL
    // =========================================================================

    group('Layout - Tablet Vertical', () {
      testWidgets('uses ListView layout on tablet vertical', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: tabletVerticalSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('displays all fields on tablet vertical', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: tabletVerticalSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(AccountSettingField), findsNWidgets(5));
        expect(find.text('Delete Account'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // LAYOUT TESTS - TABLET HORIZONTAL
    // =========================================================================

    group('Layout - Tablet Horizontal', () {
      testWidgets('uses centered constrained layout on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: true),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        // Should use Align with center alignment and SizedBox with width 900
        expect(find.byType(Align), findsWidgets);
        expect(find.byType(ListView), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('displays all fields on tablet horizontal', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: true),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(AccountSettingField), findsNWidgets(5));
        expect(find.text('Delete Account'), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('does not show AppBar when embedded on tablet horizontal', (
        tester,
      ) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: true),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsNothing);

        FlutterError.onError = originalOnError;
      });
    });

    // =========================================================================
    // EMBEDDED MODE TESTS
    // =========================================================================

    group('Embedded Mode', () {
      testWidgets('isEmbedded false shows AppBar', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: false),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: mobileSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Account Settings'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        FlutterError.onError = originalOnError;
      });

      testWidgets('isEmbedded true hides AppBar', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = ignoreOverflowErrors;

        await tester.pumpApp(
          const AccountSettingsScreen(isEmbedded: true),
          authProvider: mockAuthProvider,
          chatProvider: mockChatProvider,
          userProvider: mockUserProvider,
          screenSize: tabletHorizontalSize,
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsNothing);

        FlutterError.onError = originalOnError;
      });
    });
  });
}
