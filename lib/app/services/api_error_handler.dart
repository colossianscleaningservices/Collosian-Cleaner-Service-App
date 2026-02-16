import 'package:get/get.dart';

import '../network/utils/network_exception.dart';
import '../utils/notifier.dart';
import 'session_service.dart';

/// Global API error handler. Runs for every API error unless explicitly bypassed.
/// - Shows toast when [showAlert] and [NetworkException.shouldShowApiError]
/// - Triggers logout when [NetworkException.requiresLogout] (e.g. 401)
/// - Prevents stacking multiple alerts
class ApiErrorHandler extends GetxService {
  bool _isShowingError = false;

  /// Handles an API error: shows toast and/or triggers logout.
  /// [showAlert] when false suppresses the toast (e.g. silent refresh).
  /// Logout for 401 is always performed regardless of [showAlert].
  Future<void> handle(
    NetworkException error, {
    bool showAlert = true,
    String? contextTag,
  }) async {
    if (showAlert && error.shouldShowApiError && !_isShowingError) {
      _isShowingError = true;
      try {
        await Notifier.apiError(error, contextTag: contextTag);
      } finally {
        _isShowingError = false;
      }
    } else if (error.requiresLogout) {
      await Get.find<SessionService>().logout();
    }
  }
}
