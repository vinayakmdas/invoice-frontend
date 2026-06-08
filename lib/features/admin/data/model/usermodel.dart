import 'package:invoice/features/admin/domain/entity/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.username,
    required super.email,
    required super.phone,
    required super.isApproved,
    required super.role,
    required super.createdAt,
    super.companyName,
  });

  @override
  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? phone,
    bool? isApproved,
    String? role,
    DateTime? createdAt,
    String? profileImage,
    String? companyName,
    UserStatus? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isApproved: status != null
          ? (status == UserStatus.approved)
          : (isApproved ?? this.isApproved),
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      companyName: companyName ?? this.companyName,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isApproved: json['is_approved'] == true,
      role: json['role'] ?? 'user',
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at']) ?? DateTime.now())
          : DateTime.now(),
      companyName: json['company_name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'phone': phone,
    'is_approved': isApproved,
    'role': role,
    'created_at': createdAt.toIso8601String(),
    'company_name': companyName,
  };
}
