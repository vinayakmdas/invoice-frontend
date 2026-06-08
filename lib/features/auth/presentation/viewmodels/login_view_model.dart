import 'package:flutter/material.dart';
import 'package:invoice/core/constant/api_clints.dart';
import 'package:invoice/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:invoice/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:invoice/features/auth/domain/entities/login_result.dart';
import 'package:invoice/features/auth/domain/usecases/login_usecase.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  LoginViewModel({LoginUseCase? loginUseCase})
      : loginUseCase = loginUseCase ??
            LoginUseCase(
              AuthRepositoryImpl(
                AuthRemoteDataSourceImpl(ApiClient.dio),
              ),
            );

  String _username = '';
  String _password = '';

  bool _isLoading = false;
  bool _showPassword = false;
  bool _rememberMe = false;

  bool get isLoading => _isLoading;
  bool get showPassword => _showPassword;
  bool get rememberMe => _rememberMe;

  void updateUsername(String value) {
    _username = value;
  }

  void updatePassword(String value) {
    _password = value;
  }

  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  Future<LoginResult> login() async {
    _isLoading = true;
    notifyListeners();

    final result = await loginUseCase(
      username: _username,
      password: _password,
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }
}
