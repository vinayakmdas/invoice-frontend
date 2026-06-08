import 'package:flutter/foundation.dart';
import '../../domain/entities/register_result.dart';
import '../../data/repositories/register_repository_impl.dart';

class RegisterViewModel extends ChangeNotifier {
  final _repo = RegisterRepositoryImpl();

  // Field values
  String _name = '';
  String _username = '';
  String _email = '';
  String _phone = '';
  String _password = '';
  String _confirmPassword = '';

  // UI state
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  // Field-level validation errors
  String? nameError;
  String? usernameError;
  String? emailError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;

  // Getters
  bool get showPassword => _showPassword;
  bool get showConfirmPassword => _showConfirmPassword;
  bool get isLoading => _isLoading;

  // Updaters
  void updateName(String v) {
    _name = v.trim();
    nameError = null;
    notifyListeners();
  }

  void updateUsername(String v) {
    _username = v.trim();
    usernameError = null;
    notifyListeners();
  }

  void updateEmail(String v) {
    _email = v.trim();
    emailError = null;
    notifyListeners();
  }

  void updatePhone(String v) {
    _phone = v.trim();
    phoneError = null;
    notifyListeners();
  }

  void updatePassword(String v) {
    _password = v;
    passwordError = null;
    notifyListeners();
  }

  void updateConfirmPassword(String v) {
    _confirmPassword = v;
    confirmPasswordError = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _showConfirmPassword = !_showConfirmPassword;
    notifyListeners();
  }

  bool _validate() {
    bool valid = true;

    if (_name.isEmpty) {
      nameError = 'Full name is required';
      valid = false;
    }
    if (_username.isEmpty) {
      usernameError = 'Username is required';
      valid = false;
    }
    if (_email.isEmpty || !_email.contains('@')) {
      emailError = 'Enter a valid email';
      valid = false;
    }
    if (_phone.length != 10 || !RegExp(r'^\d{10}$').hasMatch(_phone)) {
      phoneError = 'Enter a valid 10-digit phone number';
      valid = false;
    }
    if (_password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
      valid = false;
    }
    if (_confirmPassword != _password) {
      confirmPasswordError = 'Passwords do not match';
      valid = false;
    }

    notifyListeners();
    return valid;
  }

  Future<RegisterResult> register() async {
    if (!_validate()) {
      return const RegisterResult(
        status: RegisterStatus.error,
        message: 'Please fix the errors above.',
      );
    }

    _isLoading = true;
    notifyListeners();

    final result = await _repo.register(
      name: _name,
      username: _username,
      email: _email,
      phone: _phone,
      password: _password,
    );

    // Map server-side uniqueness errors back to field errors
    switch (result.status) {
      case RegisterStatus.usernameTaken:
        usernameError = result.message;
        break;
      case RegisterStatus.emailTaken:
        emailError = result.message;
        break;
      case RegisterStatus.phoneTaken:
        phoneError = result.message;
        break;
      default:
        break;
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }
}
