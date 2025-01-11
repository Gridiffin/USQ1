import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id; // Message ID
  final String text; // Message text
  final String senderUid; // Firebase UID of the sender
  final DateTime timestamp; // Timestamp of the message

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderUid,
    required this.timestamp,
  });

  // Convert Firestore document to ChatMessage
  factory ChatMessage.fromJson(String id, Map<String, dynamic> json) {
    return ChatMessage(
      id: id,
      text: json['text'] ?? '',
      senderUid: json['senderUid'] ?? '', // Use senderUid instead of matricId
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  // Convert ChatMessage to Firestore-compatible map
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'senderUid': senderUid, // Save senderUid
      'timestamp': timestamp,
    };
  }
}
