enum UserStatus { pending, approved, rejected }

class UserEntity {
  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final bool isApproved;
  final String role;
  final DateTime createdAt;
  final String? profileImage;
  final String? companyName;

  const UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.isApproved,
    required this.role,
    required this.createdAt,
    this.profileImage,
    this.companyName,
  });

  UserStatus get status => isApproved ? UserStatus.approved : UserStatus.pending;

  UserEntity copyWith({
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
    return UserEntity(
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
      profileImage: profileImage ?? this.profileImage,
      companyName: companyName ?? this.companyName,
    );
  }
}
