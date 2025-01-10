import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
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

  Future<String> _saveImageLocally(File image, String serviceId) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/$serviceId.jpg';
    final savedImage = await image.copy(imagePath);
    return savedImage.path;
  }

  void _uploadService() async {
    final uuid = Uuid();
    final serviceId = uuid.v4();
    String? imagePath;

    if (_serviceImage != null) {
      try {
        imagePath = await _saveImageLocally(_serviceImage!, serviceId);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
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
        'imagePath': imagePath ?? '',
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
        title: Text('Upload Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: _serviceImage != null
                      ? Image.file(_serviceImage!, fit: BoxFit.cover)
                      : Icon(Icons.upload, size: 50, color: Colors.grey),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: _tagsController,
                decoration:
                    InputDecoration(labelText: 'Tags (comma separated)'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadService,
                child: Text('Upload Service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
