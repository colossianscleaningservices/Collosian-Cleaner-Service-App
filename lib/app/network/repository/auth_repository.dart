import '../../core/base/base_repository.dart';
import '../response/base_response.dart';
import '../response/login_response.dart';
import '../utils/network_result.dart';
import 'endpoint.dart';

class AuthRepository extends BaseRepository {
  /// Login API call (email + password).
  Future<NetworkResult<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    final payload = <String, dynamic>{
      'email': email.trim(),
      'password': password,
    };
    return post<LoginResponse>(
      endpoint: Endpoint.login,
      fromJson: (json) => LoginResponse.fromJson(json),
      data: payload,
    );
  }

  /// User registration API call (name, email, password, role_id).
  Future<NetworkResult<LoginResponse>> userRegister({
    required String name,
    required String email,
    required String password,
    required int roleId,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'role_id': roleId,
    };
    return post<LoginResponse>(
      endpoint: Endpoint.userRegister,
      fromJson: (json) => LoginResponse.fromJson(json),
      data: payload,
    );
  }

  /// Logout API call.
  Future<NetworkResult<BaseResponse>> logout() async {
    return post<BaseResponse>(
      endpoint: Endpoint.logout,
      fromJson: (json) => BaseResponse.fromJson(json),
    );
  }

  /// Forgot password: request reset link/OTP via API.
  Future<NetworkResult<BaseResponse>> forgotPassword({required String email}) async {
    return post<BaseResponse>(
      endpoint: Endpoint.forgotPassword,
      fromJson: (json) => BaseResponse.fromJson(json),
      data: <String, dynamic>{'email': email.trim()},
    );
  }

  /// Reset password with token from email link (POST token + new_password).
  Future<NetworkResult<BaseResponse>> resetPassword({
    required String token,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    return post<BaseResponse>(
      endpoint: Endpoint.resetPassword,
      fromJson: (json) => BaseResponse.fromJson(json),
      data: <String, dynamic>{
        'token': token.trim(),
        'password': newPassword,
        'password_confirmation': passwordConfirmation,
      },
    );
  }
}
