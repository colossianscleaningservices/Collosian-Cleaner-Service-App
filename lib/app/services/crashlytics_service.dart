import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Crashlytics service for tracking critical errors and exceptions ONLY. Mirror WAVTech: do NOT overload with routine logs.
class CrashlyticsService {
  CrashlyticsService._internal();

  static CrashlyticsService? _instance;

  static CrashlyticsService get instance => _instance ??= CrashlyticsService._internal();

  FirebaseCrashlytics? _crashlytics;
  bool _isInitialized = false;

  /// Initialize Crashlytics (call in main.dart after Firebase initialization).
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (kIsWeb) {
      if (kDebugMode) {
        debugPrint('CrashlyticsService: skipped on web');
      }
      return;
    }

    try {
      _crashlytics = FirebaseCrashlytics.instance;
      await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint(
          'CrashlyticsService: Initialized (collection disabled in debug mode)',
        );
      }
    } catch (e) {
      debugPrint('CrashlyticsService: Failed to initialize - $e');
      _isInitialized = false;
    }
  }

  /// Record a critical unhandled error/exception.
  Future<void> recordCriticalError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = true,
  }) async {
    if (!_isInitialized || _crashlytics == null) return;
    try {
      await _crashlytics!.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
      if (kDebugMode) {
        debugPrint('Crashlytics: Recorded critical error - $exception');
      }
    } catch (e) {
      debugPrint('CrashlyticsService: Failed to record error - $e');
    }
  }

  /// Record a non-fatal critical error (e.g. payment failures, server 5xx).
  Future<void> recordNonFatalError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? additionalInfo,
  }) async {
    if (!_isInitialized || _crashlytics == null) return;
    try {
      if (additionalInfo != null) {
        for (final entry in additionalInfo.entries) {
          await _crashlytics!.setCustomKey(entry.key, entry.value.toString());
        }
      }
      await _crashlytics!.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: false,
      );
      if (kDebugMode) {
        debugPrint('Crashlytics: Recorded non-fatal error - $exception');
      }
    } catch (e) {
      debugPrint('CrashlyticsService: Failed to record non-fatal error - $e');
    }
  }

  Future<void> log(String message) async {
    if (!_isInitialized || _crashlytics == null) return;
    try {
      await _crashlytics!.log(message);
    } catch (e) {
      debugPrint('CrashlyticsService: Failed to log message - $e');
    }
  }

  Future<void> setUserId(String? userId) async {
    if (!_isInitialized || _crashlytics == null) return;
    try {
      await _crashlytics!.setUserIdentifier(userId ?? 'anonymous');
    } catch (e) {
      debugPrint('CrashlyticsService: Failed to set user ID - $e');
    }
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    if (!_isInitialized || _crashlytics == null) return;
    try {
      await _crashlytics!.setCustomKey(key, value.toString());
    } catch (e) {
      debugPrint('CrashlyticsService: Failed to set custom key - $e');
    }
  }

  static bool isServerError(int? statusCode) => statusCode != null && statusCode >= 500 && statusCode < 600;
}
