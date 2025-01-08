// models/servicemodel.dart
class ServiceModel {
  final String id;
  final String title;
  final String description;
  final double price;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });

  // Convert a JSON map to a ServiceModel instance
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
    );
  }

  // Convert a ServiceModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
    };
  }

  // Static method to generate a list of placeholder services
  static List<ServiceModel> getPlaceholderServices() {
    return [
      ServiceModel(
          id: '1',
          title: 'Logo Design',
          description: 'Professional logo design services.',
          price: 50.0),
      ServiceModel(
          id: '2',
          title: 'Web Development',
          description: 'Create a responsive website tailored to your needs.',
          price: 200.0),
      ServiceModel(
          id: '3',
          title: 'SEO Optimization',
          description: 'Improve your website ranking on search engines.',
          price: 100.0),
      ServiceModel(
          id: '4',
          title: 'Social Media Management',
          description: 'Manage your social media presence effectively.',
          price: 150.0),
      ServiceModel(
          id: '5',
          title: 'Content Writing',
          description: 'Engaging content for your blog or website.',
          price: 75.0),
      ServiceModel(
          id: '6',
          title: 'Graphic Design',
          description: 'Creative graphics for your marketing needs.',
          price: 80.0),
      ServiceModel(
          id: '7',
          title: 'Video Editing',
          description: 'Professional video editing services.',
          price: 120.0),
      ServiceModel(
          id: '8',
          title: 'Consulting Services',
          description: 'Expert advice for your business.',
          price: 250.0),
    ];
  }
}
