import 'package:dio/dio.dart';

import '../../services/env_service.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient() {
    final baseOptions = BaseOptions(
      baseUrl: EnvService.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: <String, String>{
        'Accept': Headers.jsonContentType,
        'Content-Type': Headers.jsonContentType,
      },
    );
    _dio = Dio(baseOptions);
    _dio.interceptors.add(AuthInterceptor());
  }

  late final Dio _dio;

  Dio getClient() => _dio;
}

