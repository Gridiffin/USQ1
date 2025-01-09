import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/authservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loginscreen.dart'; // Import the LoginScreen file

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
    });

    if (!_emailController.text.trim().endsWith("unimas.my")) {
      setState(() {
        _errorMessage = "Only UNIMAS emails are allowed.";
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Passwords do not match.";
      });
      return;
    }

    final isUnique = await _isMatricIdUnique(_matricIdController.text.trim());
    if (!isUnique) {
      setState(() {
        _errorMessage = "Matric ID already exists.";
      });
      return;
    }

    try {
      User? user = await _authService.registerWithEmailAndPassword(
          _emailController.text.trim(), _passwordController.text.trim());
      if (user != null) {
        // Save additional user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'matricId': _matricIdController.text.trim(),
          'email': user.email,
          'createdAt': Timestamp.now(),
        });

        await _authService.sendEmailVerification(user);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification email sent!')),
        );

        // Navigate back to LoginScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _matricIdController,
                  decoration: InputDecoration(
                    labelText: 'Matric ID',
                    prefixIcon: Icon(Icons.school),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: _isPasswordHidden,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordHidden
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordHidden
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: _navigateToLogin,
                    child: Text(
                      'I Already Have an Account Login',
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: 10),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.black),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
