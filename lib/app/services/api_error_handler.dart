import 'package:ccs_app/export.dart';

import 'session_service.dart';

/// Global API error handler. Runs for every API error unless explicitly bypassed.
/// - Shows toast when [showAlert] and [NetworkException.shouldShowApiError]
/// - Triggers logout when [NetworkException.requiresLogout] (e.g. 401) and user is logged in
/// - Prevents stacking multiple alerts and duplicate login navigations
class ApiErrorHandler extends GetxService {
  bool _isShowingError = false;

  /// Handles an API error: shows toast and/or triggers logout.
  /// [showAlert] when false suppresses the toast (e.g. silent refresh).
  /// Logout for 401 is only performed when the user is currently logged in,
  /// and concurrent 401s share a single navigation to login.
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

    final session = Get.find<SessionService>();

    if (error.requiresLogout) {
      if (session.shouldIgnoreUnauthorized(contextTag: contextTag)) return;
      if (showAlert && error.shouldShowApiError) {
        await Notifier.apiError(error, contextTag: contextTag);
      } else if (session.isLoggedIn) {
        await session.logout(notifyServer: false);
      }
      return;
    }

    if (showAlert && error.shouldShowApiError && !_isShowingError) {
      _isShowingError = true;
      try {
        await Notifier.apiError(error, contextTag: contextTag);
      } finally {
        _isShowingError = false;
      }
    }
  }
}
