// screens/profile/profilepage.dart
import 'package:flutter/material.dart';
import 'uploadservice.dart';
import 'changepassword.dart';
import '../auth/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth import
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No user data found.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String userName = userData['name'] ?? 'Anonymous';
          final String userEmail = user?.email ?? 'No Email';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            AssetImage('assets/images/profile_pic.png'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        userName,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        userEmail,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.green),
                  title: Text('Settings'),
                  onTap: () {
                    _navigateToSettings(context, user, userName);
                  },
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        _navigateToUploadService(context);
                      },
                      child: Text(
                        'Upload Service',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _navigateToChangePassword(context);
                      },
                      child: Text(
                        'Change Password',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.green),
                  title: Text('Logout'),
                  onTap: () {
                    _handleLogout(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Navigate to settings screen with edit profile and change name functionality
  void _navigateToSettings(
      BuildContext context, User? user, String currentName) {
    TextEditingController nameController =
        TextEditingController(text: currentName);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Settings')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Change Name',
                    border: OutlineInputBorder(),
                  ),
                  controller: nameController,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    String newName = nameController.text.trim();
                    if (newName.isNotEmpty && user != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({'name': newName});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Name updated successfully!')),
                      );
                      setState(() {}); // Refresh the profile page
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Name cannot be empty!')),
                      );
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Navigate to upload service screen
  void _navigateToUploadService(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadServiceScreen(),
      ),
    );
  }

  // Navigate to change password screen
  void _navigateToChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordPage(),
      ),
    );
  }

  // Handle logout (placeholder)
  void _handleLogout(BuildContext context) {
    // Perform logout actions (e.g., clear user data, navigate to login screen)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );
    // Navigate to login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
}
