// screens/profile/profilepage.dart
import 'package:flutter/material.dart';
import 'uploadservice.dart';
import 'changepassword.dart';
import '../auth/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth import
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _navigateToEditProfile(context);
            },
          ),
        ],
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
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.shopping_bag, color: Colors.green),
                  title: Text('My Orders'),
                  onTap: () {
                    _navigateToOrders(context);
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.green),
                  title: Text('Settings'),
                  onTap: () {
                    _navigateToSettings(context);
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

  // Navigate to edit profile screen (placeholder)
  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Edit Profile')),
          body: Center(
            child: Text('Edit Profile Screen (Placeholder)'),
          ),
        ),
      ),
    );
  }

  // Navigate to orders screen (placeholder)
  void _navigateToOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('My Orders')),
          body: Center(
            child: Text('Orders Screen (Placeholder)'),
          ),
        ),
      ),
    );
  }

  // Navigate to settings screen (placeholder)
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Settings')),
          body: Center(
            child: Text('Settings Screen (Placeholder)'),
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
        builder: (context) => UploadServicePage(),
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
