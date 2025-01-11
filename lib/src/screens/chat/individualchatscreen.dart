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

    final senderMatricId = _auth.currentUser?.email?.split('@')[0] ??
        ''; // Assume matricId is derived from email

    final newMessage = ChatMessage(
      id: '',
      text: _messageController.text.trim(),
      senderMatricId: senderMatricId,
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

  void _navigateToUserProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtherUserProfile(
          matricId:
              widget.chatId, // Replace with the actual matricId of the user
          name: widget.userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserMatricId = _auth.currentUser?.email?.split('@')[0] ??
        ''; // Assume matricId is derived from email

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
                    final isMe = message.senderMatricId == currentUserMatricId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Color(0xFF558B2F) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message.text,
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
}
