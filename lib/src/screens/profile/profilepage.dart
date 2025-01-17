import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings.dart';
import 'uploadservice.dart';
import '../auth/loginscreen.dart';
import 'changepassword.dart';
import '../shared/servicedetailspage.dart';
import '../../models/servicemodels.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'Explorer';
  String? userProfileImage;

  Stream<QuerySnapshot> _fetchUserServices(String userId) {
    return FirebaseFirestore.instance
        .collection('services')
        .where('providerId', isEqualTo: userId)
        .snapshots();
  }

  Stream<double> _averageRatingStream(String serviceId) {
    return FirebaseFirestore.instance
        .collection('services')
        .doc(serviceId)
        .collection('ratings')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0.0;
      final ratings = snapshot.docs.map((doc) => doc['rating'] as int).toList();
      final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      return averageRating;
    });
  }

  Future<void> _deleteService(String serviceId) async {
    try {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(serviceId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete service: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFF558B2F),
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
          userName = userData['name'] ?? 'Explorer';
          userProfileImage = userData['imageUrl'];
          final String userId = user?.uid ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Color(0xFF8BC34A),
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: userProfileImage != null
                            ? NetworkImage(userProfileImage!)
                            : AssetImage('assets/images/profile_pic.png')
                                as ImageProvider,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              user?.email ?? 'No Email',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Services Uploaded by You',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: _fetchUserServices(userId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final services = snapshot.data!.docs;

                          if (services.isEmpty) {
                            return Center(
                              child: Text(
                                'No services uploaded yet.',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: services.length,
                            itemBuilder: (context, index) {
                              final serviceData = services[index].data()
                                  as Map<String, dynamic>;
                              final serviceId = services[index].id;
                              final service =
                                  ServiceModel.fromJson(serviceData);

                              return StreamBuilder<double>(
                                stream: _averageRatingStream(serviceId),
                                builder: (context, ratingSnapshot) {
                                  final averageRating =
                                      ratingSnapshot.data ?? 0.0;
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      leading: service.imageUrl != null
                                          ? Image.network(
                                              service.imageUrl,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(Icons.image,
                                              size: 50, color: Colors.grey),
                                      title: Text(
                                        service.title ?? 'Untitled',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        averageRating > 0
                                            ? 'Rating: ${averageRating.toStringAsFixed(1)}'
                                            : 'No ratings yet',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ServiceDetailsPage(
                                                    service: service),
                                          ),
                                        );
                                      },
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          _deleteService(serviceId);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Account Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildLeftAlignedButton(
                        context,
                        'Settings',
                        Icons.settings,
                        () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                  user: user, currentName: userName),
                            ),
                          );
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            setState(() {
                              userName = result['name'] ?? userName;
                              userProfileImage =
                                  result['imageUrl'] ?? userProfileImage;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      _buildLeftAlignedButton(
                        context,
                        'Change Password',
                        Icons.lock,
                        () {
                          _navigateToChangePassword(context);
                        },
                      ),
                      SizedBox(height: 10),
                      _buildLeftAlignedButton(
                        context,
                        'Upload Service',
                        Icons.upload,
                        () {
                          _navigateToUploadService(context);
                        },
                      ),
                      SizedBox(height: 20),
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeftAlignedButton(
      BuildContext context, String label, IconData icon, VoidCallback onPressed,
      {Color backgroundColor = const Color(0xFF558B2F)}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        _handleLogout(context);
      },
      icon: Icon(Icons.logout, color: Colors.white),
      label: Text(
        'Logout',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  void _navigateToUploadService(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadServicePage(),
      ),
    );
  }

  void _navigateToChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordPage(),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
}
