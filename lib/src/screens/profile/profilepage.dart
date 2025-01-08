// screens/profile/profilepage.dart
import 'package:flutter/material.dart';
import 'uploadservice.dart';
import 'changepassword.dart';
import '../auth/loginscreen.dart';
import 'settings.dart'; // Import settings.dart
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth import
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'Anonymous';

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
          userName = userData['name'] ?? 'Anonymous';
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
                  onTap: () async {
                    final newName = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SettingsPage(user: user, currentName: userName),
                      ),
                    );
                    if (newName != null && newName is String) {
                      setState(() {
                        userName = newName;
                      });
                    }
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
