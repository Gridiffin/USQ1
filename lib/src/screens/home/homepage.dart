import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../models/servicemodels.dart';
import '../profile/profilepage.dart'; // Import the ProfilePage
import '../favorites/favoritespage.dart'; // Import the FavoritesPage
import '../chat/chatscreen.dart'; // Import the ChatScreen

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
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              child: service.imagePath.isNotEmpty
                                  ? Image.file(
                                      File(service.imagePath),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              service.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              service.description,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
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

  void _showServiceDetails(BuildContext context, ServiceModel service) {
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

                    final uploaderData = snapshot.data!.docs.first.data()
                        as Map<String, dynamic>;
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User $index',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'This is a sample comment.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        // Handle adding a comment
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
