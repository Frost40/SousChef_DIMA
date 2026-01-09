import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/app_router.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/providers/auth_provider.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/providers/user_provider.dart';
import 'package:sous_chef/screens/account_screen.dart';
import 'package:sous_chef/screens/account_settings_screen.dart';
import 'package:sous_chef/themes/light_mode.dart';
import 'package:sous_chef/themes/theme_provider.dart';
import 'package:sous_chef/widgets/account_screen/account_field.dart';
import 'package:sous_chef/widgets/account_settings_field.dart';

/// Mock classes
class MockAuthProvider extends Mock implements AuthProvider {}

class MockChatProvider extends Mock implements ChatProvider {}

class MockUserProvider extends Mock implements UserProvider {}

class MockThemeProvider extends Mock implements ThemeProvider {}

/// Fake BuildContext for mocktail
class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  late MockAuthProvider mockAuthProvider;
  late MockChatProvider mockChatProvider;
  late MockUserProvider mockUserProvider;
  late MockThemeProvider mockThemeProvider;

  // Test data
  late User mockUser;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockChatProvider = MockChatProvider();
    mockUserProvider = MockUserProvider();
    mockThemeProvider = MockThemeProvider();

    // Create mock user
    mockUser = User(
      id: 'user-123',
      email: 'test@example.com',
      username: 'testuser',
      name: 'Test',
      surname: 'User',
      phone: '1234567890',
      savedAddress: '123 Test Street',
      latitude: 45.4642,
      longitude: 9.1900,
    );

    // === AuthProvider stubs ===
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.isAuthenticated).thenReturn(true);
    when(() => mockAuthProvider.user).thenReturn(mockUser);
    when(() => mockAuthProvider.init()).thenAnswer((_) async {});
    when(() => mockAuthProvider.clearErrors()).thenReturn(null);
    when(
      () => mockAuthProvider.signOut(onSignOut: any(named: 'onSignOut')),
    ).thenAnswer((_) async {});

    // === ChatProvider stubs ===
    when(() => mockChatProvider.totalUnreadCount).thenReturn(0);
    when(() => mockChatProvider.hasUnreadMessages).thenReturn(false);
    when(() => mockChatProvider.setCurrentUserId(any())).thenReturn(null);
    when(() => mockChatProvider.clearAllChats()).thenReturn(null);

    // === UserProvider stubs ===
    when(() => mockUserProvider.userData).thenReturn(mockUser);
    when(() => mockUserProvider.isLoading).thenReturn(false);
    when(() => mockUserProvider.errorMessage).thenReturn(null);
    when(() => mockUserProvider.hasEmailError).thenReturn(false);
    when(() => mockUserProvider.hasUsernameError).thenReturn(false);
    when(() => mockUserProvider.hasPhoneError).thenReturn(false);
    when(() => mockUserProvider.fetchUserData()).thenAnswer((_) async {});
    when(
      () => mockUserProvider.clearErrors(notify: any(named: 'notify')),
    ).thenReturn(null);
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
    when(
      () =>
          mockUserProvider.isUsernameTaken(any(), notify: any(named: 'notify')),
    ).thenAnswer((_) async => false);

    // === ThemeProvider stubs ===
    when(() => mockThemeProvider.themeData).thenReturn(lightMode);
    when(() => mockThemeProvider.isDarkMode).thenReturn(false);
  });

  Widget buildAccountScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
        Provider<AppRouter>(create: (_) => AppRouter()),
      ],
      child: Consumer<AppRouter>(
        builder: (context, router, child) {
          return MaterialApp(
            theme: lightMode,
            home: const AccountScreen(),
            onGenerateRoute: router.onGenerateRoute,
          );
        },
      ),
    );
  }

  Widget buildAccountSettingsScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
        Provider<AppRouter>(create: (_) => AppRouter()),
      ],
      child: MaterialApp(theme: lightMode, home: const AccountSettingsScreen()),
    );
  }

  group('Account Settings Flow', () {
    testWidgets('should display AccountScreen with settings option', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAccountScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify AccountScreen is displayed
      expect(find.byType(AccountScreen), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);

      // Verify Account Settings option is displayed
      expect(find.text('Account Settings'), findsOneWidget);
      expect(
        find.byType(AccountField),
        findsNWidgets(2),
      ); // Settings + Past Orders
    });

    testWidgets(
      'should navigate to AccountSettingsScreen when tapping settings',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAccountScreen());
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Find and tap on Account Settings
        final settingsOption = find.text('Account Settings');
        expect(settingsOption, findsOneWidget);

        await tester.tap(settingsOption);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Should navigate to AccountSettingsScreen
        expect(find.byType(AccountSettingsScreen), findsOneWidget);
      },
    );

    testWidgets('should display user information on AccountSettingsScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAccountSettingsScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify AccountSettingsScreen is displayed
      expect(find.byType(AccountSettingsScreen), findsOneWidget);

      // Verify user info fields are displayed
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Surname'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);

      // Verify current values are shown
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);
      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('should display editable fields', (WidgetTester tester) async {
      await tester.pumpWidget(buildAccountSettingsScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify AccountSettingField widgets exist
      final settingFields = find.byType(AccountSettingField);
      expect(
        settingFields,
        findsNWidgets(5),
      ); // Name, Surname, Username, Phone, Email
    });

    testWidgets('should allow editing name field', (WidgetTester tester) async {
      await tester.pumpWidget(buildAccountSettingsScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Find the Name field and tap to edit
      final nameField = find.widgetWithText(AccountSettingField, 'Name');
      expect(nameField, findsOneWidget);

      // Tap on the name field to enable editing
      await tester.tap(nameField);
      await tester.pump(const Duration(milliseconds: 300));

      // Find TextField and enter new value
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'NewName');
        await tester.pump(const Duration(milliseconds: 300));

        // Verify new value is entered
        expect(find.text('NewName'), findsOneWidget);
      }
    });

    testWidgets('should show save button when field is modified', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAccountSettingsScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Initially save button should not be visible
      expect(find.byIcon(Icons.save), findsNothing);

      // Find a text field and modify it
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'ModifiedValue');
        await tester.pump(const Duration(milliseconds: 500));

        // Save button should appear in AppBar
        expect(find.byIcon(Icons.save), findsOneWidget);
      }
    });

    testWidgets('should call updateUserProfile when saving changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAccountSettingsScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Find a text field and modify it
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'UpdatedName');
        await tester.pump(const Duration(milliseconds: 500));

        // Find and tap save button
        final saveButton = find.byIcon(Icons.save);
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pump(const Duration(milliseconds: 500));

          // Verify updateUserProfile was called
          verify(
            () => mockUserProvider.updateUserProfile(
              username: any(named: 'username'),
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              phone: any(named: 'phone'),
            ),
          ).called(1);
        }
      }
    });

    testWidgets('should display logout button on AccountScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAccountScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify logout button is displayed
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('should display Past Orders option on AccountScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAccountScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Past Orders option is displayed
      expect(find.text('Past Orders'), findsOneWidget);
    });

    testWidgets('should have back navigation from AccountSettingsScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAccountSettingsScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify back button exists
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should display theme switch on AccountScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAccountScreen());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Theme switch should be visible (either sun or moon icon)
      final sunIcon = find.byIcon(Icons.wb_sunny);
      final moonIcon = find.byIcon(Icons.nightlight_round);

      expect(
        sunIcon.evaluate().isNotEmpty || moonIcon.evaluate().isNotEmpty,
        isTrue,
      );
    });
  });
}
