import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../network/utils/api_handler.dart';
import '../../network/utils/network_result.dart';

class BaseRepository {
  final Dio _dio = Get.find<Dio>(tag: 'dio_client');
  final ApiHandler _apiHandler = Get.find<ApiHandler>(tag: 'handler');

  Dio get dio => _dio;
  ApiHandler get apiHandler => _apiHandler;

  Future<NetworkResult<T>> get<T>({
    required String endpoint,
    required T Function(dynamic) fromJson,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return _apiHandler.handleNetworkResult<T>(
        response: response,
        fromJson: fromJson,
      );
    } catch (e) {
      return _apiHandler.handleDioException<T>(error: e);
    }
  }

  Future<NetworkResult<T>> post<T>({
    required String endpoint,
    required T Function(dynamic) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _apiHandler.handleNetworkResult<T>(
        response: response,
        fromJson: fromJson,
      );
    } catch (e) {
      return _apiHandler.handleDioException<T>(error: e);
    }
  }

  Future<NetworkResult<T>> put<T>({
    required String endpoint,
    required T Function(dynamic) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _apiHandler.handleNetworkResult<T>(
        response: response,
        fromJson: fromJson,
      );
    } catch (e) {
      return _apiHandler.handleDioException<T>(error: e);
    }
  }

  Future<NetworkResult<T>> patch<T>({
    required String endpoint,
    required T Function(dynamic) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _apiHandler.handleNetworkResult<T>(
        response: response,
        fromJson: fromJson,
      );
    } catch (e) {
      return _apiHandler.handleDioException<T>(error: e);
    }
  }

  Future<NetworkResult<T>> delete<T>({
    required String endpoint,
    required T Function(dynamic) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _apiHandler.handleNetworkResult<T>(
        response: response,
        fromJson: fromJson,
      );
    } catch (e) {
      return _apiHandler.handleDioException<T>(error: e);
    }
  }
}

