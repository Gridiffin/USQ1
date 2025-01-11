import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';

class UploadServicePage extends StatefulWidget {
  @override
  _UploadServicePageState createState() => _UploadServicePageState();
}

class _UploadServicePageState extends State<UploadServicePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  File? _serviceImage;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _serviceImage = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected.')),
      );
    }
  }

  Future<String?> _uploadImageToCloudinary(File image) async {
    try {
      final url =
          Uri.parse("https://api.cloudinary.com/v1_1/dtlbv6dxo/image/upload");
      final request = http.MultipartRequest('POST', url);

      request.fields['upload_preset'] =
          'unimas_sq_preset1'; // Set in Cloudinary dashboard
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

  void _uploadService() async {
    final uuid = Uuid();
    final serviceId = uuid.v4();
    String? cloudinaryImageUrl;

    if (_serviceImage != null) {
      try {
        cloudinaryImageUrl = await _uploadImageToCloudinary(_serviceImage!);
        if (cloudinaryImageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image.')),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload error: $e')),
        );
        return;
      }
    }

    try {
      await _firestore.collection('services').doc(serviceId).set({
        'id': serviceId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _categoryController.text,
        'tags': _tagsController.text.split(','),
        'imageUrl': cloudinaryImageUrl ?? '',
        'providerId': _auth.currentUser?.displayName ?? 'Unknown User',
        'rating': 0.0,
        'createdAt': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service uploaded successfully!')),
      );
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload service: $e')),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    _tagsController.clear();
    setState(() {
      _serviceImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Service',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF558B2F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey[400]!)),
                child: _serviceImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo,
                              size: 50, color: Colors.grey[500]),
                          SizedBox(height: 10),
                          Text('Tap to select an image',
                              style: TextStyle(color: Colors.grey[500])),
                        ],
                      )
                    : Image.file(_serviceImage!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  labelText: 'Title', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                  labelText: 'Description', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                  labelText: 'Category', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _uploadService,
                icon: Icon(Icons.cloud_upload, color: Colors.white),
                label: Text('Upload', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF558B2F),
                  padding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
