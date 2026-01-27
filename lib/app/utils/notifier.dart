import 'package:toastification/toastification.dart';

import '../../export.dart';
import '../services/session_service.dart';

class Notifier {
  Notifier._();

  static const _duration = Duration(seconds: 3);

  static void success(String message, {String title = 'Success'}) {
    _show(title: title, message: message, type: ToastificationType.success);
  }

  static void info(String message, {String title = 'Info'}) {
    _show(title: title, message: message, type: ToastificationType.info);
  }

  static void error(String message, {String title = 'Error'}) {
    _show(title: title, message: message, type: ToastificationType.error);
  }

  static Future<void> apiError(
    Object error, {
    String? contextTag,
  }) async {
    final ex = error is NetworkException ? error : NetworkException.fromDio(error);
    _show(title: ex.title, message: ex.message, type: ToastificationType.error);

    if (ex.requiresLogout) {
      // Clear all prefs and redirect to login.
      await Get.find<SessionService>().logout();
    }
  }

  static void _show({
    required String title,
    required String message,
    required ToastificationType type,
  }) {
    toastification.show(
      type: type,
      style: ToastificationStyle.flat,
      alignment: Alignment.topCenter,
      autoCloseDuration: _duration,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(title),
      description: Text(message),
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
    );
  }
}

