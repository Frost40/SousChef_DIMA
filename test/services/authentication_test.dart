import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sous_chef/services/authentication.dart';
import 'package:sous_chef/models/user.dart';
import '../mocks/mock_models.dart';

/// Mock Firebase Auth classes
class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}
class MockUserCredential extends Mock implements firebase_auth.UserCredential {}
class MockFirebaseUser extends Mock implements firebase_auth.User {}
class MockUserMetadata extends Mock implements firebase_auth.UserMetadata {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}

/// Mock Firestore classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
// ignore: subtype_of_sealed_class
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
// ignore: subtype_of_sealed_class
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

/// Fake class for AuthCredential
class FakeAuthCredential extends Fake implements firebase_auth.AuthCredential {}

void main() {
  group('Authentication Service Tests', () {
    late Authentication authentication;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockCollectionReference mockCollection;
    late MockDocumentReference mockDocRef;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(FakeAuthCredential());
    });

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockGoogleSignIn = MockGoogleSignIn();
      mockCollection = MockCollectionReference();
      mockDocRef = MockDocumentReference();

      // Create Authentication with injected dependencies
      authentication = Authentication(
        firebaseAuth: mockAuth,
        firestore: mockFirestore,
        googleSignIn: mockGoogleSignIn,
      );

      // Setup common mock behaviors
      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenReturn(mockDocRef);
    });

    group('currentUser', () {
      test('should return null when no user is signed in', () {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(authentication.currentUser, isNull);
      });

      test('should return user when signed in', () {
        // Arrange
        final mockUser = MockFirebaseUser();
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('user123');

        // Act & Assert
        expect(authentication.currentUser, isNotNull);
        expect(authentication.currentUser!.uid, 'user123');
      });
    });

    group('signIn', () {
      test('should return User when sign in is successful', () async {
        // Arrange
        final mockUserCredential = MockUserCredential();
        final mockFirebaseUser = MockFirebaseUser();
        final mockDocSnapshot = MockDocumentSnapshot();
        
        when(() => mockFirebaseUser.uid).thenReturn('user123');
        when(() => mockUserCredential.user).thenReturn(mockFirebaseUser);
        when(() => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockUserCredential);
        
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn('user123');
        when(() => mockDocSnapshot.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
        });

        // Act
        final result = await authentication.signIn('test@example.com', 'password123');

        // Assert
        expect(result, isNotNull);
        verify(() => mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      test('should throw exception when email is invalid', () async {
        // Arrange
        when(() => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(firebase_auth.FirebaseAuthException(
          code: 'invalid-email',
          message: 'Invalid email',
        ));

        // Act & Assert
        expect(
          () => authentication.signIn('invalid-email', 'password'),
          throwsA(isA<firebase_auth.FirebaseAuthException>()),
        );
      });

      test('should throw exception when password is wrong', () async {
        // Arrange
        when(() => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(firebase_auth.FirebaseAuthException(
          code: 'wrong-password',
          message: 'Wrong password',
        ));

        // Act & Assert
        expect(
          () => authentication.signIn('test@example.com', 'wrongpassword'),
          throwsA(isA<firebase_auth.FirebaseAuthException>()),
        );
      });

      test('should throw exception when user not found', () async {
        // Arrange
        when(() => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(firebase_auth.FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found',
        ));

        // Act & Assert
        expect(
          () => authentication.signIn('unknown@example.com', 'password'),
          throwsA(isA<firebase_auth.FirebaseAuthException>()),
        );
      });
    });

    group('signUp', () {
      test('should create user and return User object', () async {
        // Arrange
        final mockUserCredential = MockUserCredential();
        final mockFirebaseUser = MockFirebaseUser();
        final mockDocSnapshot = MockDocumentSnapshot();
        
        when(() => mockFirebaseUser.uid).thenReturn('newuser123');
        when(() => mockUserCredential.user).thenReturn(mockFirebaseUser);
        when(() => mockAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockUserCredential);
        
        when(() => mockDocRef.set(any())).thenAnswer((_) async {});
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn('newuser123');
        when(() => mockDocSnapshot.data()).thenReturn({
          'email': 'new@example.com',
          'username': 'newuser',
        });

        // Act
        final result = await authentication.signUp(
          email: 'new@example.com',
          password: 'password123',
          username: 'newuser',
        );

        // Assert
        expect(result, isNotNull);
        verify(() => mockAuth.createUserWithEmailAndPassword(
          email: 'new@example.com',
          password: 'password123',
        )).called(1);
        verify(() => mockDocRef.set(any())).called(1);
      });

      test('should throw exception when email already in use', () async {
        // Arrange
        when(() => mockAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(firebase_auth.FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Email already in use',
        ));

        // Act & Assert
        expect(
          () => authentication.signUp(
            email: 'existing@example.com',
            password: 'password',
            username: 'user',
          ),
          throwsA(isA<firebase_auth.FirebaseAuthException>()),
        );
      });

      test('should create user with restaurant ID when provided', () async {
        // Arrange
        final mockUserCredential = MockUserCredential();
        final mockFirebaseUser = MockFirebaseUser();
        final mockDocSnapshot = MockDocumentSnapshot();
        
        when(() => mockFirebaseUser.uid).thenReturn('owner123');
        when(() => mockUserCredential.user).thenReturn(mockFirebaseUser);
        when(() => mockAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockUserCredential);
        
        when(() => mockDocRef.set(any())).thenAnswer((_) async {});
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn('owner123');
        when(() => mockDocSnapshot.data()).thenReturn({
          'email': 'owner@example.com',
          'username': 'owner',
          'restaurantId': 'rest123',
        });

        // Act
        final result = await authentication.signUp(
          email: 'owner@example.com',
          password: 'password123',
          username: 'owner',
          restaurantId: 'rest123',
        );

        // Assert
        expect(result, isNotNull);
      });

      test('should throw exception when password is weak', () async {
        // Arrange
        when(() => mockAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(firebase_auth.FirebaseAuthException(
          code: 'weak-password',
          message: 'Password is too weak',
        ));

        // Act & Assert
        expect(
          () => authentication.signUp(
            email: 'test@example.com',
            password: '123',
            username: 'user',
          ),
          throwsA(isA<firebase_auth.FirebaseAuthException>()),
        );
      });
    });

    group('signOut', () {
      test('should call Firebase Auth sign out', () async {
        // Arrange
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        // Act
        await authentication.signOut();

        // Assert
        verify(() => mockAuth.signOut()).called(1);
      });
    });

    group('getCurrentUser', () {
      test('should return null when no user is signed in', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await authentication.getCurrentUser();

        // Assert
        expect(result, isNull);
      });

      test('should return User object when user is signed in', () async {
        // Arrange
        final mockFirebaseUser = MockFirebaseUser();
        final mockDocSnapshot = MockDocumentSnapshot();
        
        when(() => mockAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.uid).thenReturn('user123');
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn('user123');
        when(() => mockDocSnapshot.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
        });

        // Act
        final result = await authentication.getCurrentUser();

        // Assert
        expect(result, isNotNull);
      });
    });

    group('getCurrentUserEmail', () {
      test('should return null when no user is signed in', () {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act
        final result = authentication.getCurrentUserEmail();

        // Assert
        expect(result, isNull);
      });

      test('should return email when user is signed in', () {
        // Arrange
        final mockFirebaseUser = MockFirebaseUser();
        when(() => mockAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.email).thenReturn('test@example.com');

        // Act
        final result = authentication.getCurrentUserEmail();

        // Assert
        expect(result, 'test@example.com');
      });
    });

    group('resetPassword', () {
      test('should send password reset email', () async {
        // Arrange
        when(() => mockAuth.sendPasswordResetEmail(email: any(named: 'email')))
            .thenAnswer((_) async {});

        // Act
        await authentication.resetPassword('test@example.com');

        // Assert
        verify(() => mockAuth.sendPasswordResetEmail(email: 'test@example.com')).called(1);
      });

      test('should throw exception for invalid email', () async {
        // Arrange
        when(() => mockAuth.sendPasswordResetEmail(email: any(named: 'email')))
            .thenThrow(firebase_auth.FirebaseAuthException(
              code: 'invalid-email',
              message: 'Invalid email',
            ));

        // Act & Assert
        expect(
          () => authentication.resetPassword('invalid'),
          throwsA(isA<firebase_auth.FirebaseAuthException>()),
        );
      });
    });

    group('isEmailInUse', () {
      test('should return true when email exists', () async {
        // Arrange
        when(() => mockAuth.fetchSignInMethodsForEmail(any()))
            .thenAnswer((_) async => ['password']);

        // Act
        final result = await authentication.isEmailInUse('existing@example.com');

        // Assert
        expect(result, true);
      });

      test('should return false when email does not exist', () async {
        // Arrange
        when(() => mockAuth.fetchSignInMethodsForEmail(any()))
            .thenAnswer((_) async => []);

        // Act
        final result = await authentication.isEmailInUse('new@example.com');

        // Assert
        expect(result, false);
      });

      test('should return false on error', () async {
        // Arrange
        when(() => mockAuth.fetchSignInMethodsForEmail(any()))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await authentication.isEmailInUse('test@example.com');

        // Assert
        expect(result, false);
      });
    });

    group('deleteUserAccount', () {
      test('should delete user from Firebase Auth', () async {
        // Arrange
        final mockFirebaseUser = MockFirebaseUser();
        when(() => mockAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.delete()).thenAnswer((_) async {});

        // Act
        await authentication.deleteUserAccount();

        // Assert
        verify(() => mockFirebaseUser.delete()).called(1);
      });

      test('should throw exception when no user is signed in', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => authentication.deleteUserAccount(),
          throwsException,
        );
      });
    });

    group('hasRecentLogin', () {
      test('should return false when no user is signed in', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await authentication.hasRecentLogin();

        // Assert
        expect(result, false);
      });

      test('should return true when last sign in is recent', () async {
        // Arrange
        final mockFirebaseUser = MockFirebaseUser();
        final mockMetadata = MockUserMetadata();
        final recentTime = DateTime.now().subtract(const Duration(minutes: 2));
        
        when(() => mockAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.lastSignInTime).thenReturn(recentTime);

        // Act
        final result = await authentication.hasRecentLogin();

        // Assert
        expect(result, true);
      });

      test('should return false when last sign in is old', () async {
        // Arrange
        final mockFirebaseUser = MockFirebaseUser();
        final mockMetadata = MockUserMetadata();
        final oldTime = DateTime.now().subtract(const Duration(minutes: 30));
        
        when(() => mockAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.lastSignInTime).thenReturn(oldTime);

        // Act
        final result = await authentication.hasRecentLogin();

        // Assert
        expect(result, false);
      });

      test('should return false when last sign in time is null', () async {
        // Arrange
        final mockFirebaseUser = MockFirebaseUser();
        final mockMetadata = MockUserMetadata();
        
        when(() => mockAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.lastSignInTime).thenReturn(null);

        // Act
        final result = await authentication.hasRecentLogin();

        // Assert
        expect(result, false);
      });
    });

    group('signInWithGoogle', () {
      test('should throw exception when Google sign in is cancelled', () async {
        // Arrange
        when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => authentication.signInWithGoogle(),
          throwsException,
        );
      });

      test('should complete sign in when Google auth succeeds', () async {
        // Arrange
        final mockGoogleAccount = MockGoogleSignInAccount();
        final mockGoogleAuth = MockGoogleSignInAuthentication();
        final mockUserCredential = MockUserCredential();
        final mockFirebaseUser = MockFirebaseUser();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleAccount);
        when(() => mockGoogleAccount.authentication).thenAnswer((_) async => mockGoogleAuth);
        when(() => mockGoogleAuth.accessToken).thenReturn('access_token');
        when(() => mockGoogleAuth.idToken).thenReturn('id_token');
        when(() => mockAuth.signInWithCredential(any())).thenAnswer((_) async => mockUserCredential);
        when(() => mockUserCredential.user).thenReturn(mockFirebaseUser);
        when(() => mockFirebaseUser.uid).thenReturn('google_user123');
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn('google_user123');
        when(() => mockDocSnapshot.data()).thenReturn({
          'email': 'google@example.com',
          'username': 'googleuser',
        });

        // Act
        final result = await authentication.signInWithGoogle();

        // Assert
        expect(result, isNotNull);
        verify(() => mockGoogleSignIn.signIn()).called(1);
        verify(() => mockAuth.signInWithCredential(any())).called(1);
      });
    });

    group('authStateChanges', () {
      test('should return stream from Firebase Auth', () {
        // Arrange
        when(() => mockAuth.authStateChanges()).thenAnswer((_) => Stream.empty());

        // Act
        final stream = authentication.authStateChanges;

        // Assert
        expect(stream, isNotNull);
        verify(() => mockAuth.authStateChanges()).called(1);
      });
    });
  });
}
