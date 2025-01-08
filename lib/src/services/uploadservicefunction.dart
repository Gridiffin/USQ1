import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ServiceUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadService({
    required String title,
    required String description,
    required double price,
    required String category,
    required List<String> tags,
    required String providerId,
  }) async {
    final uuid = Uuid();
    final serviceId = uuid.v4();

    try {
      await _firestore.collection('services').doc(serviceId).set({
        'id': serviceId,
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'tags': tags,
        'providerId': providerId,
        'rating': 0.0,
        'images': [], // Add image upload logic if needed
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to upload service: $e');
    }
  }
}
