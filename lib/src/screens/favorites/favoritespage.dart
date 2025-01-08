// screens/favorites/favoritespage.dart
import 'package:flutter/material.dart';
import '../../models/servicemodels.dart'; // Import the ServiceModel

class FavoritesPage extends StatelessWidget {
  // Example list of favorite services (replace with real data later)
  final List<ServiceModel> favoriteServices = [
    ServiceModel(
      id: '1',
      title: 'Logo Design',
      description: 'Professional logo design services.',
      price: 50.0,
    ),
    ServiceModel(
      id: '2',
      title: 'Web Development',
      description: 'Create a responsive website tailored to your needs.',
      price: 200.0,
    ),
    ServiceModel(
      id: '3',
      title: 'SEO Optimization',
      description: 'Improve your website ranking on search engines.',
      price: 100.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: favoriteServices.isEmpty
          ? Center(
              child: Text(
                'No favorites yet!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: favoriteServices.length,
              itemBuilder: (context, index) {
                final service = favoriteServices[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'lib/src/images/${service.id}.jpeg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      service.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      service.description,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Text(
                      '\$${service.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      // Navigate to service details (optional)
                      _showServiceDetails(context, service);
                    },
                  ),
                );
              },
            ),
    );
  }

  // Show service details (optional)
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
              // Rating System (Star Rating)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (starIndex) {
                  return Icon(
                    starIndex < 4
                        ? Icons.star
                        : Icons.star_border, // Example rating (4/5)
                    color: Colors.amber,
                    size: 24,
                  );
                }),
              ),
              SizedBox(height: 20),
              // Add to Cart Button (optional)
              ElevatedButton(
                onPressed: () {
                  // Handle adding to cart (optional)
                },
                child: Text('Add to Cart'),
              ),
            ],
          ),
        );
      },
    );
  }
}
