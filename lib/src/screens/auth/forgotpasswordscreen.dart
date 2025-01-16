import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For themed fonts
import '../../services/authservice.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _message;

  void _resetPassword() async {
    setState(() {
      _message = null;
    });
    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      setState(() {
        _message =
            "Password reset email has been sent. Please check your inbox.";
      });
    } catch (error) {
      setState(() {
        _message = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'lib/src/images/jungle_background.jpg'), // Add a jungle-themed background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color:
                Colors.black.withOpacity(0.3), // Add semi-transparent overlay
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Forgot Password',
                      style: GoogleFonts.adventPro(
                        textStyle: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        prefixIcon: Icon(Icons.email, color: Colors.brown),
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Send Reset Email',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (_message != null) ...[
                      SizedBox(height: 10),
                      Text(
                        _message!,
                        style: TextStyle(
                          color: _message!.contains("error")
                              ? Colors.red
                              : Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text.rich(
                        TextSpan(
                          text: 'Remember your password? ',
                          style: TextStyle(color: Colors.white),
                          children: [
                            TextSpan(
                              text: 'Back to Login',
                              style: TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
