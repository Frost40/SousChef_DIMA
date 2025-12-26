import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sous_chef/providers/chat_provider.dart';
import 'package:sous_chef/services/database/messages_firestore.dart';
import 'package:sous_chef/models/chat.dart';
import 'package:sous_chef/models/message.dart';
import '../mocks/mock_services.dart';
import '../mocks/mock_models.dart';

/// Mock Firestore classes for ChatProvider tests
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('ChatProvider Tests', () {
    late ChatProvider chatProvider;
    late MockChatFirestore mockChatFirestore;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockChatFirestore = MockChatFirestore();
      mockFirestore = MockFirebaseFirestore();
      
      // Use dependency injection to inject mock services
      chatProvider = ChatProvider(
        chatFirestore: mockChatFirestore,
        firestore: mockFirestore,
      );
      
      // Register fallback values
      registerFallbackValue(MockModels.createMockChat());
      registerFallbackValue(MockModels.createMockMessage());
    });

    tearDown(() {
      chatProvider.dispose();
    });

    group('State Management', () {
      test('initial state should have empty chats list and not loading', () {
        expect(chatProvider.chats, isEmpty);
        expect(chatProvider.isLoading, false);
        expect(chatProvider.errorMessage, isNull);
      });

      test('totalUnreadCount should be 0 initially', () {
        expect(chatProvider.totalUnreadCount, 0);
        expect(chatProvider.hasUnreadMessages, false);
      });
    });

    group('setCurrentUserId', () {
      test('should set user ID', () {
        // Act
        chatProvider.setCurrentUserId('user123');

        // No exception means success - internal state changed
        expect(true, true);
      });

      test('should clear chats when user ID set to null', () {
        // Arrange
        chatProvider.setCurrentUserId('user123');

        // Act
        chatProvider.setCurrentUserId(null);

        // Assert
        expect(chatProvider.chats, isEmpty);
      });
    });

    group('loadUserChats', () {
      test('should set error when no user is authenticated', () async {
        // Act (no user ID set)
        await chatProvider.loadUserChats();

        // Assert
        expect(chatProvider.errorMessage, 'No authenticated user');
      });

      test('should load user chats successfully', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final mockChats = [
          MockModels.createMockChat(id: 'chat1', user1Id: 'user123', user2Id: 'user456'),
          MockModels.createMockChat(id: 'chat2', user1Id: 'user123', user2Id: 'user789'),
        ];
        
        when(() => mockChatFirestore.getUserChats(any()))
            .thenAnswer((_) async => mockChats);
        when(() => mockChatFirestore.getUnreadMessagesCount(any(), any()))
            .thenAnswer((_) async => 0);

        // Setup mock Firestore for user data
        final mockCollection = MockCollectionReference();
        final mockDoc = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();
        
        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc(any())).thenReturn(mockDoc);
        when(() => mockDoc.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        // Act
        await chatProvider.loadUserChats();

        // Assert
        expect(chatProvider.isLoading, false);
        verify(() => mockChatFirestore.getUserChats('user123')).called(1);
      });

      test('should set error message on load failure', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        when(() => mockChatFirestore.getUserChats(any()))
            .thenThrow(Exception('Network error'));

        // Act
        await chatProvider.loadUserChats();

        // Assert
        expect(chatProvider.isLoading, false);
        expect(chatProvider.errorMessage, isNotNull);
      });
    });

    group('sendMessage', () {
      test('should not send when no user is authenticated', () async {
        // Act (no user ID set)
        await chatProvider.sendMessage(
          chatId: 'chat123',
          receiverId: 'user456',
          message: 'Hello',
        );

        // Assert
        expect(chatProvider.errorMessage, 'No authenticated user');
      });

      test('should send message successfully', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        when(() => mockChatFirestore.sendMessage(
          chatId: any(named: 'chatId'),
          senderId: any(named: 'senderId'),
          receiverId: any(named: 'receiverId'),
          message: any(named: 'message'),
        )).thenAnswer((_) async => MockModels.createMockMessage());

        // Act
        await chatProvider.sendMessage(
          chatId: 'chat123',
          receiverId: 'user456',
          message: 'Hello',
        );

        // Assert
        expect(chatProvider.errorMessage, isNull);
        verify(() => mockChatFirestore.sendMessage(
          chatId: 'chat123',
          senderId: 'user123',
          receiverId: 'user456',
          message: 'Hello',
        )).called(1);
      });

      test('should set error message on send failure', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        when(() => mockChatFirestore.sendMessage(
          chatId: any(named: 'chatId'),
          senderId: any(named: 'senderId'),
          receiverId: any(named: 'receiverId'),
          message: any(named: 'message'),
        )).thenThrow(Exception('Send failed'));

        // Act
        await chatProvider.sendMessage(
          chatId: 'chat123',
          receiverId: 'user456',
          message: 'Hello',
        );

        // Assert
        expect(chatProvider.errorMessage, isNotNull);
      });
    });

    group('markMessagesAsRead', () {
      test('should not mark when no user is authenticated', () async {
        // Act (no user ID set)
        await chatProvider.markMessagesAsRead('chat123');

        // No error, just silent return
        verifyNever(() => mockChatFirestore.markMessagesAsRead(any(), any()));
      });

      test('should mark messages as read successfully', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        when(() => mockChatFirestore.markMessagesAsRead(any(), any()))
            .thenAnswer((_) async {});

        // Act
        await chatProvider.markMessagesAsRead('chat123');

        // Assert
        verify(() => mockChatFirestore.markMessagesAsRead('chat123', 'user123')).called(1);
      });
    });

    group('findExistingChat', () {
      test('should return null when no user is authenticated', () {
        // Act
        final result = chatProvider.findExistingChat('user456');

        // Assert
        expect(result, isNull);
      });
    });

    group('chatHasMessages', () {
      test('should return true when chat has messages', () async {
        // Arrange
        final mockMessages = [MockModels.createMockMessage()];
        when(() => mockChatFirestore.getMessages(any()))
            .thenAnswer((_) async => mockMessages);

        // Act
        final result = await chatProvider.chatHasMessages('chat123');

        // Assert
        expect(result, true);
        verify(() => mockChatFirestore.getMessages('chat123')).called(1);
      });

      test('should return false when chat has no messages', () async {
        // Arrange
        when(() => mockChatFirestore.getMessages(any()))
            .thenAnswer((_) async => []);

        // Act
        final result = await chatProvider.chatHasMessages('chat123');

        // Assert
        expect(result, false);
      });

      test('should return false on error', () async {
        // Arrange
        when(() => mockChatFirestore.getMessages(any()))
            .thenThrow(Exception('Error'));

        // Act
        final result = await chatProvider.chatHasMessages('chat123');

        // Assert
        expect(result, false);
      });
    });

    group('createChat', () {
      test('should not create when no user is authenticated', () async {
        // Act
        final result = await chatProvider.createChat('user456');

        // Assert
        expect(result, isNull);
        expect(chatProvider.errorMessage, 'No authenticated user');
      });

      test('should create chat successfully', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        when(() => mockChatFirestore.createNewChat(
          user1Id: any(named: 'user1Id'),
          user2Id: any(named: 'user2Id'),
        )).thenAnswer((_) async => 'newChat123');

        // Act
        final result = await chatProvider.createChat('user456');

        // Assert
        expect(result, 'newChat123');
        expect(chatProvider.isLoading, false);
        verify(() => mockChatFirestore.createNewChat(
          user1Id: 'user123',
          user2Id: 'user456',
        )).called(1);
      });

      test('should set error on creation failure', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        when(() => mockChatFirestore.createNewChat(
          user1Id: any(named: 'user1Id'),
          user2Id: any(named: 'user2Id'),
        )).thenThrow(Exception('Creation failed'));

        // Act
        final result = await chatProvider.createChat('user456');

        // Assert
        expect(result, isNull);
        expect(chatProvider.errorMessage, isNotNull);
      });
    });

    group('deleteChat', () {
      test('should delete chat successfully', () async {
        // Arrange
        when(() => mockChatFirestore.deleteChat(any()))
            .thenAnswer((_) async {});

        // Act
        await chatProvider.deleteChat('chat123');

        // Assert
        expect(chatProvider.isLoading, false);
        verify(() => mockChatFirestore.deleteChat('chat123')).called(1);
      });

      test('should set error on deletion failure', () async {
        // Arrange
        when(() => mockChatFirestore.deleteChat(any()))
            .thenThrow(Exception('Delete failed'));

        // Act
        await chatProvider.deleteChat('chat123');

        // Assert
        expect(chatProvider.errorMessage, isNotNull);
      });
    });

    group('getMessages', () {
      test('should return messages for chat', () async {
        // Arrange
        final mockMessages = [
          MockModels.createMockMessage(id: 'msg1', message: 'Hello'),
          MockModels.createMockMessage(id: 'msg2', message: 'Hi there'),
        ];
        when(() => mockChatFirestore.getMessages(any()))
            .thenAnswer((_) async => mockMessages);

        // Act
        final result = await chatProvider.getMessages('chat123');

        // Assert
        expect(result.length, 2);
        expect(result[0].id, 'msg1');
        verify(() => mockChatFirestore.getMessages('chat123')).called(1);
      });

      test('should return empty list on error', () async {
        // Arrange
        when(() => mockChatFirestore.getMessages(any()))
            .thenThrow(Exception('Error'));

        // Act
        final result = await chatProvider.getMessages('chat123');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('clearAllChats', () {
      test('should clear all chat data', () {
        // Arrange
        chatProvider.setCurrentUserId('user123');

        // Act
        chatProvider.clearAllChats();

        // Assert
        expect(chatProvider.chats, isEmpty);
        expect(chatProvider.isLoading, false);
        expect(chatProvider.errorMessage, isNull);
      });
    });

    group('clearErrors', () {
      test('should clear error message', () {
        // Act
        chatProvider.clearErrors();

        // Assert
        expect(chatProvider.errorMessage, isNull);
      });
    });

    group('Unread Messages', () {
      test('totalUnreadCount should return 0 when no chats', () {
        expect(chatProvider.totalUnreadCount, 0);
      });

      test('hasUnreadMessages should be false when no unread', () {
        expect(chatProvider.hasUnreadMessages, false);
      });
    });

    group('startListeningToChats', () {
      test('should set error when no user is authenticated', () {
        // Act
        chatProvider.startListeningToChats();

        // Assert
        expect(chatProvider.errorMessage, 'No authenticated user');
      });
    });

    group('stopListeningToChats', () {
      test('should stop listening without error', () {
        // Act
        chatProvider.stopListeningToChats();

        // No exception means success
        expect(true, true);
      });
    });
  });
}
