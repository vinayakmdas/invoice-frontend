import 'package:invoice/features/auth/domain/entities/login_result.dart';
import 'package:invoice/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginResult> call({
    required String username,
    required String password,
  }) {
    return repository.login(username: username, password: password);
  }
}
