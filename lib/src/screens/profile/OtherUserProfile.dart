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
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF558B2F),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(
                  'assets/images/profile_pic.png'), // Replace with user image logic
            ),
            SizedBox(height: 20),
            Text(
              name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              matricId,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _startChat(context, currentMatricId),
              icon: Icon(Icons.chat, color: Colors.white),
              label: Text(
                'Start Chat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                backgroundColor: Color(0xFF558B2F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
