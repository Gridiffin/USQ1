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

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('lovedServices')
          .doc(widget.service.id)
          .delete();
    } else {
      await userFavoritesRef.set(widget.service.toJson());

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('lovedServices')
          .doc(widget.service.id)
          .set(widget.service.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('users')
          .doc(userId)
          .collection('lovedServices')
          .doc(widget.service.id)
          .snapshots(),
      builder: (context, snapshot) {
        final isLoved = snapshot.hasData && snapshot.data!.exists;

        return Card(
          elevation: 2, // Add elevation for better visual appearance
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              Expanded(
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
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
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
                      ),
                    ),
                    SizedBox(height: 4),
                    StreamBuilder(
                      stream: _firestore
                          .collection('services')
                          .doc(widget.service.id)
                          .collection('ratings')
                          .snapshots(),
                      builder: (context, ratingSnapshot) {
                        if (!ratingSnapshot.hasData ||
                            ratingSnapshot.data!.docs.isEmpty) {
                          return Text(
                            'No ratings yet',
                            style: TextStyle(color: Colors.grey[600]),
                          );
                        }

                        final ratings = ratingSnapshot.data!.docs
                            .map((doc) => doc['rating'] as int)
                            .toList();
                        final averageRating =
                            ratings.reduce((a, b) => a + b) / ratings.length;

                        return Text(
                          'Rating: ${averageRating.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Love Button
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    isLoved ? Icons.favorite : Icons.favorite_border,
                    color: isLoved ? Colors.red : Colors.grey,
                  ),
                  onPressed: _toggleLove,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
