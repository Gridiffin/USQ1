import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({Key? key}) : super(key: key);

  Future<int> _getUserCount() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return querySnapshot.docs.length;
  }

  Future<int> _getServiceCount() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('services').get();
    return querySnapshot.docs.length;
  }

  Future<List<Map<String, dynamic>>> _getTopRatedServices() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('services')
        .orderBy('rating', descending: true)
        .limit(5)
        .get();

    return querySnapshot.docs
        .map((doc) => {'title': doc['title'], 'rating': doc['rating']})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: const Color(0xFF558B2F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reports Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            FutureBuilder<int>(
              future: _getUserCount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Text('Total Users: ${snapshot.data ?? 0}');
              },
            ),
            const SizedBox(height: 10),
            FutureBuilder<int>(
              future: _getServiceCount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Text('Total Services: ${snapshot.data ?? 0}');
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Top Rated Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getTopRatedServices(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final services = snapshot.data ?? [];
                if (services.isEmpty) {
                  return const Text('No services found.');
                }

                return Column(
                  children: services.map((service) {
                    return ListTile(
                      title: Text(service['title']),
                      subtitle: Text('Rating: ${service['rating']}'),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
