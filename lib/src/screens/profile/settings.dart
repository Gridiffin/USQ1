import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  final User? user;
  final String currentName;

  SettingsPage({required this.user, required this.currentName});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _updateUserProfileImage(_profileImage!);
    }
  }

  Future<String?> _uploadImageToCloudinary(File image) async {
    try {
      final url =
          Uri.parse("https://api.cloudinary.com/v1_1/dtlbv6dxo/image/upload");
      final request = http.MultipartRequest('POST', url);

      request.fields['upload_preset'] =
          'unimas_sq_preset1'; // Cloudinary preset
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final jsonResponse = json.decode(responseData.body);
        return jsonResponse['secure_url'];
      } else {
        print('Cloudinary upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  Future<void> _updateUserProfileImage(File image) async {
    try {
      final imageUrl = await _uploadImageToCloudinary(image);

      if (imageUrl != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user!.uid);

        await userDoc.update({
          'imageUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image to Cloudinary.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture: $e')),
      );
    }
  }

  Future<void> _updateUserProfile() async {
    String newName = _nameController.text.trim();
    if (newName.isNotEmpty && widget.user != null) {
      try {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user!.uid);

        await userDoc.update({
          'name': newName,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pop(context, {'name': newName});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name cannot be empty!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFF558B2F),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_profileImage != null)
                CircleAvatar(
                  radius: 60,
                  backgroundImage: FileImage(_profileImage!),
                )
              else
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.user!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data!.get('imageUrl') != null) {
                      return CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            NetworkImage(snapshot.data!.get('imageUrl')),
                      );
                    }
                    return CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          AssetImage('assets/images/profile_pic.png'),
                    );
                  },
                ),
              SizedBox(height: 10),
              TextButton(
                onPressed: _pickImage,
                child: Text(
                  'Change Profile Picture',
                  style: TextStyle(color: Colors.green[900], fontSize: 16),
                ),
              ),
              SizedBox(height: 30),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[900]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green[700]!),
                  ),
                ),
                controller: _nameController,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _updateUserProfile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color(0xFF558B2F),
                ),
                child: Text('Save',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
