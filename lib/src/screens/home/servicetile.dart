// Updated servicetile.dart to reinforce background color
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/servicemodels.dart';
import 'dart:io';

class ServiceTile extends StatefulWidget {
  final ServiceModel service;

  ServiceTile({required this.service});

  @override
  _ServiceTileState createState() => _ServiceTileState();
}

class _ServiceTileState extends State<ServiceTile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _toggleLove() async {
    final userId = _auth.currentUser!.uid;
    final userFavoritesRef = _firestore
        .collection('favorites')
        .doc(userId)
        .collection('userFavorites')
        .doc(widget.service.id);

    final docSnapshot = await userFavoritesRef.get();

    if (docSnapshot.exists) {
      await userFavoritesRef.delete();
    } else {
      await userFavoritesRef.set(widget.service.toJson());
    }
  }

  Future<double> _getAverageRating() async {
    final ratingsSnapshot = await _firestore
        .collection('services')
        .doc(widget.service.id)
        .collection('ratings')
        .get();

    if (ratingsSnapshot.docs.isEmpty) return 0;

    final ratings =
        ratingsSnapshot.docs.map((doc) => doc['rating'] as int).toList();
    final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
    return averageRating;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _getAverageRating(),
      builder: (context, snapshot) {
        final averageRating = snapshot.data ?? 0;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.green.shade200, // Ensures the jungle-green background
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: widget.service.imagePath.isNotEmpty
                      ? (widget.service.imagePath.startsWith('http')
                          ? Image.network(
                              widget.service.imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Image.file(
                              File(widget.service.imagePath),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ))
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade300,
                          ),
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.green.shade800,
                          ),
                        ),
                ),
              ),
              // Title, Rating, and Love Button Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.service.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      averageRating > 0
                          ? 'Rating: ${averageRating.toStringAsFixed(1)}'
                          : 'No ratings yet',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              // Love Button
              Align(
                alignment: Alignment.centerRight,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('favorites')
                      .doc(_auth.currentUser!.uid)
                      .collection('userFavorites')
                      .doc(widget.service.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final isLoved = snapshot.hasData && snapshot.data!.exists;

                    return IconButton(
                      icon: Icon(
                        isLoved ? Icons.favorite : Icons.favorite_border,
                        color: isLoved ? Colors.red : Colors.brown,
                      ),
                      onPressed: _toggleLove,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
