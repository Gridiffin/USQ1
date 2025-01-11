import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'dart:io';
import '../../models/servicemodels.dart';
import 'servicetile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeContent extends StatelessWidget {
  final String? searchQuery;

  HomeContent({this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/jungle_background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ServiceModel.fromJson(data);
          }).toList();

          final filteredServices = services.where((service) {
            final titleLower = service.title.toLowerCase();
            final queryLower = searchQuery?.toLowerCase() ?? '';
            return titleLower.contains(queryLower);
          }).toList();

          if (filteredServices.isEmpty) {
            return Center(
              child: Text(
                'No services found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.brown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: filteredServices.length,
            itemBuilder: (context, index) {
              final service = filteredServices[index];
              return GestureDetector(
                onTap: () {
                  _showServiceDetails(context, service);
                },
                child: ServiceTile(service: service),
              );
            },
          );
        },
      ),
    );
  }

  void _showServiceDetails(BuildContext context, ServiceModel service) {
    final TextEditingController _commentController = TextEditingController();
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    double _currentRating = 0;

    Future<String> _getUploaderName(String providerId) async {
      final userDoc =
          await _firestore.collection('users').doc(providerId).get();
      return userDoc.exists ? userDoc['name'] ?? 'Unknown' : 'Unknown';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.green.shade100,
      builder: (context) {
        return FutureBuilder<String>(
          future: _getUploaderName(service.providerId),
          builder: (context, snapshot) {
            final uploaderName = snapshot.data ?? 'Loading...';

            return Container(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (service.imageUrl.isNotEmpty)
                      Image.network(
                        service.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
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
                      style:
                          TextStyle(fontSize: 16, color: Colors.green.shade900),
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
                                'userId':
                                    _auth.currentUser!.email ?? 'Anonymous',
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
            );
          },
        );
      },
    );
  }
}
