import 'package:dio/dio.dart';
import 'package:invoice/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:invoice/features/auth/domain/entities/login_result.dart';
import 'package:invoice/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(
        username: username,
        password: password,
      );

      final data = response.data;

      int? findId(Map map) {
        final raw = map['user_id'] ?? map['id'];
        if (raw != null) {
          if (raw is int) return raw;
          return int.tryParse(raw.toString());
        }
        for (final value in map.values) {
          if (value is Map) {
            final nestedId = findId(value);
            if (nestedId != null) return nestedId;
          }
        }
        return null;
      }

      String? findRole(Map map) {
        if (map['role'] != null) {
          return map['role'].toString();
        }
        for (final value in map.values) {
          if (value is Map) {
            final nestedRole = findRole(value);
            if (nestedRole != null) return nestedRole;
          }
        }
        return null;
      }

      if (data != null && data is Map) {
        final userId = findId(data);
        final role = findRole(data);
        final statusFlag = data['status'];
        
        final isSuccess = statusFlag == true || (statusFlag != false && userId != null);

        if (isSuccess) {
          return LoginResult(
            status: LoginStatus.success,
            message: data['message'] ?? "Login Success",
            role: role,
            userId: userId,
            username: data['username']?.toString() ?? data['name']?.toString() ?? username,
          );
        }
      }

      return LoginResult(
        status: LoginStatus.invalidCredentials,
        message: (data != null && data is Map)
            ? (data['message'] ?? "Invalid username or password")
            : "Invalid response from server",
      );
    } on DioException catch (e) {
      print("DIO ERROR: ${e.message}");
      print("RESPONSE: ${e.response?.data}");

      String errorMessage = "Connection error. Please try again.";
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'] ?? errorMessage;
        } else if (data is String && data.isNotEmpty) {
          errorMessage = data;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      return LoginResult(status: LoginStatus.error, message: errorMessage);
    } catch (e) {
      print("UNEXPECTED ERROR: $e");
      return LoginResult(
        status: LoginStatus.error,
        message: "An unexpected error occurred",
      );
    }
  }
}
