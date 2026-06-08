import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<Response> login({
    required String username,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<Response> login({
    required String username,
    required String password,
  }) async {
    return await dio.post(
      'login/',
      data: {
        'username': username,
        'password': password,
      },
    );
  }
}
