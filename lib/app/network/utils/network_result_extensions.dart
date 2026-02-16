import 'package:get/get.dart';

import '../../services/api_error_handler.dart';
import 'network_exception.dart';
import 'network_result.dart';

extension NetworkResultX<T> on NetworkResult<T> {
  /// Handles API result with optional error override.
  /// - [success]: required, called with data on success
  /// - [showAlert]: when true (default), global handler shows toast. When false, suppresses toast (e.g. silent refresh)
  /// - [contextTag]: optional tag for logging/debugging
  /// - [onError]: optional. When provided, runs AFTER the global handler. Use for extra per-call logic.
  void handle({
    required void Function(T data) success,
    bool showAlert = true,
    String? contextTag,
    void Function(NetworkException error)? onError,
  }) {
    switch (this) {
      case NetworkSuccess<T>(:final data):
        success(data);
      case NetworkError<T>(error: final e):
        Get.find<ApiErrorHandler>().handle(e, showAlert: showAlert, contextTag: contextTag);
        onError?.call(e);
    }
  }
}
