import 'package:invoice/core/constant/api_clints.dart';
import 'package:invoice/features/admin/data/model/admin_item_model.dart';
import 'package:invoice/features/admin/data/model/invoice_model.dart';
import 'package:invoice/features/admin/data/model/usermodel.dart';
import 'package:invoice/features/admin/data/repository/admin_repository.dart';
import 'package:invoice/features/admin/domain/entity/admin_entity.dart';
import 'package:invoice/features/admin/domain/entity/dashboard_entity.dart';
import 'package:invoice/features/admin/domain/entity/invoice_entity.dart';
import 'package:invoice/features/admin/domain/entity/user_entity.dart';

class AdminRepositoryImpl implements AdminRepository {
  // ------ Methods ------------------------------------------------------------

  @override
  Future<List<UserEntity>> getUsers() async {
    try {
      final response = await ApiClient.dio.get('users/');
      if (response.data is List) {
        return (response.data as List)
            .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
            .toList();
      } else if (response.data is Map) {
        final list = response.data['users'] ?? response.data['data'] ?? [];
        return (list as List)
            .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print("ERROR FETCHING USERS: $e");
      rethrow;
    }
  }

  @override
  Future<void> approveUser(String userId) async {
    try {
      await ApiClient.dio.put(
        'approve-user/$userId/',
        data: {'is_approved': true},
      );
    } catch (e) {
      print("ERROR APPROVING USER: $e");
      rethrow;
    }
  }

  @override
  Future<void> rejectUser(String userId) async {
    try {
      await ApiClient.dio.put('users/$userId/', data: {'is_approved': false});
    } catch (e) {
      print("ERROR REJECTING USER: $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await ApiClient.dio.delete('delete-user/$userId/');
    } catch (e) {
      print("ERROR DELETING USER: $e");
      rethrow;
    }
  }

  @override
  Future<List<InvoiceEntity>> getInvoices() async {
    try {
      final response = await ApiClient.dio.get('invoices/');
      if (response.data is List) {
        return (response.data as List)
            .map((i) => InvoiceModel.fromJson(i as Map<String, dynamic>))
            .toList();
      } else if (response.data is Map) {
        final list = response.data['invoices'] ?? response.data['data'] ?? [];
        return (list as List)
            .map((i) => InvoiceModel.fromJson(i as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print("ERROR FETCHING INVOICES: $e");
      rethrow;
    }
  }

  @override
  Future<InvoiceEntity> getInvoiceById(String invoiceId) async {
    try {
      final response = await ApiClient.dio.get('invoices/$invoiceId/');
      if (response.data is Map) {
        return InvoiceModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception("Invalid response format");
    } catch (e) {
      print("ERROR FETCHING INVOICE DETAIL: $e");
      rethrow;
    }
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
    try {
      final users = await getUsers();
      final invoices = await getInvoices();

      final pending = users.where((u) => u.status == UserStatus.pending).length;
      final approved = users
          .where((u) => u.status == UserStatus.approved)
          .length;
      final rejected = users
          .where((u) => u.status == UserStatus.rejected)
          .length;

      double revenue = 0;
      for (final inv in invoices) {
        if (inv.status.toLowerCase() == 'paid') {
          revenue += inv.totalAmount;
        }
      }

      return DashboardStats(
        totalUsers: users.length,
        pendingApprovals: pending,
        approvedUsers: approved,
        rejectedUsers: rejected,
        totalInvoices: invoices.length,
        totalRevenue: revenue,
      );
    } catch (e) {
      print("ERROR GETTING DASHBOARD STATS: $e");
      rethrow;
    }
  }

  @override
  Future<AdminEntity> getAdminProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return AdminModel.fromJson({
      'id': 'admin1',
      'name': 'Admin User',
      'email': 'admin@invoiceapp.com',
      'phone': '+91 90000 00001',
      'role': 'Super Admin',
      'last_login': DateTime.now()
          .subtract(const Duration(hours: 2))
          .toIso8601String(),
    });
  }
}
