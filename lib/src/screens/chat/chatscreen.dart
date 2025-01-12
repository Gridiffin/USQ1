import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'individualchatscreen.dart';

class ChatScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _fetchUserDetails(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = _auth.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFF558B2F),
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
            return Center(
              child: Text(
                'No chats available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = chat['participants'] as List<dynamic>?;

              // Extract the other participant's UID
              final otherParticipantUid = participants?.firstWhere(
                (id) => id != currentUserUid,
                orElse: () => null,
              );

              if (otherParticipantUid == null) {
                return ListTile(
                  title: Text('Unknown User'),
                  subtitle: Text('User details not found'),
                );
              }

              return FutureBuilder<Map<String, dynamic>?>(
                future: _fetchUserDetails(otherParticipantUid),
                builder: (context,
                    AsyncSnapshot<Map<String, dynamic>?> userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text('Loading...'));
                  }

                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return ListTile(
                      title: Text('Unknown User'),
                      subtitle: Text('User details not found'),
                    );
                  }

                  final userData = userSnapshot.data!;
                  final profileImage = userData['imageUrl'];

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profileImage != null
                            ? NetworkImage(profileImage)
                            : AssetImage('assets/images/profile_pic.png')
                                as ImageProvider,
                        radius: 25,
                      ),
                      title: Text(
                        userData['name'] ?? 'Name not found',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        chat['lastMessage'] ?? 'No messages yet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IndividualChatScreen(
                              chatId: chat.id,
                              userName: userData['name'] ?? 'Unknown',
                            ),
                          ),
                        );
                      },
                    ),
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
