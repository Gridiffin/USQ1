import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Favorites'),
        ),
        body: Center(
          child: Text('Please log in to view your favorites.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .doc(userId)
            .collection('userFavorites')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final favoriteDocs = snapshot.data!.docs;

          if (favoriteDocs.isEmpty) {
            return Center(
              child: Text(
                'No favorites yet!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: favoriteDocs.length,
            itemBuilder: (context, index) {
              final favoriteId = favoriteDocs[index].id;

              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('services')
                    .doc(favoriteId)
                    .get(),
                builder:
                    (context, AsyncSnapshot<DocumentSnapshot> serviceSnapshot) {
                  if (!serviceSnapshot.hasData) {
                    return ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  final serviceData =
                      serviceSnapshot.data!.data() as Map<String, dynamic>?;

                  if (serviceData == null) {
                    return ListTile(
                      title: Text('Service not found'),
                    );
                  }

                  return Card(
                    child: ListTile(
                      leading: serviceData['imagePath'] != null
                          ? (serviceData['imagePath']
                                  .toString()
                                  .startsWith('http')
                              ? Image.network(
                                  serviceData['imagePath'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(serviceData['imagePath']),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ))
                          : Icon(Icons.image, size: 50, color: Colors.grey),
                      title: Text(serviceData['title'] ?? 'Unknown Title'),
                      subtitle: Text(serviceData['description'] ??
                          'No description available'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          // Remove the service from the user's favorites
                          await FirebaseFirestore.instance
                              .collection('favorites')
                              .doc(userId)
                              .collection('userFavorites')
                              .doc(favoriteId)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Removed from favorites')),
                          );
                        },
                      ),
                      onTap: () {
                        // Navigate to the detailed service page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailPage(
                              title: serviceData['title'] ?? 'Unknown Title',
                              description: serviceData['description'] ??
                                  'No description available',
                              price: serviceData['price']?.toDouble() ?? 0.0,
                              imageUrl: serviceData['imagePath'] ?? '',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ServiceDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  ServiceDetailPage({
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? (imageUrl.startsWith('http')
                    ? Image.network(imageUrl,
                        fit: BoxFit.cover, width: double.infinity)
                    : Image.file(
                        File(imageUrl),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ))
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 100, color: Colors.grey),
                  ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(description,
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 16),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
