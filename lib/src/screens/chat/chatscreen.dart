// ChatScreen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'individualchatscreen.dart'; // Import the IndividualChatScreen file

class ChatScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUserUid =
        _auth.currentUser?.uid ?? ''; // Get the current user's UID

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('chats')
            .where('participants', arrayContains: currentUserUid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!.docs;
          if (chats.isEmpty) {
            return Center(child: Text('No chats available'));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final List<dynamic>? participants =
                  chat['participants'] as List<dynamic>?;

              // Extract the other participant's UID
              final otherParticipantUid = participants?.firstWhere(
                (id) => id != currentUserUid,
                orElse: () => null,
              );

              print(
                  'Other participant UID: $otherParticipantUid'); // Debug line

              if (otherParticipantUid == null) {
                return ListTile(
                  title: Text('Unknown User'),
                  subtitle: Text('User details not found'),
                );
              }

              return FutureBuilder(
                future: _firestore
                    .collection('users')
                    .doc(otherParticipantUid)
                    .get(),
                builder:
                    (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  if (!userSnapshot.hasData ||
                      userSnapshot.data == null ||
                      !userSnapshot.data!.exists) {
                    print(
                        'Error: User document not found for UID $otherParticipantUid'); // Debug line
                    return ListTile(
                      title: Text('Unknown User ($otherParticipantUid)'),
                      subtitle: Text('User details not found'),
                    );
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;

                  if (userData == null) {
                    print(
                        'Error: User data is null for UID $otherParticipantUid'); // Debug line
                    return ListTile(
                      title: Text('Unknown User ($otherParticipantUid)'),
                      subtitle: Text('User details not found'),
                    );
                  }

                  return ListTile(
                    title: Text(userData['name'] ?? 'Name not found'),
                    subtitle: Text(chat['lastMessage'] ?? 'No messages yet'),
                    onTap: () {
                      if (chat.id.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IndividualChatScreen(
                              chatId: chat.id,
                              userName: userData['name'] ?? 'Unknown',
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
