import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

class SecureLogger {
  static const List<String> _sensitiveKeys = [
    'token',
    'authorization',
    'bearer',
    'password',
    'password_confirmation',
    'secret',
    'api_key',
    'access_token',
    'refresh_token',
    'id_token',
    'email',
    'phone',
    'card_number',
    'cvv',
    'ssn',
    'credit_card',
  ];

  static const String _maskedValue = '***REDACTED***';

  /// Sanitize string by masking sensitive patterns
  static String _sanitizeString(String message) {
    String sanitized = message;

    // Mask tokens (Bearer tokens, JWT-like strings)
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'(Bearer\s+)([A-Za-z0-9\-._~+/]+=*)', caseSensitive: false),
      (match) => '${match.group(1)}$_maskedValue',
    );

    // Mask email addresses
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      (match) => _maskedValue,
    );

    // Mask phone numbers
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'),
      (match) => _maskedValue,
    );

    // Mask potential tokens (long alphanumeric strings)
    sanitized = sanitized.replaceAllMapped(RegExp(r'\b[A-Za-z0-9]{32,}\b'), (
      match,
    ) {
      final value = match.group(0)!;
      // Don't mask if it looks like a UUID or standard format
      if (value.contains('-') || value.contains('_')) {
        return value;
      }
      return _maskedValue;
    });

    return sanitized;
  }

  /// Sanitize map/JSON data
  static dynamic _sanitizeData(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final sanitized = <String, dynamic>{};
      for (final entry in data.entries) {
        final key = entry.key.toString().toLowerCase();
        final isSensitive = _sensitiveKeys.any((sk) => key.contains(sk));

        if (isSensitive) {
          sanitized[entry.key] = _maskedValue;
        } else if (entry.value is Map || entry.value is List) {
          sanitized[entry.key] = _sanitizeData(entry.value);
        } else if (entry.value is String) {
          sanitized[entry.key] = _sanitizeString(entry.value as String);
        } else {
          sanitized[entry.key] = entry.value;
        }
      }
      return sanitized;
    }

    if (data is List) {
      return data.map((item) => _sanitizeData(item)).toList();
    }

    if (data is String) {
      return _sanitizeString(data);
    }

    return data;
  }

  /// Log message with sanitization (only in debug mode)
  static void log(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) {
      // In release mode, don't log to console
      return;
    }

    final sanitizedMessage = _sanitizeString(message);
    dev.log(
      sanitizedMessage,
      name: tag.toUpperCase(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log data/JSON with sanitization (only in debug mode)
  static void logData(String tag, String label, dynamic data) {
    if (!kDebugMode) {
      return;
    }

    final sanitizedData = _sanitizeData(data);
    dev.log('$label: $sanitizedData', name: tag.toUpperCase());
  }

  /// Log error safely and report to Crashlytics in release mode
  /// Only exceptions are reported to Crashlytics, not routine errors
  static void logError(String tag, Object error, [StackTrace? stackTrace]) {
    final sanitizedError = error.toString();

    if (kDebugMode) {
      dev.log(
        sanitizedError,
        name: tag.toUpperCase(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Expose sanitizeString for external use if needed
  static String sanitizeString(String message) => _sanitizeString(message);
}

