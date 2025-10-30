import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String message;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.message,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    this.isRead = false,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Message(
      id: doc.id,
      message: data['message'] ?? '',
      senderId: data['sender_id'] ?? '',
      receiverId: data['receiver_id'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'timestamp': Timestamp.fromDate(timestamp),
      'is_read': isRead,
    };
  }
}