// screens/profile/settings.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  final User? user;
  final String currentName;

  SettingsPage({required this.user, required this.currentName});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateUserName() async {
    String newName = _nameController.text.trim();
    if (newName.isNotEmpty && widget.user != null) {
      try {
        // Update the name in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user!.uid)
            .update({'name': newName});

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Name updated successfully!')),
        );

        // Refresh the profile page by passing the updated name back
        Navigator.pop(context, newName);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update name: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name cannot be empty!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Change Name',
                border: OutlineInputBorder(),
              ),
              controller: _nameController,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserName,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
