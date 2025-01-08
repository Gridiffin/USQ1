import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // Import generated Firebase options

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures proper initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Load the appropriate options for the platform
  );
  runApp(MyApp()); // Make sure MyApp() is properly defined and called here
}

// Define the MyApp class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Initialization',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), // Define a basic HomePage
    );
  }
}

// Define the HomePage class for the app's home screen
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Initialized'),
      ),
      body: Center(
        child: Text(
          'Firebase is successfully initialized!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
