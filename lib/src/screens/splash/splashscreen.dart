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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/src/images/splashbg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color:
                Colors.black.withOpacity(0.3), // Add semi-transparent overlay
          ),
          Center(
            child: Image.asset(
              'lib/src/images/app_logo.png',
              width: 200,
              height: 200,
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
            ),
          ),
        ],
      ),
    );
  }
}
