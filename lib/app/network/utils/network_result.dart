import 'network_exception.dart';

sealed class NetworkResult<T> {
  const NetworkResult();

  const factory NetworkResult.success(T data) = NetworkSuccess<T>;

  const factory NetworkResult.error(NetworkException error) = NetworkError<T>;

  void when({
    required void Function(T data) success,
    required void Function(NetworkException error) error,
  }) {
    switch (this) {
      case NetworkSuccess<T>(:final data):
        success(data);
      case NetworkError<T>(error: final e):
        error(e);
    }
  }
}

class NetworkSuccess<T> extends NetworkResult<T> {
  const NetworkSuccess(this.data);
  final T data;
}

class NetworkError<T> extends NetworkResult<T> {
  const NetworkError(this.error);
  final NetworkException error;
}

