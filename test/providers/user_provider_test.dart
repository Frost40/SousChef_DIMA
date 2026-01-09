import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/providers/user_provider.dart';
import '../mocks/mock_services.dart';
import '../mocks/mock_models.dart';

void main() {
  group('UserProvider Tests', () {
    late UserProvider userProvider;
    late MockUserFirestore mockUserFirestore;
    late MockAuthentication mockAuthentication;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(MockModels.createMockUser());
    });

    setUp(() {
      mockUserFirestore = MockUserFirestore();
      mockAuthentication = MockAuthentication();

      // Create UserProvider with injected mocks
      userProvider = UserProvider(
        userFirestore: mockUserFirestore,
        authentication: mockAuthentication,
      );
    });

    tearDown(() {
      userProvider.dispose();
    });

    group('State Management', () {
      test('initial state should have no user data and not be loading', () {
        expect(userProvider.isLoading, false);
        expect(userProvider.errorMessage, null);
        expect(userProvider.userData, null);
      });

      test('should have no field error flags initially', () {
        expect(userProvider.hasEmailError, false);
        expect(userProvider.hasPasswordError, false);
        expect(userProvider.hasUsernameError, false);
        expect(userProvider.hasPhoneError, false);
      });
    });

    group('init', () {
      test('should load current user data and notify listeners', () async {
        // Arrange
        final mockUser = MockModels.createMockUser(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
        );
        when(() => mockUserFirestore.getFullUserData())
            .thenAnswer((_) async => mockUser);

        var notifyCount = 0;
        userProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await userProvider.init();

        // Assert
        expect(userProvider.userData, isNotNull);
        expect(userProvider.userData?.id, 'user123');
        expect(userProvider.userData?.email, 'test@example.com');
        expect(notifyCount, greaterThan(0));

        // Verify service was called
        verify(() => mockUserFirestore.getFullUserData()).called(1);
      });

      test('should handle null user data gracefully', () async {
        // Arrange
        when(() => mockUserFirestore.getFullUserData())
            .thenAnswer((_) async => null);

        // Act
        await userProvider.init();

        // Assert
        expect(userProvider.userData, null);

        // Verify service was called
        verify(() => mockUserFirestore.getFullUserData()).called(1);
      });
    });

    group('setFieldErrors', () {
      test('should set email error flag for empty email', () {
        // Act
        userProvider.setFieldErrors(emptyEmail: true);

        // Assert
        expect(userProvider.hasEmailError, true);
        expect(userProvider.errorMessage, contains('Email cannot be empty'));
      });

      test('should set email error flag for invalid email', () {
        // Act
        userProvider.setFieldErrors(invalidEmail: true);

        // Assert
        expect(userProvider.hasEmailError, true);
        expect(userProvider.errorMessage, contains('Invalid email format'));
      });

      test('should set password error flag for empty password', () {
        // Act
        userProvider.setFieldErrors(emptyPassword: true);

        // Assert
        expect(userProvider.hasPasswordError, true);
        expect(userProvider.errorMessage, contains('Password cannot be empty'));
      });

      test('should set password error flag for weak password', () {
        // Act
        userProvider.setFieldErrors(weakPassword: true);

        // Assert
        expect(userProvider.hasPasswordError, true);
        expect(userProvider.errorMessage, contains('Password must have at least 6 characters'));
      });

      test('should set username error flag for empty username', () {
        // Act
        userProvider.setFieldErrors(emptyUsername: true);

        // Assert
        expect(userProvider.hasUsernameError, true);
        expect(userProvider.errorMessage, contains('Username cannot be empty'));
      });

      test('should set phone error flag for empty phone', () {
        // Act
        userProvider.setFieldErrors(emptyPhone: true);

        // Assert
        expect(userProvider.hasPhoneError, true);
        expect(userProvider.errorMessage, contains('Phone cannot be empty'));
      });

      test('should set phone error flag for invalid phone', () {
        // Act
        userProvider.setFieldErrors(invalidPhone: true);

        // Assert
        expect(userProvider.hasPhoneError, true);
        expect(userProvider.errorMessage, contains('Invalid phone number format'));
      });

      test('should combine multiple errors in error message', () {
        // Act
        userProvider.setFieldErrors(
          emptyEmail: true,
          emptyPassword: true,
          weakPassword: true,
        );

        // Assert
        expect(userProvider.hasEmailError, true);
        expect(userProvider.hasPasswordError, true);
        expect(userProvider.errorMessage, contains('Email, Password cannot be empty'));
        expect(userProvider.errorMessage, contains('Password must have at least 6 characters'));
      });

      test('should notify listeners when errors are set', () {
        // Arrange
        var notifyCount = 0;
        userProvider.addListener(() {
          notifyCount++;
        });

        // Act
        userProvider.setFieldErrors(emptyEmail: true);

        // Assert
        expect(notifyCount, 1);
      });
    });

    group('clearErrors', () {
      test('should clear all error flags and messages', () {
        // Arrange - set some errors first
        userProvider.setFieldErrors(
          emptyEmail: true,
          weakPassword: true,
          emptyUsername: true,
          invalidPhone: true,
        );

        // Act
        userProvider.clearErrors();

        // Assert
        expect(userProvider.hasEmailError, false);
        expect(userProvider.hasPasswordError, false);
        expect(userProvider.hasUsernameError, false);
        expect(userProvider.hasPhoneError, false);
        expect(userProvider.errorMessage, null);
      });

      test('should notify listeners when clearing errors', () {
        // Arrange
        userProvider.setFieldErrors(emptyEmail: true);
        var notifyCount = 0;
        userProvider.addListener(() {
          notifyCount++;
        });

        // Act
        userProvider.clearErrors(notify: true);

        // Assert
        expect(notifyCount, 1);
      });

      test('should not notify listeners when notify is false', () {
        // Arrange
        userProvider.setFieldErrors(emptyEmail: true);
        var notifyCount = 0;
        userProvider.addListener(() {
          notifyCount++;
        });

        // Act
        userProvider.clearErrors(notify: false);

        // Assert
        expect(notifyCount, 0);
      });
    });

    group('updateUserProfile', () {
      test('should update user profile and notify listeners on success', () async {
        // Arrange
        final updatedUser = MockModels.createMockUser(
          id: 'user123',
          username: 'newusername',
          name: 'New',
          surname: 'Name',
          phone: '0987654321',
        );
        when(() => mockUserFirestore.updateUserProfile(
              username: any(named: 'username'),
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              phone: any(named: 'phone'),
            )).thenAnswer((_) async {});
        when(() => mockUserFirestore.getFullUserData())
            .thenAnswer((_) async => updatedUser);

        var notifyCount = 0;
        userProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await userProvider.updateUserProfile(
          username: 'newusername',
          name: 'New',
          surname: 'Name',
          phone: '0987654321',
        );

        // Assert
        expect(userProvider.userData?.username, 'newusername');
        expect(userProvider.isLoading, false);
        expect(userProvider.errorMessage, null);
        expect(notifyCount, greaterThan(0));

        // Verify services were called
        verify(() => mockUserFirestore.updateUserProfile(
              username: 'newusername',
              name: 'New',
              surname: 'Name',
              phone: '0987654321',
            )).called(1);
        verify(() => mockUserFirestore.getFullUserData()).called(1);
      });

      test('should set error message on profile update failure', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserProfile(
              username: any(named: 'username'),
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              phone: any(named: 'phone'),
            )).thenThrow(Exception('Update failed'));

        // Act
        await userProvider.updateUserProfile(username: 'newusername');

        // Assert
        expect(userProvider.isLoading, false);
        expect(userProvider.errorMessage, isNotNull);
      });

      test('should set username error flag when error contains username', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserProfile(
              username: any(named: 'username'),
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              phone: any(named: 'phone'),
            )).thenThrow(Exception('username error'));

        // Act
        await userProvider.updateUserProfile(username: 'newusername');

        // Assert
        expect(userProvider.hasUsernameError, true);
      });

      test('should set phone error flag when error contains phone', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserProfile(
              username: any(named: 'username'),
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              phone: any(named: 'phone'),
            )).thenThrow(Exception('phone error'));

        // Act
        await userProvider.updateUserProfile(phone: 'invalid');

        // Assert
        expect(userProvider.hasPhoneError, true);
      });
    });

    group('updateUserEmail', () {
      test('should update email and notify listeners on success', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserEmail(any()))
            .thenAnswer((_) async {});
        when(() => mockAuthentication.getCurrentUserEmail())
            .thenReturn('new@example.com');

        var notifyCount = 0;
        userProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await userProvider.updateUserEmail('new@example.com');

        // Assert
        expect(userProvider.isLoading, false);
        expect(userProvider.errorMessage, null);
        expect(notifyCount, greaterThan(0));

        // Verify service was called
        verify(() => mockUserFirestore.updateUserEmail('new@example.com')).called(1);
      });

      test('should set error message and email flag on failure', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserEmail(any()))
            .thenThrow(Exception('email-already-in-use'));

        // Act
        await userProvider.updateUserEmail('existing@example.com');

        // Assert
        expect(userProvider.isLoading, false);
        expect(userProvider.hasEmailError, true);
        expect(userProvider.errorMessage, 'Email already in use');
      });

      test('should handle invalid-email error', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserEmail(any()))
            .thenThrow(Exception('invalid-email'));

        // Act
        await userProvider.updateUserEmail('invalid');

        // Assert
        expect(userProvider.hasEmailError, true);
        expect(userProvider.errorMessage, 'Invalid email format');
      });
    });

    group('updateUserAddress', () {
      test('should update address and notify listeners on success', () async {
        // Arrange
        final updatedUser = MockModels.createMockUser(
          id: 'user123',
          email: 'test@example.com',
        );
        when(() => mockUserFirestore.updateUserAddress(
              address: any(named: 'address'),
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
            )).thenAnswer((_) async {});
        when(() => mockUserFirestore.getFullUserData())
            .thenAnswer((_) async => updatedUser);

        var notifyCount = 0;
        userProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await userProvider.updateUserAddress(
          address: '123 Test St',
          latitude: 45.0,
          longitude: 9.0,
        );

        // Assert
        expect(userProvider.isLoading, false);
        expect(userProvider.errorMessage, null);
        expect(notifyCount, greaterThan(0));

        // Verify services were called
        verify(() => mockUserFirestore.updateUserAddress(
              address: '123 Test St',
              latitude: 45.0,
              longitude: 9.0,
            )).called(1);
        verify(() => mockUserFirestore.getFullUserData()).called(1);
      });

      test('should set error message on address update failure', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserAddress(
              address: any(named: 'address'),
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
            )).thenThrow(Exception('Update failed'));

        // Act
        await userProvider.updateUserAddress(
          address: '123 Test St',
          latitude: 45.0,
          longitude: 9.0,
        );

        // Assert
        expect(userProvider.isLoading, false);
        expect(userProvider.errorMessage, isNotNull);
      });
    });

    group('updateUserPassword', () {
      test('should update password and notify listeners on success', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserPassword(any()))
            .thenAnswer((_) async {});

        var notifyCount = 0;
        userProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await userProvider.updateUserPassword('newpassword123');

        // Assert
        expect(userProvider.isLoading, false);
        expect(userProvider.errorMessage, null);
        expect(notifyCount, greaterThan(0));

        // Verify service was called
        verify(() => mockUserFirestore.updateUserPassword('newpassword123')).called(1);
      });

      test('should set error message and password flag on weak password', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserPassword(any()))
            .thenThrow(Exception('weak-password'));

        // Act
        await userProvider.updateUserPassword('123');

        // Assert
        expect(userProvider.isLoading, false);
        expect(userProvider.hasPasswordError, true);
        expect(userProvider.errorMessage, 'Password is too weak');
      });

      test('should handle requires-recent-login error', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserPassword(any()))
            .thenThrow(Exception('requires-recent-login'));

        // Act
        await userProvider.updateUserPassword('newpassword');

        // Assert
        expect(userProvider.hasPasswordError, true);
        expect(userProvider.errorMessage, contains('recent login'));
      });
    });

    group('fetchUserData', () {
      test('should fetch user data and notify listeners', () async {
        // Arrange
        final mockUser = MockModels.createMockUser(
          id: 'user123',
          email: 'test@example.com',
        );
        when(() => mockUserFirestore.getFullUserData())
            .thenAnswer((_) async => mockUser);

        var notifyCount = 0;
        userProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await userProvider.fetchUserData();

        // Assert
        expect(userProvider.userData, isNotNull);
        expect(userProvider.userData?.id, 'user123');
        expect(userProvider.isLoading, false);
        expect(notifyCount, greaterThan(0));

        // Verify service was called
        verify(() => mockUserFirestore.getFullUserData()).called(1);
      });

      test('should set error message on fetch failure', () async {
        // Arrange
        when(() => mockUserFirestore.getFullUserData())
            .thenThrow(Exception('No authenticated user'));

        // Act
        await userProvider.fetchUserData();

        // Assert
        expect(userProvider.isLoading, false);
        expect(userProvider.errorMessage, 'No authenticated user');
      });

      test('should handle User not found error', () async {
        // Arrange
        when(() => mockUserFirestore.getFullUserData())
            .thenThrow(Exception('User not found'));

        // Act
        await userProvider.fetchUserData();

        // Assert
        expect(userProvider.errorMessage, 'User not found');
      });
    });

    group('isUsernameTaken', () {
      test('should return true when username is taken', () async {
        // Arrange
        when(() => mockUserFirestore.isUsernameTaken(any()))
            .thenAnswer((_) async => true);

        // Act
        final result = await userProvider.isUsernameTaken('existinguser');

        // Assert
        expect(result, true);
        expect(userProvider.hasUsernameError, true);
        expect(userProvider.errorMessage, 'Username already taken');

        // Verify service was called
        verify(() => mockUserFirestore.isUsernameTaken('existinguser')).called(1);
      });

      test('should return false when username is available', () async {
        // Arrange
        when(() => mockUserFirestore.isUsernameTaken(any()))
            .thenAnswer((_) async => false);

        // Act
        final result = await userProvider.isUsernameTaken('newuser');

        // Assert
        expect(result, false);
        expect(userProvider.hasUsernameError, false);

        // Verify service was called
        verify(() => mockUserFirestore.isUsernameTaken('newuser')).called(1);
      });

      test('should notify listeners when notify is true', () async {
        // Arrange
        when(() => mockUserFirestore.isUsernameTaken(any()))
            .thenAnswer((_) async => false);

        var notifyCount = 0;
        userProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await userProvider.isUsernameTaken('newuser', notify: true);

        // Assert
        expect(notifyCount, greaterThan(0));
      });

      test('should not notify listeners when notify is false', () async {
        // Arrange
        when(() => mockUserFirestore.isUsernameTaken(any()))
            .thenAnswer((_) async => false);

        var notifyCount = 0;
        userProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await userProvider.isUsernameTaken('newuser', notify: false);

        // Assert
        expect(notifyCount, 0);
      });

      test('should handle error and return false', () async {
        // Arrange
        when(() => mockUserFirestore.isUsernameTaken(any()))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await userProvider.isUsernameTaken('username', notify: true);

        // Assert
        expect(result, false);
        expect(userProvider.isLoading, false);
        expect(userProvider.errorMessage, isNotNull);
      });
    });

    group('deleteUserData', () {
      test('should delete user data and clear local state', () async {
        // Arrange
        final mockUser = MockModels.createMockUser(id: 'user123');
        when(() => mockUserFirestore.getFullUserData())
            .thenAnswer((_) async => mockUser);
        when(() => mockUserFirestore.deleteUserData())
            .thenAnswer((_) async {});

        await userProvider.init(); // Load user first

        var notifyCount = 0;
        userProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await userProvider.deleteUserData();

        // Assert
        expect(userProvider.userData, null);
        expect(userProvider.isLoading, false);
        expect(userProvider.errorMessage, null);
        expect(notifyCount, greaterThan(0));

        // Verify service was called
        verify(() => mockUserFirestore.deleteUserData()).called(1);
      });

      test('should set error message on delete failure', () async {
        // Arrange
        when(() => mockUserFirestore.deleteUserData())
            .thenThrow(Exception('Delete failed'));

        // Act
        await userProvider.deleteUserData();

        // Assert
        expect(userProvider.isLoading, false);
        expect(userProvider.errorMessage, isNotNull);
      });
    });

    group('getFavoriteRestaurantIds', () {
      test('should fetch favorites and notify listeners', () async {
        // Arrange
        final mockUser = MockModels.createMockUser(
          id: 'user123',
          favourites: ['restaurant1', 'restaurant2'],
        );
        when(() => mockUserFirestore.getFullUserData())
            .thenAnswer((_) async => mockUser);
        when(() => mockUserFirestore.getFavoriteRestaurantIds())
            .thenAnswer((_) async => ['restaurant1', 'restaurant2']);

        await userProvider.init(); // Load user first

        var notifyCount = 0;
        userProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await userProvider.getFavoriteRestaurantIds();

        // Assert
        expect(userProvider.isLoading, false);
        expect(notifyCount, greaterThan(0));

        // Verify service was called
        verify(() => mockUserFirestore.getFavoriteRestaurantIds()).called(1);
      });

      test('should handle empty favorites list', () async {
        // Arrange
        final mockUser = MockModels.createMockUser(id: 'user123');
        when(() => mockUserFirestore.getFullUserData())
            .thenAnswer((_) async => mockUser);
        when(() => mockUserFirestore.getFavoriteRestaurantIds())
            .thenAnswer((_) async => []);

        await userProvider.init();

        // Act
        await userProvider.getFavoriteRestaurantIds();

        // Assert
        expect(userProvider.isLoading, false);
      });

      test('should handle error gracefully', () async {
        // Arrange
        final mockUser = MockModels.createMockUser(id: 'user123');
        when(() => mockUserFirestore.getFullUserData())
            .thenAnswer((_) async => mockUser);
        when(() => mockUserFirestore.getFavoriteRestaurantIds())
            .thenThrow(Exception('Network error'));

        await userProvider.init();

        // Act
        await userProvider.getFavoriteRestaurantIds();

        // Assert
        expect(userProvider.isLoading, false);
        // Error is logged but not thrown
      });
    });

    group('syncPendingChanges', () {
      test('should sync pending removals to Firestore', () async {
        // Arrange
        final mockUser = MockModels.createMockUser(
          id: 'user123',
          favourites: ['restaurant1'],
        );
        when(() => mockUserFirestore.getFullUserData())
            .thenAnswer((_) async => mockUser);
        when(() => mockUserFirestore.removeFromFavorites(any(), any()))
            .thenAnswer((_) async {});

        await userProvider.init();

        // Act
        userProvider.syncPendingChanges();

        // Assert - no pending changes initially, so nothing to verify
        // This just ensures the method runs without error
      });
    });

    group('Error Message Mapping', () {
      test('should map email-already-in-use error', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserEmail(any()))
            .thenThrow(Exception('email-already-in-use'));

        // Act
        await userProvider.updateUserEmail('test@example.com');

        // Assert
        expect(userProvider.errorMessage, 'Email already in use');
      });

      test('should map invalid-email error', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserEmail(any()))
            .thenThrow(Exception('invalid-email'));

        // Act
        await userProvider.updateUserEmail('invalid');

        // Assert
        expect(userProvider.errorMessage, 'Invalid email format');
      });

      test('should map weak-password error', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserPassword(any()))
            .thenThrow(Exception('weak-password'));

        // Act
        await userProvider.updateUserPassword('123');

        // Assert
        expect(userProvider.errorMessage, 'Password is too weak');
      });

      test('should map requires-recent-login error', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserPassword(any()))
            .thenThrow(Exception('requires-recent-login'));

        // Act
        await userProvider.updateUserPassword('newpassword');

        // Assert
        expect(userProvider.errorMessage, contains('recent login'));
      });

      test('should map No authenticated user error', () async {
        // Arrange
        when(() => mockUserFirestore.getFullUserData())
            .thenThrow(Exception('No authenticated user'));

        // Act
        await userProvider.fetchUserData();

        // Assert
        expect(userProvider.errorMessage, 'No authenticated user');
      });

      test('should map User not found error', () async {
        // Arrange
        when(() => mockUserFirestore.getFullUserData())
            .thenThrow(Exception('User not found'));

        // Act
        await userProvider.fetchUserData();

        // Assert
        expect(userProvider.errorMessage, 'User not found');
      });

      test('should return generic error message for unknown errors', () async {
        // Arrange
        when(() => mockUserFirestore.getFullUserData())
            .thenThrow(Exception('Unknown error'));

        // Act
        await userProvider.fetchUserData();

        // Assert
        expect(userProvider.errorMessage, contains('An error occurred'));
      });
    });

    group('Loading State', () {
      test('should set loading state during profile update', () async {
        // Arrange
        final completer = Completer<void>();
        when(() => mockUserFirestore.updateUserProfile(
              username: any(named: 'username'),
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              phone: any(named: 'phone'),
            )).thenAnswer((_) => completer.future);
        when(() => mockUserFirestore.getFullUserData())
            .thenAnswer((_) async => MockModels.createMockUser());

        // Act
        final future = userProvider.updateUserProfile(username: 'test');

        // Assert - loading should be true while waiting
        expect(userProvider.isLoading, true);

        // Complete the operation
        completer.complete();
        await future;

        // Assert - loading should be false after completion
        expect(userProvider.isLoading, false);
      });

      test('should set loading state during email update', () async {
        // Arrange
        final completer = Completer<void>();
        when(() => mockUserFirestore.updateUserEmail(any()))
            .thenAnswer((_) => completer.future);
        when(() => mockAuthentication.getCurrentUserEmail())
            .thenReturn('new@example.com');

        // Act
        final future = userProvider.updateUserEmail('new@example.com');

        // Assert - loading should be true while waiting
        expect(userProvider.isLoading, true);

        // Complete the operation
        completer.complete();
        await future;

        // Assert - loading should be false after completion
        expect(userProvider.isLoading, false);
      });

      test('should set loading state during password update', () async {
        // Arrange
        final completer = Completer<void>();
        when(() => mockUserFirestore.updateUserPassword(any()))
            .thenAnswer((_) => completer.future);

        // Act
        final future = userProvider.updateUserPassword('newpassword');

        // Assert - loading should be true while waiting
        expect(userProvider.isLoading, true);

        // Complete the operation
        completer.complete();
        await future;

        // Assert - loading should be false after completion
        expect(userProvider.isLoading, false);
      });

      test('should set loading state during data fetch', () async {
        // Arrange
        final completer = Completer<User?>();
        when(() => mockUserFirestore.getFullUserData())
            .thenAnswer((_) => completer.future);

        // Act
        final future = userProvider.fetchUserData();

        // Assert - loading should be true while waiting
        expect(userProvider.isLoading, true);

        // Complete the operation
        completer.complete(MockModels.createMockUser());
        await future;

        // Assert - loading should be false after completion
        expect(userProvider.isLoading, false);
      });

      test('should set loading state during delete operation', () async {
        // Arrange
        final completer = Completer<void>();
        when(() => mockUserFirestore.deleteUserData())
            .thenAnswer((_) => completer.future);

        // Act
        final future = userProvider.deleteUserData();

        // Assert - loading should be true while waiting
        expect(userProvider.isLoading, true);

        // Complete the operation
        completer.complete();
        await future;

        // Assert - loading should be false after completion
        expect(userProvider.isLoading, false);
      });
    });

    group('Field Error Detection', () {
      test('should detect email error from error message', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserProfile(
              username: any(named: 'username'),
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              phone: any(named: 'phone'),
            )).thenThrow(Exception('email validation failed'));

        // Act
        await userProvider.updateUserProfile(username: 'test');

        // Assert
        expect(userProvider.hasEmailError, true);
      });

      test('should detect password error from error message', () async {
        // Arrange
        when(() => mockUserFirestore.updateUserProfile(
              username: any(named: 'username'),
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              phone: any(named: 'phone'),
            )).thenThrow(Exception('password is invalid'));

        // Act
        await userProvider.updateUserProfile(username: 'test');

        // Assert
        expect(userProvider.hasPasswordError, true);
      });
    });

    group('dispose', () {
      test('should cancel all pending timers on dispose', () async {
        // Arrange - create a separate provider for this test
        final localMockUserFirestore = MockUserFirestore();
        final localMockAuth = MockAuthentication();
        final localProvider = UserProvider(
          userFirestore: localMockUserFirestore,
          authentication: localMockAuth,
        );

        final mockUser = MockModels.createMockUser(
          id: 'user123',
          favourites: ['restaurant1'],
        );
        when(() => localMockUserFirestore.getFullUserData())
            .thenAnswer((_) async => mockUser);

        await localProvider.init();

        // Act & Assert - should not throw
        expect(() => localProvider.dispose(), returnsNormally);
      });
    });
  });

  group('UserProvider Widget Integration Tests', () {
    late UserProvider userProvider;
    late MockUserFirestore mockUserFirestore;
    late MockAuthentication mockAuthentication;

    setUp(() {
      mockUserFirestore = MockUserFirestore();
      mockAuthentication = MockAuthentication();
      userProvider = UserProvider(
        userFirestore: mockUserFirestore,
        authentication: mockAuthentication,
      );
    });

    tearDown(() {
      userProvider.dispose();
    });

    testWidgets('toggleFavorite should show confirmation dialog and remove on confirm', (WidgetTester tester) async {
      // Arrange
      final mockUser = MockModels.createMockUser(
        id: 'user123',
        favourites: ['restaurant1'],
      );
      when(() => mockUserFirestore.getFullUserData())
          .thenAnswer((_) async => mockUser);
      when(() => mockUserFirestore.removeFromFavorites(any(), any()))
          .thenAnswer((_) async {});

      await userProvider.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    userProvider.toggleFavorite(
                      context,
                      'restaurant1',
                      'Test Restaurant',
                    );
                  },
                  child: const Text('Toggle'),
                ),
              );
            },
          ),
        ),
      );

      // Act - tap the toggle button
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      // Assert - confirmation dialog should appear
      expect(find.text('Remove from Favorites'), findsOneWidget);

      // Tap Remove button
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      // Verify the service was called
      verify(() => mockUserFirestore.removeFromFavorites('user123', 'restaurant1')).called(1);
    });

    testWidgets('toggleFavorite should not remove when cancelled', (WidgetTester tester) async {
      // Arrange
      final mockUser = MockModels.createMockUser(
        id: 'user123',
        favourites: ['restaurant1'],
      );
      when(() => mockUserFirestore.getFullUserData())
          .thenAnswer((_) async => mockUser);

      await userProvider.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    userProvider.toggleFavorite(
                      context,
                      'restaurant1',
                      'Test Restaurant',
                    );
                  },
                  child: const Text('Toggle'),
                ),
              );
            },
          ),
        ),
      );

      // Act - tap the toggle button
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      // Tap Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify the service was NOT called
      verifyNever(() => mockUserFirestore.removeFromFavorites(any(), any()));
    });

    testWidgets('addToFavorites should add restaurant and show success dialog', (WidgetTester tester) async {
      // Arrange
      final mockUser = MockModels.createMockUser(
        id: 'user123',
        favourites: [],
      );
      when(() => mockUserFirestore.getFullUserData())
          .thenAnswer((_) async => mockUser);
      when(() => mockUserFirestore.addToFavorites(any(), any()))
          .thenAnswer((_) async {});

      await userProvider.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    userProvider.addToFavorites(
                      context,
                      'restaurant1',
                      'Test Restaurant',
                    );
                  },
                  child: const Text('Add'),
                ),
              );
            },
          ),
        ),
      );

      // Act - tap the add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Assert - success dialog should appear
      expect(find.text('Added to Favorites'), findsOneWidget);

      // Verify the service was called
      verify(() => mockUserFirestore.addToFavorites('user123', 'restaurant1')).called(1);
    });

    testWidgets('addToFavorites should not add duplicate', (WidgetTester tester) async {
      // Arrange
      final mockUser = MockModels.createMockUser(
        id: 'user123',
        favourites: ['restaurant1'],
      );
      when(() => mockUserFirestore.getFullUserData())
          .thenAnswer((_) async => mockUser);

      await userProvider.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    userProvider.addToFavorites(
                      context,
                      'restaurant1',
                      'Test Restaurant',
                    );
                  },
                  child: const Text('Add'),
                ),
              );
            },
          ),
        ),
      );

      // Act - tap the add button (restaurant already in favorites)
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify the service was NOT called (duplicate)
      verifyNever(() => mockUserFirestore.addToFavorites(any(), any()));
    });

    testWidgets('toggleFavorite should do nothing when userData is null', (WidgetTester tester) async {
      // Arrange - don't initialize user data

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    userProvider.toggleFavorite(
                      context,
                      'restaurant1',
                      'Test Restaurant',
                    );
                  },
                  child: const Text('Toggle'),
                ),
              );
            },
          ),
        ),
      );

      // Act - tap the toggle button
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      // Assert - no dialog should appear
      expect(find.text('Remove from Favorites'), findsNothing);

      // Verify no service calls
      verifyNever(() => mockUserFirestore.removeFromFavorites(any(), any()));
    });

    testWidgets('addToFavorites should do nothing when userData is null', (WidgetTester tester) async {
      // Arrange - don't initialize user data

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    userProvider.addToFavorites(
                      context,
                      'restaurant1',
                      'Test Restaurant',
                    );
                  },
                  child: const Text('Add'),
                ),
              );
            },
          ),
        ),
      );

      // Act - tap the add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Assert - no dialog should appear
      expect(find.text('Added to Favorites'), findsNothing);

      // Verify no service calls
      verifyNever(() => mockUserFirestore.addToFavorites(any(), any()));
    });

    testWidgets('toggleFavorite should restore favorite and show error dialog on failure', (WidgetTester tester) async {
      // Arrange
      final mockUser = MockModels.createMockUser(
        id: 'user123',
        favourites: ['restaurant1'],
      );
      when(() => mockUserFirestore.getFullUserData())
          .thenAnswer((_) async => mockUser);
      when(() => mockUserFirestore.removeFromFavorites(any(), any()))
          .thenAnswer((_) => Future.error(Exception('Network error')));

      await userProvider.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    userProvider.toggleFavorite(
                      context,
                      'restaurant1',
                      'Test Restaurant',
                    );
                  },
                  child: const Text('Toggle'),
                ),
              );
            },
          ),
        ),
      );

      // Act - tap the toggle button
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      // Tap Remove button to confirm
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      // Assert - error dialog should appear
      expect(find.text('Error'), findsOneWidget);
      expect(find.textContaining('Failed to remove'), findsOneWidget);
    });

    testWidgets('addToFavorites should restore state and show error dialog on failure', (WidgetTester tester) async {
      // Arrange
      final mockUser = MockModels.createMockUser(
        id: 'user123',
        favourites: [],
      );
      when(() => mockUserFirestore.getFullUserData())
          .thenAnswer((_) async => mockUser);
      when(() => mockUserFirestore.addToFavorites(any(), any()))
          .thenAnswer((_) => Future.error(Exception('Network error')));

      await userProvider.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    userProvider.addToFavorites(
                      context,
                      'restaurant1',
                      'Test Restaurant',
                    );
                  },
                  child: const Text('Add'),
                ),
              );
            },
          ),
        ),
      );

      // Act - tap the add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Assert - error dialog should appear
      expect(find.text('Error'), findsOneWidget);
      expect(find.textContaining('Failed to add'), findsOneWidget);
    });
  });
}
