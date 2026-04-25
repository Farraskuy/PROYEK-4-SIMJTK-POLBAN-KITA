class UserModel {
  final String id;
  final String username;
  final String email;
  final String name;
  final String role;
  final String programStudy;
  final String photoUrl;
  final String source;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    this.programStudy = '',
    this.photoUrl = '',
    this.source = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      isActive: (json['isActive'] ?? false) as bool,
      programStudy: (json['programStudy'] ?? '').toString(),
      photoUrl: (json['photoUrl'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'role': role,
      'isActive': isActive,
      'programStudy': programStudy,
      'photoUrl': photoUrl,
      'source': source,
    };
  }
}
