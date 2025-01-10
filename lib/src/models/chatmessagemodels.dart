import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String text;
  final String senderMatricId;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderMatricId,
    required this.timestamp,
  });

  // Convert Firestore document to ChatMessage
  factory ChatMessage.fromJson(String id, Map<String, dynamic> json) {
    return ChatMessage(
      id: id,
      text: json['text'] ?? '',
      senderMatricId: json['senderMatricId'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  // Convert ChatMessage to Firestore-compatible map
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'senderMatricId': senderMatricId,
      'timestamp': timestamp,
    };
  }
}
