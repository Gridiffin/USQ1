// models/servicemodel.dart
class ServiceModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl; // Added field for image URL

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl, // Updated constructor to include imageUrl
  });

  // Convert a JSON map to a ServiceModel instance
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] ?? '', // Added handling for imageUrl
    );
  }

  // Convert a ServiceModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl, // Include imageUrl in the JSON map
    };
  }

  // Static method to generate a list of placeholder services
  static List<ServiceModel> getPlaceholderServices() {
    return [
      ServiceModel(
          id: '1',
          title: 'Logo Design',
          description: 'Professional logo design services.',
          price: 50.0,
          imageUrl: 'https://via.placeholder.com/150'), // Example image URL
      ServiceModel(
          id: '2',
          title: 'Web Development',
          description: 'Create a responsive website tailored to your needs.',
          price: 200.0,
          imageUrl: 'https://via.placeholder.com/150'),
      ServiceModel(
          id: '3',
          title: 'SEO Optimization',
          description: 'Improve your website ranking on search engines.',
          price: 100.0,
          imageUrl: 'https://via.placeholder.com/150'),
      ServiceModel(
          id: '4',
          title: 'Social Media Management',
          description: 'Manage your social media presence effectively.',
          price: 150.0,
          imageUrl: 'https://via.placeholder.com/150'),
      ServiceModel(
          id: '5',
          title: 'Content Writing',
          description: 'Engaging content for your blog or website.',
          price: 75.0,
          imageUrl: 'https://via.placeholder.com/150'),
      ServiceModel(
          id: '6',
          title: 'Graphic Design',
          description: 'Creative graphics for your marketing needs.',
          price: 80.0,
          imageUrl: 'https://via.placeholder.com/150'),
      ServiceModel(
          id: '7',
          title: 'Video Editing',
          description: 'Professional video editing services.',
          price: 120.0,
          imageUrl: 'https://via.placeholder.com/150'),
      ServiceModel(
          id: '8',
          title: 'Consulting Services',
          description: 'Expert advice for your business.',
          price: 250.0,
          imageUrl: 'https://via.placeholder.com/150'),
    ];
  }
}
