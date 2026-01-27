import 'package:flutter/foundation.dart';

class SecureLogger {
  SecureLogger._();

  static void log(String tag, String message) {
    if (!kDebugMode) return;
    // Basic redaction for common sensitive values.
    final safe = message
        .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9\-\._]+'), 'Bearer [REDACTED]')
        .replaceAll(RegExp(r'\b[A-Z]{2}\d{6}[A-Z]\b'), '[REDACTED_NIN]')
        .replaceAll(RegExp(r'\b\d{10,}\b'), '[REDACTED_NUMBER]');
    // ignore: avoid_print
    print('[$tag] $safe');
  }
}

