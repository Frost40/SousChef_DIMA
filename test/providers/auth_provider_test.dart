import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:sous_chef/providers/auth_provider.dart';
import '../mocks/mock_services.dart';
import '../mocks/mock_models.dart';

/// Mock class for Firebase User (used for auth state changes)
class MockFirebaseUser extends Mock implements firebase_auth.User {}

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late MockAuthentication mockAuth;
    late MockUserFirestore mockUserFirestore;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(MockModels.createMockUser());
    });

    setUp(() {
      mockAuth = MockAuthentication();
      mockUserFirestore = MockUserFirestore();

      // Stub the authStateChanges stream to prevent errors during initialization
      when(() => mockAuth.authStateChanges).thenAnswer(
        (_) => Stream<firebase_auth.User?>.empty(),
      );

      // Stub getCurrentUser to return null (no user logged in initially)
      when(() => mockAuth.getCurrentUser()).thenAnswer((_) async => null);

      // Create AuthProvider with injected mocks
      authProvider = AuthProvider(
        auth: mockAuth,
        userFirestore: mockUserFirestore,
      );
    });

    group('Initialization', () {
      test('init should load current user and notify listeners', () async {
        // Arrange
        final mockUser = MockModels.createMockUser(
          id: 'init-user',
          email: 'init@example.com',
        );
        when(() => mockAuth.getCurrentUser()).thenAnswer((_) async => mockUser);

        var notifyCount = 0;
        authProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await authProvider.init();

        // Assert
        expect(authProvider.user, isNotNull);
        expect(authProvider.user?.id, 'init-user');
        expect(notifyCount, greaterThan(0));
      });

      test('should update user when auth state changes to logged in', () async {
        // Arrange
        final mockUser = MockModels.createMockUser(
          id: 'stream-user',
          email: 'stream@example.com',
        );

        // Create a stream controller to simulate auth state changes
        final streamController =
            StreamController<firebase_auth.User?>.broadcast();

        when(() => mockAuth.authStateChanges)
            .thenAnswer((_) => streamController.stream);
        when(() => mockAuth.getCurrentUser()).thenAnswer((_) async => mockUser);

        // Create new provider with the stream
        final streamAuthProvider = AuthProvider(
          auth: mockAuth,
          userFirestore: mockUserFirestore,
        );

        // Act - simulate auth state change
        streamController.add(MockFirebaseUser());

        // Allow stream to process
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(streamAuthProvider.user, isNotNull);

        // Cleanup
        streamAuthProvider.dispose();
        await streamController.close();
      });

      test('should clear user when auth state changes to logged out', () async {
        // Arrange
        final streamController =
            StreamController<firebase_auth.User?>.broadcast();

        when(() => mockAuth.authStateChanges)
            .thenAnswer((_) => streamController.stream);
        when(() => mockAuth.getCurrentUser()).thenAnswer((_) async => null);

        // Create new provider with the stream
        final streamAuthProvider = AuthProvider(
          auth: mockAuth,
          userFirestore: mockUserFirestore,
        );

        // Act - simulate auth state change to null (logged out)
        streamController.add(null);

        // Allow stream to process
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(streamAuthProvider.user, null);
        expect(streamAuthProvider.isAuthenticated, false);

        // Cleanup
        streamAuthProvider.dispose();
        await streamController.close();
      });
    });

    tearDown(() {
      authProvider.dispose();
    });

    group('State Management', () {
      test('initial state should be not authenticated and not loading', () {
        expect(authProvider.isAuthenticated, false);
        expect(authProvider.isLoading, false);
        expect(authProvider.errorMessage, null);
        expect(authProvider.user, null);
      });

      test('should have no error flags initially', () {
        expect(authProvider.hasEmailError, false);
        expect(authProvider.hasPasswordError, false);
        expect(authProvider.hasUsernameError, false);
        expect(authProvider.hasRestaurantnameError, false);
        expect(authProvider.hasConfirmPasswordError, false);
      });
    });

    group('signIn', () {
      test('should set user and isAuthenticated to true on successful sign in', () async {
        // Arrange
        final mockUser = MockModels.createMockUser(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
        );

        when(() => mockAuth.signIn(any(), any()))
            .thenAnswer((_) async => mockUser);

        // Act
        await authProvider.signIn('test@example.com', 'password123');

        // Assert
        expect(authProvider.isAuthenticated, true);
        expect(authProvider.user, isNotNull);
        expect(authProvider.user?.id, 'user123');
        expect(authProvider.user?.email, 'test@example.com');
        expect(authProvider.isLoading, false);
        expect(authProvider.errorMessage, null);

        // Verify service was called correctly
        verify(() => mockAuth.signIn('test@example.com', 'password123')).called(1);
      });

      test('should set error message on failed sign in', () async {
        // Arrange
        when(() => mockAuth.signIn(any(), any()))
            .thenThrow(Exception('Authentication failed'));

        // Act
        await authProvider.signIn('test@example.com', 'wrongpassword');

        // Assert
        expect(authProvider.isAuthenticated, false);
        expect(authProvider.user, null);
        expect(authProvider.isLoading, false);
        expect(authProvider.errorMessage, isNotNull);
      });

      test('should set email error flag for FirebaseAuthException with user-not-found', () async {
        // Arrange
        when(() => mockAuth.signIn(any(), any())).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'user-not-found',
            message: 'User not found',
          ),
        );

        // Act
        await authProvider.signIn('nonexistent@example.com', 'password123');

        // Assert
        expect(authProvider.hasEmailError, true);
        expect(authProvider.errorMessage, 'User not found');
      });

      test('should set password error flag for wrong password', () async {
        // Arrange
        when(() => mockAuth.signIn(any(), any())).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'wrong-password',
            message: 'Wrong password',
          ),
        );

        // Act
        await authProvider.signIn('test@example.com', 'wrongpassword');

        // Assert
        expect(authProvider.hasPasswordError, true);
        expect(authProvider.errorMessage, 'Incorrect password');
      });

      test('should set email error flag for invalid-email', () async {
        // Arrange
        when(() => mockAuth.signIn(any(), any())).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'invalid-email',
            message: 'Invalid email',
          ),
        );

        // Act
        await authProvider.signIn('invalid-email', 'password123');

        // Assert
        expect(authProvider.hasEmailError, true);
        expect(authProvider.errorMessage, 'Invalid email format');
      });

      test('should handle invalid-credential error', () async {
        // Arrange
        when(() => mockAuth.signIn(any(), any())).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'invalid-credential',
            message: 'Invalid credential',
          ),
        );

        // Act
        await authProvider.signIn('test@example.com', 'password123');

        // Assert
        expect(authProvider.errorMessage, 'Invalid credentials');
      });

      test('should handle unknown FirebaseAuthException error code', () async {
        // Arrange
        when(() => mockAuth.signIn(any(), any())).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'unknown-error-code',
            message: 'Some unknown error',
          ),
        );

        // Act
        await authProvider.signIn('test@example.com', 'password123');

        // Assert
        expect(authProvider.errorMessage, 'Error: Some unknown error');
      });
    });

    group('signUp', () {
      test('should create user and set authenticated state on success', () async {
        // Arrange
        final mockUser = MockModels.createMockUser(
          id: 'newuser123',
          email: 'new@example.com',
          username: 'newuser',
        );

        when(() => mockUserFirestore.isUsernameTaken(any()))
            .thenAnswer((_) async => false);
        when(() => mockAuth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
              restaurantId: any(named: 'restaurantId'),
            )).thenAnswer((_) async => mockUser);

        // Act
        await authProvider.signUp(
          email: 'new@example.com',
          password: 'password123',
          username: 'newuser',
        );

        // Assert
        expect(authProvider.isAuthenticated, true);
        expect(authProvider.user, isNotNull);
        expect(authProvider.user?.id, 'newuser123');
        expect(authProvider.isLoading, false);
        expect(authProvider.errorMessage, null);
      });

      test('should set username error when username is already taken', () async {
        // Arrange
        when(() => mockUserFirestore.isUsernameTaken(any()))
            .thenAnswer((_) async => true);

        // Act
        await authProvider.signUp(
          email: 'test@example.com',
          password: 'password123',
          username: 'takenusername',
        );

        // Assert
        expect(authProvider.hasUsernameError, true);
        expect(authProvider.errorMessage, 'Username is already taken');
        expect(authProvider.isAuthenticated, false);
      });

      test('should handle email already in use error', () async {
        // Arrange
        when(() => mockUserFirestore.isUsernameTaken(any()))
            .thenAnswer((_) async => false);
        when(() => mockAuth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
              restaurantId: any(named: 'restaurantId'),
            )).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'Email already in use',
          ),
        );

        // Act
        await authProvider.signUp(
          email: 'existing@example.com',
          password: 'password123',
          username: 'newuser',
        );

        // Assert
        expect(authProvider.hasEmailError, true);
        expect(authProvider.errorMessage, 'Email already in use');
      });

      test('should handle weak-password error', () async {
        // Arrange
        when(() => mockUserFirestore.isUsernameTaken(any()))
            .thenAnswer((_) async => false);
        when(() => mockAuth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
              restaurantId: any(named: 'restaurantId'),
            )).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'weak-password',
            message: 'Password is too weak',
          ),
        );

        // Act
        await authProvider.signUp(
          email: 'test@example.com',
          password: '123',
          username: 'newuser',
        );

        // Assert
        expect(authProvider.hasPasswordError, true);
        expect(authProvider.errorMessage, 'Password is too weak');
      });
    });

    group('signOut', () {
      test('should clear user and set authenticated to false', () async {
        // Arrange - First sign in
        final mockUser = MockModels.createMockUser();
        when(() => mockAuth.signIn(any(), any()))
            .thenAnswer((_) async => mockUser);
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        await authProvider.signIn('test@example.com', 'password123');
        expect(authProvider.isAuthenticated, true);

        // Act
        await authProvider.signOut();

        // Assert
        expect(authProvider.user, null);
        expect(authProvider.isAuthenticated, false);
        verify(() => mockAuth.signOut()).called(1);
      });

      test('should call onSignOut callback if provided', () async {
        // Arrange
        when(() => mockAuth.signOut()).thenAnswer((_) async {});
        var callbackCalled = false;

        // Act
        await authProvider.signOut(onSignOut: () {
          callbackCalled = true;
        });

        // Assert
        expect(callbackCalled, true);
      });
    });

    group('Error Handling', () {
      test('clearErrors should reset all error states', () {
        // Setup: Set some errors
        authProvider.setFieldErrors(
          emptyEmail: true,
          emptyPassword: true,
          emptyUsername: true,
        );

        // Verify errors are set
        expect(authProvider.hasEmailError, true);
        expect(authProvider.hasPasswordError, true);
        expect(authProvider.hasUsernameError, true);
        expect(authProvider.errorMessage, isNotNull);

        // Action: Clear errors
        authProvider.clearErrors();

        // Assert: All errors should be false
        expect(authProvider.hasEmailError, false);
        expect(authProvider.hasPasswordError, false);
        expect(authProvider.hasUsernameError, false);
        expect(authProvider.errorMessage, null);
      });

      test('setFieldErrors should set specific field errors', () {
        // Action: Set specific errors
        authProvider.setFieldErrors(
          emptyEmail: true,
          emptyPassword: false,
          emptyUsername: true,
        );

        // Assert: Only specified fields should be true
        expect(authProvider.hasEmailError, true);
        expect(authProvider.hasPasswordError, false);
        expect(authProvider.hasUsernameError, true);
      });

      test('setFieldErrors should create correct error message', () {
        // Action: Set multiple errors
        authProvider.setFieldErrors(
          emptyEmail: true,
          emptyPassword: true,
        );

        // Assert: Error message should include both fields
        expect(authProvider.errorMessage, contains('Email'));
        expect(authProvider.errorMessage, contains('Password'));
        expect(authProvider.errorMessage, contains('cannot be empty'));
      });

      test('setFieldErrors should handle invalidEmail error', () {
        // Action
        authProvider.setFieldErrors(
          invalidEmail: true,
        );

        // Assert
        expect(authProvider.hasEmailError, true);
        expect(authProvider.errorMessage, contains('Invalid email format'));
      });

      test('setFieldErrors should handle invalidPassword error', () {
        // Action
        authProvider.setFieldErrors(
          invalidPassword: true,
        );

        // Assert
        expect(authProvider.hasPasswordError, true);
        expect(authProvider.errorMessage,
            contains('Password must have at least 7 characters'));
      });

      test('setFieldErrors should handle invalidConfirmPassword error', () {
        // Action
        authProvider.setFieldErrors(
          invalidConfirmPassword: true,
        );

        // Assert
        expect(authProvider.hasConfirmPasswordError, true);
        expect(authProvider.errorMessage,
            contains('Confirm Password is different from the password chosen'));
      });

      test('setFieldErrors should handle emptyConfirmPassword error', () {
        // Action
        authProvider.setFieldErrors(
          emptyConfirmPassword: true,
        );

        // Assert
        expect(authProvider.hasConfirmPasswordError, true);
        expect(authProvider.errorMessage, contains('Confirm Password'));
        expect(authProvider.errorMessage, contains('cannot be empty'));
      });

      test('setFieldErrors should handle emptyRestaurantname error', () {
        // Action
        authProvider.setFieldErrors(
          emptyRestaurantname: true,
        );

        // Assert
        expect(authProvider.hasRestaurantnameError, true);
        expect(authProvider.errorMessage, contains('Restaurant name'));
        expect(authProvider.errorMessage, contains('cannot be empty'));
      });

      test('setFieldErrors should handle multiple validation errors', () {
        // Action: Set multiple validation errors
        authProvider.setFieldErrors(
          emptyEmail: true,
          invalidPassword: true,
          emptyUsername: true,
        );

        // Assert
        expect(authProvider.hasEmailError, true);
        expect(authProvider.hasPasswordError, true);
        expect(authProvider.hasUsernameError, true);
        expect(authProvider.errorMessage, contains('Email'));
        expect(authProvider.errorMessage, contains('Username'));
        expect(authProvider.errorMessage, contains('cannot be empty'));
        expect(authProvider.errorMessage,
            contains('Password must have at least 7 characters'));
      });
    });

    group('resetPassword', () {
      test('should send reset email and clear errors on success', () async {
        // Arrange
        when(() => mockAuth.resetPassword(any())).thenAnswer((_) async {});

        // Act
        await authProvider.resetPassword('test@example.com');

        // Assert
        expect(authProvider.isLoading, false);
        expect(authProvider.errorMessage, null);
        verify(() => mockAuth.resetPassword('test@example.com')).called(1);
      });

      test('should set error message on failure', () async {
        // Arrange
        when(() => mockAuth.resetPassword(any()))
            .thenThrow(Exception('Reset password failed'));

        // Act
        await authProvider.resetPassword('invalid@example.com');

        // Assert
        expect(authProvider.errorMessage, isNotNull);
      });
    });

    group('isEmailInUse', () {
      test('should return true when email is in use', () async {
        // Arrange
        when(() => mockAuth.isEmailInUse(any())).thenAnswer((_) async => true);

        // Act
        final result = await authProvider.isEmailInUse('existing@example.com');

        // Assert
        expect(result, true);
        verify(() => mockAuth.isEmailInUse('existing@example.com')).called(1);
      });

      test('should return false when email is available', () async {
        // Arrange
        when(() => mockAuth.isEmailInUse(any())).thenAnswer((_) async => false);

        // Act
        final result = await authProvider.isEmailInUse('new@example.com');

        // Assert
        expect(result, false);
      });

      test('should return false and set error message on failure', () async {
        // Arrange
        when(() => mockAuth.isEmailInUse(any()))
            .thenThrow(Exception('Check failed'));

        // Act
        final result = await authProvider.isEmailInUse('test@example.com');

        // Assert
        expect(result, false);
        expect(authProvider.errorMessage, 'Error checking email availability');
      });
    });

    group('deleteUserAccount', () {
      test('should delete user and clear state', () async {
        // Arrange - First sign in
        final mockUser = MockModels.createMockUser();
        when(() => mockAuth.signIn(any(), any()))
            .thenAnswer((_) async => mockUser);
        when(() => mockAuth.deleteUserAccount()).thenAnswer((_) async {});

        await authProvider.signIn('test@example.com', 'password123');
        expect(authProvider.isAuthenticated, true);

        // Act
        await authProvider.deleteUserAccount();

        // Assert
        expect(authProvider.user, null);
        expect(authProvider.isAuthenticated, false);
        expect(authProvider.isLoading, false);
        verify(() => mockAuth.deleteUserAccount()).called(1);
      });

      test('should set error message on deletion failure', () async {
        // Arrange
        when(() => mockAuth.deleteUserAccount())
            .thenThrow(Exception('Deletion failed'));

        // Act
        await authProvider.deleteUserAccount();

        // Assert
        expect(authProvider.errorMessage, isNotNull);
      });

      test('should handle requires-recent-login error on deletion', () async {
        // Arrange
        when(() => mockAuth.deleteUserAccount()).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'requires-recent-login',
            message: 'Requires recent login',
          ),
        );

        // Act
        await authProvider.deleteUserAccount();

        // Assert
        expect(authProvider.errorMessage,
            'This operation requires a recent login. Please sign out and sign in again.');
      });
    });

    group('hasRecentLogin', () {
      test('should return true for recent login', () async {
        // Arrange
        when(() => mockAuth.hasRecentLogin()).thenAnswer((_) async => true);

        // Act
        final result = await authProvider.hasRecentLogin();

        // Assert
        expect(result, true);
        verify(() => mockAuth.hasRecentLogin()).called(1);
      });

      test('should return false for old login', () async {
        // Arrange
        when(() => mockAuth.hasRecentLogin()).thenAnswer((_) async => false);

        // Act
        final result = await authProvider.hasRecentLogin();

        // Assert
        expect(result, false);
      });

      test('should set error message on hasRecentLogin failure', () async {
        // Arrange
        when(() => mockAuth.hasRecentLogin())
            .thenThrow(Exception('Check failed'));

        // Act
        final result = await authProvider.hasRecentLogin();

        // Assert
        expect(result, false);
        expect(authProvider.errorMessage, isNotNull);
      });
    });

    group('signInWithGoogle', () {
      test(
          'should set user and isAuthenticated to true on successful Google sign in',
          () async {
        // Arrange
        final mockUser = MockModels.createMockUser(
          id: 'google-user',
          email: 'google@example.com',
          username: 'googleuser',
        );

        when(() => mockAuth.signInWithGoogle())
            .thenAnswer((_) async => mockUser);

        // Act
        await authProvider.signInWithGoogle();

        // Assert
        expect(authProvider.isAuthenticated, true);
        expect(authProvider.user, isNotNull);
        expect(authProvider.user?.id, 'google-user');
        expect(authProvider.isLoading, false);
        expect(authProvider.errorMessage, null);

        verify(() => mockAuth.signInWithGoogle()).called(1);
      });

      test('should set error message on failed Google sign in', () async {
        // Arrange
        when(() => mockAuth.signInWithGoogle())
            .thenThrow(Exception('Google sign in failed'));

        // Act
        await authProvider.signInWithGoogle();

        // Assert
        expect(authProvider.isAuthenticated, false);
        expect(authProvider.user, null);
        expect(authProvider.isLoading, false);
        expect(authProvider.errorMessage, isNotNull);
      });

      test('should handle FirebaseAuthException on Google sign in', () async {
        // Arrange
        when(() => mockAuth.signInWithGoogle()).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'invalid-credential',
            message: 'Invalid credential',
          ),
        );

        // Act
        await authProvider.signInWithGoogle();

        // Assert
        expect(authProvider.errorMessage, 'Invalid credentials');
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when state changes', () {
        var notifyCount = 0;
        authProvider.addListener(() {
          notifyCount++;
        });

        // Trigger state change
        authProvider.clearErrors();

        // Verify notification
        expect(notifyCount, greaterThan(0));
      });

      test('should notify listeners on signIn', () async {
        // Arrange
        final mockUser = MockModels.createMockUser();
        when(() => mockAuth.signIn(any(), any()))
            .thenAnswer((_) async => mockUser);

        var notifyCount = 0;
        authProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await authProvider.signIn('test@example.com', 'password123');

        // Assert - Should notify at least twice (loading start and loading end)
        expect(notifyCount, greaterThanOrEqualTo(2));
      });
    });
  });
}
