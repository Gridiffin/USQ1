import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../models/servicemodels.dart';
import 'servicetile.dart'; // Updated ServiceTile
import 'package:firebase_auth/firebase_auth.dart';

class HomeContent extends StatelessWidget {
  final String? searchQuery;

  HomeContent({this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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

        print(
            'Filtered Services Length: ${filteredServices.length}'); // Debugging
        print('Filtered Services: $filteredServices'); // Debugging

        if (filteredServices.isEmpty) {
          return Center(
            child: Text(
              'No services found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
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
            print('Rendering ServiceTile for: ${service.title}'); // Debugging
            return GestureDetector(
              onTap: () {
                _showServiceDetails(context, service);
              },
              child: ServiceTile(service: service),
            );
          },
        );
      },
    );
  }

  void _showServiceDetails(BuildContext context, ServiceModel service) {
    final TextEditingController _commentController = TextEditingController();
    double _currentRating = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service.imagePath.isNotEmpty)
                  Image.file(
                    File(service.imagePath),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                SizedBox(height: 10),
                Text(
                  service.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  service.description,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Divider(),
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        if (_commentController.text.isNotEmpty) {
                          FirebaseFirestore.instance
                              .collection('services')
                              .doc(service.id)
                              .collection('comments')
                              .add({
                            'userId': FirebaseAuth.instance.currentUser!.uid,
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
                            final userEmail =
                                FirebaseAuth.instance.currentUser!.email;
                            final ratingRef = FirebaseFirestore.instance
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
  }
}
