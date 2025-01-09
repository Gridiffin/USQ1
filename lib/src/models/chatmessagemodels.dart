import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
  });

  // Convert a Firestore document to a ChatMessage instance
  factory ChatMessage.fromJson(String id, Map<String, dynamic> json) {
    return ChatMessage(
      id: id,
      text: json['text'] ?? '',
      senderId: json['senderId'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  // Convert a ChatMessage instance to a Firestore-compatible map
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'senderId': senderId,
      'timestamp': timestamp,
    };
  }
}
