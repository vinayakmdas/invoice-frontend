import 'package:invoice/features/user/domain/enitites/invoice_enitites.dart';

abstract class UserInvoiceRepository {
  Future<List<UserInvoiceEntity>> getInvoices();
  Future<UserInvoiceEntity> addInvoice(UserInvoiceEntity invoice);
  Future<void> deleteInvoice(int id);
}
