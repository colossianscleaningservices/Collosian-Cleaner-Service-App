import 'network_exception.dart';

sealed class NetworkResult<T> {
  const NetworkResult();

  const factory NetworkResult.success(T data) = NetworkSuccess;

  const factory NetworkResult.error(NetworkException error) = NetworkError;

  void when({required Function(T success) success, required Function(NetworkException error) error}) {
    switch (this) {
      case NetworkSuccess<T> _:
        success((this as NetworkSuccess<T>).data);
      case NetworkError<T> _:
        error((this as NetworkError<T>).error);
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
