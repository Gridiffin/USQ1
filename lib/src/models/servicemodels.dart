class ServiceModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> tags;
  final String imagePath;
  final String providerId;
  final double rating;
  final DateTime createdAt;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tags,
    required this.imagePath,
    required this.providerId,
    required this.rating,
    required this.createdAt,
  });

  // Convert a JSON map to a ServiceModel instance
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      tags: List<String>.from(json['tags']),
      imagePath: json['imagePath'] ?? '',
      providerId: json['providerId'],
      rating: (json['rating'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Convert a ServiceModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'imagePath': imagePath,
      'providerId': providerId,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
