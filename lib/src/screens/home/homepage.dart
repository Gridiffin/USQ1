import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../models/servicemodels.dart';
import '../profile/profilepage.dart'; // Import the ProfilePage
import '../favorites/favoritespage.dart'; // Import the FavoritesPage
import '../chat/chatscreen.dart'; // Import the ChatScreen
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Widget> _screens = [
    HomeContent(),
    FavoritesPage(),
    ProfilePage(),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.chat, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? HomeContent(searchQuery: _searchQuery)
          : _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class HomeContent extends StatelessWidget {
  final String searchQuery;

  HomeContent({this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('services').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final services = snapshot.data!.docs.map((doc) {
          return ServiceModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();

        final filteredServices = services
            .where((service) =>
                service.title.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

        return filteredServices.isEmpty
            ? Center(
                child: Text(
                  'No services found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : GridView.builder(
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
    );
  }
}

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

      // Remove the service from lovedServices
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('lovedServices')
          .doc(widget.service.id)
          .delete();
    } else {
      await userFavoritesRef.set(widget.service.toJson());

      // Add the service to lovedServices
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
          child: Column(
            children: [
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
              ListTile(
                title: Text(widget.service.title),
                subtitle: StreamBuilder(
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
                trailing: IconButton(
                  icon: Icon(
                    isLoved ? Icons.favorite : Icons.favorite_border,
                    color: isLoved ? Colors.red : null,
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
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('name', isEqualTo: service.providerId)
                    .limit(1)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      'Loading uploader info...',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    );
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return Text(
                      'Uploader information not found',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    );
                  }

                  final uploaderData =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  return Text(
                    'Uploaded by: ${uploaderData['name'] ?? 'Unknown'}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  );
                },
              ),
              SizedBox(height: 10),
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
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('services')
                    .doc(service.id)
                    .collection('comments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final comments = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index].data();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(comment['userId'])
                                  .get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    'Loading user info...',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  );
                                }
                                if (userSnapshot.hasError ||
                                    !userSnapshot.hasData ||
                                    !userSnapshot.data!.exists) {
                                  return Text(
                                    'Unknown User',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  );
                                }
                                final userData = userSnapshot.data!.data()
                                    as Map<String, dynamic>;
                                final userName = userData['name'] ?? 'Unknown';
                                return Text(
                                  userName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                            Text(
                              comment['text'] ?? '',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
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
                          'userId': FirebaseAuth.instance.currentUser!
                              .uid, // Replace with actual user ID
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
