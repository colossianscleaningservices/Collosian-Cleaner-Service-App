import 'package:ccs_app/app/network/response/login_signup_response.dart';

import '../../core/base/base_repository.dart';
import '../response/base_response.dart';
import '../utils/network_result.dart';
import 'endpoint.dart';

class AuthRepository extends BaseRepository {
  /// Login (email + password). Returns token and user per OpenAPI.
  Future<NetworkResult<LoginSignupResponse>> login({
    required String email,
    required String password,
  }) async {
    final payload = <String, String>{'email': email.trim(), 'password': password.trim()};
    return post<LoginSignupResponse>(
      endpoint: Endpoint.authLogin,
      fromJson: (json) => LoginSignupResponse.fromJson(json),
      data: payload,
    );
  }

  /// Register (OpenAPI: first_name, last_name, email, password, password_confirmation, role).
  /// [role] must be 'client' or 'staff'.
  Future<NetworkResult<LoginSignupResponse>> userRegister({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? phoneNumber,
  }) async {
    final payload = <String, dynamic>{
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email': email.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': role,
    };
    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      payload['phone_number'] = phoneNumber.trim();
    }
    return post<LoginSignupResponse>(
      endpoint: Endpoint.authRegister,
      fromJson: (json) => LoginSignupResponse.fromJson(json),
      data: payload,
    );
  }

  /// Logout (requires Bearer token).
  Future<NetworkResult<BaseResponse>> logout() async {
    return post<BaseResponse>(
      endpoint: Endpoint.authLogout,
      fromJson: (json) => BaseResponse.fromJson(json),
    );
  }

  /// Get current authenticated user (requires Bearer token).
  Future<NetworkResult<BaseResponse>> getCurrentUser() async {
    return get<BaseResponse>(
      endpoint: Endpoint.authUser,
      fromJson: (json) => BaseResponse.fromJson(json),
    );
  }

  /// Forgot password: request reset link (sends email).
  Future<NetworkResult<BaseResponse>> forgotPassword({required String email}) async {
    return post<BaseResponse>(
      endpoint: Endpoint.authForgotPassword,
      fromJson: (json) => BaseResponse.fromJson(json),
      data: <String, dynamic>{'email': email.trim()},
    );
  }

  /// Reset password with token from email (token, email, password, password_confirmation).
  Future<NetworkResult<BaseResponse>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return post<BaseResponse>(
      endpoint: Endpoint.authResetPassword,
      fromJson: (json) => BaseResponse.fromJson(json),
      data: <String, dynamic>{
        'token': token.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  /// Change password (authenticated; current_password + new password).
  Future<NetworkResult<BaseResponse>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    return post<BaseResponse>(
      endpoint: Endpoint.authChangePassword,
      fromJson: (json) => BaseResponse.fromJson(json),
      data: <String, dynamic>{
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  // ─── Cleaner assessment (staff only; used e.g. during onboarding) ────────

  /// GET assessment categories.
  Future<NetworkResult<DataResponse>> getAssessmentCategories() async {
    return get<DataResponse>(
      endpoint: Endpoint.cleanerAssessmentCategories,
      fromJson: (json) => DataResponse.fromJson(json),
    );
  }

  /// GET assessment forms, optionally by [categoryId].
  Future<NetworkResult<DataResponse>> getAssessmentForms({int? categoryId}) async {
    return get<DataResponse>(
      endpoint: Endpoint.cleanerAssessmentForms,
      fromJson: (json) => DataResponse.fromJson(json),
      queryParameters: categoryId != null ? {'category_id': categoryId} : null,
    );
  }

  /// POST save assessment form responses (form_id + list of question_id + answer).
  Future<NetworkResult<BaseResponse>> saveAssessmentForms({
    required int formId,
    required List<Map<String, dynamic>> responses,
  }) async {
    return post<BaseResponse>(
      endpoint: Endpoint.cleanerAssessmentForms,
      fromJson: (json) => BaseResponse.fromJson(json),
      data: <String, dynamic>{
        'form_id': formId,
        'responses': responses,
      },
    );
  }

  /// POST save government verification code.
  Future<NetworkResult<BaseResponse>> saveGovCode({required String verificationCode}) async {
    return post<BaseResponse>(
      endpoint: Endpoint.cleanerAssessmentGovCode,
      fromJson: (json) => BaseResponse.fromJson(json),
      data: <String, dynamic>{'verification_code': verificationCode},
    );
  }

  // ─── Device registration (call on dashboard open so latest data is saved) ───

  /// POST save device details (platform, app_version, optional: debug, ip, timezone, onesignal_player_id).
  Future<NetworkResult<BaseResponse>> saveDeviceDetails({
    required String platform,
    required String appVersion,
    bool? debug,
    String? ip,
    String? timezone,
    String? onesignalPlayerId,
  }) async {
    final payload = <String, dynamic>{
      'platform': platform,
      'app_version': appVersion,
    };
    if (debug != null) payload['debug'] = debug;
    if (ip != null && ip.isNotEmpty) payload['ip'] = ip;
    if (timezone != null && timezone.isNotEmpty) payload['timezone'] = timezone;
    if (onesignalPlayerId != null && onesignalPlayerId.isNotEmpty) {
      payload['onesignal_player_id'] = onesignalPlayerId;
    }
    return post<BaseResponse>(
      endpoint: Endpoint.device,
      fromJson: (json) => BaseResponse.fromJson(json),
      data: payload,
    );
  }
}
