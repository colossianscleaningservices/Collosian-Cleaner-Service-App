import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:ccs_app/app/routes/app_pages.dart';
import 'package:ccs_app/app/services/crashlytics_service.dart';
import 'package:ccs_app/app/services/network_monitor_service.dart';
import 'package:ccs_app/app/utils/notifier.dart';
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

void _showErrorOverlay(Object error) {
  try {
    if (!Get.isRegistered<NetworkMonitorService>()) return;
  } catch (_) {
    return;
  }
  if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) return;

  try {
    final context = Get.context;
    if (context == null) return;

    Notifier.openSheet(
      context,
      type: SheetType.error,
      title: 'Something went wrong',
      message:
          'We encountered an unexpected error. Please try again or contact support if the problem persists.',
      showPrimaryButton: true,
      showSecondaryButton: false,
      primaryButtonLabel: 'Reload App',
      onPrimaryPressed: () {
        Get.back();
        Get.offAllNamed(Routes.SPLASH);
      },
    );
  } catch (e) {
    SecureLogger.logError('ERROR_HANDLER', e);
  }
}

void _reportToCrashReporting(Object error, StackTrace? stack) {
  CrashlyticsService.instance.recordCriticalError(
    error,
    stack,
    reason: 'Unhandled exception',
    fatal: true,
  );
}
