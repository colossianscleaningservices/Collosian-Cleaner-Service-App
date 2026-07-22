import 'package:ccs_app/export.dart';

import 'session_service.dart';

/// Global API error handler. Runs for every API error unless explicitly bypassed.
/// - Shows toast when [showAlert] and [NetworkException.shouldShowApiError]
/// - Triggers logout when [NetworkException.requiresLogout] (e.g. 401) and user is logged in
/// - Prevents stacking multiple alerts
class ApiErrorHandler extends GetxService {
  bool _isShowingError = false;

  /// Handles an API error: shows toast and/or triggers logout.
  /// [showAlert] when false suppresses the toast (e.g. silent refresh).
  /// Logout for 401 is only performed when the user is currently logged in.
  Future<void> handle(
    NetworkException error, {
    bool showAlert = true,
    String? contextTag,
  }) async {
    try {
      Loader.hide();
    } catch (e) {
      e.printError(info: contextTag ?? runtimeType.toString());
    }

    if (showAlert && error.shouldShowApiError && !_isShowingError) {
      _isShowingError = true;
      try {
        await Notifier.apiError(error, contextTag: contextTag);
      } finally {
        _isShowingError = false;
      }
    } else if (error.requiresLogout && Get.find<SessionService>().isLoggedIn) {
      await Get.find<SessionService>().logout();
    }
  }
}
