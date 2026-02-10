import 'dart:io';

import 'package:ccs_app/app/utils/secure_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kDebugMode) {
      return super.onRequest(options, handler);
    }

    try {
      final parsedDate = DateFormat(
        'dd-MM-yyyy HH:mm:ss',
      ).format(DateTime.now());
      SecureLogger.log(
        'DIO',
        '[$parsedDate] -> [${options.method}] || ${options.uri}',
      );

      // Sanitize headers before logging
      final sanitizedHeaders = _sanitizeHeaders(options.headers);
      SecureLogger.logData('DIO', 'REQUEST HEADERS', sanitizedHeaders);

      if (options.data != null) {
        SecureLogger.log('DIO', 'REQUEST BODY ->');
        try {
          SecureLogger.logData('DIO', 'REQUEST BODY', options.data);
        } catch (e) {
          try {
            final fData = options.data as FormData;
            final sanitizedFields = <String, String>{};
            for (final entry in fData.fields) {
              sanitizedFields[entry.key] = SecureLogger.sanitizeString(
                entry.value,
              );
            }
            SecureLogger.logData('DIO', 'FORM FIELDS', sanitizedFields);

            // Log file info without sensitive data
            for (final entry in fData.files) {
              SecureLogger.log(
                'DIO',
                '${entry.key}: [File: ${entry.value.filename}]',
              );
            }
          } catch (e) {
            SecureLogger.log(
              'DIO',
              'REQUEST DATA: ${SecureLogger.sanitizeString(options.data.toString())}',
            );
          }
        }
      }
    } catch (e) {
      SecureLogger.logError('DIO', e);
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response,
      ResponseInterceptorHandler handler,
      ) {
    if (!kDebugMode) {
      return super.onResponse(response, handler);
    }

    try {
      SecureLogger.log(
        'DIO',
        '(${DateTime.now()}) <- [${response.statusCode}] || ${response.realUri}',
      );

      SecureLogger.log('DIO', 'RESPONSE BODY ->');
      SecureLogger.logData('DIO', 'RESPONSE', response.data);
    } catch (e) {
      SecureLogger.logError('DIO', e);
    }

    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kDebugMode) {
      return super.onError(err, handler);
    }

    try {
      final exec = err.error;
      if (exec is HandshakeException) {
        SecureLogger.log(
          'DIO API ERROR',
          'HANDSHAKE: ${exec.message} || ${err.requestOptions.uri}',
        );
      } else {
        SecureLogger.log(
          'DIO API ERROR',
          '-> [${err.response?.statusCode}] || ${err.requestOptions.uri}',
        );
      }

      if (err.response?.data != null) {
        SecureLogger.logData('DIO', 'ERR BODY', err.response?.data);
      }
    } catch (e) {
      SecureLogger.logError('DIO', e);
    }

    return super.onError(err, handler);
  }

  /// Sanitize headers before logging
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, dynamic>{};
    for (final entry in headers.entries) {
      final key = entry.key.toLowerCase();
      if (key.contains('authorization') || key.contains('token') || key.contains('secret') || key.contains('api-key')) {
        sanitized[entry.key] = '***REDACTED***';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }
}
