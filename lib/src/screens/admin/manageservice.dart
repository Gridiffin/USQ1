import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/servicedetailspage.dart';
import '../../models/servicemodels.dart';

class ManageServicesPage extends StatelessWidget {
  const ManageServicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        backgroundColor: const Color(0xFF558B2F),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No services found.'));
          }

          final services = snapshot.data!.docs;

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final serviceDoc = services[index];
              final serviceData = serviceDoc.data() as Map<String, dynamic>;
              final service = ServiceModel.fromJson({
                ...serviceData,
                'id': serviceDoc.id, // Ensure the id is included
              });

              return ListTile(
                leading: service.imageUrl.isNotEmpty
                    ? Image.network(
                        service.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.image, size: 50, color: Colors.grey),
                title:
                    Text(service.title.isNotEmpty ? service.title : 'Untitled'),
                subtitle: Text(service.description.isNotEmpty
                    ? service.description
                    : 'No Description'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ServiceDetailsPage(service: service),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Service'),
                        content: Text(
                            'Are you sure you want to delete this service?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await FirebaseFirestore.instance
                          .collection('services')
                          .doc(service.id)
                          .delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${service.title} deleted.')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
