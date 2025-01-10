import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/chatmessagemodels.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('chats')
            .where('participants', arrayContains: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading chats: ${snapshot.error}'),
            );
          }
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
              final otherParticipant = (chat['participants'] as List)
                  .firstWhere((id) => id != _auth.currentUser!.uid);

              return FutureBuilder(
                future:
                    _firestore.collection('users').doc(otherParticipant).get(),
                builder:
                    (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return SizedBox.shrink();
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(userData['profileImageUrl'] ?? ''),
                    ),
                    title: Text(userData['name']),
                    subtitle: Text(chat['lastMessage']),
                    onTap: () => _openChat(context, chat.id, userData['name']),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _openChat(BuildContext context, String chatId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            IndividualChatScreen(chatId: chatId, userName: userName),
      ),
    );
  }
}

class IndividualChatScreen extends StatefulWidget {
  final String chatId;
  final String userName;

  const IndividualChatScreen({
    Key? key,
    required this.chatId,
    required this.userName,
  }) : super(key: key);

  @override
  _IndividualChatScreenState createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final newMessage = ChatMessage(
        id: '',
        text: _messageController.text.trim(),
        senderId: _auth.currentUser?.uid ?? '',
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(newMessage.toJson());

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == _auth.currentUser?.uid;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message Input Field
          Container(
            padding: const EdgeInsets.all(8.0),
            color:
                Colors.white, // Ensure the input field has a visible background
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
