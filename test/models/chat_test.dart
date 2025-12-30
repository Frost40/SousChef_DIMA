import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/chat.dart';

// Mock class for DocumentSnapshot
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('Chat Model Tests', () {
    group('Constructor', () {
      test('should create Chat with all required fields', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'user1',
          user2Id: 'user2',
        );

        expect(chat.id, 'chat123');
        expect(chat.user1Id, 'user1');
        expect(chat.user2Id, 'user2');
        expect(chat.lastMessage, isNull);
        expect(chat.lastMessageTime, isNull);
        expect(chat.unreadCount, 0);
      });

      test('should create Chat with all optional fields', () {
        final messageTime = DateTime(2025, 12, 27, 10, 30);
        final chat = Chat(
          id: 'chat456',
          user1Id: 'userA',
          user2Id: 'userB',
          lastMessage: 'Hello there!',
          lastMessageTime: messageTime,
          unreadCount: 5,
        );

        expect(chat.id, 'chat456');
        expect(chat.user1Id, 'userA');
        expect(chat.user2Id, 'userB');
        expect(chat.lastMessage, 'Hello there!');
        expect(chat.lastMessageTime, messageTime);
        expect(chat.unreadCount, 5);
      });

      test('should default unreadCount to 0 when not provided', () {
        final chat = Chat(
          id: 'chat789',
          user1Id: 'user1',
          user2Id: 'user2',
        );

        expect(chat.unreadCount, 0);
      });

      test('should allow null lastMessage', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'user1',
          user2Id: 'user2',
          lastMessage: null,
        );

        expect(chat.lastMessage, isNull);
      });

      test('should allow null lastMessageTime', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'user1',
          user2Id: 'user2',
          lastMessageTime: null,
        );

        expect(chat.lastMessageTime, isNull);
      });

      test('should handle empty string user IDs', () {
        final chat = Chat(
          id: '',
          user1Id: '',
          user2Id: '',
        );

        expect(chat.id, '');
        expect(chat.user1Id, '');
        expect(chat.user2Id, '');
      });

      test('should handle empty lastMessage', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'user1',
          user2Id: 'user2',
          lastMessage: '',
        );

        expect(chat.lastMessage, '');
      });
    });

    group('fromFirestore', () {
      late MockDocumentSnapshot mockDoc;

      setUp(() {
        mockDoc = MockDocumentSnapshot();
      });

      test('should create Chat from Firestore document with all fields', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 12, 27, 14, 30));
        
        when(() => mockDoc.id).thenReturn('chat123');
        when(() => mockDoc.data()).thenReturn({
          'user1_id': 'user1',
          'user2_id': 'user2',
          'last_message': 'Hello!',
          'last_message_time': timestamp,
        });

        final chat = Chat.fromFirestore(mockDoc);

        expect(chat.id, 'chat123');
        expect(chat.user1Id, 'user1');
        expect(chat.user2Id, 'user2');
        expect(chat.lastMessage, 'Hello!');
        expect(chat.lastMessageTime, timestamp.toDate());
      });

      test('should handle missing user1_id with empty string default', () {
        when(() => mockDoc.id).thenReturn('chat123');
        when(() => mockDoc.data()).thenReturn({
          'user2_id': 'user2',
          'last_message': 'Hello!',
        });

        final chat = Chat.fromFirestore(mockDoc);

        expect(chat.user1Id, '');
      });

      test('should handle missing user2_id with empty string default', () {
        when(() => mockDoc.id).thenReturn('chat123');
        when(() => mockDoc.data()).thenReturn({
          'user1_id': 'user1',
          'last_message': 'Hello!',
        });

        final chat = Chat.fromFirestore(mockDoc);

        expect(chat.user2Id, '');
      });

      test('should handle null last_message', () {
        when(() => mockDoc.id).thenReturn('chat123');
        when(() => mockDoc.data()).thenReturn({
          'user1_id': 'user1',
          'user2_id': 'user2',
          'last_message': null,
        });

        final chat = Chat.fromFirestore(mockDoc);

        expect(chat.lastMessage, isNull);
      });

      test('should handle missing last_message field', () {
        when(() => mockDoc.id).thenReturn('chat123');
        when(() => mockDoc.data()).thenReturn({
          'user1_id': 'user1',
          'user2_id': 'user2',
        });

        final chat = Chat.fromFirestore(mockDoc);

        expect(chat.lastMessage, isNull);
      });

      test('should handle null last_message_time', () {
        when(() => mockDoc.id).thenReturn('chat123');
        when(() => mockDoc.data()).thenReturn({
          'user1_id': 'user1',
          'user2_id': 'user2',
          'last_message_time': null,
        });

        final chat = Chat.fromFirestore(mockDoc);

        expect(chat.lastMessageTime, isNull);
      });

      test('should handle missing last_message_time field', () {
        when(() => mockDoc.id).thenReturn('chat123');
        when(() => mockDoc.data()).thenReturn({
          'user1_id': 'user1',
          'user2_id': 'user2',
        });

        final chat = Chat.fromFirestore(mockDoc);

        expect(chat.lastMessageTime, isNull);
      });

      test('should handle empty Firestore document data', () {
        when(() => mockDoc.id).thenReturn('chat123');
        when(() => mockDoc.data()).thenReturn({});

        final chat = Chat.fromFirestore(mockDoc);

        expect(chat.id, 'chat123');
        expect(chat.user1Id, '');
        expect(chat.user2Id, '');
        expect(chat.lastMessage, isNull);
        expect(chat.lastMessageTime, isNull);
      });

      test('should correctly parse Timestamp to DateTime', () {
        final expectedDateTime = DateTime(2025, 6, 15, 9, 45, 30);
        final timestamp = Timestamp.fromDate(expectedDateTime);

        when(() => mockDoc.id).thenReturn('chat123');
        when(() => mockDoc.data()).thenReturn({
          'user1_id': 'user1',
          'user2_id': 'user2',
          'last_message_time': timestamp,
        });

        final chat = Chat.fromFirestore(mockDoc);

        expect(chat.lastMessageTime, expectedDateTime);
      });

      test('should handle Firestore document with extra fields', () {
        when(() => mockDoc.id).thenReturn('chat123');
        when(() => mockDoc.data()).thenReturn({
          'user1_id': 'user1',
          'user2_id': 'user2',
          'extra_field': 'should be ignored',
          'another_field': 123,
        });

        final chat = Chat.fromFirestore(mockDoc);

        expect(chat.id, 'chat123');
        expect(chat.user1Id, 'user1');
        expect(chat.user2Id, 'user2');
      });
    });

    group('toFirestore', () {
      test('should convert Chat to Firestore map with all fields', () {
        final messageTime = DateTime(2025, 12, 27, 16, 0);
        final chat = Chat(
          id: 'chat123',
          user1Id: 'user1',
          user2Id: 'user2',
          lastMessage: 'Goodbye!',
          lastMessageTime: messageTime,
          unreadCount: 3,
        );

        final firestoreMap = chat.toFirestore();

        expect(firestoreMap['user1_id'], 'user1');
        expect(firestoreMap['user2_id'], 'user2');
        expect(firestoreMap['last_message'], 'Goodbye!');
        expect(firestoreMap['last_message_time'], isA<Timestamp>());
        expect(
          (firestoreMap['last_message_time'] as Timestamp).toDate(),
          messageTime,
        );
      });

      test('should not include id in Firestore map', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'user1',
          user2Id: 'user2',
        );

        final firestoreMap = chat.toFirestore();

        expect(firestoreMap.containsKey('id'), isFalse);
      });

      test('should not include unreadCount in Firestore map', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'user1',
          user2Id: 'user2',
          unreadCount: 10,
        );

        final firestoreMap = chat.toFirestore();

        expect(firestoreMap.containsKey('unreadCount'), isFalse);
        expect(firestoreMap.containsKey('unread_count'), isFalse);
      });

      test('should handle null lastMessage', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'user1',
          user2Id: 'user2',
          lastMessage: null,
        );

        final firestoreMap = chat.toFirestore();

        expect(firestoreMap['last_message'], isNull);
      });

      test('should handle null lastMessageTime', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'user1',
          user2Id: 'user2',
          lastMessageTime: null,
        );

        final firestoreMap = chat.toFirestore();

        expect(firestoreMap['last_message_time'], isNull);
      });

      test('should handle empty strings', () {
        final chat = Chat(
          id: '',
          user1Id: '',
          user2Id: '',
          lastMessage: '',
        );

        final firestoreMap = chat.toFirestore();

        expect(firestoreMap['user1_id'], '');
        expect(firestoreMap['user2_id'], '');
        expect(firestoreMap['last_message'], '');
      });

      test('should return map with exactly 4 keys', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'user1',
          user2Id: 'user2',
        );

        final firestoreMap = chat.toFirestore();

        expect(firestoreMap.length, 4);
        expect(firestoreMap.containsKey('user1_id'), isTrue);
        expect(firestoreMap.containsKey('user2_id'), isTrue);
        expect(firestoreMap.containsKey('last_message'), isTrue);
        expect(firestoreMap.containsKey('last_message_time'), isTrue);
      });

      test('should correctly convert DateTime to Timestamp', () {
        final dateTime = DateTime(2025, 1, 15, 12, 30, 45);
        final chat = Chat(
          id: 'chat123',
          user1Id: 'user1',
          user2Id: 'user2',
          lastMessageTime: dateTime,
        );

        final firestoreMap = chat.toFirestore();
        final timestamp = firestoreMap['last_message_time'] as Timestamp;

        expect(timestamp.toDate(), dateTime);
      });
    });

    group('getOtherUserId', () {
      test('should return user2Id when currentUserId is user1Id', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'userA',
          user2Id: 'userB',
        );

        final otherUserId = chat.getOtherUserId('userA');

        expect(otherUserId, 'userB');
      });

      test('should return user1Id when currentUserId is user2Id', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'userA',
          user2Id: 'userB',
        );

        final otherUserId = chat.getOtherUserId('userB');

        expect(otherUserId, 'userA');
      });

      test('should return user2Id when currentUserId does not match either user', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'userA',
          user2Id: 'userB',
        );

        // When currentUserId doesn't match user1Id, it returns user1Id
        final otherUserId = chat.getOtherUserId('userC');

        expect(otherUserId, 'userA');
      });

      test('should handle empty currentUserId', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'userA',
          user2Id: 'userB',
        );

        final otherUserId = chat.getOtherUserId('');

        expect(otherUserId, 'userA');
      });

      test('should handle empty user1Id', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: '',
          user2Id: 'userB',
        );

        final otherUserId = chat.getOtherUserId('');

        expect(otherUserId, 'userB');
      });

      test('should handle both users with same id', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'sameUser',
          user2Id: 'sameUser',
        );

        final otherUserId = chat.getOtherUserId('sameUser');

        expect(otherUserId, 'sameUser');
      });

      test('should work correctly with special characters in user IDs', () {
        final chat = Chat(
          id: 'chat123',
          user1Id: 'user@email.com',
          user2Id: 'user+special_chars',
        );

        expect(chat.getOtherUserId('user@email.com'), 'user+special_chars');
        expect(chat.getOtherUserId('user+special_chars'), 'user@email.com');
      });

      test('should work correctly with long user IDs', () {
        final longUserId1 = 'a' * 100;
        final longUserId2 = 'b' * 100;
        final chat = Chat(
          id: 'chat123',
          user1Id: longUserId1,
          user2Id: longUserId2,
        );

        expect(chat.getOtherUserId(longUserId1), longUserId2);
        expect(chat.getOtherUserId(longUserId2), longUserId1);
      });
    });

    group('Round-trip serialization', () {
      test('should maintain data integrity through toFirestore and fromFirestore', () {
        final originalTime = DateTime(2025, 12, 27, 18, 30);
        final originalChat = Chat(
          id: 'chat123',
          user1Id: 'user1',
          user2Id: 'user2',
          lastMessage: 'Test message',
          lastMessageTime: originalTime,
          unreadCount: 7,
        );

        // Convert to Firestore format
        final firestoreData = originalChat.toFirestore();

        // Mock document snapshot with the Firestore data
        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('chat123');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        // Convert back from Firestore
        final restoredChat = Chat.fromFirestore(mockDoc);

        expect(restoredChat.id, originalChat.id);
        expect(restoredChat.user1Id, originalChat.user1Id);
        expect(restoredChat.user2Id, originalChat.user2Id);
        expect(restoredChat.lastMessage, originalChat.lastMessage);
        expect(restoredChat.lastMessageTime, originalChat.lastMessageTime);
        // Note: unreadCount is not persisted in Firestore, so it won't be restored
      });

      test('should handle round-trip with null optional fields', () {
        final originalChat = Chat(
          id: 'chat456',
          user1Id: 'userX',
          user2Id: 'userY',
          lastMessage: null,
          lastMessageTime: null,
        );

        final firestoreData = originalChat.toFirestore();

        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('chat456');
        when(() => mockDoc.data()).thenReturn(firestoreData);

        final restoredChat = Chat.fromFirestore(mockDoc);

        expect(restoredChat.id, originalChat.id);
        expect(restoredChat.user1Id, originalChat.user1Id);
        expect(restoredChat.user2Id, originalChat.user2Id);
        expect(restoredChat.lastMessage, isNull);
        expect(restoredChat.lastMessageTime, isNull);
      });
    });
  });
}
