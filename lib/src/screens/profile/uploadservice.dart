import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class UploadServiceScreen extends StatefulWidget {
  @override
  _UploadServiceScreenState createState() => _UploadServiceScreenState();
}

class _UploadServiceScreenState extends State<UploadServiceScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagsController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _uploadService() async {
    final uuid = Uuid();
    final serviceId = uuid.v4();

    try {
      await _firestore.collection('services').doc(serviceId).set({
        'id': serviceId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'category': _categoryController.text,
        'tags': _tagsController.text.split(','),
        'providerId': 'currentUserId', // Replace with actual provider ID
        'rating': 0.0,
        'images': [], // Add logic for image uploads if needed
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
    _priceController.clear();
    _categoryController.clear();
    _tagsController.clear();
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
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _tagsController,
                decoration: InputDecoration(labelText: 'Tags (comma separated)'),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _uploadService,
                  child: Text('Upload Service'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
