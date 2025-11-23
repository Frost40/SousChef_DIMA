import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/chat.dart';
import '../../models/message.dart';

class ChatFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference alle collections principali
  CollectionReference get _chatsTable => _firestore.collection('chats');

  // Funzione helper per accedere alla sottocollezione
  CollectionReference _messagesCollection(String chatId) {
    return _chatsTable.doc(chatId).collection('messages');
  }

  // Ottieni tutte le chat di un utente
  Future<List<Chat>> getUserChats(String userId) async {
    QuerySnapshot snapshot =
        await _chatsTable
            .where(
              Filter.or(
                Filter('user1_id', isEqualTo: userId),
                Filter('user2_id', isEqualTo: userId),
              ),
            )
            .get();

    List<Chat> chats =
        snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList();

    chats.sort((a, b) {
      if (a.lastMessageTime == null) return 1;
      if (b.lastMessageTime == null) return -1;
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });

    return chats;
  }

  /// Ottieni i messaggi di una chat specifica
  Future<List<Message>> getChatMessages(String chatId) async {
    // MODIFICATO: Usa la sottocollezione e rimuovi .where('chat_id'...)
    QuerySnapshot snapshot =
        await _messagesCollection(
          chatId,
        ).orderBy('timestamp', descending: false).get();

    return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
  }

  /// Alias for getChatMessages
  Future<List<Message>> getMessages(String chatId) async {
    return getChatMessages(chatId);
  }

  /// Conta i messaggi non letti in una chat per un utente specifico
  Future<int> getUnreadMessagesCount(String chatId, String userId) async {
    // MODIFICATO: Usa la sottocollezione e rimuovi .where('chat_id'...)
    QuerySnapshot snapshot =
        await _messagesCollection(chatId)
            .where('receiver_id', isEqualTo: userId)
            .where('is_read', isEqualTo: false)
            .get();

    return snapshot.docs.length;
  }

  /// Invia un nuovo messaggio
  Future<Message> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    // MODIFICATO: Rimuovi 'chat_id' dalla mappa dei dati
    final messageData = {
      // 'chat_id': chatId, // Non più necessario!
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'is_read': false,
    };

    // MODIFICATO: Aggiungi il messaggio alla sottocollezione
    final DocumentReference messageDoc = await _messagesCollection(
      chatId,
    ).add(messageData);

    // Questa parte rimane invariata
    await _chatsTable.doc(chatId).update({
      'last_message': message,
      'last_message_time': FieldValue.serverTimestamp(),
    });

    final createdMessageDoc = await messageDoc.get();
    return Message.fromFirestore(createdMessageDoc);
  }

  /// Marca i messaggi come letti
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    // MODIFICATO: Usa la sottocollezione e rimuovi .where('chat_id'...)
    QuerySnapshot snapshot =
        await _messagesCollection(chatId)
            .where('receiver_id', isEqualTo: userId)
            .where('is_read', isEqualTo: false)
            .get();

    final batch = _firestore.batch();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'is_read': true});
    }

    await batch.commit();
  }

  /// Crea una nuova chat tra due utenti (o restituisce quella esistente)
  Future<String> createNewChat({
    required String user1Id,
    required String user2Id,
  }) async {
    debugPrint('ChatFirestore: Creating chat between $user1Id and $user2Id');

    // Check if chat already exists
    final existingChats =
        await _chatsTable
            .where(
              Filter.or(
                Filter.and(
                  Filter('user1_id', isEqualTo: user1Id),
                  Filter('user2_id', isEqualTo: user2Id),
                ),
                Filter.and(
                  Filter('user1_id', isEqualTo: user2Id),
                  Filter('user2_id', isEqualTo: user1Id),
                ),
              ),
            )
            .get();

    if (existingChats.docs.isNotEmpty) {
      final existingChatId = existingChats.docs.first.id;
      debugPrint('ChatFirestore: Chat already exists with ID: $existingChatId');
      return existingChatId;
    }

    final chatData = {
      'user1_id': user1Id,
      'user2_id': user2Id,
      'last_message': null,
      'last_message_time': null,
    };

    try {
      final DocumentReference chatDoc = await _chatsTable.add(chatData);
      debugPrint('ChatFirestore: Chat document created with ID: ${chatDoc.id}');

      // Non aggiorniamo più l'array 'chats' nei documenti utente
      // Le chat vengono recuperate tramite query su user1_id e user2_id

      debugPrint('ChatFirestore: Chat created successfully');
      return chatDoc.id;
    } catch (e) {
      debugPrint('ChatFirestore: Error creating chat - $e');
      rethrow;
    }
  }

  /// Elimina una chat e tutti i suoi messaggi
  Future<void> deleteChat(String chatId) async {
    // MODIFICATO: Punta alla sottocollezione e rimuovi .where('chat_id'...)
    QuerySnapshot messagesSnapshot = await _messagesCollection(chatId).get();

    final batch = _firestore.batch();

    for (var doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_chatsTable.doc(chatId));

    await batch.commit();
  }

  /// Stream per ascoltare i messaggi di una chat in tempo reale
  Stream<List<Message>> getMessagesStream(String chatId) {
    // MODIFICATO: Usa la sottocollezione e rimuovi .where('chat_id'...)
    return _messagesCollection(chatId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList(),
        );
  }

  /// Stream per ascoltare le chat dell'utente in tempo reale
  Stream<List<Chat>> getUserChatsStream(String userId) {
    return _chatsTable
        .where(
          Filter.or(
            Filter('user1_id', isEqualTo: userId),
            Filter('user2_id', isEqualTo: userId),
          ),
        )
        .snapshots()
        .map((snapshot) {
          List<Chat> chats =
              snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList();

          chats.sort((a, b) {
            if (a.lastMessageTime == null) return 1;
            if (b.lastMessageTime == null) return -1;
            return b.lastMessageTime!.compareTo(a.lastMessageTime!);
          });

          return chats;
        });
  }
}
