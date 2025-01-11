import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../chat/individualchatscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtherUserProfile extends StatelessWidget {
  final String matricId; // User's matric ID
  final String name; // User's display name

  OtherUserProfile({required this.matricId, required this.name});

  Future<void> _startChat(BuildContext context) async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) {
      print("User not logged in");
      return;
    }

    // Fetch other user's UID from matricId
    final otherUserUid = await getUidFromMatricId(matricId);

    // Ensure `otherUserUid` is valid and is NOT the chat's document ID
    if (otherUserUid == null || otherUserUid == currentUserUid) {
      print("Invalid otherUserUid or chatting with self.");
      return;
    }

    // Generate consistent chat ID
    final chatId = _generateChatId(currentUserUid, otherUserUid);

    // Check if the chat already exists
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      // Create the chat if it doesn't exist
      await chatRef.set({
        'participants': [currentUserUid, otherUserUid],
        'lastMessage': '',
        'timestamp': Timestamp.now(),
      });
    }

    // Navigate to the chat screen
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

  Future<String?> getUidFromMatricId(String matricId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('matricId', isEqualTo: matricId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id; // Return the UID
      } else {
        print("No user found for matricId: $matricId");
        return null; // No match found
      }
    } catch (e) {
      print("Error fetching UID from matricId: $e");
      return null;
    }
  }

  String _generateChatId(String uid1, String uid2) {
    final sortedUids = [uid1, uid2]..sort();
    return sortedUids.join('_');
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => _startChat(context),
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
