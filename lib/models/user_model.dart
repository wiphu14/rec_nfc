class UserModel {
  final int id;
  final String username;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final int organizationId;
  final String? organizationName;
  final String? organizationCode;
  final bool isActive;
  final String? lastLogin;
  final String createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    this.phone,
    required this.role,
    required this.organizationId,
    this.organizationName,
    this.organizationCode,
    required this.isActive,
    this.lastLogin,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      username: json['username']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'user',
      organizationId: json['organization_id'] is int 
          ? json['organization_id'] 
          : int.parse(json['organization_id']?.toString() ?? '0'),
      organizationName: json['organization_name']?.toString(),
      organizationCode: json['organization_code']?.toString(),
      isActive: json['is_active'] == true || 
                json['is_active'] == 1 || 
                json['is_active'] == '1',
      lastLogin: json['last_login']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'organization_id': organizationId,
      'organization_name': organizationName,
      'organization_code': organizationCode,
      'is_active': isActive,
      'last_login': lastLogin,
      'created_at': createdAt,
    };
  }

  // Getters
  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
  bool get isSuperAdmin => role == 'super_admin';

  String get displayName => fullName.isNotEmpty ? fullName : username;
  String get organization => organizationName ?? organizationCode ?? 'N/A';

  // Copy with method
  UserModel copyWith({
    int? id,
    String? username,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    int? organizationId,
    String? organizationName,
    String? organizationCode,
    bool? isActive,
    String? lastLogin,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      organizationCode: organizationCode ?? this.organizationCode,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}