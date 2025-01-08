import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // Import generated Firebase options
import 'src/screens/splash/splashscreen.dart';
import 'src/screens/home/homepage.dart'; // Import HomePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures proper initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Load the appropriate options for the platform
  );
  runApp(MyApp()); // Make sure MyApp() is properly defined and called here
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Add 'return' here to return the MaterialApp widget
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Start with SplashScreen
      routes: {
        '/home': (context) => HomePage(), // Define the route for HomePage
      },
    );
  }
}
