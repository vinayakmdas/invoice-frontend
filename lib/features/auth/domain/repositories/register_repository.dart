import '../entities/register_result.dart';

abstract class RegisterRepository {
  Future<RegisterResult> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
  });
}
