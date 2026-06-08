import 'package:invoice/features/admin/domain/entity/admin_entity.dart';

class AdminModel extends AdminEntity {
  const AdminModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    required super.lastLogin,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'admin',
      lastLogin: DateTime.tryParse(json['last_login'] ?? '') ?? DateTime.now(),
    );
  }
}
