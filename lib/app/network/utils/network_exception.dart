import 'dart:io';

import 'package:dio/dio.dart';

/// Unified network exception + mapping (merges the previous ErrorMapper idea).
sealed class NetworkException implements Exception {
  const NetworkException({
    required this.title,
    required this.message,
    this.statusCode,
    this.isRetryable = false,
    this.requiresLogout = false,
  });

  final String title;
  final String message;
  final int? statusCode;
  final bool isRetryable;

  /// True when the user should be logged out (401/expired/invalid token).
  final bool requiresLogout;

  static NetworkException fromDio(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      // 401 / unauthenticated: UnauthorizedRequestException.requiresLogout = true
      // so Notifier.apiError() will call SessionService.logout().
      if (statusCode == 401 || _looksUnauthenticated(data, error.message)) {
        return UnauthorizedRequestException(
          statusCode: statusCode,
          title: 'Session expired',
          message: 'Please login again.',
        );
      }

      // Timeouts / connectivity
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return TimeoutException(
          title: 'Connection timeout',
          message: 'Please check your internet connection and try again.',
          statusCode: statusCode,
        );
      }

      if (error.type == DioExceptionType.connectionError ||
          (error.type == DioExceptionType.unknown &&
              error.error is SocketException)) {
        return NoInternetException(
          title: 'No connection',
          message: 'Please check your internet connection and try again.',
        );
      }

      // HTTP error response
      if (error.type == DioExceptionType.badResponse && statusCode != null) {
        return ApiException(
          title: 'Error',
          message: _extractMessage(data) ?? 'Something went wrong. Please try again.',
          statusCode: statusCode,
          isRetryable: statusCode >= 500,
        );
      }

      return UnexpectedNetworkException(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
        statusCode: statusCode,
      );
    }

    if (error is SocketException) {
      return NoInternetException(
        title: 'No connection',
        message: 'Please check your internet connection and try again.',
      );
    }

    return UnexpectedNetworkException(
      title: 'Error',
      message: 'Something went wrong. Please try again.',
    );
  }

  static bool _looksUnauthenticated(Object? data, String? message) {
    final msg = (message ?? '').toLowerCase();
    if (msg.contains('unauthenticated') || msg.contains('invalid token')) {
      return true;
    }
    if (data is Map) {
      final type = (data['type'] ?? data['error'] ?? '').toString().toLowerCase();
      if (type.contains('invalid_token') || type.contains('expired_token')) return true;
      final m = (data['message'] ?? '').toString().toLowerCase();
      if (m.contains('unauthenticated')) return true;
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

class ApiException extends NetworkException {
  const ApiException({
    required super.title,
    required super.message,
    super.statusCode,
    super.isRetryable = false,
  });
}

class UnauthorizedRequestException extends NetworkException {
  const UnauthorizedRequestException({
    required super.title,
    required super.message,
    super.statusCode,
  }) : super(requiresLogout: true);
}

class NoInternetException extends NetworkException {
  const NoInternetException({
    required super.title,
    required super.message,
  }) : super(isRetryable: true);
}

class TimeoutException extends NetworkException {
  const TimeoutException({
    required super.title,
    required super.message,
    super.statusCode,
  }) : super(isRetryable: true);
}

class UnexpectedNetworkException extends NetworkException {
  const UnexpectedNetworkException({
    required super.title,
    required super.message,
    super.statusCode,
  });
}

