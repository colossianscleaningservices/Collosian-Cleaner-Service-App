import 'dart:io';

import 'package:dio/dio.dart';

import 'network_exception.dart';
import 'network_result.dart';

typedef JsonMapper<T> = T Function(dynamic json);

class ApiHandler {
  const ApiHandler();

  Future<NetworkResult<T>> handleNetworkResult<T>({
    required Response<dynamic> response,
    required JsonMapper<T> fromJson,
  }) async {
    final ok = <int>[HttpStatus.ok, HttpStatus.created];
    final statusCode = response.statusCode ?? -1;

    if (!ok.contains(statusCode)) {
      // Convert non-success response into NetworkException
      return NetworkResult.error(
        NetworkException.fromDio(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        ),
      );
    }

    final data = response.data;
    if (data == null) {
      return NetworkResult.error(
        const UnexpectedNetworkException(
          title: 'Empty response',
          message: 'No data returned from server.',
        ),
      );
    }

    try {
      return NetworkResult.success(fromJson(data));
    } catch (_) {
      return NetworkResult.error(
        const UnexpectedNetworkException(
          title: 'Parse error',
          message: 'Unable to process server response.',
        ),
      );
    }
  }

  NetworkResult<T> handleDioException<T>({required dynamic error}) {
    return NetworkResult.error(NetworkException.fromDio(error));
  }
}

