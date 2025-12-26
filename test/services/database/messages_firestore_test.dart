import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/models/chat.dart';
import 'package:sous_chef/models/message.dart';
import 'package:sous_chef/services/database/messages_firestore.dart';
import '../../mocks/mock_models.dart';

/// Mock Firestore classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}
class MockWriteBatch extends Mock implements WriteBatch {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockFilter extends Mock implements Filter {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockDocumentReference());
    registerFallbackValue(MockFilter());
  });

  group('ChatFirestore Service Tests', () {
    late ChatFirestore chatFirestore;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockChatsCollection;
    late MockDocumentReference mockChatDoc;
    late MockCollectionReference mockMessagesCollection;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockChatsCollection = MockCollectionReference();
      mockChatDoc = MockDocumentReference();
      mockMessagesCollection = MockCollectionReference();

      // Setup chain BEFORE creating ChatFirestore
      when(() => mockFirestore.collection('chats'))
          .thenReturn(mockChatsCollection);
      when(() => mockChatsCollection.doc(any()))
          .thenReturn(mockChatDoc);
      when(() => mockChatDoc.collection('messages'))
          .thenReturn(mockMessagesCollection);

      // Create ChatFirestore with mock Firestore
      chatFirestore = ChatFirestore(firestoreInstance: mockFirestore);
    });

    group('getUserChats', () {
      test('should return list of chats for user', () async {
        // Arrange
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockDoc1 = MockQueryDocumentSnapshot();
        final mockDoc2 = MockQueryDocumentSnapshot();
        final mockQuery = MockQuery();

        when(() => mockChatsCollection.where(any<Filter>()))
            .thenReturn(mockQuery);
        when(() => mockQuery.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
        
        when(() => mockDoc1.id).thenReturn('chat1');
        when(() => mockDoc1.data()).thenReturn({
          'user1_id': 'user123',
          'user2_id': 'user456',
          'last_message': 'Hello',
          'last_message_time': Timestamp.now(),
        });
        
        when(() => mockDoc2.id).thenReturn('chat2');
        when(() => mockDoc2.data()).thenReturn({
          'user1_id': 'user123',
          'user2_id': 'user789',
          'last_message': 'Hi there',
          'last_message_time': Timestamp.now(),
        });

        // Act
        final result = await chatFirestore.getUserChats('user123');

        // Assert
        expect(result.length, 2);
        expect(result[0].id, isNotNull);
      });

      test('should return empty list when no chats', () async {
        // Arrange
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockQuery = MockQuery();

        when(() => mockChatsCollection.where(any<Filter>()))
            .thenReturn(mockQuery);
        when(() => mockQuery.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([]);

        // Act
        final result = await chatFirestore.getUserChats('user123');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getChatMessages', () {
      test('should return messages ordered by timestamp', () async {
        // Arrange
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockMessage1 = MockQueryDocumentSnapshot();
        final mockMessage2 = MockQueryDocumentSnapshot();
        final mockQuery = MockQuery();

        when(() => mockMessagesCollection.orderBy('timestamp', descending: false))
            .thenReturn(mockQuery);
        when(() => mockQuery.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockMessage1, mockMessage2]);
        
        when(() => mockMessage1.id).thenReturn('msg1');
        when(() => mockMessage1.data()).thenReturn({
          'sender_id': 'user1',
          'receiver_id': 'user2',
          'message': 'Hello',
          'timestamp': Timestamp.now(),
          'is_read': false,
        });
        
        when(() => mockMessage2.id).thenReturn('msg2');
        when(() => mockMessage2.data()).thenReturn({
          'sender_id': 'user2',
          'receiver_id': 'user1',
          'message': 'Hi back',
          'timestamp': Timestamp.now(),
          'is_read': true,
        });

        // Act
        final result = await chatFirestore.getChatMessages('chat123');

        // Assert
        expect(result.length, 2);
        expect(result[0].id, 'msg1');
        expect(result[0].message, 'Hello');
      });

      test('should return empty list when no messages', () async {
        // Arrange
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockQuery = MockQuery();

        when(() => mockMessagesCollection.orderBy('timestamp', descending: false))
            .thenReturn(mockQuery);
        when(() => mockQuery.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([]);

        // Act
        final result = await chatFirestore.getChatMessages('chat123');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getMessages', () {
      test('should be an alias for getChatMessages', () async {
        // Arrange
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockQuery = MockQuery();

        when(() => mockMessagesCollection.orderBy('timestamp', descending: false))
            .thenReturn(mockQuery);
        when(() => mockQuery.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([]);

        // Act
        final result = await chatFirestore.getMessages('chat123');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getUnreadMessagesCount', () {
      test('should return count of unread messages', () async {
        // Arrange
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockDoc1 = MockQueryDocumentSnapshot();
        final mockDoc2 = MockQueryDocumentSnapshot();
        final mockQuery = MockQuery();
        final mockQuery2 = MockQuery();

        when(() => mockMessagesCollection.where('receiver_id', isEqualTo: 'user123'))
            .thenReturn(mockQuery);
        when(() => mockQuery.where('is_read', isEqualTo: false))
            .thenReturn(mockQuery2);
        when(() => mockQuery2.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

        // Act
        final result = await chatFirestore.getUnreadMessagesCount('chat123', 'user123');

        // Assert
        expect(result, 2);
      });

      test('should return 0 when no unread messages', () async {
        // Arrange
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockQuery = MockQuery();
        final mockQuery2 = MockQuery();

        when(() => mockMessagesCollection.where('receiver_id', isEqualTo: 'user123'))
            .thenReturn(mockQuery);
        when(() => mockQuery.where('is_read', isEqualTo: false))
            .thenReturn(mockQuery2);
        when(() => mockQuery2.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([]);

        // Act
        final result = await chatFirestore.getUnreadMessagesCount('chat123', 'user123');

        // Assert
        expect(result, 0);
      });
    });

    group('sendMessage', () {
      test('should create message and update chat', () async {
        // Arrange
        final mockMessageDoc = MockDocumentReference();
        final mockCreatedDoc = MockDocumentSnapshot();

        when(() => mockMessagesCollection.add(any()))
            .thenAnswer((_) async => mockMessageDoc);
        when(() => mockChatDoc.update(any()))
            .thenAnswer((_) async {});
        when(() => mockMessageDoc.get())
            .thenAnswer((_) async => mockCreatedDoc);
        
        when(() => mockCreatedDoc.id).thenReturn('newMsg123');
        when(() => mockCreatedDoc.data()).thenReturn({
          'sender_id': 'user1',
          'receiver_id': 'user2',
          'message': 'Test message',
          'timestamp': Timestamp.now(),
          'is_read': false,
        });
        when(() => mockCreatedDoc.exists).thenReturn(true);

        // Act
        final result = await chatFirestore.sendMessage(
          chatId: 'chat123',
          senderId: 'user1',
          receiverId: 'user2',
          message: 'Test message',
        );

        // Assert
        expect(result.id, 'newMsg123');
        expect(result.message, 'Test message');
        verify(() => mockMessagesCollection.add(any())).called(1);
        verify(() => mockChatDoc.update(any())).called(1);
      });
    });

    group('markMessagesAsRead', () {
      test('should mark all unread messages as read', () async {
        // Arrange
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockDoc1 = MockQueryDocumentSnapshot();
        final mockDoc2 = MockQueryDocumentSnapshot();
        final mockBatch = MockWriteBatch();
        final mockQuery = MockQuery();
        final mockQuery2 = MockQuery();
        final mockDocRef1 = MockDocumentReference();
        final mockDocRef2 = MockDocumentReference();

        when(() => mockMessagesCollection.where('receiver_id', isEqualTo: 'user123'))
            .thenReturn(mockQuery);
        when(() => mockQuery.where('is_read', isEqualTo: false))
            .thenReturn(mockQuery2);
        when(() => mockQuery2.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
        
        when(() => mockDoc1.reference).thenReturn(mockDocRef1);
        when(() => mockDoc2.reference).thenReturn(mockDocRef2);
        
        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.update(any(), any())).thenReturn(null);
        when(() => mockBatch.commit()).thenAnswer((_) async {});

        // Act
        await chatFirestore.markMessagesAsRead('chat123', 'user123');

        // Assert
        verify(() => mockBatch.update(mockDocRef1, {'is_read': true})).called(1);
        verify(() => mockBatch.update(mockDocRef2, {'is_read': true})).called(1);
        verify(() => mockBatch.commit()).called(1);
      });
    });

    group('createNewChat', () {
      test('should return existing chat ID if chat exists', () async {
        // Arrange
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockExistingChat = MockQueryDocumentSnapshot();
        final mockQuery = MockQuery();

        when(() => mockChatsCollection.where(any<Filter>()))
            .thenReturn(mockQuery);
        when(() => mockQuery.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockExistingChat]);
        when(() => mockExistingChat.id).thenReturn('existingChat123');

        // Act
        final result = await chatFirestore.createNewChat(
          user1Id: 'user1',
          user2Id: 'user2',
        );

        // Assert
        expect(result, 'existingChat123');
      });

      test('should create new chat if none exists', () async {
        // Arrange
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockNewChatDoc = MockDocumentReference();
        final mockQuery = MockQuery();

        when(() => mockChatsCollection.where(any<Filter>()))
            .thenReturn(mockQuery);
        when(() => mockQuery.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([]);
        
        when(() => mockChatsCollection.add(any()))
            .thenAnswer((_) async => mockNewChatDoc);
        when(() => mockNewChatDoc.id).thenReturn('newChat123');

        // Act
        final result = await chatFirestore.createNewChat(
          user1Id: 'user1',
          user2Id: 'user2',
        );

        // Assert
        expect(result, 'newChat123');
        verify(() => mockChatsCollection.add(any())).called(1);
      });
    });

    group('deleteChat', () {
      test('should delete all messages and the chat', () async {
        // Arrange
        final mockMessagesSnapshot = MockQuerySnapshot();
        final mockMsg1 = MockQueryDocumentSnapshot();
        final mockMsg2 = MockQueryDocumentSnapshot();
        final mockBatch = MockWriteBatch();
        final mockMsgRef1 = MockDocumentReference();
        final mockMsgRef2 = MockDocumentReference();

        when(() => mockMessagesCollection.get())
            .thenAnswer((_) async => mockMessagesSnapshot);
        when(() => mockMessagesSnapshot.docs).thenReturn([mockMsg1, mockMsg2]);
        
        when(() => mockMsg1.reference).thenReturn(mockMsgRef1);
        when(() => mockMsg2.reference).thenReturn(mockMsgRef2);
        
        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.delete(any())).thenReturn(null);
        when(() => mockBatch.commit()).thenAnswer((_) async {});

        // Act
        await chatFirestore.deleteChat('chat123');

        // Assert
        verify(() => mockBatch.delete(mockMsgRef1)).called(1);
        verify(() => mockBatch.delete(mockMsgRef2)).called(1);
        verify(() => mockBatch.delete(mockChatDoc)).called(1);
        verify(() => mockBatch.commit()).called(1);
      });
    });

    group('Mock Models Integration', () {
      test('createMockChat should create valid chat instance', () {
        final chat = MockModels.createMockChat(
          id: 'chat123',
          user1Id: 'user1',
          user2Id: 'user2',
        );

        expect(chat.id, 'chat123');
        expect(chat.user1Id, 'user1');
        expect(chat.user2Id, 'user2');
      });

      test('createMockMessage should create valid message instance', () {
        final message = MockModels.createMockMessage(
          id: 'msg123',
          message: 'Hello World',
        );

        expect(message.id, 'msg123');
        expect(message.message, 'Hello World');
      });
    });
  });
}
