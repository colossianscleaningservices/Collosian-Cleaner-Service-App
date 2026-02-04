import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../services/pref.dart';

/// Interceptor that appends authentication and meta headers to every request.
/// Doing this at request time guarantees updated tokens and timezone are sent.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['platform'] =
        kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios');
    options.headers['isDebug'] = kDebugMode.toString();
    options.headers['timezone'] = Prefs().getTimeZoneData(Prefs.timezone);
    final token = Prefs().token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
