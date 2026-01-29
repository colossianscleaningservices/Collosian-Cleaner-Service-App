import 'package:dio/dio.dart';

class DioClient {
  Dio getClient() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    return dio;
  }
}
