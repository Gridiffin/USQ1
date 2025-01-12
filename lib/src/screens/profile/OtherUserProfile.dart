import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../chat/individualchatscreen.dart';
import '../shared/servicedetailspage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/servicemodels.dart';

class OtherUserProfile extends StatelessWidget {
  final String matricId; // User's matric ID
  final String name; // User's display name

  OtherUserProfile({required this.matricId, required this.name});

  Future<void> _startChat(BuildContext context) async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) {
      print("User not logged in");
      return;
    }

    // Fetch other user's UID from matricId
    final otherUserUid = await getUidFromMatricId(matricId);

    // Ensure `otherUserUid` is valid and is NOT the chat's document ID
    if (otherUserUid == null || otherUserUid == currentUserUid) {
      print("Invalid otherUserUid or chatting with self.");
      return;
    }

    // Generate consistent chat ID
    final chatId = _generateChatId(currentUserUid, otherUserUid);

    // Check if the chat already exists
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      // Create the chat if it doesn't exist
      await chatRef.set({
        'participants': [currentUserUid, otherUserUid],
        'lastMessage': '',
        'timestamp': Timestamp.now(),
      });
    }

    // Navigate to the chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IndividualChatScreen(
          chatId: chatId,
          userName: name,
        ),
      ),
    );
  }

  Future<String?> getUidFromMatricId(String matricId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('matricId', isEqualTo: matricId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id; // Return the UID
      } else {
        print("No user found for matricId: $matricId");
        return null; // No match found
      }
    } catch (e) {
      print("Error fetching UID from matricId: $e");
      return null;
    }
  }

  String _generateChatId(String uid1, String uid2) {
    final sortedUids = [uid1, uid2]..sort();
    return sortedUids.join('_');
  }

  Stream<QuerySnapshot> _fetchUserServices(String matricId) async* {
    try {
      // Fetch UID from matricId
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('matricId', isEqualTo: matricId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final userUid = query.docs.first.id;

        // Fetch services where providerId matches UID
        yield* FirebaseFirestore.instance
            .collection('services')
            .where('providerId', isEqualTo: userUid)
            .snapshots();
      } else {
        // Return an empty stream if no user is found
        yield* Stream.fromIterable([]);
      }
    } catch (e) {
      print("Error fetching services: $e");
      // Return an empty stream in case of an error
      yield* Stream.fromIterable([]);
    }
  }

  Stream<double> _averageRatingStream(String serviceId) {
    return FirebaseFirestore.instance
        .collection('services')
        .doc(serviceId)
        .collection('ratings')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0.0;
      final ratings = snapshot.docs.map((doc) => doc['rating'] as int).toList();
      final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      return averageRating;
    });
  }

  Future<String?> _fetchProfileImage(String matricId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('matricId', isEqualTo: matricId)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        final userData = query.docs.first.data();
        return userData['imageUrl']; // Return the imageUrl field
      }
    } catch (e) {
      print("Error fetching profile image: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF558B2F),
        centerTitle: true,
      ),
      body: FutureBuilder<String?>(
        future: _fetchProfileImage(matricId),
        builder: (context, snapshot) {
          final profileImage = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: profileImage != null
                            ? NetworkImage(profileImage)
                            : AssetImage('assets/images/profile_pic.png')
                                as ImageProvider,
                      ),
                      SizedBox(height: 20),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        matricId,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _startChat(context),
                        icon: Icon(Icons.chat, color: Colors.white),
                        label: Text(
                          'Start Chat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          backgroundColor: Color(0xFF558B2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Services by $name',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _fetchUserServices(matricId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final services = snapshot.data!.docs;

                      if (services.isEmpty) {
                        return Center(
                          child: Text(
                            'No services uploaded yet.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final serviceData =
                              services[index].data() as Map<String, dynamic>;
                          final serviceId = services[index].id;
                          return StreamBuilder<double>(
                            stream: _averageRatingStream(serviceId),
                            builder: (context, ratingSnapshot) {
                              final averageRating = ratingSnapshot.data ?? 0.0;
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: serviceData['imageUrl'] != null
                                      ? Image.network(
                                          serviceData['imageUrl'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(Icons.image,
                                          size: 50, color: Colors.grey),
                                  title: Text(
                                    serviceData['title'] ?? 'Untitled',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    averageRating > 0
                                        ? 'Rating: ${averageRating.toStringAsFixed(1)}'
                                        : 'No ratings yet',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                  ),
                                  onTap: () {
                                    final service =
                                        ServiceModel.fromJson(serviceData);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ServiceDetailsPage(
                                          service:
                                              service, // Pass the converted ServiceModel
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
