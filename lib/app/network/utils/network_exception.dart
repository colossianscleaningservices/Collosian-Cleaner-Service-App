import 'dart:io';

import 'package:dio/dio.dart';

import '../../model/api_error.dart';

/// Sealed network exception hierarchy (mirrors WAVTech).
/// Base has errorMessage, shouldShowApiError, errBody; subtypes add apiErrorMessage for display.
sealed class NetworkException implements Exception {
  const NetworkException({
    required this.errorMessage,
    this.shouldShowApiError = true,
    this.errBody,
    this.title,
    this.statusCode,
    this.isRetryable = false,
    this.requiresLogout = false,
  });

  final String errorMessage;
  final bool shouldShowApiError;
  final DefaultApiError? errBody;
  final String? title;
  final int? statusCode;
  final bool isRetryable;
  final bool requiresLogout;

  /// Display title for UI (e.g. toast/sheet). Defaults to 'Error'.
  String get displayTitle => title ?? 'Error';

  /// Display message for UI. Override in ApiException subclasses to prefer apiErrorMessage.
  String get message => errorMessage;

  /// Fallback when a raw error (e.g. DioException) is passed to Notifier.apiError().
  static NetworkException fromDio(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      if (statusCode == 401 || _looksUnauthenticated(data, error.message)) {
        return UnauthorizedRequestException(
          errorMessage: 'Sorry, the request is unauthorized.',
          title: 'Session expired',
          apiErrorMessage: _extractMessage(data),
          statusCode: statusCode,
        );
      }
      if (statusCode == 403) {
        return ForbiddenException(
          errorMessage: "Sorry, you don't have permission for this action.",
          title: 'Access denied',
          apiErrorMessage: _extractMessage(data),
          statusCode: statusCode,
        );
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.transformTimeout) {
        return RequestTimeoutException(
          errorMessage: 'Sorry, the request has timed out.',
          apiErrorMessage: _extractMessage(data),
        );
      }
      if (error.type == DioExceptionType.connectionError ||
          (error.type == DioExceptionType.unknown &&
              error.error is SocketException)) {
        return NoInternetConnectionException(
          errorMessage: 'No internet connection.',
        );
      }
      if (error.type == DioExceptionType.badResponse && statusCode != null) {
        return DefaultApiException(
          errorMessage: 'Something went wrong. Please try again.',
          apiErrorMessage: _extractMessage(data),
          statusCode: statusCode,
        );
      }
      return UnexpectedErrorException(
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
    if (error is SocketException) {
      return NoInternetConnectionException(
        errorMessage: 'No internet connection.',
      );
    }
    return UnexpectedErrorException(
      errorMessage: 'Something went wrong. Please try again.',
    );
  }

  static bool _looksUnauthenticated(Object? data, String? msg) {
    final m = (msg ?? '').toLowerCase();
    if (m.contains('unauthenticated') || m.contains('invalid token')) return true;
    if (data is Map) {
      final t = (data['type'] ?? data['error'] ?? '').toString().toLowerCase();
      if (t.contains('invalid_token') || t.contains('expired_token')) return true;
      final s = (data['message'] ?? '').toString().toLowerCase();
      if (s.contains('unauthenticated')) return true;
    }
    return false;
  }

  static String? _extractMessage(Object? data) {
    if (data == null) return null;
    if (data is String && data.trim().isNotEmpty) return data;
    if (data is Map) {
      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) return message;
    }
    return null;
  }
}

// ─── ApiException (has apiErrorMessage for server message) ─────────────────

class ApiException extends NetworkException {
  const ApiException({
    required super.errorMessage,
    this.apiErrorMessage,
    super.errBody,
    super.shouldShowApiError,
    super.title,
    super.statusCode,
    super.isRetryable,
    super.requiresLogout,
  });

  final String? apiErrorMessage;

  @override
  String get message => shouldShowApiError ? (apiErrorMessage ?? errorMessage) : errorMessage;
}

class DefaultApiException extends ApiException {
  const DefaultApiException({
    required super.errorMessage,
    super.apiErrorMessage,
    super.errBody,
    super.shouldShowApiError,
    super.title,
    super.statusCode,
  });
}

class UnauthorizedRequestException extends ApiException {
  const UnauthorizedRequestException({
    required super.errorMessage,
    super.apiErrorMessage,
    super.errBody,
    super.shouldShowApiError,
    super.title,
    super.statusCode,
  }) : super(requiresLogout: true);
}

class ForbiddenException extends ApiException {
  const ForbiddenException({
    required super.errorMessage,
    super.apiErrorMessage,
    super.errBody,
    super.shouldShowApiError,
    super.title,
    super.statusCode,
  });
}

class NotFoundException extends ApiException {
  const NotFoundException({
    required super.errorMessage,
    super.apiErrorMessage,
    super.errBody,
    super.shouldShowApiError,
    super.title,
    super.statusCode,
  });

  @override
  String get message => shouldShowApiError ? (apiErrorMessage ?? errorMessage) : errorMessage;
}

class ConflictException extends ApiException {
  const ConflictException({
    required super.errorMessage,
    super.apiErrorMessage,
    super.shouldShowApiError,
    super.title,
    super.statusCode,
  });

  @override
  String get message => shouldShowApiError ? (apiErrorMessage ?? errorMessage) : errorMessage;
}

class RequestTimeoutException extends ApiException {
  const RequestTimeoutException({
    required super.errorMessage,
    super.apiErrorMessage,
    super.shouldShowApiError,
    super.title,
    super.statusCode,
  }) : super(isRetryable: true);

  @override
  String get message => shouldShowApiError ? (apiErrorMessage ?? errorMessage) : errorMessage;
}

class UnableToProcessException extends ApiException {
  const UnableToProcessException({
    required super.errorMessage,
    super.apiErrorMessage,
    super.errBody,
    super.shouldShowApiError,
    super.title,
    super.statusCode,
  });

  @override
  String get message => shouldShowApiError ? (apiErrorMessage ?? errorMessage) : errorMessage;
}

class InternalServerErrorException extends ApiException {
  const InternalServerErrorException({
    required super.errorMessage,
    super.apiErrorMessage,
    super.shouldShowApiError,
    super.title,
    super.statusCode,
  }) : super(isRetryable: true);

  @override
  String get message => shouldShowApiError ? (apiErrorMessage ?? errorMessage) : errorMessage;
}

class ServiceUnavailableException extends ApiException {
  const ServiceUnavailableException({
    required super.errorMessage,
    super.apiErrorMessage,
    super.shouldShowApiError,
    super.title,
    super.statusCode,
  }) : super(isRetryable: true);

  @override
  String get message => shouldShowApiError ? (apiErrorMessage ?? errorMessage) : errorMessage;
}

class EmptyResponseException extends ApiException {
  const EmptyResponseException({
    required super.errorMessage,
    super.apiErrorMessage,
    super.shouldShowApiError,
  });

  @override
  String get message => shouldShowApiError ? (apiErrorMessage ?? errorMessage) : errorMessage;
}

// ─── Non-Api (no server body) ─────────────────────────────────────────────────

class SendTimeoutException extends NetworkException {
  const SendTimeoutException({required super.errorMessage}) : super(isRetryable: true);
}

class RequestCanceledException extends NetworkException {
  const RequestCanceledException({required super.errorMessage});
}

class NoInternetConnectionException extends NetworkException {
  const NoInternetConnectionException({required super.errorMessage}) : super(isRetryable: true);
}

class SecureConnectionException extends NetworkException {
  const SecureConnectionException({required super.errorMessage});
}

/// Named to avoid collision with dart:core FormatException.
class NetworkFormatException extends NetworkException {
  const NetworkFormatException({required super.errorMessage});
}

class UnexpectedErrorException extends NetworkException {
  const UnexpectedErrorException({required super.errorMessage});
}

// ─── Notifier compatibility: title getter ────────────────────────────────────

extension NetworkExceptionDisplay on NetworkException {
  /// For Notifier and UI: use displayTitle and message.
  String get title => displayTitle;
}
