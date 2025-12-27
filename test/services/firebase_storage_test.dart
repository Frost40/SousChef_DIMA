import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:sous_chef/services/firebase_storage.dart' as app_storage;

/// Mock classes
class MockFirebaseStorage extends Mock
    implements firebase_storage.FirebaseStorage {}

class MockReference extends Mock implements firebase_storage.Reference {}

class MockTaskSnapshot extends Mock implements firebase_storage.TaskSnapshot {}

/// Custom mock UploadTask that properly implements Future<TaskSnapshot>
class MockUploadTask extends Mock implements firebase_storage.UploadTask {
  final Future<firebase_storage.TaskSnapshot> _future;

  MockUploadTask(this._future);

  @override
  Future<S> then<S>(
    FutureOr<S> Function(firebase_storage.TaskSnapshot) onValue, {
    Function? onError,
  }) =>
      _future.then(onValue, onError: onError);

  @override
  Future<firebase_storage.TaskSnapshot> whenComplete(
          FutureOr<void> Function() action) =>
      _future.whenComplete(action);

  @override
  Future<firebase_storage.TaskSnapshot> catchError(Function onError,
          {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);

  @override
  Stream<firebase_storage.TaskSnapshot> asStream() => _future.asStream();

  @override
  Future<firebase_storage.TaskSnapshot> timeout(Duration timeLimit,
          {FutureOr<firebase_storage.TaskSnapshot> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);
}

/// Custom mock file that allows setting the path
class MockFile extends Mock implements File {
  final String _path;
  MockFile(this._path);

  @override
  String get path => _path;
}

/// Fake class for registerFallbackValue
class FakeFile extends Fake implements File {}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  group('FirebaseStorage Service Tests', () {
    late app_storage.FirebaseStorage storageService;
    late MockFirebaseStorage mockStorage;
    late MockReference mockRootRef;
    late MockReference mockChildRef;
    late MockTaskSnapshot mockTaskSnapshot;

    setUp(() {
      mockStorage = MockFirebaseStorage();
      mockRootRef = MockReference();
      mockChildRef = MockReference();
      mockTaskSnapshot = MockTaskSnapshot();

      // Setup reference chain
      when(() => mockStorage.ref()).thenReturn(mockRootRef);
      when(() => mockRootRef.child(any())).thenReturn(mockChildRef);

      storageService = app_storage.FirebaseStorage(storage: mockStorage);
    });

    /// Helper to create a successful upload mock
    void setupSuccessfulUpload(String expectedUrl) {
      when(() => mockTaskSnapshot.ref).thenReturn(mockChildRef);
      when(() => mockChildRef.getDownloadURL())
          .thenAnswer((_) async => expectedUrl);
      when(() => mockChildRef.putFile(any())).thenAnswer(
          (_) => MockUploadTask(Future.value(mockTaskSnapshot)));
    }

    group('uploadRestaurantImage', () {
      test('should upload image and return download URL on success', () async {
        // Arrange
        const restaurantId = 'rest123';
        const expectedUrl = 'https://storage.googleapis.com/bucket/image.png';
        final mockFile = MockFile('/test/path/image.jpg');

        setupSuccessfulUpload(expectedUrl);

        // Act
        final result =
            await storageService.uploadRestaurantImage(restaurantId, mockFile);

        // Assert
        expect(result, equals(expectedUrl));
        verify(() => mockRootRef
            .child('images/restaurants/$restaurantId/profile_image.png')).called(1);
        verify(() => mockChildRef.putFile(mockFile)).called(1);
      });

      test('should return null for invalid file extension', () async {
        // Arrange
        const restaurantId = 'rest123';
        final mockFile = MockFile('/test/path/image.pdf');

        // Act
        final result =
            await storageService.uploadRestaurantImage(restaurantId, mockFile);

        // Assert
        expect(result, isNull);
        verifyNever(() => mockChildRef.putFile(any()));
      });

      test('should return null for .txt file extension', () async {
        const restaurantId = 'rest123';
        final mockFile = MockFile('/test/path/document.txt');

        final result =
            await storageService.uploadRestaurantImage(restaurantId, mockFile);

        expect(result, isNull);
        verifyNever(() => mockChildRef.putFile(any()));
      });

      test('should accept jpg extension', () async {
        const restaurantId = 'rest123';
        const expectedUrl = 'https://storage.googleapis.com/bucket/image.png';
        final mockFile = MockFile('/test/path/image.jpg');

        setupSuccessfulUpload(expectedUrl);

        final result =
            await storageService.uploadRestaurantImage(restaurantId, mockFile);

        expect(result, equals(expectedUrl));
      });

      test('should accept jpeg extension', () async {
        const restaurantId = 'rest123';
        const expectedUrl = 'https://storage.googleapis.com/bucket/image.png';
        final mockFile = MockFile('/test/path/image.jpeg');

        setupSuccessfulUpload(expectedUrl);

        final result =
            await storageService.uploadRestaurantImage(restaurantId, mockFile);

        expect(result, equals(expectedUrl));
      });

      test('should accept png extension', () async {
        const restaurantId = 'rest123';
        const expectedUrl = 'https://storage.googleapis.com/bucket/image.png';
        final mockFile = MockFile('/test/path/image.png');

        setupSuccessfulUpload(expectedUrl);

        final result =
            await storageService.uploadRestaurantImage(restaurantId, mockFile);

        expect(result, equals(expectedUrl));
      });

      test('should accept gif extension', () async {
        const restaurantId = 'rest123';
        const expectedUrl = 'https://storage.googleapis.com/bucket/image.png';
        final mockFile = MockFile('/test/path/image.gif');

        setupSuccessfulUpload(expectedUrl);

        final result =
            await storageService.uploadRestaurantImage(restaurantId, mockFile);

        expect(result, equals(expectedUrl));
      });

      test('should accept webp extension', () async {
        const restaurantId = 'rest123';
        const expectedUrl = 'https://storage.googleapis.com/bucket/image.png';
        final mockFile = MockFile('/test/path/image.webp');

        setupSuccessfulUpload(expectedUrl);

        final result =
            await storageService.uploadRestaurantImage(restaurantId, mockFile);

        expect(result, equals(expectedUrl));
      });

      test('should handle uppercase extension', () async {
        const restaurantId = 'rest123';
        const expectedUrl = 'https://storage.googleapis.com/bucket/image.png';
        final mockFile = MockFile('/test/path/image.JPG');

        setupSuccessfulUpload(expectedUrl);

        final result =
            await storageService.uploadRestaurantImage(restaurantId, mockFile);

        expect(result, equals(expectedUrl));
      });

      test('should return null when upload throws exception', () async {
        const restaurantId = 'rest123';
        final mockFile = MockFile('/test/path/image.jpg');

        when(() => mockChildRef.putFile(any()))
            .thenThrow(Exception('Upload failed'));

        final result =
            await storageService.uploadRestaurantImage(restaurantId, mockFile);

        expect(result, isNull);
      });

      test('should construct correct storage path', () async {
        const restaurantId = 'rest123';
        const expectedUrl = 'https://storage.googleapis.com/bucket/image.png';
        final mockFile = MockFile('/test/path/image.jpg');

        setupSuccessfulUpload(expectedUrl);

        await storageService.uploadRestaurantImage(restaurantId, mockFile);

        verify(() => mockRootRef
            .child('images/restaurants/rest123/profile_image.png')).called(1);
      });
    });

    group('uploadDishImage', () {
      test('should upload dish image and return download URL on success',
          () async {
        const restaurantId = 'rest123';
        const dishId = 'dish456';
        const expectedUrl = 'https://storage.googleapis.com/bucket/dish.png';
        final mockFile = MockFile('/test/path/dish.png');

        setupSuccessfulUpload(expectedUrl);

        final result = await storageService.uploadDishImage(
            restaurantId, dishId, mockFile);

        expect(result, equals(expectedUrl));
        verify(() => mockRootRef.child(
            'images/restaurants/$restaurantId/dishes/$dishId.png')).called(1);
      });

      test('should return null for invalid dish image extension', () async {
        const restaurantId = 'rest123';
        const dishId = 'dish456';
        final mockFile = MockFile('/test/path/dish.pdf');

        final result = await storageService.uploadDishImage(
            restaurantId, dishId, mockFile);

        expect(result, isNull);
        verifyNever(() => mockChildRef.putFile(any()));
      });

      test('should return null when dish upload throws exception', () async {
        const restaurantId = 'rest123';
        const dishId = 'dish456';
        final mockFile = MockFile('/test/path/dish.jpg');

        when(() => mockChildRef.putFile(any()))
            .thenThrow(Exception('Upload failed'));

        final result = await storageService.uploadDishImage(
            restaurantId, dishId, mockFile);

        expect(result, isNull);
      });

      test('should construct correct storage path for dish image', () async {
        const restaurantId = 'rest123';
        const dishId = 'dish456';
        const expectedUrl = 'https://storage.googleapis.com/bucket/dish.png';
        final mockFile = MockFile('/test/path/dish.jpg');

        setupSuccessfulUpload(expectedUrl);

        await storageService.uploadDishImage(restaurantId, dishId, mockFile);

        verify(() => mockRootRef
            .child('images/restaurants/rest123/dishes/dish456.png')).called(1);
      });

      test('should accept valid image extensions for dish', () async {
        const restaurantId = 'rest123';
        const dishId = 'dish456';
        const expectedUrl = 'https://storage.googleapis.com/bucket/dish.png';

        for (final ext in ['jpg', 'jpeg', 'png', 'gif', 'webp']) {
          final mockFile = MockFile('/test/path/dish.$ext');

          setupSuccessfulUpload(expectedUrl);

          final result = await storageService.uploadDishImage(
              restaurantId, dishId, mockFile);

          expect(result, equals(expectedUrl),
              reason: 'Extension $ext should be accepted');
        }
      });
    });

    group('deleteDishImage', () {
      test('should delete dish image successfully', () async {
        const restaurantId = 'rest123';
        const dishId = 'dish456';

        when(() => mockChildRef.delete()).thenAnswer((_) async {});

        await storageService.deleteDishImage(restaurantId, dishId);

        verify(() => mockRootRef.child(
            'images/restaurants/$restaurantId/dishes/$dishId.png')).called(1);
        verify(() => mockChildRef.delete()).called(1);
      });

      test('should handle object-not-found error gracefully', () async {
        const restaurantId = 'rest123';
        const dishId = 'dish456';

        when(() => mockChildRef.delete()).thenThrow(
          firebase_storage.FirebaseException(
            plugin: 'firebase_storage',
            code: 'object-not-found',
            message: 'Object not found',
          ),
        );

        // Should complete without throwing
        await expectLater(
          storageService.deleteDishImage(restaurantId, dishId),
          completes,
        );
      });

      test('should rethrow non-object-not-found FirebaseException', () async {
        const restaurantId = 'rest123';
        const dishId = 'dish456';

        when(() => mockChildRef.delete()).thenThrow(
          firebase_storage.FirebaseException(
            plugin: 'firebase_storage',
            code: 'unauthorized',
            message: 'Unauthorized',
          ),
        );

        await expectLater(
          storageService.deleteDishImage(restaurantId, dishId),
          throwsA(isA<firebase_storage.FirebaseException>()),
        );
      });

      test('should rethrow generic exceptions', () async {
        const restaurantId = 'rest123';
        const dishId = 'dish456';

        when(() => mockChildRef.delete())
            .thenThrow(Exception('Network error'));

        await expectLater(
          storageService.deleteDishImage(restaurantId, dishId),
          throwsA(isA<Exception>()),
        );
      });

      test('should construct correct path for deletion', () async {
        const restaurantId = 'rest123';
        const dishId = 'dish456';

        when(() => mockChildRef.delete()).thenAnswer((_) async {});

        await storageService.deleteDishImage(restaurantId, dishId);

        verify(() => mockRootRef
            .child('images/restaurants/rest123/dishes/dish456.png')).called(1);
      });
    });

    group('Service Initialization', () {
      test('should initialize with injected storage instance', () {
        final service = app_storage.FirebaseStorage(storage: mockStorage);
        expect(service, isNotNull);
      });

      test('should have uploadRestaurantImage method', () {
        expect(storageService.uploadRestaurantImage, isNotNull);
      });

      test('should have uploadDishImage method', () {
        expect(storageService.uploadDishImage, isNotNull);
      });

      test('should have deleteDishImage method', () {
        expect(storageService.deleteDishImage, isNotNull);
      });
    });

    group('Error Handling', () {
      test('should return null when getDownloadURL fails', () async {
        const restaurantId = 'rest123';
        final mockFile = MockFile('/test/path/image.jpg');

        when(() => mockTaskSnapshot.ref).thenReturn(mockChildRef);
        when(() => mockChildRef.putFile(any())).thenAnswer(
            (_) => MockUploadTask(Future.value(mockTaskSnapshot)));
        when(() => mockChildRef.getDownloadURL())
            .thenThrow(Exception('Failed to get URL'));

        final result =
            await storageService.uploadRestaurantImage(restaurantId, mockFile);

        expect(result, isNull);
      });

      test('should return null when dish getDownloadURL fails', () async {
        const restaurantId = 'rest123';
        const dishId = 'dish456';
        final mockFile = MockFile('/test/path/dish.jpg');

        when(() => mockTaskSnapshot.ref).thenReturn(mockChildRef);
        when(() => mockChildRef.putFile(any())).thenAnswer(
            (_) => MockUploadTask(Future.value(mockTaskSnapshot)));
        when(() => mockChildRef.getDownloadURL())
            .thenThrow(Exception('Failed to get URL'));

        final result = await storageService.uploadDishImage(
            restaurantId, dishId, mockFile);

        expect(result, isNull);
      });
    });
  });
}
