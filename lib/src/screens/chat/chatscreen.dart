// screens/chat/chatscreen.dart
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  // Example list of conversations (replace with real data later)
  final List<Map<String, String>> conversations = [
    {'name': 'John Doe', 'lastMessage': 'Hi, I’m interested in your service!'},
    {'name': 'Jane Smith', 'lastMessage': 'Can you provide more details?'},
    {'name': 'Alice Johnson', 'lastMessage': 'Thanks for the quick response!'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(conversation['name']![0]), // First letter of the name
            ),
            title: Text(conversation['name']!),
            subtitle: Text(conversation['lastMessage']!),
            onTap: () {
              // Navigate to the individual chat screen
              _openChat(context, conversation['name']!);
            },
          );
        },
      ),
    );
  }

  // Open individual chat (placeholder)
  void _openChat(BuildContext context, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(userName),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: 10, // Example: 10 messages
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Message $index'),
                      subtitle: Text('This is a sample message.'),
                    );
                  },
                ),
              ),
              // Message Input
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        // Handle sending a message
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
