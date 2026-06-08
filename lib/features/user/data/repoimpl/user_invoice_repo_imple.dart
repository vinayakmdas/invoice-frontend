import 'package:invoice/features/user/data/model/invoice_data_model.dart';
import 'package:invoice/features/user/domain/enitites/invoice_enitites.dart';
import 'package:invoice/features/user/domain/repo/user_invoice_repo.dart';
import '../datasources/user_api_datasource.dart';

class UserInvoiceRepositoryImpl implements UserInvoiceRepository {
  final UserApiDatasource _datasource;
  UserInvoiceRepositoryImpl(this._datasource);

  @override
  Future<List<UserInvoiceEntity>> getInvoices() => _datasource.fetchInvoices();

  @override
  Future<UserInvoiceEntity> addInvoice(UserInvoiceEntity invoice) {
    final model = InvoiceDataModel(
      customerName: invoice.customerName,
      email: invoice.email,
      phone: invoice.phone,
      address: invoice.address,
      date: invoice.date,
      item: invoice.item,
      createdBy: invoice.createdBy,
    );
    return _datasource.createInvoice(model);
  }

  @override
  Future<void> deleteInvoice(int id) => _datasource.deleteInvoice(id);
}
