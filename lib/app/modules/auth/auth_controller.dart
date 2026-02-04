import 'package:ccs_app/app/network/repository/auth_repository.dart';
import 'package:ccs_app/app/network/response/login_response.dart';
import 'package:ccs_app/app/network/utils/network_exception.dart';
import 'package:ccs_app/app/network/utils/network_result.dart';
import 'package:ccs_app/app/services/onesignal_service.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/export.dart';

enum AppRole { client, cleaner }

/// Backend role_id for client (adjust if your API uses different values).
const int _roleIdClient = 1;

class AuthController extends GetxController {
  final selectedRole = Rxn<AppRole>();

  final AuthRepository _authRepository = AuthRepository();

  void selectRole(AppRole role) => selectedRole.value = role;

  // Login
  final loginFormKey = GlobalKey<FormState>();
  final loginEmailCtrl = TextEditingController();
  final loginPasswordCtrl = TextEditingController();
  final loginObscure = true.obs;
  final isLoggingIn = false.obs;
  final loginErrorMsg = Rxn<String>();

  // Sign-up (shared)
  final signupFormKey = GlobalKey<FormState>();
  final signupFirstNameCtrl = TextEditingController();
  final signupLastNameCtrl = TextEditingController();
  final signupEmailCtrl = TextEditingController();
  final signupPhoneCtrl = TextEditingController();
  final signupPasswordCtrl = TextEditingController();
  final signupObscure = true.obs;
  final isSigningUp = false.obs;
  final signupErrorMsg = Rxn<String>();

  // Cleaner-only
  final signupNiNumberCtrl = TextEditingController();

  // Forgot/Reset password
  final forgotEmailCtrl = TextEditingController();
  final resetPasswordCtrl = TextEditingController();
  final resetConfirmPasswordCtrl = TextEditingController();
  final resetObscure = true.obs;
  final resetFormKey = GlobalKey<FormState>();
  final isResettingPassword = false.obs;
  final resetErrorMsg = Rxn<String>();

  /// Token for reset password (from deep link / route params: e.g. Get.parameters['token']).
  String get resetToken => Get.parameters['token'] ?? '';

  // Navigation helpers (single auth module)
  void goToLogin() => Get.offAllNamed(Routes.LOGIN);

  void backToLogin() => Get.until((route) => Get.currentRoute == Routes.LOGIN);

  void goToRoleSelection(BuildContext context) {
    Notifier.openSheet(
      context,
      showPrimaryButton: true,
      showSecondaryButton: true,
      title: "Continue as ",
      message: "Choose how you want to use Colossians Cleaning Services",
      icon: IconsaxPlusLinear.profile_2user,
      primaryButtonLabel: "I am a Client",
      secondaryButtonLabel: "I am a Cleaner",
      onPrimaryPressed: () {
        selectRole(AppRole.client);
        Get.toNamed(Routes.CLIENT_DASHBOARD);
      },
      onSecondaryPressed: () {
        selectRole(AppRole.cleaner);
        Get.toNamed(Routes.CLEANER_DASHBOARD);
      },
    );
  }

  void goToSignup() => Get.toNamed(Routes.SIGN_UP);

  void goToForgotPassword() => Get.toNamed(Routes.FORGOT_PASSWORD);

  void goToResetPassword() => Get.toNamed(Routes.RESET_PASSWORD);

  Future<void> login() async {
    if (isLoggingIn.value) return;
    if (!(loginFormKey.currentState?.validate() ?? false)) return;
    loginErrorMsg.value = null;
    isLoggingIn.value = true;
    try {
      final result = await _authRepository.login(
        email: loginEmailCtrl.text,
        password: loginPasswordCtrl.text,
      );

      switch (result) {
        case NetworkSuccess(data: final response):
          final data = response.data;
          if (data == null) throw Exception(response.message ?? 'Login failed');
          await _saveUserData(data);
          setPushUserId(data.id?.toString());
          _routeByRoleId(data.roleId);
        case NetworkError(error: final e):
          loginErrorMsg.value = e.message;
          await Notifier.apiError(e, contextTag: 'login');
      }
    } catch (e) {
      loginErrorMsg.value = _errorMessage(e);
      await Notifier.apiError(e, contextTag: 'login');
    } finally {
      isLoggingIn.value = false;
    }
  }

  void setPushUserId(String? userId) {
    if (userId != null && userId.isNotEmpty) {
      OneSignalService.login(userId);
    }
  }

  Future<void> signup() async {
    if (isSigningUp.value) return;
    if (!(signupFormKey.currentState?.validate() ?? false)) return;
    final role = selectedRole.value;
    if (role == null) {
      Notifier.error('Please choose Client or Cleaner.');
      return;
    }
    signupErrorMsg.value = null;
    isSigningUp.value = true;
    try {
      final name =
          '${signupFirstNameCtrl.text.trim()} ${signupLastNameCtrl.text.trim()}'.trim();
      final roleId = role == AppRole.client ? _roleIdClient : 2;

      final result = await _authRepository.userRegister(
        name: name.isNotEmpty ? name : signupEmailCtrl.text,
        email: signupEmailCtrl.text,
        password: signupPasswordCtrl.text,
        roleId: roleId,
      );

      switch (result) {
        case NetworkSuccess(data: final response):
          final data = response.data;
          if (data == null) throw Exception(response.message ?? 'Registration failed');
          await _saveUserData(data);
          setPushUserId(data.id?.toString());
          if (role == AppRole.client) {
            Get.offAllNamed(Routes.CLIENT_DASHBOARD);
          } else {
            Get.offAllNamed(Routes.CLEANER_DASHBOARD);
          }
        case NetworkError(error: final e):
          signupErrorMsg.value = e.message;
          await Notifier.apiError(e, contextTag: 'signup');
      }
    } catch (e) {
      signupErrorMsg.value = _errorMessage(e);
      await Notifier.apiError(e, contextTag: 'signup');
    } finally {
      isSigningUp.value = false;
    }
  }

  Future<void> submitForgotPassword() async {
    if (!(forgotEmailCtrl.text.trim().isNotEmpty)) {
      Notifier.error('Please enter your email.');
      return;
    }
    try {
      final result = await _authRepository.forgotPassword(
        email: forgotEmailCtrl.text,
      );
      switch (result) {
        case NetworkSuccess():
          Notifier.success(
            'If an account exists for this email, you will receive a password reset link.',
            title: 'Check your email',
          );
          Get.offAllNamed(Routes.LOGIN);
        case NetworkError(error: final e):
          await Notifier.apiError(e, contextTag: 'forgot_password');
      }
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'forgot_password');
    }
  }

  Future<void> submitResetPassword() async {
    if (isResettingPassword.value) return;
    if (!(resetFormKey.currentState?.validate() ?? false)) return;
    final password = resetPasswordCtrl.text;
    final confirm = resetConfirmPasswordCtrl.text;
    if (password != confirm) {
      resetErrorMsg.value = 'Passwords do not match.';
      return;
    }
    if (resetToken.isEmpty) {
      resetErrorMsg.value = 'Invalid or expired reset link. Please request a new one.';
      return;
    }
    resetErrorMsg.value = null;
    isResettingPassword.value = true;
    try {
      final result = await _authRepository.resetPassword(
        token: resetToken,
        newPassword: password,
        passwordConfirmation: confirm,
      );
      switch (result) {
        case NetworkSuccess():
          Notifier.success('Your password has been reset. You can sign in now.', title: 'Password reset');
          Get.offAllNamed(Routes.LOGIN);
        case NetworkError(error: final e):
          resetErrorMsg.value = e.message;
          await Notifier.apiError(e, contextTag: 'reset_password');
      }
    } catch (e) {
      resetErrorMsg.value = _errorMessage(e);
      await Notifier.apiError(e, contextTag: 'reset_password');
    } finally {
      isResettingPassword.value = false;
    }
  }

  static String _errorMessage(dynamic e) {
    if (e is NetworkException) return e.message;
    return e.toString();
  }

  Future<void> _saveUserData(Data data) async {
    final prefs = Prefs();
    await prefs.setToken(data.token ?? '');
    if (data.id != null) prefs.putData(Prefs.id, data.id.toString());
    if (data.email != null && data.email!.isNotEmpty) prefs.putData(Prefs.email, data.email!);
    if (data.firstName != null && data.firstName!.isNotEmpty) {
      prefs.putData(Prefs.firstName, data.firstName!);
    }
    if (data.lastName != null && data.lastName!.isNotEmpty) {
      prefs.putData(Prefs.lastName, data.lastName!);
    }
    if (data.roleId != null) prefs.putData(Prefs.roleId, data.roleId.toString());
  }

  void _routeByRoleId(num? roleId) {
    if (roleId != null && roleId.toInt() == _roleIdClient) {
      Get.offAllNamed(Routes.CLIENT_DASHBOARD);
    } else {
      Get.offAllNamed(Routes.CLEANER_DASHBOARD);
    }
  }

  @override
  void onClose() {
    loginEmailCtrl.dispose();
    loginPasswordCtrl.dispose();

    signupFirstNameCtrl.dispose();
    signupLastNameCtrl.dispose();
    signupEmailCtrl.dispose();
    signupPhoneCtrl.dispose();
    signupPasswordCtrl.dispose();
    signupNiNumberCtrl.dispose();

    forgotEmailCtrl.dispose();
    resetPasswordCtrl.dispose();
    resetConfirmPasswordCtrl.dispose();
    super.onClose();
  }
}
