import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/servicemodels.dart';
import '../shared/servicedetailspage.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title:
              Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Color(0xFF558B2F),
        ),
        body: Center(
          child: Text(
            'Please log in to view your favorites.',
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFF558B2F),
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
                    return SizedBox
                        .shrink(); // Skip rendering until data is ready
                  }

                  final serviceData =
                      serviceSnapshot.data!.data() as Map<String, dynamic>?;

                  if (serviceData == null || serviceData.isEmpty) {
                    return SizedBox.shrink(); // Skip missing services
                  }

                  final service = ServiceModel.fromJson(serviceData);

                  return Card(
                    color: Colors.green.shade200,
                    shadowColor: Colors.black54,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      leading: service.imageUrl.isNotEmpty
                          ? Image.network(
                              service.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.image, size: 50, color: Colors.grey),
                      title: Text(
                        service.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        service.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ServiceDetailsPage(service: service),
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
