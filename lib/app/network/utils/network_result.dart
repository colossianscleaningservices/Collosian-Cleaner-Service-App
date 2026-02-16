import 'network_exception.dart';

sealed class NetworkResult<T> {
  const NetworkResult();

  const factory NetworkResult.success(T data) = NetworkSuccess<T>;

  const factory NetworkResult.error(NetworkException error) = NetworkError<T>;
}

class NetworkSuccess<T> extends NetworkResult<T> {
  const NetworkSuccess(this.data);
  final T data;
}

class NetworkError<T> extends NetworkResult<T> {
  const NetworkError(this.error);
  final NetworkException error;
}
