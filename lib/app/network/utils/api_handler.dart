import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/utils.dart';

import '../../model/api_error.dart';
import '../../services/crashlytics_service.dart';
import '../../utils/alerts.dart';
import '../../utils/extension.dart';
import 'exception_message.dart';
import 'network_exception.dart';
import 'network_result.dart';

typedef JsonMapper<T> = T Function(dynamic json);
typedef ErrorMapper = DefaultApiError? Function(dynamic json);

class ApiHandler {
  ApiHandler({
    this.errorMapper = ApiHandler.getErrorMessageFromResponse,
    this.shouldShowApiErrors = true,
    this.exceptionMessages = const ExceptionMessage(),
  });

  final ErrorMapper errorMapper;
  final bool shouldShowApiErrors;
  final ExceptionMessage exceptionMessages;

  Future<NetworkResult<T>> handleNetworkResult<T>({
    required Response<dynamic> response,
    required JsonMapper<T> fromJson,
    bool shouldHandleUnauthorizedRequest = true,
  }) async {
    try {
      const correctCodes = [200, 201];
      final statusCode = response.statusCode ?? -1;

      if (statusCode == HttpStatus.badRequest || !correctCodes.contains(statusCode)) {
        return NetworkResult.error(
          _handleResponse(
            response: response,
            shouldHandleUnauthorizedRequest: shouldHandleUnauthorizedRequest,
          ),
        );
      }

      if (isResponseBlank(response.data)) {
        return NetworkResult.error(
          UnexpectedErrorException(
            errorMessage: exceptionMessages.unexpectedError,
          ),
        );
      }

      final data = response.data;
      if (data == null) {
        return NetworkResult.error(
          EmptyResponseException(
            errorMessage: exceptionMessages.emptyResponse,
            shouldShowApiError: shouldShowApiErrors,
          ),
        );
      }

      try {
        return NetworkResult.success(fromJson(data));
      } catch (e) {
        e.printError();
        return NetworkResult.error(
          UnableToProcessException(
            errorMessage: exceptionMessages.unableToProcess,
            shouldShowApiError: shouldShowApiErrors,
          ),
        );
      }
    } catch (e) {
      return NetworkResult.error(
        UnexpectedErrorException(
          errorMessage: exceptionMessages.unexpectedError,
        ),
      );
    }
  }

  NetworkResult<T> handleDioException<T>({
    dynamic error,
    bool shouldHandleUnauthorizedRequest = true,
  }) =>
      NetworkResult.error(
        _getDioException(
          error: error,
          shouldHandleUnauthorizedRequest: shouldHandleUnauthorizedRequest,
        ),
      );

  NetworkException _handleResponse<T>({
    Response<T>? response,
    bool shouldHandleUnauthorizedRequest = true,
  }) {
    final dynamic errorJson = response?.data;
    String? errMsg;
    DefaultApiError? error;

    try {
      error = errorMapper(errorJson);
      errMsg = error?.message;
    } catch (e) {
      if (kDebugMode) {
        log('API_HANDLER', 'Failed to map error response: $e');
      }
    }

    final statusCode = response?.statusCode ?? -1;
    switch (statusCode) {
      case 400:
        return DefaultApiException(
          apiErrorMessage: errMsg,
          errBody: error,
          errorMessage: exceptionMessages.defaultError,
          shouldShowApiError: shouldShowApiErrors,
        );
      case 401:
      case 403:
        return UnauthorizedRequestException(
          apiErrorMessage: errMsg,
          errBody: error,
          errorMessage: exceptionMessages.unauthorizedRequest,
          shouldShowApiError: shouldShowApiErrors,
          title: 'Session expired',
        );
      case 404:
        return NotFoundException(
          apiErrorMessage: errMsg,
          errBody: error,
          errorMessage: exceptionMessages.notFound,
          shouldShowApiError: shouldShowApiErrors,
        );
      case 408:
        return RequestTimeoutException(
          apiErrorMessage: errMsg,
          errorMessage: exceptionMessages.requestTimeout,
          shouldShowApiError: shouldShowApiErrors,
        );
      case 409:
        return ConflictException(
          apiErrorMessage: errMsg,
          errorMessage: exceptionMessages.conflict,
          shouldShowApiError: shouldShowApiErrors,
        );
      case 422:
        return UnableToProcessException(
          apiErrorMessage: errMsg,
          errBody: error,
          errorMessage: exceptionMessages.unableToProcess,
          shouldShowApiError: shouldShowApiErrors,
        );
      case 500:
        _trackServerError(statusCode, errMsg, response);
        return InternalServerErrorException(
          apiErrorMessage: errMsg,
          errorMessage: exceptionMessages.internalServerError,
          shouldShowApiError: shouldShowApiErrors,
        );
      case 503:
        _trackServerError(statusCode, errMsg, response);
        return ServiceUnavailableException(
          apiErrorMessage: errMsg,
          errorMessage: exceptionMessages.serviceUnavailable,
          shouldShowApiError: shouldShowApiErrors,
        );
      default:
        return DefaultApiException(
          apiErrorMessage: errMsg,
          errorMessage: exceptionMessages.defaultError,
          shouldShowApiError: shouldShowApiErrors,
        );
    }
  }

  NetworkException _getDioException({
    dynamic error,
    bool shouldHandleUnauthorizedRequest = true,
  }) {
    if (error is Exception) {
      try {
        if (error is DioException) {
          final networkException = switch (error.type) {
            DioExceptionType.cancel => RequestCanceledException(
                errorMessage: exceptionMessages.requestCancelled,
              ),
            DioExceptionType.connectionTimeout => RequestTimeoutException(
                errorMessage: exceptionMessages.requestTimeout,
                shouldShowApiError: shouldShowApiErrors,
              ),
            DioExceptionType.unknown => error.error is HandshakeException
                ? SecureConnectionException(
                    errorMessage: exceptionMessages.secureConnectionFailed,
                  )
                : error.error is SocketException
                    ? NoInternetConnectionException(
                        errorMessage: exceptionMessages.noInternetConnection,
                      )
                    : UnexpectedErrorException(
                        errorMessage: exceptionMessages.unexpectedError,
                      ),
            DioExceptionType.receiveTimeout => SendTimeoutException(
                errorMessage: exceptionMessages.sendTimeout,
              ),
            DioExceptionType.badResponse => _handleResponse(
                response: error.response,
                shouldHandleUnauthorizedRequest: shouldHandleUnauthorizedRequest,
              ),
            DioExceptionType.sendTimeout => SendTimeoutException(
                errorMessage: exceptionMessages.sendTimeout,
              ),
            DioExceptionType.badCertificate => SecureConnectionException(
                errorMessage: exceptionMessages.secureConnectionFailed,
              ),
            DioExceptionType.connectionError => error.error is HandshakeException
                ? SecureConnectionException(
                    errorMessage: exceptionMessages.secureConnectionFailed,
                  )
                : NoInternetConnectionException(
                    errorMessage: exceptionMessages.noInternetConnection,
                  ),

          };
          return networkException;
        }
        if (error is SocketException) {
          return NoInternetConnectionException(
            errorMessage: exceptionMessages.noInternetConnection,
          );
        }
        return UnexpectedErrorException(
          errorMessage: exceptionMessages.unexpectedError,
        );
      } on FormatException catch (_) {
        return NetworkFormatException(errorMessage: exceptionMessages.formatException);
      } catch (_) {
        return UnexpectedErrorException(
          errorMessage: exceptionMessages.unexpectedError,
        );
      }
    }

    if (error.toString().contains('is not a subtype of')) {
      return UnableToProcessException(
        errorMessage: exceptionMessages.unableToProcess,
        shouldShowApiError: false,
      );
    }
    return UnexpectedErrorException(
      errorMessage: exceptionMessages.unexpectedError,
    );
  }

  void _trackServerError(
    int statusCode,
    String? errorMessage,
    Response? response,
  ) {
    if (!CrashlyticsService.isServerError(statusCode)) return;
    try {
      CrashlyticsService.instance.recordNonFatalError(
        Exception(
          'Server Error $statusCode: ${errorMessage ?? "Unknown error"}',
        ),
        StackTrace.current,
        reason: 'Critical server error encountered',
        additionalInfo: {
          'status_code': statusCode,
          'endpoint': response?.requestOptions.path ?? 'unknown',
          'method': response?.requestOptions.method ?? 'unknown',
          'error_message': errorMessage ?? 'No message',
        },
      );
    } catch (e) {
      if (kDebugMode) {
        log('API_HANDLER', 'Failed to track server error: $e');
      }
    }
  }

  static DefaultApiError? getErrorMessageFromResponse(dynamic json) => json != null ? DefaultApiError.fromJson(json) : null;
}
