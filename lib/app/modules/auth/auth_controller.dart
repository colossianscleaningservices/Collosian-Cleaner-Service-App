import 'package:ccs_app/export.dart';
import 'package:ccs_app/app/services/onesignal_service.dart';

enum AppRole { client, cleaner }

class AuthController extends GetxController {
  final selectedRole = Rxn<AppRole>();

  void selectRole(AppRole role) => selectedRole.value = role;

  // Login
  final loginFormKey = GlobalKey<FormState>();
  final loginEmailCtrl = TextEditingController();
  final loginPasswordCtrl = TextEditingController();
  final loginObscure = true.obs;
  final isLoggingIn = false.obs;

  // Sign-up (shared)
  final signupFormKey = GlobalKey<FormState>();
  final signupFirstNameCtrl = TextEditingController();
  final signupLastNameCtrl = TextEditingController();
  final signupEmailCtrl = TextEditingController();
  final signupPhoneCtrl = TextEditingController();
  final signupPasswordCtrl = TextEditingController();
  final signupObscure = true.obs;
  final isSigningUp = false.obs;

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

  void goToRoleSelection(BuildContext context) {
    // Get.toNamed(Routes.ROLE_SELECTION);

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

  // Stubs for now (API wiring comes next)
  Future<void> login() async {
    if (isLoggingIn.value) return;
    isLoggingIn.value = true;
    try {
      // TODO: call login API, read role from response, route to correct dashboard.
      await Future<void>.delayed(const Duration(milliseconds: 800));
      // When API returns user id: setPushUserId(response.userId.toString());
    } finally {
      isLoggingIn.value = false;
    }
  }

  /// Call after successful login when backend provides user id (for push targeting).
  void setPushUserId(String? userId) {
    if (userId != null && userId.isNotEmpty) {
      OneSignalService.login(userId);
    }
  }

  Future<void> signup() async {
    if (isSigningUp.value) return;
    isSigningUp.value = true;
    try {
      // TODO: call signup API based on selectedRole; then OneSignalService.login(userId.toString());
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (selectedRole.value == AppRole.client) {
        Get.offAllNamed(Routes.CLIENT_DASHBOARD);
      } else {
        Get.offAllNamed(Routes.CLEANER_DASHBOARD);
      }
    } finally {
      isSigningUp.value = false;
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
