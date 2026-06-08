import 'package:invoice/features/admin/domain/entity/admin_entity.dart';
import 'package:invoice/features/admin/domain/entity/dashboard_entity.dart';
import 'package:invoice/features/admin/domain/entity/invoice_entity.dart';
import 'package:invoice/features/admin/domain/entity/user_entity.dart';

abstract class AdminRepository {
  Future<List<UserEntity>> getUsers();
  Future<void> approveUser(String userId);
  Future<void> rejectUser(String userId);
  Future<void> deleteUser(String userId);
  Future<List<InvoiceEntity>> getInvoices();
  Future<InvoiceEntity> getInvoiceById(String invoiceId);
  Future<DashboardStats> getDashboardStats();
  Future<AdminEntity> getAdminProfile();
}
