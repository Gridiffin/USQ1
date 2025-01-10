import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../chat/individualchatscreen.dart';

class OtherUserProfile extends StatelessWidget {
  final String matricId; // User's matric ID
  final String name; // User's display name

  OtherUserProfile({required this.matricId, required this.name});

  Future<void> _startChat(BuildContext context, String currentMatricId) async {
    final chatId = _generateChatId(currentMatricId, matricId);

    // Ensure chat exists in Firestore
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'participants': [currentMatricId, matricId],
        'lastMessage': '',
        'timestamp': Timestamp.now(),
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IndividualChatScreen(
          chatId: chatId,
          userName: name,
        ),
      ),
    );
  }

  String _generateChatId(String matricId1, String matricId2) {
    final sortedIds = [matricId1, matricId2]..sort();
    return sortedIds.join('_');
  }

  @override
  Widget build(BuildContext context) {
    final currentMatricId =
        "current_user_matric_id"; // Replace with actual logic

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _startChat(context, currentMatricId),
          child: Text('Start Chat'),
        ),
      ),
    );
  }
}
