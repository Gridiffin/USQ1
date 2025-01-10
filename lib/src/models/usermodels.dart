class UserModel {
  final String uid; // User's Firebase UID
  final String name; // Display name of the user
  final String email; // User's email address
  final String matricId; // User's unique matric ID
  final String imageUrl; // Profile picture URL

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.matricId,
    required this.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      matricId: json['matricId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'matricId': matricId,
      'imageUrl': imageUrl,
    };
  }
}
