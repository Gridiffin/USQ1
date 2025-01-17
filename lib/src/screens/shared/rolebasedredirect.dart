import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/homepage.dart';
import '../admin/adminpanelpage.dart';
import '../auth/loginscreen.dart';

class RoleBasedRedirect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Safety fallback: Redirect to LoginScreen if no user is logged in
      return LoginScreen();
    }

    print("Checking role for UID: ${user.uid}");

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('admins').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          print("Error fetching admin data: ${snapshot.error}");
          return HomePage(); // Fallback to HomePage on error
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          // Admin account detected
          final adminData = snapshot.data!.data() as Map<String, dynamic>;
          final bool isVerified = adminData['isVerified'] ?? false;

          if (isVerified) {
            print("Admin verified. Redirecting to AdminPanelPage.");
            return AdminPanelPage(adminData: adminData);
          } else {
            print("Admin account not verified.");
            return Scaffold(
              body: Center(
                child: Text(
                    "Admin account is not verified. Please contact support."),
              ),
            );
          }
        }

        // Fallback to HomePage for regular users
        print("No admin role found. Redirecting to HomePage.");
        return HomePage();
      },
    );
  }
}
