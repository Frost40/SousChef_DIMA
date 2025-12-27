import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sous_chef/models/user.dart';

// Mock class for DocumentSnapshot
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('User Model Tests', () {
    group('Constructor', () {
      test('should create User with all required fields', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        expect(user.id, 'user123');
        expect(user.email, 'test@example.com');
        expect(user.username, 'testuser');
        expect(user.name, 'John');
        expect(user.surname, 'Doe');
        expect(user.phone, '1234567890');
        expect(user.restaurantId, isNull);
        expect(user.favourites, isEmpty);
        expect(user.chats, isEmpty);
        expect(user.savedAddress, isNull);
        expect(user.latitude, isNull);
        expect(user.longitude, isNull);
      });

      test('should create User with all optional fields', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          restaurantId: 'restaurant123',
          favourites: ['fav1', 'fav2'],
          chats: ['chat1', 'chat2'],
          savedAddress: '123 Main St',
          latitude: 45.4642,
          longitude: 9.1900,
        );

        expect(user.restaurantId, 'restaurant123');
        expect(user.favourites, ['fav1', 'fav2']);
        expect(user.chats, ['chat1', 'chat2']);
        expect(user.savedAddress, '123 Main St');
        expect(user.latitude, 45.4642);
        expect(user.longitude, 9.1900);
      });

      test('should default favourites to empty list', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        expect(user.favourites, isA<List<String>>());
        expect(user.favourites, isEmpty);
      });

      test('should default chats to empty list', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        expect(user.chats, isA<List<String>>());
        expect(user.chats, isEmpty);
      });

      test('should handle empty string values', () {
        final user = User(
          id: '',
          email: '',
          username: '',
          name: '',
          surname: '',
          phone: '',
        );

        expect(user.id, '');
        expect(user.email, '');
        expect(user.username, '');
        expect(user.name, '');
        expect(user.surname, '');
        expect(user.phone, '');
      });

      test('should handle special characters in fields', () {
        final user = User(
          id: 'user123',
          email: 'test+special@example.com',
          username: 'user_name.test',
          name: 'José María',
          surname: "O'Connor",
          phone: '+1-555-123-4567',
        );

        expect(user.email, 'test+special@example.com');
        expect(user.username, 'user_name.test');
        expect(user.name, 'José María');
        expect(user.surname, "O'Connor");
        expect(user.phone, '+1-555-123-4567');
      });

      test('should handle negative coordinates', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          latitude: -33.8688,
          longitude: -151.2093,
        );

        expect(user.latitude, -33.8688);
        expect(user.longitude, -151.2093);
      });

      test('should handle zero coordinates', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          latitude: 0.0,
          longitude: 0.0,
        );

        expect(user.latitude, 0.0);
        expect(user.longitude, 0.0);
      });

      test('should handle large favourites list', () {
        final largeFavourites = List.generate(100, (i) => 'fav$i');
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          favourites: largeFavourites,
        );

        expect(user.favourites.length, 100);
        expect(user.favourites.first, 'fav0');
        expect(user.favourites.last, 'fav99');
      });
    });

    group('fromFirestore', () {
      late MockDocumentSnapshot mockDoc;

      setUp(() {
        mockDoc = MockDocumentSnapshot();
      });

      test('should create User from Firestore document with all fields', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
          'restaurant_id': 'restaurant123',
          'favourites': ['fav1', 'fav2'],
          'chats': ['chat1', 'chat2'],
          'saved_address': '123 Main St',
          'latitude': 45.4642,
          'longitude': 9.1900,
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.id, 'user123');
        expect(user.email, 'test@example.com');
        expect(user.username, 'testuser');
        expect(user.name, 'John');
        expect(user.surname, 'Doe');
        expect(user.phone, '1234567890');
        expect(user.restaurantId, 'restaurant123');
        expect(user.favourites, ['fav1', 'fav2']);
        expect(user.chats, ['chat1', 'chat2']);
        expect(user.savedAddress, '123 Main St');
        expect(user.latitude, 45.4642);
        expect(user.longitude, 9.1900);
      });

      test('should handle missing email with empty string default', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.email, '');
      });

      test('should handle null email with empty string default', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': null,
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.email, '');
      });

      test('should handle missing username with empty string default', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.username, '');
      });

      test('should handle missing name with empty string default', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'surname': 'Doe',
          'phone': '1234567890',
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.name, '');
      });

      test('should handle missing surname with empty string default', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'phone': '1234567890',
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.surname, '');
      });

      test('should handle missing phone with empty string default', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.phone, '');
      });

      test('should handle null restaurant_id with empty string', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
          'restaurant_id': null,
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.restaurantId, '');
      });

      test('should handle missing restaurant_id with empty string', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.restaurantId, '');
      });

      test('should handle null favourites with empty list', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
          'favourites': null,
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.favourites, isEmpty);
        expect(user.favourites, isA<List<String>>());
      });

      test('should handle missing favourites with empty list', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.favourites, isEmpty);
      });

      test('should handle null chats with empty list', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
          'chats': null,
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.chats, isEmpty);
        expect(user.chats, isA<List<String>>());
      });

      test('should handle missing chats with empty list', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.chats, isEmpty);
      });

      test('should handle null saved_address', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
          'saved_address': null,
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.savedAddress, isNull);
      });

      test('should handle missing saved_address', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.savedAddress, isNull);
      });

      test('should handle null latitude', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
          'latitude': null,
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.latitude, isNull);
      });

      test('should handle null longitude', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
          'longitude': null,
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.longitude, isNull);
      });

      test('should convert integer latitude to double', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
          'latitude': 45,
          'longitude': 9,
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.latitude, 45.0);
        expect(user.longitude, 9.0);
        expect(user.latitude, isA<double>());
        expect(user.longitude, isA<double>());
      });

      test('should handle empty Firestore document data', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({});

        final user = User.fromFirestore(mockDoc);

        expect(user.id, 'user123');
        expect(user.email, '');
        expect(user.username, '');
        expect(user.name, '');
        expect(user.surname, '');
        expect(user.phone, '');
        expect(user.restaurantId, '');
        expect(user.favourites, isEmpty);
        expect(user.chats, isEmpty);
      });

      test('should handle Firestore document with extra fields', () {
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'John',
          'surname': 'Doe',
          'phone': '1234567890',
          'extra_field': 'should be ignored',
          'another_field': 123,
        });

        final user = User.fromFirestore(mockDoc);

        expect(user.id, 'user123');
        expect(user.email, 'test@example.com');
      });
    });

    group('toFirestore', () {
      test('should convert User to Firestore map with required fields only', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        final firestoreMap = user.toFirestore();

        expect(firestoreMap['email'], 'test@example.com');
        expect(firestoreMap['username'], 'testuser');
        expect(firestoreMap['name'], 'John');
        expect(firestoreMap['surname'], 'Doe');
        expect(firestoreMap['phone'], '1234567890');
        expect(firestoreMap['favourites'], isEmpty);
        expect(firestoreMap['chats'], isEmpty);
      });

      test('should convert User to Firestore map with all fields', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          restaurantId: 'restaurant123',
          favourites: ['fav1', 'fav2'],
          chats: ['chat1', 'chat2'],
          savedAddress: '123 Main St',
          latitude: 45.4642,
          longitude: 9.1900,
        );

        final firestoreMap = user.toFirestore();

        expect(firestoreMap['restaurant_id'], 'restaurant123');
        expect(firestoreMap['favourites'], ['fav1', 'fav2']);
        expect(firestoreMap['chats'], ['chat1', 'chat2']);
        expect(firestoreMap['saved_address'], '123 Main St');
        expect(firestoreMap['latitude'], 45.4642);
        expect(firestoreMap['longitude'], 9.1900);
      });

      test('should not include id in Firestore map', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        final firestoreMap = user.toFirestore();

        expect(firestoreMap.containsKey('id'), isFalse);
      });

      test('should not include restaurant_id when null', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          restaurantId: null,
        );

        final firestoreMap = user.toFirestore();

        expect(firestoreMap.containsKey('restaurant_id'), isFalse);
      });

      test('should not include saved_address when null', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          savedAddress: null,
        );

        final firestoreMap = user.toFirestore();

        expect(firestoreMap.containsKey('saved_address'), isFalse);
      });

      test('should not include latitude when null', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          latitude: null,
        );

        final firestoreMap = user.toFirestore();

        expect(firestoreMap.containsKey('latitude'), isFalse);
      });

      test('should not include longitude when null', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          longitude: null,
        );

        final firestoreMap = user.toFirestore();

        expect(firestoreMap.containsKey('longitude'), isFalse);
      });

      test('should handle empty strings', () {
        final user = User(
          id: '',
          email: '',
          username: '',
          name: '',
          surname: '',
          phone: '',
        );

        final firestoreMap = user.toFirestore();

        expect(firestoreMap['email'], '');
        expect(firestoreMap['username'], '');
        expect(firestoreMap['name'], '');
        expect(firestoreMap['surname'], '');
        expect(firestoreMap['phone'], '');
      });

      test('should handle empty favourites and chats lists', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          favourites: [],
          chats: [],
        );

        final firestoreMap = user.toFirestore();

        expect(firestoreMap['favourites'], isEmpty);
        expect(firestoreMap['chats'], isEmpty);
      });

      test('should include latitude 0.0', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          latitude: 0.0,
          longitude: 0.0,
        );

        final firestoreMap = user.toFirestore();

        expect(firestoreMap.containsKey('latitude'), isTrue);
        expect(firestoreMap.containsKey('longitude'), isTrue);
        expect(firestoreMap['latitude'], 0.0);
        expect(firestoreMap['longitude'], 0.0);
      });
    });

    group('copyWith', () {
      test('should create copy with no changes when no parameters provided', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          favourites: ['fav1'],
          chats: ['chat1'],
          savedAddress: '123 Main St',
          latitude: 45.4642,
          longitude: 9.1900,
        );

        final copy = user.copyWith();

        expect(copy.id, user.id);
        expect(copy.email, user.email);
        expect(copy.username, user.username);
        expect(copy.name, user.name);
        expect(copy.surname, user.surname);
        expect(copy.phone, user.phone);
        expect(copy.favourites, user.favourites);
        expect(copy.chats, user.chats);
        expect(copy.savedAddress, user.savedAddress);
        expect(copy.latitude, user.latitude);
        expect(copy.longitude, user.longitude);
      });

      test('should update id when provided', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        final copy = user.copyWith(id: 'newId');

        expect(copy.id, 'newId');
        expect(copy.email, user.email);
      });

      test('should update email when provided', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        final copy = user.copyWith(email: 'new@example.com');

        expect(copy.email, 'new@example.com');
        expect(copy.id, user.id);
      });

      test('should update username when provided', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        final copy = user.copyWith(username: 'newusername');

        expect(copy.username, 'newusername');
      });

      test('should update name when provided', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        final copy = user.copyWith(name: 'Jane');

        expect(copy.name, 'Jane');
      });

      test('should update surname when provided', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        final copy = user.copyWith(surname: 'Smith');

        expect(copy.surname, 'Smith');
      });

      test('should update phone when provided', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        final copy = user.copyWith(phone: '0987654321');

        expect(copy.phone, '0987654321');
      });

      test('should update favourites when provided', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          favourites: ['fav1'],
        );

        final copy = user.copyWith(favourites: ['fav2', 'fav3']);

        expect(copy.favourites, ['fav2', 'fav3']);
      });

      test('should update savedAddress when provided', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          savedAddress: 'Old Address',
        );

        final copy = user.copyWith(savedAddress: 'New Address');

        expect(copy.savedAddress, 'New Address');
      });

      test('should update latitude when provided', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          latitude: 45.0,
        );

        final copy = user.copyWith(latitude: 50.0);

        expect(copy.latitude, 50.0);
      });

      test('should update longitude when provided', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          longitude: 9.0,
        );

        final copy = user.copyWith(longitude: 10.0);

        expect(copy.longitude, 10.0);
      });

      test('should update multiple fields at once', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        final copy = user.copyWith(
          name: 'Jane',
          surname: 'Smith',
          email: 'jane@example.com',
        );

        expect(copy.name, 'Jane');
        expect(copy.surname, 'Smith');
        expect(copy.email, 'jane@example.com');
        expect(copy.username, user.username);
        expect(copy.phone, user.phone);
      });

      test('should preserve chats when not provided', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          chats: ['chat1', 'chat2'],
        );

        final copy = user.copyWith(name: 'Jane');

        expect(copy.chats, ['chat1', 'chat2']);
      });

      test('should not affect original user when copying', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
        );

        final copy = user.copyWith(name: 'Jane');

        expect(user.name, 'John');
        expect(copy.name, 'Jane');
      });
    });

    group('Round-trip serialization', () {
      test('should maintain data integrity through toFirestore and fromFirestore', () {
        final originalUser = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          restaurantId: 'restaurant123',
          favourites: ['fav1', 'fav2'],
          chats: ['chat1', 'chat2'],
          savedAddress: '123 Main St',
          latitude: 45.4642,
          longitude: 9.1900,
        );

        // Convert to Firestore format
        final firestoreData = originalUser.toFirestore();

        // Mock document snapshot with the Firestore data
        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        // Convert back from Firestore
        final restoredUser = User.fromFirestore(mockDoc);

        expect(restoredUser.id, originalUser.id);
        expect(restoredUser.email, originalUser.email);
        expect(restoredUser.username, originalUser.username);
        expect(restoredUser.name, originalUser.name);
        expect(restoredUser.surname, originalUser.surname);
        expect(restoredUser.phone, originalUser.phone);
        expect(restoredUser.restaurantId, originalUser.restaurantId);
        expect(restoredUser.favourites, originalUser.favourites);
        expect(restoredUser.chats, originalUser.chats);
        expect(restoredUser.savedAddress, originalUser.savedAddress);
        expect(restoredUser.latitude, originalUser.latitude);
        expect(restoredUser.longitude, originalUser.longitude);
      });

      test('should handle round-trip with minimal data', () {
        final originalUser = User(
          id: 'user456',
          email: 'minimal@example.com',
          username: 'minimal',
          name: 'Min',
          surname: 'User',
          phone: '1111111111',
        );

        final firestoreData = originalUser.toFirestore();

        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('user456');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        final restoredUser = User.fromFirestore(mockDoc);

        expect(restoredUser.id, originalUser.id);
        expect(restoredUser.email, originalUser.email);
        expect(restoredUser.favourites, isEmpty);
        expect(restoredUser.chats, isEmpty);
      });

      test('should handle round-trip with empty lists', () {
        final originalUser = User(
          id: 'user789',
          email: 'test@example.com',
          username: 'testuser',
          name: 'Test',
          surname: 'User',
          phone: '2222222222',
          favourites: [],
          chats: [],
        );

        final firestoreData = originalUser.toFirestore();

        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('user789');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        final restoredUser = User.fromFirestore(mockDoc);

        expect(restoredUser.favourites, isEmpty);
        expect(restoredUser.chats, isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle user with restaurant owner role', () {
        final user = User(
          id: 'owner123',
          email: 'owner@restaurant.com',
          username: 'restaurantowner',
          name: 'Restaurant',
          surname: 'Owner',
          phone: '1234567890',
          restaurantId: 'myRestaurant123',
        );

        expect(user.restaurantId, 'myRestaurant123');
        expect(user.restaurantId, isNotNull);
        expect(user.restaurantId!.isNotEmpty, isTrue);
      });

      test('should handle user without restaurant (regular customer)', () {
        final user = User(
          id: 'customer123',
          email: 'customer@example.com',
          username: 'customer',
          name: 'Regular',
          surname: 'Customer',
          phone: '1234567890',
        );

        expect(user.restaurantId, isNull);
      });

      test('should handle extreme coordinate values', () {
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'John',
          surname: 'Doe',
          phone: '1234567890',
          latitude: 90.0, // North Pole
          longitude: 180.0, // International Date Line
        );

        expect(user.latitude, 90.0);
        expect(user.longitude, 180.0);
      });

      test('should handle unicode in user fields', () {
        final user = User(
          id: 'user123',
          email: 'user@例え.jp',
          username: '用户名',
          name: '名前',
          surname: 'Müller',
          phone: '+1234567890',
          savedAddress: '東京都渋谷区',
        );

        expect(user.email, 'user@例え.jp');
        expect(user.username, '用户名');
        expect(user.name, '名前');
        expect(user.surname, 'Müller');
        expect(user.savedAddress, '東京都渋谷区');
      });

      test('should handle very long strings', () {
        final longString = 'A' * 1000;
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: longString,
          surname: 'Doe',
          phone: '1234567890',
        );

        expect(user.name.length, 1000);
      });
    });
  });
}
