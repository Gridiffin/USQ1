import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/authservice.dart';
import 'loginscreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _matricIdController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _errorMessage;
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool _isLoading = false;

  Future<bool> _isMatricIdUnique(String matricId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('matricId', isEqualTo: matricId)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  void _register() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true; // Show loading indicator
    });

    // Normalize email input
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final matricId = _matricIdController.text.trim();
    final name = _nameController.text.trim();

    if (!email.endsWith("unimas.my")) {
      setState(() {
        _errorMessage = "Only UNIMAS emails are allowed.";
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Passwords do not match.";
        _isLoading = false;
      });
      return;
    }

    if (matricId.isEmpty) {
      setState(() {
        _errorMessage = "Matric ID cannot be empty.";
        _isLoading = false;
      });
      return;
    }

    final isUnique = await _isMatricIdUnique(matricId);
    if (!isUnique) {
      setState(() {
        _errorMessage = "Matric ID already exists.";
        _isLoading = false;
      });
      return;
    }

    try {
      User? user = await _authService.registerWithEmailAndPassword(email, password);
      if (user != null) {
        // Save additional user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'matricId': matricId,
          'email': email,
          'createdAt': Timestamp.now(),
        });

        await _authService.sendEmailVerification(user);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification email sent! Please check your inbox.')),
        );

        // Navigate to LoginScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString().contains(']')
            ? error.toString().split(']').last.trim()
            : "An unexpected error occurred. Please try again.";
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/src/images/jungle_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay
          Container(color: Colors.black.withOpacity(0.3)),
          // Form
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join us now!',
                      style: GoogleFonts.adventPro(
                        textStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person, color: Colors.brown),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _matricIdController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        labelText: 'Matric ID',
                        prefixIcon: Icon(Icons.school, color: Colors.brown),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email, color: Colors.brown),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: _isPasswordHidden,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: Colors.brown),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                            color: Colors.brown,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordHidden = !_isPasswordHidden;
                            });
                          },
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _isConfirmPasswordHidden,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock, color: Colors.brown),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordHidden ? Icons.visibility : Icons.visibility_off,
                            color: Colors.brown,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                            });
                          },
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_isLoading)
                      Center(child: CircularProgressIndicator(color: Colors.white))
                    else
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          'Create Account',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        children: [
                          Text(
                            'I Already Have an Account ',
                            style: TextStyle(color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: _navigateToLogin,
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ]
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
