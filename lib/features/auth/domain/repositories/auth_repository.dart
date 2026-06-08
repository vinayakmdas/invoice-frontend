import 'package:invoice/features/auth/domain/entities/login_result.dart';

abstract class AuthRepository {
  Future<LoginResult> login({
    required String username,
    required String password,
  });
}
