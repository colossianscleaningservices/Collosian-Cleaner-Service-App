import 'package:ccs_app/export.dart';
import 'package:dio/dio.dart';

import '../../services/env_service.dart';
import '../../services/pref.dart';
import 'auth_interceptor.dart';
import 'log_interceptor.dart' as ccs_log;

class DioClient {
  DioClient() {

    final baseOptions = BaseOptions(
      baseUrl: EnvService.apiBaseUrl,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
      sendTimeout: const Duration(seconds: 120),
      headers: <String, String>{
        'Accept': Headers.jsonContentType,
        'Content-Type': Headers.jsonContentType,
        if (Prefs().token.isNotEmpty) 'Authorization': 'Bearer ${Prefs().token}',
      },
    );
    _dio = Dio(baseOptions);
    _dio.interceptors.add(AuthInterceptor());
    if (kDebugMode) _dio.interceptors.add(ccs_log.LogInterceptor());
  }

  late final Dio _dio;

  Dio getClient() => _dio;
}
