class AdminModel {
  final String uid;
  final String name;
  final String email;
  final bool isVerified;

  AdminModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.isVerified,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'Admin',
      email: json['email'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'isVerified': isVerified,
    };
  }
}
