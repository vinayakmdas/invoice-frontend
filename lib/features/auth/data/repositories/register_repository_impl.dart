import 'package:dio/dio.dart';
import 'package:invoice/core/constant/api_clints.dart';
import '../../domain/entities/register_result.dart';
import '../../domain/repositories/register_repository.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  @override
  Future<RegisterResult> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      await ApiClient.dio.post(
        'register/',
        data: {
          'name': name,
          'username': username,
          'email': email,
          'phone': phone,
          'password': password,
          // is_approved is intentionally omitted — backend defaults it to false
        },
      );

      return const RegisterResult(
        status: RegisterStatus.success,
        message: 'Account created! Please wait for admin approval.',
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map) {
        if (data.containsKey('username')) {
          return RegisterResult(
            status: RegisterStatus.usernameTaken,
            message: 'Username already taken.',
          );
        }
        if (data.containsKey('email')) {
          return RegisterResult(
            status: RegisterStatus.emailTaken,
            message: 'Email already registered.',
          );
        }
        if (data.containsKey('phone')) {
          return RegisterResult(
            status: RegisterStatus.phoneTaken,
            message: 'Phone number already registered.',
          );
        }
      }

      return RegisterResult(
        status: RegisterStatus.error,
        message: 'Something went wrong. Please try again.',
      );
    } catch (_) {
      return const RegisterResult(
        status: RegisterStatus.error,
        message: 'Unexpected error. Please try again.',
      );
    }
  }
}
