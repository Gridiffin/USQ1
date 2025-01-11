import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../../models/servicemodels.dart';

class ServiceDetailsPage extends StatelessWidget {
  final ServiceModel service;

  ServiceDetailsPage({required this.service});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _commentController = TextEditingController();
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    double _currentRating = 0;

    Future<String> _getUploaderName(String providerId) async {
      final userDoc =
          await _firestore.collection('users').doc(providerId).get();
      return userDoc.exists ? userDoc['name'] ?? 'Unknown' : 'Unknown';
    }

    return FutureBuilder<String>(
      future: _getUploaderName(service.providerId),
      builder: (context, snapshot) {
        final uploaderName = snapshot.data ?? 'Loading...';

        return Scaffold(
          appBar: AppBar(
            title: Text(
              service.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color(0xFF558B2F),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (service.imagePath.isNotEmpty)
                    (service.imagePath.startsWith('http')
                        ? Image.network(
                            service.imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Image.file(
                            File(service.imagePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ))
                  else
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.green.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.green.shade800,
                      ),
                    ),
                  SizedBox(height: 10),
                  Text(
                    service.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green.shade900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Uploaded by: $uploaderName',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/chat', arguments: {
                          'receiverId': service.providerId,
                          'receiverName': uploaderName,
                        });
                      },
                      child: Text('Chat'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('services')
                        .doc(service.id)
                        .collection('comments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text('No comments yet.',
                            style: TextStyle(color: Colors.green.shade900));
                      }

                      final comments = snapshot.data!.docs;

                      return Column(
                        children: comments.map((commentDoc) {
                          final commentData =
                              commentDoc.data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(
                              commentData['text'] ?? '',
                              style: TextStyle(color: Colors.green.shade900),
                            ),
                            subtitle: Text(
                              commentData['userId'] ?? 'Anonymous',
                              style: TextStyle(color: Colors.green.shade600),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send, color: Colors.green.shade800),
                        onPressed: () {
                          if (_commentController.text.isNotEmpty) {
                            _firestore
                                .collection('services')
                                .doc(service.id)
                                .collection('comments')
                                .add({
                              'userId': _auth.currentUser!.email ?? 'Anonymous',
                              'text': _commentController.text,
                            });
                            _commentController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  Text(
                    'Rate this service',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  SizedBox(height: 10),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              Icons.star,
                              color: index < _currentRating
                                  ? Colors.yellow
                                  : Colors.grey,
                            ),
                            onPressed: () async {
                              setState(() {
                                _currentRating = index + 1;
                              });
                              final userEmail = _auth.currentUser!.email;
                              final ratingRef = _firestore
                                  .collection('services')
                                  .doc(service.id)
                                  .collection('ratings')
                                  .doc(userEmail);

                              await ratingRef.set({'rating': index + 1});
                            },
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
