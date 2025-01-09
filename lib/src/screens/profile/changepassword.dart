import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isOldPasswordHidden = true;
  bool _isNewPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  Future<void> _handleSubmit(BuildContext context) async {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all the fields.')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New passwords do not match.')),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      String email = user?.email ?? '';

      // Reauthenticate the user
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: _oldPasswordController.text,
      );
      await user?.reauthenticateWithCredential(credential).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Old password is incorrect.')),
        );
        throw error;
      });

      // Update password
      await user?.updatePassword(_newPasswordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your password has been changed successfully.')),
      );

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Password',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _oldPasswordController,
              obscureText: _isOldPasswordHidden,
              decoration: InputDecoration(
                hintText: 'Enter your Old Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isOldPasswordHidden
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isOldPasswordHidden = !_isOldPasswordHidden;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              obscureText: _isNewPasswordHidden,
              decoration: InputDecoration(
                hintText: 'Enter your New Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordHidden
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isNewPasswordHidden = !_isNewPasswordHidden;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _isConfirmPasswordHidden,
              decoration: InputDecoration(
                hintText: 'Confirm your New Password',
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  _handleSubmit(context);
                },
                child: Text(
                  'Submit',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
