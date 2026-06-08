import 'package:flutter/material.dart';
import 'package:invoice/features/user/domain/enitites/invoice_enitites.dart';
import 'package:invoice/features/user/domain/repo/user_invoice_repo.dart';

enum InvoiceState { idle, loading, success, error }

class InvoiceViewModel extends ChangeNotifier {
  final UserInvoiceRepository _repository;
  InvoiceViewModel(this._repository);

  List<UserInvoiceEntity> _invoices = [];
  List<UserInvoiceEntity> get invoices => List.unmodifiable(_invoices);

  InvoiceState _state = InvoiceState.idle;
  InvoiceState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<void> loadInvoices(int userId) async {
    _state = InvoiceState.loading;
    notifyListeners();
    try {
      final all = await _repository.getInvoices();
      // Show only invoices belonging to this user
      _invoices = all.where((inv) => inv.createdBy == userId).toList();
      _state = InvoiceState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = InvoiceState.error;
    }
    notifyListeners();
  }

  /// Returns null on success, error string on failure.
  Future<String?> addInvoice({
    required String customerName,
    required String email,
    required String phone,
    required String address,
    required String date,
    required int item,
    required int createdBy,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final newInvoice = await _repository.addInvoice(
        UserInvoiceEntity(
          customerName: customerName,
          email: email,
          phone: phone,
          address: address,
          date: date,
          item: item,
          createdBy: createdBy,
        ),
      );
      _invoices = [..._invoices];
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<String?> deleteInvoice(int id) async {
    try {
      await _repository.deleteInvoice(id);
      _invoices = _invoices.where((inv) => inv.id != id).toList();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
