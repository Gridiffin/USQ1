import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // Import generated Firebase options
import 'screens/home_screen.dart'; // Import the home screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures proper initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Load the appropriate options for the platform
  );
  runApp(MyApp()); // Run the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Initialization',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(), // Updated to use a separated HomeScreen file
    );
  }
}
