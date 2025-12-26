import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sous_chef/models/chat.dart';
import 'package:sous_chef/models/message.dart';
import 'package:sous_chef/models/user.dart';
import 'package:sous_chef/models/restaurant.dart';
import 'package:sous_chef/services/database/messages_firestore.dart';

/// Provider that manages chat operations using the ChatFirestore service.
/// Implements ChangeNotifier to notify dependent widgets when chat data changes.
class ChatProvider with ChangeNotifier {
  // Service instances
  final ChatFirestore _chatFirestore;
  final FirebaseFirestore _firestore;

  /// Constructor with dependency injection for testability
  /// In production, defaults to real service instances
  ChatProvider({
    ChatFirestore? chatFirestore,
    FirebaseFirestore? firestore,
  })  : _chatFirestore = chatFirestore ?? ChatFirestore(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Current user ID from AuthProvider
  String? _currentUserId;

  // Current user chats with additional info
  List<ChatInfo> _chats = [];

  // Flag indicating if a data operation is in progress
  bool _isLoading = false;

  // Error message from the last operation
  String? _errorMessage;

  // Stream subscription for real-time chat updates
  StreamSubscription<List<Chat>>? _chatsSubscription;

  // Flag to track if listener is active
  bool _isListening = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ChatInfo> get chats => _chats;

  /// Get total count of unread messages across all chats
  int get totalUnreadCount {
    if (_chats.isEmpty) return 0;

    return _chats.fold<int>(0, (total, chat) {
      return total + chat.unreadCount;
    });
  }

  /// Check if there are any unread messages
  bool get hasUnreadMessages => totalUnreadCount > 0;

  /// Set the current user ID (should be called from outside, typically from AuthProvider)
  void setCurrentUserId(String? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      if (userId == null) {
        _chats = [];
        notifyListeners();
      }
      // Non chiamiamo loadUserChats() qui - sarà il listener stream a caricare le chat
    }
  }

  /// Initialize the provider by loading current user's chats
  Future<void> init() async {
    if (_currentUserId != null) {
      await loadUserChats();
    }
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    super.dispose();
  }

  /// Clears all chat data and resets the provider state
  void clearAllChats() {
    _chatsSubscription?.cancel();
    _isListening = false;
    _currentUserId = null;
    _chats = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
    debugPrint('ChatProvider: All chats cleared');
  }

  /// Clears all error states and messages
  void clearErrors({bool notify = true}) {
    _errorMessage = null;
    if (notify) notifyListeners();
  }

  /// Load user chats (one-time fetch)
  Future<void> loadUserChats() async {
    if (_currentUserId == null) {
      _errorMessage = 'No authenticated user';
      notifyListeners();
      return;
    }

    debugPrint('ChatProvider: Loading chats for user $_currentUserId');
    clearErrors(notify: false);
    _isLoading = true;
    notifyListeners();

    try {
      final chats = await _chatFirestore.getUserChats(_currentUserId!);
      debugPrint('ChatProvider: Loaded ${chats.length} chats');
      await _enrichChatsWithUserInfo(chats, _currentUserId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('ChatProvider: Error loading chats - $e');
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Start listening to real-time chat updates
  void startListeningToChats() {
    if (_currentUserId == null) {
      _errorMessage = 'No authenticated user';
      debugPrint('ChatProvider: Cannot start listening - no user ID');
      notifyListeners();
      return;
    }

    // Se già in ascolto, non avviare un nuovo listener
    if (_isListening) {
      debugPrint('ChatProvider: Already listening to chats, skipping');
      return;
    }

    debugPrint(
      'ChatProvider: Starting to listen to chats for user $_currentUserId',
    );
    _chatsSubscription?.cancel();
    _isListening = true;
    _chatsSubscription = _chatFirestore
        .getUserChatsStream(_currentUserId!)
        .listen(
          (chats) async {
            debugPrint(
              'ChatProvider: Received ${chats.length} chats from stream',
            );
            await _enrichChatsWithUserInfo(chats, _currentUserId!);
            notifyListeners();
          },
          onError: (error) {
            debugPrint('ChatProvider: Stream error - $error');
            _errorMessage = _getErrorMessage(error);
            notifyListeners();
          },
        );
  }

  /// Stop listening to real-time chat updates
  void stopListeningToChats() {
    _chatsSubscription?.cancel();
    _isListening = false;
    debugPrint('ChatProvider: Stopped listening to chats');
  }

  /// Enrich chats with user information and unread count
  Future<void> _enrichChatsWithUserInfo(
    List<Chat> chats,
    String currentUserId,
  ) async {
    // Crea una nuova lista invece di modificare _chats direttamente
    final List<ChatInfo> newChats = [];

    // Usa un Set per tracciare gli ID delle chat già processate
    final Set<String> processedChatIds = {};

    for (var chat in chats) {
      // Salta i duplicati
      if (processedChatIds.contains(chat.id)) {
        debugPrint('Skipping duplicate chat ${chat.id}');
        continue;
      }
      processedChatIds.add(chat.id);

      try {
        final otherUserId = chat.getOtherUserId(currentUserId);
        final otherUserData = await _getUserData(otherUserId);
        final unreadCount = await _chatFirestore.getUnreadMessagesCount(
          chat.id,
          currentUserId,
        );

        // Recupera l'immagine del ristorante se l'utente ne ha uno
        String? restaurantImageUrl;
        if (otherUserData?.restaurantId != null &&
            otherUserData!.restaurantId!.isNotEmpty) {
          restaurantImageUrl = await _getRestaurantImage(
            otherUserData.restaurantId!,
          );
        }

        newChats.add(
          ChatInfo(
            chat: chat,
            otherUser: otherUserData,
            restaurantImageUrl: restaurantImageUrl,
            unreadCount: unreadCount,
          ),
        );
      } catch (e) {
        debugPrint('Error enriching chat ${chat.id}: $e');
      }
    }

    // Assegna la nuova lista solo alla fine
    _chats = newChats;
    debugPrint('ChatProvider: Enriched ${_chats.length} unique chats');
  }

  /// Get user data by ID
  Future<User?> _getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return User.fromFirestore(userDoc);
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
    return null;
  }

  /// Get restaurant image URL by restaurant ID
  Future<String?> _getRestaurantImage(String restaurantId) async {
    try {
      final restaurantDoc =
          await _firestore.collection('restaurants').doc(restaurantId).get();
      if (restaurantDoc.exists) {
        final restaurant = Restaurant.fromFirestore(restaurantDoc);
        return restaurant.imageUrl;
      }
    } catch (e) {
      debugPrint('Error fetching restaurant image: $e');
    }
    return null;
  }

  /// Send a message in a chat
  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String message,
  }) async {
    if (_currentUserId == null) {
      _errorMessage = 'No authenticated user';
      notifyListeners();
      return;
    }

    clearErrors(notify: false);

    try {
      await _chatFirestore.sendMessage(
        chatId: chatId,
        senderId: _currentUserId!,
        receiverId: receiverId,
        message: message,
      );
      // Non ricarichiamo le chat, il listener stream le aggiornerà automaticamente
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Mark messages as read in a chat
  Future<void> markMessagesAsRead(String chatId) async {
    if (_currentUserId == null) return;

    try {
      await _chatFirestore.markMessagesAsRead(chatId, _currentUserId!);
      // Update local unread count
      final chatIndex = _chats.indexWhere((c) => c.chat.id == chatId);
      if (chatIndex != -1) {
        _chats[chatIndex] = _chats[chatIndex].copyWith(unreadCount: 0);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  /// Find existing chat with another user or return null
  String? findExistingChat(String otherUserId) {
    if (_currentUserId == null) return null;

    try {
      final existingChat = _chats.firstWhere((chatInfo) {
        final chat = chatInfo.chat;
        return (chat.user1Id == _currentUserId &&
                chat.user2Id == otherUserId) ||
            (chat.user2Id == _currentUserId && chat.user1Id == otherUserId);
      });
      return existingChat.chat.id;
    } catch (e) {
      return null;
    }
  }

  /// Check if a chat has any messages
  Future<bool> chatHasMessages(String chatId) async {
    try {
      final messages = await _chatFirestore.getMessages(chatId);
      return messages.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking chat messages: $e');
      return false;
    }
  }

  /// Create a new chat with another user
  Future<String?> createChat(String otherUserId) async {
    if (_currentUserId == null) {
      _errorMessage = 'No authenticated user';
      debugPrint('ChatProvider: Cannot create chat - no user ID');
      notifyListeners();
      return null;
    }

    debugPrint(
      'ChatProvider: Creating chat between $_currentUserId and $otherUserId',
    );
    clearErrors(notify: false);
    _isLoading = true;
    notifyListeners();

    try {
      final chatId = await _chatFirestore.createNewChat(
        user1Id: _currentUserId!,
        user2Id: otherUserId,
      );
      debugPrint('ChatProvider: Chat created successfully with ID: $chatId');
      _isLoading = false;
      notifyListeners();
      // Non chiamiamo più loadUserChats() perché il listener stream
      // riceverà automaticamente l'aggiornamento
      return chatId;
    } catch (e) {
      debugPrint('ChatProvider: Error creating chat - $e');
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Delete a chat
  Future<void> deleteChat(String chatId) async {
    clearErrors(notify: false);
    _isLoading = true;
    notifyListeners();

    try {
      await _chatFirestore.deleteChat(chatId);
      _chats.removeWhere((c) => c.chat.id == chatId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Get messages for a specific chat (one-time fetch)
  Future<List<Message>> getMessages(String chatId) async {
    try {
      return await _chatFirestore.getMessages(chatId);
    } catch (e) {
      debugPrint('Error getting messages: $e');
      return [];
    }
  }

  /// Get messages stream for a specific chat
  Stream<List<Message>> getMessagesStream(String chatId) {
    return _chatFirestore.getMessagesStream(chatId);
  }

  /// Converts errors into user-friendly messages
  String _getErrorMessage(dynamic error) {
    String errorMessage = error.toString();

    if (errorMessage.contains('No authenticated user')) {
      return 'No authenticated user';
    } else if (errorMessage.contains('permission-denied')) {
      return 'Permission denied';
    } else if (errorMessage.contains('not-found')) {
      return 'Chat not found';
    }

    return 'An error occurred: $errorMessage';
  }
}

/// Helper class to combine chat with additional information
class ChatInfo {
  final Chat chat;
  final User? otherUser;
  final String? restaurantImageUrl;
  final int unreadCount;

  ChatInfo({
    required this.chat,
    required this.otherUser,
    this.restaurantImageUrl,
    this.unreadCount = 0,
  });

  ChatInfo copyWith({
    Chat? chat,
    User? otherUser,
    String? restaurantImageUrl,
    int? unreadCount,
  }) {
    return ChatInfo(
      chat: chat ?? this.chat,
      otherUser: otherUser ?? this.otherUser,
      restaurantImageUrl: restaurantImageUrl ?? this.restaurantImageUrl,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
