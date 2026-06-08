import 'package:flutter/material.dart';
import 'package:invoice/features/admin/data/model/usermodel.dart';
import 'package:invoice/features/admin/domain/entity/admin_entity.dart';
import 'package:invoice/features/admin/domain/entity/dashboard_entity.dart';
import 'package:invoice/features/admin/domain/entity/invoice_entity.dart';
import 'package:invoice/features/admin/domain/entity/user_entity.dart';
import 'package:invoice/features/admin/domain/repository/admin_repository_impl.dart';
import 'package:invoice/features/auth/presentation/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Enum for loading state ────────────────────────────────────────────────────

enum LoadingState { idle, loading, loaded, error }

// ── Auth Provider ─────────────────────────────────────────────────────────────

class AuthProvider extends ChangeNotifier {
  AdminEntity? _admin;
  bool _isLoggedIn = true; // Set to true since login page already done
  LoadingState _state = LoadingState.idle;
  String? _error;

  AdminEntity? get admin => _admin;
  bool get isLoggedIn => _isLoggedIn;
  LoadingState get state => _state;
  String? get error => _error;

  final AdminRepositoryImpl _repo = AdminRepositoryImpl();

  Future<void> loadAdminProfile() async {
    _state = LoadingState.loading;
    notifyListeners();
    try {
      _admin = await _repo.getAdminProfile();
      _state = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    }
    notifyListeners();
  }

  void logout(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
    _isLoggedIn = false;
    _admin = null;
    notifyListeners();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginView()),
      (route) => false,
    );
  }
}

// ── User Provider ─────────────────────────────────────────────────────────────

class UserProvider extends ChangeNotifier {
  List<UserEntity> _users = [];
  LoadingState _state = LoadingState.idle;
  String? _error;
  String _searchQuery = '';
  String _filterStatus = 'All'; // All, Pending, Approved, Rejected

  List<UserEntity> get users => _filteredUsers;
  LoadingState get state => _state;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;

  int get pendingCount =>
      _users.where((u) => u.status == UserStatus.pending).length;

  List<UserEntity> get _filteredUsers {
    var result = _users.where((u) => u.role != 'admin').toList();
    // Apply status filter
    if (_filterStatus != 'All') {
      final status = UserStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == _filterStatus.toLowerCase(),
        orElse: () => UserStatus.pending,
      );
      result = result.where((u) => u.status == status).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (u) =>
                u.name.toLowerCase().contains(q) ||
                u.email.toLowerCase().contains(q) ||
                u.phone.toLowerCase().contains(q),
          )
          .toList();
    }

    return result;
  }

  final AdminRepositoryImpl _repo = AdminRepositoryImpl();

  Future<void> loadUsers() async {
    _state = LoadingState.loading;
    notifyListeners();
    try {
      _users = await _repo.getUsers();
      _state = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    }
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<bool> approveUser(String userId) async {
    print("🔥 APPROVE CALLED: $userId");
    try {
      await _repo.approveUser(userId);
      print("✅ REPO SUCCESS");
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        // ✅ Cast to UserModel before copyWith
        final user = _users[idx] as UserModel;
        _users[idx] = user.copyWith(status: UserStatus.approved);
      }
      notifyListeners();
      return true;
    } catch (e) {
      print("❌ CAUGHT IN PROVIDER: $e");
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectUser(String userId) async {
    try {
      await _repo.rejectUser(userId);
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(status: UserStatus.rejected);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _repo.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

// ── Invoice Provider ──────────────────────────────────────────────────────────

class InvoiceProvider extends ChangeNotifier {
  List<InvoiceEntity> _invoices = [];
  InvoiceEntity? _selectedInvoice;
  LoadingState _state = LoadingState.idle;
  LoadingState _detailState = LoadingState.idle;
  String? _error;
  String _searchQuery = '';
  String _statusFilter = 'All';

  List<InvoiceEntity> get invoices => _filteredInvoices;
  InvoiceEntity? get selectedInvoice => _selectedInvoice;
  LoadingState get state => _state;
  LoadingState get detailState => _detailState;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  List<InvoiceEntity> get _filteredInvoices {
    var result = _invoices;

    if (_statusFilter != 'All') {
      result = result
          .where((i) => i.status.toLowerCase() == _statusFilter.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (i) =>
                i.customerName.toLowerCase().contains(q) ||
                i.invoiceNumber.toLowerCase().contains(q) ||
                i.createdByUserName.toLowerCase().contains(q),
          )
          .toList();
    }

    return result;
  }

  final AdminRepositoryImpl _repo = AdminRepositoryImpl();

  Future<void> loadInvoices() async {
    _state = LoadingState.loading;
    notifyListeners();
    try {
      _invoices = await _repo.getInvoices();
      _state = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    }
    notifyListeners();
  }

  Future<void> loadInvoiceDetail(String invoiceId) async {
    _detailState = LoadingState.loading;
    notifyListeners();
    try {
      // Try to find in already fetched local list first
      final localInvoice = _invoices.firstWhere((i) => i.id == invoiceId);
      _selectedInvoice = localInvoice;
      _detailState = LoadingState.loaded;
    } catch (e) {
      // Fallback to repository fetch if not present in the local list
      try {
        _selectedInvoice = await _repo.getInvoiceById(invoiceId);
        _detailState = LoadingState.loaded;
      } catch (err) {
        _error = err.toString();
        _detailState = LoadingState.error;
      }
    }
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  void clearSelectedInvoice() {
    _selectedInvoice = null;
    notifyListeners();
  }
}

// ── Dashboard Provider ────────────────────────────────────────────────────────

class DashboardProvider extends ChangeNotifier {
  DashboardStats? _stats;
  LoadingState _state = LoadingState.idle;
  String? _error;

  DashboardStats? get stats => _stats;
  LoadingState get state => _state;
  String? get error => _error;

  final AdminRepositoryImpl _repo = AdminRepositoryImpl();

  Future<void> loadStats() async {
    _state = LoadingState.loading;
    notifyListeners();
    try {
      _stats = await _repo.getDashboardStats();
      _state = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    }
    notifyListeners();
  }
}
