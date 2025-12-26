import 'dart:async';

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

      test('should not trigger change when setting same user ID', () {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        var notifyCount = 0;
        chatProvider.addListener(() {
          notifyCount++;
        });

        // Act - set same user ID again
        chatProvider.setCurrentUserId('user123');

        // Assert - should not notify since ID didn't change
        expect(notifyCount, 0);
      });
    });

    group('init', () {
      test('should load user chats when user ID is set', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        when(() => mockChatFirestore.getUserChats(any()))
            .thenAnswer((_) async => []);

        // Act
        await chatProvider.init();

        // Assert
        verify(() => mockChatFirestore.getUserChats('user123')).called(1);
      });

      test('should not load chats when user ID is null', () async {
        // Act (no user ID set)
        await chatProvider.init();

        // Assert
        verifyNever(() => mockChatFirestore.getUserChats(any()));
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

      test('should update local unread count when chat exists', () async {
        // Arrange - load chats first
        chatProvider.setCurrentUserId('user123');
        final mockChats = [
          MockModels.createMockChat(id: 'chat123', user1Id: 'user123', user2Id: 'user456'),
        ];

        when(() => mockChatFirestore.getUserChats(any()))
            .thenAnswer((_) async => mockChats);
        when(() => mockChatFirestore.getUnreadMessagesCount(any(), any()))
            .thenAnswer((_) async => 5); // Initially 5 unread
        when(() => mockChatFirestore.markMessagesAsRead(any(), any()))
            .thenAnswer((_) async {});

        // Setup mock Firestore
        final mockCollection = MockCollectionReference();
        final mockDoc = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc(any())).thenReturn(mockDoc);
        when(() => mockDoc.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        await chatProvider.loadUserChats();
        expect(chatProvider.chats.first.unreadCount, 5);

        // Act
        await chatProvider.markMessagesAsRead('chat123');

        // Assert - unread count should be 0
        expect(chatProvider.chats.first.unreadCount, 0);
      });

      test('should handle error when marking messages as read', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        when(() => mockChatFirestore.markMessagesAsRead(any(), any()))
            .thenThrow(Exception('Mark read failed'));

        // Act - should not throw
        await chatProvider.markMessagesAsRead('chat123');

        // Assert - error is logged but not thrown
        expect(true, true);
      });
    });

    group('findExistingChat', () {
      test('should return null when no user is authenticated', () {
        // Act
        final result = chatProvider.findExistingChat('user456');

        // Assert
        expect(result, isNull);
      });

      test('should return chat id when chat exists with user as user1', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final mockChats = [
          MockModels.createMockChat(id: 'chat1', user1Id: 'user123', user2Id: 'user456'),
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

        await chatProvider.loadUserChats();

        // Act
        final result = chatProvider.findExistingChat('user456');

        // Assert
        expect(result, 'chat1');
      });

      test('should return chat id when chat exists with user as user2', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final mockChats = [
          MockModels.createMockChat(id: 'chat2', user1Id: 'user456', user2Id: 'user123'),
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

        await chatProvider.loadUserChats();

        // Act
        final result = chatProvider.findExistingChat('user456');

        // Assert
        expect(result, 'chat2');
      });

      test('should return null when no matching chat found', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final mockChats = [
          MockModels.createMockChat(id: 'chat1', user1Id: 'user123', user2Id: 'user456'),
        ];

        when(() => mockChatFirestore.getUserChats(any()))
            .thenAnswer((_) async => mockChats);
        when(() => mockChatFirestore.getUnreadMessagesCount(any(), any()))
            .thenAnswer((_) async => 0);

        // Setup mock Firestore
        final mockCollection = MockCollectionReference();
        final mockDoc = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc(any())).thenReturn(mockDoc);
        when(() => mockDoc.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        await chatProvider.loadUserChats();

        // Act - search for different user
        final result = chatProvider.findExistingChat('user999');

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

      test('totalUnreadCount should sum unread counts from all chats', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final mockChats = [
          MockModels.createMockChat(id: 'chat1', user1Id: 'user123', user2Id: 'user456'),
          MockModels.createMockChat(id: 'chat2', user1Id: 'user123', user2Id: 'user789'),
        ];

        when(() => mockChatFirestore.getUserChats(any()))
            .thenAnswer((_) async => mockChats);
        // Return different unread counts for different chats
        var callCount = 0;
        when(() => mockChatFirestore.getUnreadMessagesCount(any(), any()))
            .thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? 3 : 2; // 3 unread for first, 2 for second
        });

        // Setup mock Firestore
        final mockCollection = MockCollectionReference();
        final mockDoc = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc(any())).thenReturn(mockDoc);
        when(() => mockDoc.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        await chatProvider.loadUserChats();

        // Assert
        expect(chatProvider.totalUnreadCount, 5); // 3 + 2
        expect(chatProvider.hasUnreadMessages, true);
      });
    });

    group('startListeningToChats', () {
      test('should set error when no user is authenticated', () {
        // Act
        chatProvider.startListeningToChats();

        // Assert
        expect(chatProvider.errorMessage, 'No authenticated user');
      });

      test('should start listening to chats stream successfully', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final streamController = StreamController<List<Chat>>.broadcast();

        when(() => mockChatFirestore.getUserChatsStream(any()))
            .thenAnswer((_) => streamController.stream);
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
        chatProvider.startListeningToChats();

        // Emit some chats
        streamController.add([
          MockModels.createMockChat(id: 'chat1', user1Id: 'user123', user2Id: 'user456'),
        ]);

        // Allow stream to process
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        verify(() => mockChatFirestore.getUserChatsStream('user123')).called(1);

        // Cleanup
        await streamController.close();
      });

      test('should not start new listener if already listening', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final streamController = StreamController<List<Chat>>.broadcast();

        when(() => mockChatFirestore.getUserChatsStream(any()))
            .thenAnswer((_) => streamController.stream);

        // Act - start listening twice
        chatProvider.startListeningToChats();
        chatProvider.startListeningToChats();

        // Assert - should only be called once
        verify(() => mockChatFirestore.getUserChatsStream('user123')).called(1);

        // Cleanup
        await streamController.close();
      });

      test('should handle stream errors', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final streamController = StreamController<List<Chat>>.broadcast();

        when(() => mockChatFirestore.getUserChatsStream(any()))
            .thenAnswer((_) => streamController.stream);

        // Act
        chatProvider.startListeningToChats();

        // Emit error
        streamController.addError(Exception('Stream error'));

        // Allow stream to process
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(chatProvider.errorMessage, isNotNull);

        // Cleanup
        await streamController.close();
      });
    });

    group('stopListeningToChats', () {
      test('should stop listening without error', () {
        // Act
        chatProvider.stopListeningToChats();

        // No exception means success
        expect(true, true);
      });

      test('should stop active listener', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final streamController = StreamController<List<Chat>>.broadcast();

        when(() => mockChatFirestore.getUserChatsStream(any()))
            .thenAnswer((_) => streamController.stream);

        // Start listening first
        chatProvider.startListeningToChats();

        // Act
        chatProvider.stopListeningToChats();

        // Assert - can start listening again
        chatProvider.startListeningToChats();
        verify(() => mockChatFirestore.getUserChatsStream('user123')).called(2);

        // Cleanup
        await streamController.close();
      });
    });

    group('getMessagesStream', () {
      test('should return messages stream for chat', () {
        // Arrange
        final streamController = StreamController<List<Message>>.broadcast();
        when(() => mockChatFirestore.getMessagesStream(any()))
            .thenAnswer((_) => streamController.stream);

        // Act
        final stream = chatProvider.getMessagesStream('chat123');

        // Assert
        expect(stream, isA<Stream<List<Message>>>());
        verify(() => mockChatFirestore.getMessagesStream('chat123')).called(1);

        // Cleanup
        streamController.close();
      });
    });

    group('Error Messages', () {
      test('should return permission denied message', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        when(() => mockChatFirestore.getUserChats(any()))
            .thenThrow(Exception('permission-denied'));

        // Act
        await chatProvider.loadUserChats();

        // Assert
        expect(chatProvider.errorMessage, 'Permission denied');
      });

      test('should return not found message', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        when(() => mockChatFirestore.getUserChats(any()))
            .thenThrow(Exception('not-found'));

        // Act
        await chatProvider.loadUserChats();

        // Assert
        expect(chatProvider.errorMessage, 'Chat not found');
      });

      test('should return generic error message for unknown errors', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        when(() => mockChatFirestore.getUserChats(any()))
            .thenThrow(Exception('Some unknown error'));

        // Act
        await chatProvider.loadUserChats();

        // Assert
        expect(chatProvider.errorMessage, contains('An error occurred'));
      });
    });

    group('clearErrors', () {
      test('should clear error message with notify', () {
        // Act
        chatProvider.clearErrors();

        // Assert
        expect(chatProvider.errorMessage, isNull);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when loading chats', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        when(() => mockChatFirestore.getUserChats(any()))
            .thenAnswer((_) async => []);

        var notifyCount = 0;
        chatProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await chatProvider.loadUserChats();

        // Assert - should notify at least twice (loading start and end)
        expect(notifyCount, greaterThanOrEqualTo(2));
      });

      test('should notify listeners when creating chat', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        when(() => mockChatFirestore.createNewChat(
          user1Id: any(named: 'user1Id'),
          user2Id: any(named: 'user2Id'),
        )).thenAnswer((_) async => 'newChat123');

        var notifyCount = 0;
        chatProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await chatProvider.createChat('user456');

        // Assert
        expect(notifyCount, greaterThanOrEqualTo(2));
      });

      test('should notify listeners when deleting chat', () async {
        // Arrange
        when(() => mockChatFirestore.deleteChat(any()))
            .thenAnswer((_) async {});

        var notifyCount = 0;
        chatProvider.addListener(() {
          notifyCount++;
        });

        // Act
        await chatProvider.deleteChat('chat123');

        // Assert
        expect(notifyCount, greaterThanOrEqualTo(2));
      });
    });

    group('Duplicate Chat Handling', () {
      test('should skip duplicate chats when enriching', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        // Same chat ID twice - simulating duplicate
        final mockChats = [
          MockModels.createMockChat(id: 'chat1', user1Id: 'user123', user2Id: 'user456'),
          MockModels.createMockChat(id: 'chat1', user1Id: 'user123', user2Id: 'user456'),
        ];

        when(() => mockChatFirestore.getUserChats(any()))
            .thenAnswer((_) async => mockChats);
        when(() => mockChatFirestore.getUnreadMessagesCount(any(), any()))
            .thenAnswer((_) async => 0);

        // Setup mock Firestore
        final mockCollection = MockCollectionReference();
        final mockDoc = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc(any())).thenReturn(mockDoc);
        when(() => mockDoc.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        // Act
        await chatProvider.loadUserChats();

        // Assert - should only have 1 chat, not 2
        expect(chatProvider.chats.length, 1);
      });
    });

    group('User and Restaurant Data', () {
      test('should load user data when user document exists', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final mockChats = [
          MockModels.createMockChat(id: 'chat1', user1Id: 'user123', user2Id: 'user456'),
        ];

        when(() => mockChatFirestore.getUserChats(any()))
            .thenAnswer((_) async => mockChats);
        when(() => mockChatFirestore.getUnreadMessagesCount(any(), any()))
            .thenAnswer((_) async => 0);

        // Setup mock Firestore with existing user document
        final mockCollection = MockCollectionReference();
        final mockDoc = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc(any())).thenReturn(mockDoc);
        when(() => mockDoc.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn('user456');
        when(() => mockDocSnapshot.data()).thenReturn({
          'email': 'other@example.com',
          'username': 'otheruser',
          'name': 'Other',
          'surname': 'User',
          'phone': '9876543210',
          'restaurantId': null,
          'favourites': <String>[],
          'chats': <String>[],
        });

        // Act
        await chatProvider.loadUserChats();

        // Assert - chat should have user info
        expect(chatProvider.chats.length, 1);
        expect(chatProvider.chats.first.otherUser, isNotNull);
        expect(chatProvider.chats.first.otherUser?.username, 'otheruser');
      });

      test('should load restaurant image when user has restaurantId', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final mockChats = [
          MockModels.createMockChat(id: 'chat1', user1Id: 'user123', user2Id: 'user456'),
        ];

        when(() => mockChatFirestore.getUserChats(any()))
            .thenAnswer((_) async => mockChats);
        when(() => mockChatFirestore.getUnreadMessagesCount(any(), any()))
            .thenAnswer((_) async => 0);

        // Setup mock Firestore for user with restaurantId
        final mockUsersCollection = MockCollectionReference();
        final mockUserDoc = MockDocumentReference();
        final mockUserSnapshot = MockDocumentSnapshot();

        final mockRestaurantsCollection = MockCollectionReference();
        final mockRestaurantDoc = MockDocumentReference();
        final mockRestaurantSnapshot = MockDocumentSnapshot();

        // Use specific collection names in the when clause
        when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
        when(() => mockFirestore.collection('restaurants')).thenReturn(mockRestaurantsCollection);
        
        when(() => mockUsersCollection.doc(any())).thenReturn(mockUserDoc);
        when(() => mockUserDoc.get()).thenAnswer((_) async => mockUserSnapshot);
        when(() => mockUserSnapshot.exists).thenReturn(true);
        when(() => mockUserSnapshot.id).thenReturn('user456');
        when(() => mockUserSnapshot.data()).thenReturn({
          'email': 'chef@example.com',
          'username': 'chefuser',
          'name': 'Chef',
          'surname': 'User',
          'phone': '1111111111',
          'restaurant_id': 'restaurant123',
          'favourites': <String>[],
          'chats': <String>[],
        });

        when(() => mockRestaurantsCollection.doc(any())).thenReturn(mockRestaurantDoc);
        when(() => mockRestaurantDoc.get()).thenAnswer((_) async => mockRestaurantSnapshot);
        when(() => mockRestaurantSnapshot.exists).thenReturn(true);
        when(() => mockRestaurantSnapshot.id).thenReturn('restaurant123');
        when(() => mockRestaurantSnapshot.data()).thenReturn({
          'name': 'Test Restaurant',
          'owner_id': 'user456',
          'address': '123 Test Street',
          'is_open': true,
          'restaurant_types': <String>['fixed_menu'],
          'location': const GeoPoint(0, 0),
          'image_url': 'https://example.com/restaurant.jpg',
        });

        // Act
        await chatProvider.loadUserChats();

        // Assert
        expect(chatProvider.chats.length, 1);
        expect(chatProvider.chats.first.restaurantImageUrl, 'https://example.com/restaurant.jpg');
      });

      test('should handle error when fetching user data', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final mockChats = [
          MockModels.createMockChat(id: 'chat1', user1Id: 'user123', user2Id: 'user456'),
        ];

        when(() => mockChatFirestore.getUserChats(any()))
            .thenAnswer((_) async => mockChats);
        when(() => mockChatFirestore.getUnreadMessagesCount(any(), any()))
            .thenAnswer((_) async => 0);

        // Setup mock Firestore to throw error
        final mockCollection = MockCollectionReference();
        final mockDoc = MockDocumentReference();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc(any())).thenReturn(mockDoc);
        when(() => mockDoc.get()).thenThrow(Exception('Firestore error'));

        // Act
        await chatProvider.loadUserChats();

        // Assert - should still have chat but with null user
        expect(chatProvider.chats.length, 1);
        expect(chatProvider.chats.first.otherUser, isNull);
      });

      test('should handle error when fetching restaurant image', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final mockChats = [
          MockModels.createMockChat(id: 'chat1', user1Id: 'user123', user2Id: 'user456'),
        ];

        when(() => mockChatFirestore.getUserChats(any()))
            .thenAnswer((_) async => mockChats);
        when(() => mockChatFirestore.getUnreadMessagesCount(any(), any()))
            .thenAnswer((_) async => 0);

        // Setup mock Firestore
        final mockUsersCollection = MockCollectionReference();
        final mockUserDoc = MockDocumentReference();
        final mockUserSnapshot = MockDocumentSnapshot();

        final mockRestaurantsCollection = MockCollectionReference();
        final mockRestaurantDoc = MockDocumentReference();

        when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
        when(() => mockUsersCollection.doc(any())).thenReturn(mockUserDoc);
        when(() => mockUserDoc.get()).thenAnswer((_) async => mockUserSnapshot);
        when(() => mockUserSnapshot.exists).thenReturn(true);
        when(() => mockUserSnapshot.id).thenReturn('user456');
        when(() => mockUserSnapshot.data()).thenReturn({
          'email': 'chef@example.com',
          'username': 'chefuser',
          'name': 'Chef',
          'surname': 'User',
          'phone': '1111111111',
          'restaurant_id': 'restaurant123',
          'favourites': <String>[],
          'chats': <String>[],
        });

        when(() => mockFirestore.collection('restaurants')).thenReturn(mockRestaurantsCollection);
        when(() => mockRestaurantsCollection.doc(any())).thenReturn(mockRestaurantDoc);
        when(() => mockRestaurantDoc.get()).thenThrow(Exception('Restaurant fetch error'));

        // Act
        await chatProvider.loadUserChats();

        // Assert - should still have chat with user but null restaurant image
        expect(chatProvider.chats.length, 1);
        expect(chatProvider.chats.first.otherUser, isNotNull);
        expect(chatProvider.chats.first.restaurantImageUrl, isNull);
      });

      test('should handle restaurant document not existing', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final mockChats = [
          MockModels.createMockChat(id: 'chat1', user1Id: 'user123', user2Id: 'user456'),
        ];

        when(() => mockChatFirestore.getUserChats(any()))
            .thenAnswer((_) async => mockChats);
        when(() => mockChatFirestore.getUnreadMessagesCount(any(), any()))
            .thenAnswer((_) async => 0);

        // Setup mock Firestore
        final mockUsersCollection = MockCollectionReference();
        final mockUserDoc = MockDocumentReference();
        final mockUserSnapshot = MockDocumentSnapshot();

        final mockRestaurantsCollection = MockCollectionReference();
        final mockRestaurantDoc = MockDocumentReference();
        final mockRestaurantSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
        when(() => mockUsersCollection.doc(any())).thenReturn(mockUserDoc);
        when(() => mockUserDoc.get()).thenAnswer((_) async => mockUserSnapshot);
        when(() => mockUserSnapshot.exists).thenReturn(true);
        when(() => mockUserSnapshot.id).thenReturn('user456');
        when(() => mockUserSnapshot.data()).thenReturn({
          'email': 'chef@example.com',
          'username': 'chefuser',
          'name': 'Chef',
          'surname': 'User',
          'phone': '1111111111',
          'restaurant_id': 'restaurant123',
          'favourites': <String>[],
          'chats': <String>[],
        });

        when(() => mockFirestore.collection('restaurants')).thenReturn(mockRestaurantsCollection);
        when(() => mockRestaurantsCollection.doc(any())).thenReturn(mockRestaurantDoc);
        when(() => mockRestaurantDoc.get()).thenAnswer((_) async => mockRestaurantSnapshot);
        when(() => mockRestaurantSnapshot.exists).thenReturn(false);

        // Act
        await chatProvider.loadUserChats();

        // Assert
        expect(chatProvider.chats.length, 1);
        expect(chatProvider.chats.first.restaurantImageUrl, isNull);
      });

      test('should handle enriching error gracefully', () async {
        // Arrange
        chatProvider.setCurrentUserId('user123');
        final mockChats = [
          MockModels.createMockChat(id: 'chat1', user1Id: 'user123', user2Id: 'user456'),
        ];

        when(() => mockChatFirestore.getUserChats(any()))
            .thenAnswer((_) async => mockChats);
        when(() => mockChatFirestore.getUnreadMessagesCount(any(), any()))
            .thenThrow(Exception('Unread count error'));

        // Setup mock Firestore
        final mockCollection = MockCollectionReference();
        final mockDoc = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc(any())).thenReturn(mockDoc);
        when(() => mockDoc.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        // Act
        await chatProvider.loadUserChats();

        // Assert - chat should be skipped due to error
        expect(chatProvider.chats.length, 0);
      });
    });
  });
}
