import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/services/database/user_firestore.dart';
import '../../mocks/mock_models.dart';

/// Mock classes for Firebase
class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}
class MockFirebaseUser extends Mock implements firebase_auth.User {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

void main() {
  group('UserFirestore Service Tests', () {
    late UserFirestore userFirestore;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockUsersCollection;
    late MockDocumentReference mockUserDoc;
    late MockFirebaseUser mockFirebaseUser;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUsersCollection = MockCollectionReference();
      mockUserDoc = MockDocumentReference();
      mockFirebaseUser = MockFirebaseUser();

      // Setup Firestore chain BEFORE creating UserFirestore
      when(() => mockFirestore.collection('users'))
          .thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(any()))
          .thenReturn(mockUserDoc);

      // Create UserFirestore with mocks
      userFirestore = UserFirestore(
        firebaseAuth: mockFirebaseAuth,
        firestore: mockFirestore,
      );
    });

    group('updateUserProfile', () {
      test('should update user profile fields in Firestore', () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.uid).thenReturn('user123');
        when(() => mockUserDoc.update(any())).thenAnswer((_) async {});
        when(() => mockFirebaseUser.updateDisplayName(any()))
            .thenAnswer((_) async {});

        // Act
        await userFirestore.updateUserProfile(
          username: 'newUsername',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        // Assert
        verify(() => mockUserDoc.update(any())).called(1);
      });

      test('should throw when no authenticated user', () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => userFirestore.updateUserProfile(username: 'test'),
          throwsException,
        );
      });

      test('should not update if no fields provided', () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.uid).thenReturn('user123');

        // Act
        await userFirestore.updateUserProfile();

        // Assert
        verifyNever(() => mockUserDoc.update(any()));
      });
    });

    group('updateUserAddress', () {
      test('should update address and coordinates', () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.uid).thenReturn('user123');
        when(() => mockUserDoc.update(any())).thenAnswer((_) async {});

        // Act
        await userFirestore.updateUserAddress(
          address: '123 Main St',
          latitude: 45.0,
          longitude: 9.0,
        );

        // Assert
        verify(() => mockUserDoc.update({
          'saved_address': '123 Main St',
          'latitude': 45.0,
          'longitude': 9.0,
        })).called(1);
      });

      test('should throw when no authenticated user', () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => userFirestore.updateUserAddress(
            address: 'test',
            latitude: 0,
            longitude: 0,
          ),
          throwsException,
        );
      });
    });

    group('updateUserEmail', () {
      test('should send verification email to new address', () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.uid).thenReturn('user123');
        when(() => mockFirebaseUser.email).thenReturn('old@example.com');
        when(() => mockFirebaseUser.verifyBeforeUpdateEmail(any()))
            .thenAnswer((_) async {});
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(null));

        // Act
        await userFirestore.updateUserEmail('new@example.com');

        // Assert
        verify(() => mockFirebaseUser.verifyBeforeUpdateEmail('new@example.com'))
            .called(1);
      });

      test('should throw when no authenticated user', () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => userFirestore.updateUserEmail('new@example.com'),
          throwsException,
        );
      });
    });

    group('updateUserPassword', () {
      test('should update password in Firebase Auth', () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.uid).thenReturn('user123');
        when(() => mockFirebaseUser.updatePassword(any()))
            .thenAnswer((_) async {});

        // Act
        await userFirestore.updateUserPassword('newPassword123');

        // Assert
        verify(() => mockFirebaseUser.updatePassword('newPassword123')).called(1);
      });

      test('should throw when no authenticated user', () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => userFirestore.updateUserPassword('newPassword'),
          throwsException,
        );
      });
    });

    group('getFullUserData', () {
      test('should return User when data exists', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.uid).thenReturn('user123');
        when(() => mockUserDoc.get(any()))
            .thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn('user123');
        when(() => mockDocSnapshot.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'Test',
          'surname': 'User',
        });

        // Act
        final result = await userFirestore.getFullUserData();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 'user123');
      });

      test('should return null when no authenticated user', () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await userFirestore.getFullUserData();

        // Assert
        expect(result, isNull);
      });

      test('should return null when document does not exist', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.uid).thenReturn('user123');
        when(() => mockUserDoc.get(any()))
            .thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        // Act
        final result = await userFirestore.getFullUserData();

        // Assert
        expect(result, isNull);
      });
    });

    group('isUsernameTaken', () {
      test('should return true when username exists', () async {
        // Arrange
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockDoc = MockQueryDocumentSnapshot();
        final mockQuery = MockQuery();

        when(() => mockUsersCollection.where('username', isEqualTo: 'existingUser'))
            .thenReturn(mockQuery);
        when(() => mockQuery.limit(1)).thenReturn(mockQuery);
        when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockDoc]);

        // Act
        final result = await userFirestore.isUsernameTaken('existingUser');

        // Assert
        expect(result, isTrue);
      });

      test('should return false when username is available', () async {
        // Arrange
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockQuery = MockQuery();

        when(() => mockUsersCollection.where('username', isEqualTo: 'newUser'))
            .thenReturn(mockQuery);
        when(() => mockQuery.limit(1)).thenReturn(mockQuery);
        when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([]);

        // Act
        final result = await userFirestore.isUsernameTaken('newUser');

        // Assert
        expect(result, isFalse);
      });
    });

    group('getFavoriteRestaurantIds', () {
      test('should return list of favorite restaurant IDs', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.uid).thenReturn('user123');
        when(() => mockUserDoc.get(any()))
            .thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.data()).thenReturn({
          'favourites': ['rest1', 'rest2', 'rest3'],
        });

        // Act
        final result = await userFirestore.getFavoriteRestaurantIds();

        // Assert
        expect(result, ['rest1', 'rest2', 'rest3']);
      });

      test('should return empty list when no authenticated user', () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await userFirestore.getFavoriteRestaurantIds();

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list when no favourites field', () async {
        // Arrange
        final mockDocSnapshot = MockDocumentSnapshot();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.uid).thenReturn('user123');
        when(() => mockUserDoc.get(any()))
            .thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.data()).thenReturn({});

        // Act
        final result = await userFirestore.getFavoriteRestaurantIds();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('addToFavorites', () {
      test('should add restaurant to favorites', () async {
        // Arrange
        when(() => mockUserDoc.update(any())).thenAnswer((_) async {});

        // Act
        await userFirestore.addToFavorites('user123', 'rest456');

        // Assert
        verify(() => mockUserDoc.update({
          'favourites': FieldValue.arrayUnion(['rest456']),
        })).called(1);
      });
    });

    group('removeFromFavorites', () {
      test('should remove restaurant from favorites', () async {
        // Arrange
        when(() => mockUserDoc.update(any())).thenAnswer((_) async {});

        // Act
        await userFirestore.removeFromFavorites('user123', 'rest456');

        // Assert
        verify(() => mockUserDoc.update({
          'favourites': FieldValue.arrayRemove(['rest456']),
        })).called(1);
      });
    });

    group('updateUserRestaurant', () {
      test('should update restaurant ID for user', () {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.uid).thenReturn('user123');
        when(() => mockUserDoc.update(any())).thenAnswer((_) async {});

        // Act
        userFirestore.updateUserRestaurant('rest789');

        // Assert
        verify(() => mockUserDoc.update({'restaurantId': 'rest789'})).called(1);
      });

      test('should throw when no authenticated user', () {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => userFirestore.updateUserRestaurant('rest123'),
          throwsException,
        );
      });
    });

    group('User Model Tests', () {
      test('createMockUser should create valid user instance', () {
        final user = MockModels.createMockUser(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
        );

        expect(user.id, 'user123');
        expect(user.email, 'test@example.com');
        expect(user.username, 'testuser');
      });

      test('user should have optional fields', () {
        final user = MockModels.createMockUser(
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        expect(user.name, 'John');
        expect(user.surname, 'Doe');
        expect(user.phone, '1234567890');
      });
    });
  });
}
