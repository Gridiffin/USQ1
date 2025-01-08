// screens/splash/splashscreen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../auth/loginscreen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Navigate to the LoginScreen after a delay
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white, // Set background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/src/images/app_logo.png', // Path to your logo
              width: 170, // Adjust width as needed
              height: 170, // Adjust height as needed
            ),
          ],
        ),
      ),
    );
  }
}
