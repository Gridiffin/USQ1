// screens/home/homepage.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/servicemodels.dart';
import '../profile/profilepage.dart'; // Import the ProfilePage
import '../favorites/favoritespage.dart'; // Import the FavoritesPage
import '../chat/chatscreen.dart'; // Import the ChatScreen

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex =
      0; // Track the selected index for the bottom navigation bar
  final TextEditingController _searchController =
      TextEditingController(); // Controller for search bar
  String _searchQuery = ''; // Track the search query

  // Define the screens for the bottom navigation bar
  final List<Widget> _screens = [
    HomeContent(), // Home screen content
    FavoritesPage(), // Favorites screen
    ProfilePage(), // Profile screen
  ];

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40, // Set a fixed height for the search bar
          child: TextField(
            controller: _searchController, // Connect the controller
            decoration: InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search), // Search icon
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        // Clear the search text
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null, // Show clear button only when there's text
            ),
            onChanged: (value) {
              // Update the search query as the user types
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        actions: [
          // Chat Button
          IconButton(
            icon: Icon(Icons.chat, size: 30), // Chat icon
            onPressed: () {
              // Navigate to chat screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? HomeContent(searchQuery: _searchQuery) // Pass the search query
          : _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favorites"), // Favorites tab
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"), // Profile tab
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  // Handle bottom navigation bar taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

// Home Content (moved from the original build method)
class HomeContent extends StatelessWidget {
  final String searchQuery;

  HomeContent({this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('services')
          .where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThanOrEqualTo: searchQuery + '\uF7FF')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final services = snapshot.data!.docs.map((doc) {
          return ServiceModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();

        return services.isEmpty
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
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to a detailed view of the service
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
                              child: Image.network(
                                service.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$${service.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                // Rating System (Star Rating)
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < 4
                                          ? Icons.star
                                          : Icons
                                              .star_border, // Example rating (4/5)
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                              ],
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

  // Show service details (including comments and rating)
  void _showServiceDetails(BuildContext context, ServiceModel service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                service.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(service.description),
              SizedBox(height: 20),
              // Comment Section
              Expanded(
                child: ListView.builder(
                  itemCount: 5, // Example: 5 comments
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('User $index'),
                      subtitle: Text('This is a sample comment.'),
                    );
                  },
                ),
              ),
              // Add Comment Input
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
        );
      },
    );
  }
}
