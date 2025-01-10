import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IndividualChatScreen extends StatefulWidget {
  final String chatId;
  final String userName;

  IndividualChatScreen({required this.chatId, required this.userName});

  @override
  _IndividualChatScreenState createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final _messageController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  void _sendMessage(String matricId) async {
    if (_messageController.text.trim().isEmpty) return;

    final message = {
      'text': _messageController.text.trim(),
      'senderMatricId': matricId,
      'timestamp': Timestamp.now(),
    };

    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add(message);

    _messageController.clear();

    await _firestore.collection('chats').doc(widget.chatId).update({
      'lastMessage': message['text'],
      'timestamp': message['timestamp'],
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMatricId =
        "current_user_matric_id"; // Replace with actual logic

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
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

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderMatricId'] == currentMatricId;

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
                        child: Text(message['text']),
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
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(currentMatricId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
