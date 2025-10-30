import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final String user1Id;
  final String user2Id;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  Chat({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory Chat.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Chat(
      id: doc.id,
      user1Id: data['user1_id'] ?? '',
      user2Id: data['user2_id'] ?? '',
      lastMessage: data['last_message'],
      lastMessageTime:
          data['last_message_time'] != null
              ? (data['last_message_time'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user1_id': user1Id,
      'user2_id': user2Id,
      'last_message': lastMessage,
      'last_message_time':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
    };
  }

  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }
}
