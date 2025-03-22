import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String senderId;
  final String receiverId;
  final DateTime sendTime;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.sendTime,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Message(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['sender_id'] ?? '',
      receiverId: data['receiver_id'] ?? '',
      sendTime: (data['send_time'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'send_time': Timestamp.fromDate(sendTime),
    };
  }
}