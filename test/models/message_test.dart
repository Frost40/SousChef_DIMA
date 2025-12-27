import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/message.dart';

// Mock class for DocumentSnapshot
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('Message Model Tests', () {
    group('Constructor', () {
      test('should create Message with all required fields', () {
        final timestamp = DateTime(2025, 12, 27, 10, 30);
        final message = Message(
          id: 'msg123',
          message: 'Hello World',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: timestamp,
        );

        expect(message.id, 'msg123');
        expect(message.message, 'Hello World');
        expect(message.senderId, 'sender1');
        expect(message.receiverId, 'receiver1');
        expect(message.timestamp, timestamp);
        expect(message.isRead, false);
      });

      test('should create Message with isRead set to true', () {
        final timestamp = DateTime(2025, 12, 27, 10, 30);
        final message = Message(
          id: 'msg123',
          message: 'Hello',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: timestamp,
          isRead: true,
        );

        expect(message.isRead, true);
      });

      test('should default isRead to false when not provided', () {
        final message = Message(
          id: 'msg123',
          message: 'Test',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: DateTime.now(),
        );

        expect(message.isRead, false);
      });

      test('should handle empty message string', () {
        final message = Message(
          id: 'msg123',
          message: '',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: DateTime.now(),
        );

        expect(message.message, '');
      });

      test('should handle empty string IDs', () {
        final message = Message(
          id: '',
          message: 'Hello',
          senderId: '',
          receiverId: '',
          timestamp: DateTime.now(),
        );

        expect(message.id, '');
        expect(message.senderId, '');
        expect(message.receiverId, '');
      });

      test('should handle long message content', () {
        final longMessage = 'A' * 10000;
        final message = Message(
          id: 'msg123',
          message: longMessage,
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: DateTime.now(),
        );

        expect(message.message, longMessage);
        expect(message.message.length, 10000);
      });

      test('should handle special characters in message', () {
        final specialMessage = 'Hello! @#\$%^&*() 🎉 émoji ñ';
        final message = Message(
          id: 'msg123',
          message: specialMessage,
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: DateTime.now(),
        );

        expect(message.message, specialMessage);
      });

      test('should handle multiline message', () {
        final multilineMessage = 'Line 1\nLine 2\nLine 3';
        final message = Message(
          id: 'msg123',
          message: multilineMessage,
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: DateTime.now(),
        );

        expect(message.message, multilineMessage);
        expect(message.message.contains('\n'), true);
      });

      test('should preserve timestamp with milliseconds', () {
        final timestamp = DateTime(2025, 12, 27, 10, 30, 45, 123);
        final message = Message(
          id: 'msg123',
          message: 'Test',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: timestamp,
        );

        expect(message.timestamp.millisecond, 123);
      });
    });

    group('fromFirestore', () {
      late MockDocumentSnapshot mockDoc;

      setUp(() {
        mockDoc = MockDocumentSnapshot();
      });

      test('should create Message from Firestore document with all fields', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 12, 27, 14, 30));

        when(() => mockDoc.id).thenReturn('msg123');
        when(() => mockDoc.data()).thenReturn({
          'message': 'Hello!',
          'sender_id': 'user1',
          'receiver_id': 'user2',
          'timestamp': timestamp,
          'is_read': true,
        });

        final message = Message.fromFirestore(mockDoc);

        expect(message.id, 'msg123');
        expect(message.message, 'Hello!');
        expect(message.senderId, 'user1');
        expect(message.receiverId, 'user2');
        expect(message.timestamp, timestamp.toDate());
        expect(message.isRead, true);
      });

      test('should handle missing message field with empty string default', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 12, 27, 14, 30));

        when(() => mockDoc.id).thenReturn('msg123');
        when(() => mockDoc.data()).thenReturn({
          'sender_id': 'user1',
          'receiver_id': 'user2',
          'timestamp': timestamp,
        });

        final message = Message.fromFirestore(mockDoc);

        expect(message.message, '');
      });

      test('should handle null message field with empty string default', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 12, 27, 14, 30));

        when(() => mockDoc.id).thenReturn('msg123');
        when(() => mockDoc.data()).thenReturn({
          'message': null,
          'sender_id': 'user1',
          'receiver_id': 'user2',
          'timestamp': timestamp,
        });

        final message = Message.fromFirestore(mockDoc);

        expect(message.message, '');
      });

      test('should handle missing sender_id with empty string default', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 12, 27, 14, 30));

        when(() => mockDoc.id).thenReturn('msg123');
        when(() => mockDoc.data()).thenReturn({
          'message': 'Hello',
          'receiver_id': 'user2',
          'timestamp': timestamp,
        });

        final message = Message.fromFirestore(mockDoc);

        expect(message.senderId, '');
      });

      test('should handle missing receiver_id with empty string default', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 12, 27, 14, 30));

        when(() => mockDoc.id).thenReturn('msg123');
        when(() => mockDoc.data()).thenReturn({
          'message': 'Hello',
          'sender_id': 'user1',
          'timestamp': timestamp,
        });

        final message = Message.fromFirestore(mockDoc);

        expect(message.receiverId, '');
      });

      test('should handle missing is_read with false default', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 12, 27, 14, 30));

        when(() => mockDoc.id).thenReturn('msg123');
        when(() => mockDoc.data()).thenReturn({
          'message': 'Hello',
          'sender_id': 'user1',
          'receiver_id': 'user2',
          'timestamp': timestamp,
        });

        final message = Message.fromFirestore(mockDoc);

        expect(message.isRead, false);
      });

      test('should handle null is_read with false default', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 12, 27, 14, 30));

        when(() => mockDoc.id).thenReturn('msg123');
        when(() => mockDoc.data()).thenReturn({
          'message': 'Hello',
          'sender_id': 'user1',
          'receiver_id': 'user2',
          'timestamp': timestamp,
          'is_read': null,
        });

        final message = Message.fromFirestore(mockDoc);

        expect(message.isRead, false);
      });

      test('should correctly parse Timestamp to DateTime', () {
        final expectedDateTime = DateTime(2025, 6, 15, 9, 45, 30);
        final timestamp = Timestamp.fromDate(expectedDateTime);

        when(() => mockDoc.id).thenReturn('msg123');
        when(() => mockDoc.data()).thenReturn({
          'message': 'Hello',
          'sender_id': 'user1',
          'receiver_id': 'user2',
          'timestamp': timestamp,
        });

        final message = Message.fromFirestore(mockDoc);

        expect(message.timestamp, expectedDateTime);
      });

      test('should handle Firestore document with extra fields', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 12, 27, 14, 30));

        when(() => mockDoc.id).thenReturn('msg123');
        when(() => mockDoc.data()).thenReturn({
          'message': 'Hello',
          'sender_id': 'user1',
          'receiver_id': 'user2',
          'timestamp': timestamp,
          'extra_field': 'should be ignored',
          'another_field': 123,
        });

        final message = Message.fromFirestore(mockDoc);

        expect(message.id, 'msg123');
        expect(message.message, 'Hello');
      });

      test('should handle is_read as true', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 12, 27, 14, 30));

        when(() => mockDoc.id).thenReturn('msg123');
        when(() => mockDoc.data()).thenReturn({
          'message': 'Hello',
          'sender_id': 'user1',
          'receiver_id': 'user2',
          'timestamp': timestamp,
          'is_read': true,
        });

        final message = Message.fromFirestore(mockDoc);

        expect(message.isRead, true);
      });

      test('should handle is_read as false', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 12, 27, 14, 30));

        when(() => mockDoc.id).thenReturn('msg123');
        when(() => mockDoc.data()).thenReturn({
          'message': 'Hello',
          'sender_id': 'user1',
          'receiver_id': 'user2',
          'timestamp': timestamp,
          'is_read': false,
        });

        final message = Message.fromFirestore(mockDoc);

        expect(message.isRead, false);
      });
    });

    group('toFirestore', () {
      test('should convert Message to Firestore map with all fields', () {
        final timestamp = DateTime(2025, 12, 27, 16, 0);
        final message = Message(
          id: 'msg123',
          message: 'Hello World!',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: timestamp,
          isRead: true,
        );

        final firestoreMap = message.toFirestore();

        expect(firestoreMap['message'], 'Hello World!');
        expect(firestoreMap['sender_id'], 'sender1');
        expect(firestoreMap['receiver_id'], 'receiver1');
        expect(firestoreMap['timestamp'], isA<Timestamp>());
        expect((firestoreMap['timestamp'] as Timestamp).toDate(), timestamp);
        expect(firestoreMap['is_read'], true);
      });

      test('should not include id in Firestore map', () {
        final message = Message(
          id: 'msg123',
          message: 'Hello',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: DateTime.now(),
        );

        final firestoreMap = message.toFirestore();

        expect(firestoreMap.containsKey('id'), isFalse);
      });

      test('should return map with exactly 5 keys', () {
        final message = Message(
          id: 'msg123',
          message: 'Hello',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: DateTime.now(),
        );

        final firestoreMap = message.toFirestore();

        expect(firestoreMap.length, 5);
        expect(firestoreMap.containsKey('message'), isTrue);
        expect(firestoreMap.containsKey('sender_id'), isTrue);
        expect(firestoreMap.containsKey('receiver_id'), isTrue);
        expect(firestoreMap.containsKey('timestamp'), isTrue);
        expect(firestoreMap.containsKey('is_read'), isTrue);
      });

      test('should handle empty strings', () {
        final message = Message(
          id: '',
          message: '',
          senderId: '',
          receiverId: '',
          timestamp: DateTime.now(),
        );

        final firestoreMap = message.toFirestore();

        expect(firestoreMap['message'], '');
        expect(firestoreMap['sender_id'], '');
        expect(firestoreMap['receiver_id'], '');
      });

      test('should correctly convert DateTime to Timestamp', () {
        final dateTime = DateTime(2025, 1, 15, 12, 30, 45);
        final message = Message(
          id: 'msg123',
          message: 'Test',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: dateTime,
        );

        final firestoreMap = message.toFirestore();
        final timestamp = firestoreMap['timestamp'] as Timestamp;

        expect(timestamp.toDate(), dateTime);
      });

      test('should handle isRead as false', () {
        final message = Message(
          id: 'msg123',
          message: 'Test',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: DateTime.now(),
          isRead: false,
        );

        final firestoreMap = message.toFirestore();

        expect(firestoreMap['is_read'], false);
      });

      test('should handle isRead as true', () {
        final message = Message(
          id: 'msg123',
          message: 'Test',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: DateTime.now(),
          isRead: true,
        );

        final firestoreMap = message.toFirestore();

        expect(firestoreMap['is_read'], true);
      });

      test('should handle special characters in message content', () {
        final specialMessage = 'Hello! @#\$%^&*() 🎉 émoji ñ';
        final message = Message(
          id: 'msg123',
          message: specialMessage,
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: DateTime.now(),
        );

        final firestoreMap = message.toFirestore();

        expect(firestoreMap['message'], specialMessage);
      });
    });

    group('Round-trip serialization', () {
      test('should maintain data integrity through toFirestore and fromFirestore', () {
        final originalTimestamp = DateTime(2025, 12, 27, 18, 30);
        final originalMessage = Message(
          id: 'msg123',
          message: 'Test message content',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: originalTimestamp,
          isRead: true,
        );

        // Convert to Firestore format
        final firestoreData = originalMessage.toFirestore();

        // Mock document snapshot with the Firestore data
        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('msg123');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        // Convert back from Firestore
        final restoredMessage = Message.fromFirestore(mockDoc);

        expect(restoredMessage.id, originalMessage.id);
        expect(restoredMessage.message, originalMessage.message);
        expect(restoredMessage.senderId, originalMessage.senderId);
        expect(restoredMessage.receiverId, originalMessage.receiverId);
        expect(restoredMessage.timestamp, originalMessage.timestamp);
        expect(restoredMessage.isRead, originalMessage.isRead);
      });

      test('should handle round-trip with isRead false', () {
        final originalTimestamp = DateTime(2025, 12, 27, 18, 30);
        final originalMessage = Message(
          id: 'msg456',
          message: 'Another test',
          senderId: 'userA',
          receiverId: 'userB',
          timestamp: originalTimestamp,
          isRead: false,
        );

        final firestoreData = originalMessage.toFirestore();

        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('msg456');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        final restoredMessage = Message.fromFirestore(mockDoc);

        expect(restoredMessage.isRead, false);
      });

      test('should handle round-trip with empty message', () {
        final originalMessage = Message(
          id: 'msg789',
          message: '',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: DateTime.now(),
        );

        final firestoreData = originalMessage.toFirestore();

        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('msg789');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        final restoredMessage = Message.fromFirestore(mockDoc);

        expect(restoredMessage.message, '');
      });

      test('should handle round-trip with special characters', () {
        final specialContent = 'Test 🎉 with émojis & spëcial chars!';
        final originalMessage = Message(
          id: 'msg999',
          message: specialContent,
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: DateTime.now(),
        );

        final firestoreData = originalMessage.toFirestore();

        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('msg999');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        final restoredMessage = Message.fromFirestore(mockDoc);

        expect(restoredMessage.message, specialContent);
      });
    });

    group('Edge Cases', () {
      test('should handle same sender and receiver ID', () {
        final message = Message(
          id: 'msg123',
          message: 'Self message',
          senderId: 'sameUser',
          receiverId: 'sameUser',
          timestamp: DateTime.now(),
        );

        expect(message.senderId, message.receiverId);
      });

      test('should handle timestamp at epoch', () {
        final epochTime = DateTime.fromMillisecondsSinceEpoch(0);
        final message = Message(
          id: 'msg123',
          message: 'Old message',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: epochTime,
        );

        expect(message.timestamp, epochTime);
      });

      test('should handle future timestamp', () {
        final futureTime = DateTime(2050, 1, 1, 0, 0);
        final message = Message(
          id: 'msg123',
          message: 'Future message',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: futureTime,
        );

        expect(message.timestamp, futureTime);
      });

      test('should handle whitespace-only message', () {
        final message = Message(
          id: 'msg123',
          message: '   \t\n  ',
          senderId: 'sender1',
          receiverId: 'receiver1',
          timestamp: DateTime.now(),
        );

        expect(message.message, '   \t\n  ');
      });

      test('should handle user IDs with special characters', () {
        final message = Message(
          id: 'msg123',
          message: 'Test',
          senderId: 'user@email.com',
          receiverId: 'user+special_chars',
          timestamp: DateTime.now(),
        );

        expect(message.senderId, 'user@email.com');
        expect(message.receiverId, 'user+special_chars');
      });
    });
  });
}
