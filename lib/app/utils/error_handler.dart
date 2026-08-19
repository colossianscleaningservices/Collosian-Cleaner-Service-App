import 'package:flutter/foundation.dart';

import 'package:ccs_app/app/services/crashlytics_service.dart';
import 'package:ccs_app/app/utils/secure_logger.dart';

/// Global error handler for Flutter framework errors (mirror WAVTech).
void setupErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    SecureLogger.logError(
      'FLUTTER_ERROR',
      details.exception,
      details.stack,
    );
    FlutterError.presentError(details);
    if (kReleaseMode) {
      _reportToCrashReporting(details.exception, details.stack);
    }
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    SecureLogger.logError('PLATFORM_ERROR', error, stack);
    if (kReleaseMode) {
      _reportToCrashReporting(error, stack);
    }
    return true;
  };
}

void _reportToCrashReporting(Object error, StackTrace? stack) {
  CrashlyticsService.instance.recordCriticalError(
    error,
    stack,
    reason: 'Unhandled exception',
    fatal: true,
  );
}
