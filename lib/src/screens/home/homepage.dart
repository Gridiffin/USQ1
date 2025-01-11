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
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search services or users...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _showUserResults = false;
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
                _showUserResults = value.isNotEmpty;
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
                Divider(),
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
        items: const [
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
              style: TextStyle(fontSize: 18, color: Colors.grey),
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
              title: Text(user['name'] ?? 'Unknown User'),
              subtitle: Text(user['email'] ?? 'No Email'),
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
