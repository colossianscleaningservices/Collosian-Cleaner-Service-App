import 'package:ccs_app/export.dart';

enum AppRole { client, cleaner }

class AuthController extends GetxController {
  final selectedRole = Rxn<AppRole>();

  void selectRole(AppRole role) => selectedRole.value = role;

  // Login
  final loginEmailCtrl = TextEditingController();
  final loginPasswordCtrl = TextEditingController();
  final loginObscure = true.obs;

  // Sign-up (shared)
  final signupFirstNameCtrl = TextEditingController();
  final signupLastNameCtrl = TextEditingController();
  final signupEmailCtrl = TextEditingController();
  final signupPhoneCtrl = TextEditingController();
  final signupPasswordCtrl = TextEditingController();
  final signupObscure = true.obs;

  // Cleaner-only
  final signupNiNumberCtrl = TextEditingController();

  // Forgot/Reset password
  final forgotEmailCtrl = TextEditingController();
  final resetPasswordCtrl = TextEditingController();
  final resetConfirmPasswordCtrl = TextEditingController();
  final resetObscure = true.obs;

  // Navigation helpers (single auth module)
  void goToLogin() => Get.offAllNamed(Routes.LOGIN);

  void backToLogin() => Get.until((route) => Get.currentRoute == Routes.LOGIN);

  void goToRoleSelection() => Get.toNamed(Routes.ROLE_SELECTION);

  void goToSignup() => Get.toNamed(Routes.SIGN_UP);

  void goToForgotPassword() => Get.toNamed(Routes.FORGOT_PASSWORD);

  void goToResetPassword() => Get.toNamed(Routes.RESET_PASSWORD);

  // Stubs for now (API wiring comes next)
  Future<void> login() async {
    // TODO: call login API, read role from response, route to correct dashboard.
  }

  Future<void> signup() async {
    // TODO: call signup API based on selectedRole.
    if (selectedRole.value == AppRole.client) {
      Get.offAllNamed(Routes.CLIENT_DASHBOARD);
    } else {
      Get.offAllNamed(Routes.CLEANER_DASHBOARD);
    }
  }

  Future<void> submitForgotPassword() async {
    // TODO: call forgot password API (send OTP/link).
  }

  Future<void> submitResetPassword() async {
    // TODO: call reset password API.
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
