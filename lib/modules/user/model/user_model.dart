class UserModel {
  final String id;
  final String name;
  final String nomorInduk;
  final String passwordHash;
  final String role;
  final bool isActive;
  final String createdAt;
  final String email;
  final String programStudy;
  final String photoUrl;
  final String source;

  const UserModel({
    required this.id,
    required this.name,
    required this.nomorInduk,
    required this.passwordHash,
    required this.role,
    required this.isActive,
    this.createdAt = '',
    this.email = '',
    this.programStudy = '',
    this.photoUrl = '',
    this.source = '',
  });

  String get username => nomorInduk;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['id'] ?? '';
    final number = (json['nomor_induk'] ?? json['username'] ?? '').toString();
    final roleRaw = (json['role'] ?? '').toString().trim().toLowerCase();

    return UserModel(
      id: rawId.toString(),
      name: (json['name'] ?? '').toString(),
      nomorInduk: number,
      passwordHash:
          (json['password_hash'] ?? json['password'] ?? '').toString(),
      role: roleRaw == 'staff' ? 'teknisi' : roleRaw,
      isActive: (json['isActive'] ?? true) as bool,
      createdAt: (json['createdAt'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      programStudy: (json['programStudy'] ?? '').toString(),
      photoUrl: (json['photoUrl'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? nomorInduk,
    String? passwordHash,
    String? role,
    bool? isActive,
    String? createdAt,
    String? email,
    String? programStudy,
    String? photoUrl,
    String? source,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nomorInduk: nomorInduk ?? this.nomorInduk,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      programStudy: programStudy ?? this.programStudy,
      photoUrl: photoUrl ?? this.photoUrl,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'name': name,
      'nomor_induk': nomorInduk,
      'username': nomorInduk,
      'password_hash': passwordHash,
      'password': passwordHash,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt,
      'email': email,
      'programStudy': programStudy,
      'photoUrl': photoUrl,
      'source': source,
    };
  }
}
