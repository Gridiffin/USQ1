// Simplified homepage.dart retaining search icon toggle for search bar
import 'package:flutter/material.dart';
import '../profile/profilepage.dart'; // Import the ProfilePage
import '../favorites/favoritespage.dart'; // Import the FavoritesPage
import '../chat/chatscreen.dart'; // Import the ChatScreen
import 'homecontent.dart'; // Separated HomeContent
import '../profile/otheruserprofile.dart'; // Import OtherUserProfile
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearchBar = false;
  bool _showUserResults = false;

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
        backgroundColor: Colors.green.shade700,
        title: _selectedIndex != 2
            ? (_showSearchBar
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search services or users...',
                        hintStyle: TextStyle(
                          height: 1.5, // Aligns text vertically with icon
                          color: Colors.green.shade900,
                        ),
                        border: InputBorder.none,
                        prefixIcon:
                            Icon(Icons.search, color: Colors.green.shade900),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear, color: Colors.green.shade900),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _showUserResults = false;
                              _showSearchBar = false;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                          _showUserResults = value.isNotEmpty;
                        });
                      },
                    ),
                  )
                : Text('Side Quest',
                    style: TextStyle(color: Colors.green.shade100)))
            : Text('Profile', style: TextStyle(color: Colors.green.shade100)),
        actions: [
          if (_selectedIndex != 2 && !_showSearchBar)
            IconButton(
              icon: Icon(Icons.search, size: 30, color: Colors.green.shade900),
              onPressed: () {
                setState(() {
                  _showSearchBar = true;
                });
              },
            ),
          IconButton(
            icon: Icon(Icons.chat, size: 30, color: Colors.green.shade900),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            },
          ),
        ],
      ),
      body: _searchQuery.isEmpty
          ? (_selectedIndex == 0
              ? HomeContent() // Use HomeContent directly
              : _screens[_selectedIndex])
          : Column(
              children: [
                if (_showUserResults)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: UserSearchResults(searchQuery: _searchQuery),
                  ),
                Divider(color: Colors.green.shade900),
                Expanded(
                  // Use Expanded to give HomeContent the remaining space
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HomeContent(searchQuery: _searchQuery),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green.shade100,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green.shade900,
        unselectedItemColor: Colors.green.shade600,
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

class UserSearchResults extends StatelessWidget {
  final String searchQuery;

  UserSearchResults({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs.where((user) {
          final userData = user.data() as Map<String, dynamic>;
          return (userData['name']?.toString().toLowerCase() ?? '')
              .contains(searchQuery);
        }).toList();

        if (users.isEmpty) {
          return Center(
            child: Text(
              'No users found',
              style: TextStyle(fontSize: 18, color: Colors.brown),
            ),
          );
        }

        return Column(
          children: users.map((userDoc) {
            final user = userDoc.data() as Map<String, dynamic>;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user['imageUrl'] != null
                    ? NetworkImage(user['imageUrl'])
                    : const AssetImage('assets/images/profile_pic.png')
                        as ImageProvider,
              ),
              title: Text(
                user['name'] ?? 'Unknown User',
                style: TextStyle(color: Colors.green.shade900),
              ),
              subtitle: Text(user['email'] ?? 'No Email',
                  style: TextStyle(color: Colors.green.shade700)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtherUserProfile(
                      matricId: user['matricId'],
                      name: user['name'],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
