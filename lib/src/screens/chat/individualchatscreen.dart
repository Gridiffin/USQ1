import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/chatmessagemodels.dart';
import '../profile/otheruserprofile.dart';

class IndividualChatScreen extends StatefulWidget {
  final String chatId;
  final String userName;

  IndividualChatScreen({required this.chatId, required this.userName});

  @override
  _IndividualChatScreenState createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final senderUid = _auth.currentUser?.uid ?? '';

    final newMessage = ChatMessage(
      id: '',
      text: _messageController.text.trim(),
      senderUid: senderUid,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add(newMessage.toJson());
    await _firestore.collection('chats').doc(widget.chatId).update({
      'lastMessage': newMessage.text,
      'timestamp': Timestamp.fromDate(newMessage.timestamp),
    });

    _messageController.clear();
  }

  void _navigateToUserProfile(BuildContext context) async {
    try {
      final chatDoc =
          await _firestore.collection('chats').doc(widget.chatId).get();
      if (chatDoc.exists) {
        final participants = chatDoc['participants'] as List<dynamic>;
        final otherUserUid = participants.firstWhere(
          (uid) => uid != _auth.currentUser?.uid,
          orElse: () => null,
        );

        if (otherUserUid != null) {
          final userDoc =
              await _firestore.collection('users').doc(otherUserUid).get();
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtherUserProfile(
                  matricId: userData['matricId'],
                  name: userData['name'],
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      print("Error navigating to user profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = _auth.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _navigateToUserProfile(context),
          child: Text(
            widget.userName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Color(0xFF558B2F),
      ),
      body: Column(
        children: [
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

                final messages = snapshot.data!.docs.map((doc) {
                  return ChatMessage.fromJson(
                      doc.id, doc.data() as Map<String, dynamic>);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Align(
                      alignment: _getMessageAlignment(message.senderUid),
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: message.senderUid == currentUserUid
                              ? Color(0xFF558B2F)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: message.senderUid == currentUserUid
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF558B2F)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Alignment _getMessageAlignment(String senderUid) {
    return senderUid == _auth.currentUser?.uid
        ? Alignment.centerRight
        : Alignment.centerLeft;
  }
}
