import 'package:ccs_app/app/model/Section_model.dart';
import 'package:ccs_app/app/network/repository/auth_repository.dart';
import 'package:ccs_app/app/network/response/base_response.dart';
import 'package:ccs_app/app/network/response/login_response.dart';
import 'package:ccs_app/app/network/utils/network_result.dart';
import 'package:ccs_app/app/services/onesignal_service.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/export.dart';
import 'package:step_progress/step_progress.dart';

class AuthController extends GetxController {
  final selectedRole = Rxn<UserRole>();

  final AuthRepository _authRepository = AuthRepository();

  void selectRole(UserRole role) => selectedRole.value = role;

  // Cleaner assessment APIs (in AuthRepository; used e.g. during onboarding / post-signup)
  Future<NetworkResult<DataResponse>> getAssessmentCategories() =>
      _authRepository.getAssessmentCategories();
  Future<NetworkResult<DataResponse>> getAssessmentForms({int? categoryId}) =>
      _authRepository.getAssessmentForms(categoryId: categoryId);
  Future<NetworkResult<BaseResponse>> saveAssessmentForms({
    required int formId,
    required List<Map<String, dynamic>> responses,
  }) =>
      _authRepository.saveAssessmentForms(formId: formId, responses: responses);
  Future<NetworkResult<BaseResponse>> saveGovCode({required String verificationCode}) =>
      _authRepository.saveGovCode(verificationCode: verificationCode);

  /// Logout: call API then clear local state. (SessionService may use this or call repository directly.)
  Future<NetworkResult<BaseResponse>> logout() => _authRepository.logout();

  /// Get current authenticated user (e.g. for session refresh or profile).
  Future<NetworkResult<LoginResponse>> getCurrentUser() => _authRepository.getCurrentUser();

  /// Change password (authenticated user).
  Future<NetworkResult<BaseResponse>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) =>
      _authRepository.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

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
  /// Email for reset password (from route params or leave empty if reset link doesn't provide it).
  String get resetEmail => Get.parameters['email'] ?? '';

  // Change password (authenticated user; used by ChangePasswordView)
  final changePasswordFormKey = GlobalKey<FormState>();
  final changePasswordCurrentCtrl = TextEditingController();
  final changePasswordNewCtrl = TextEditingController();
  final changePasswordConfirmCtrl = TextEditingController();
  final showChangeCurrentPassword = false.obs;
  final showChangeNewPassword = false.obs;
  final showChangeConfirmPassword = false.obs;
  final isChangingPassword = false.obs;

  String? validateChangeCurrentPassword(String? value) {
    if (value == null || value.isEmpty) return 'Current password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateChangeNewPassword(String? value) {
    if (value == null || value.isEmpty) return 'New password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Include at least one uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Include at least one number';
    if (value == changePasswordCurrentCtrl.text) return 'New password must be different';
    return null;
  }

  String? validateChangeConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != changePasswordNewCtrl.text) return 'Passwords do not match';
    return null;
  }

  Future<void> submitChangePassword() async {
    if (!(changePasswordFormKey.currentState?.validate() ?? false)) return;
    isChangingPassword.value = true;
    try {
      final result = await _authRepository.changePassword(
        currentPassword: changePasswordCurrentCtrl.text,
        password: changePasswordNewCtrl.text,
        passwordConfirmation: changePasswordConfirmCtrl.text,
      );
      switch (result) {
        case NetworkSuccess():
          Notifier.success('Password changed successfully');
          Get.back();
        case NetworkError(error: final e):
          await Notifier.apiError(e, contextTag: 'change_password');
      }
    } catch (e) {
      Notifier.error('Failed to change password');
    } finally {
      isChangingPassword.value = false;
    }
  }

  // Navigation helpers (single auth module)
  void goToLogin() => Get.offAllNamed(Routes.LOGIN);

  void backToLogin() => Get.until((route) => Get.currentRoute == Routes.LOGIN);

  //Agreement
  var stepProgressController = StepProgressController(initialStep: 0, totalSteps: 4);
  var stepCurrentIndex = 0.obs;
  RxList<SectionModel> sectionList = <SectionModel>[].obs;
  ScrollController scrollController = ScrollController();
  ScrollController stepScrollController = ScrollController();

  /// sectionIndex -> (questionIndex -> selected answer)
  final selectedAgreementAnswers = <int, Map<int, String>>{}.obs;

  void setAgreementAnswer(int sectionIndex, int questionIndex, String answer) {
    selectedAgreementAnswers.value[sectionIndex] ??= {};
    selectedAgreementAnswers.value[sectionIndex]![questionIndex] = answer;
    selectedAgreementAnswers.refresh();
  }

  String? getAgreementAnswer(int sectionIndex, int questionIndex) {
    return selectedAgreementAnswers.value[sectionIndex]?[questionIndex];
  }

  bool isAgreementStepComplete(int sectionIndex) {
    if (sectionIndex >= sectionList.length) return true;
    final questions = sectionList[sectionIndex].questions ?? [];
    if (questions.isEmpty) return true;
    final answers = selectedAgreementAnswers.value[sectionIndex];
    if (answers == null) return false;
    for (var i = 0; i < questions.length; i++) {
      if (!answers.containsKey(i) || answers[i]!.isEmpty) return false;
    }
    return true;
  }

  @override
  void onInit() {
    initSectionsList();
    stepProgressController = StepProgressController(initialStep: 0, totalSteps: sectionList.length);
    super.onInit();
  }

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
        selectRole(UserRole.client);
        Get.toNamed(Routes.CLIENT_DASHBOARD);
      },
      onSecondaryPressed: () {
        selectRole(UserRole.cleaner);
        resetAgreement();
        // Get.toNamed(Routes.AGREEMENT);
        Get.toNamed(Routes.CLEANER_DASHBOARD);
      },
    );
  }

  void resetAgreement() {
    selectedAgreementAnswers.value.clear();
    stepCurrentIndex.value = 0;
    stepProgressController.setCurrentStep(stepCurrentIndex.value);
  }

  void initSectionsList() {
    sectionList.clear();
    List<QuestionModel> questions = [];
    questions.add(
      QuestionModel(
        question: 'What should you always do before using a new cleaning chemical?',
        answers: [
          'Mix it with another product to make it stronger',
          'Smell it to check strength',
          'Read the label and safety instructions',
          'Use it only on floors'
        ],
      ),
    );
    questions.add(
      QuestionModel(
        question: 'Which two products must NEVER be mixed together?',
        answers: ['Glass cleaner and water', 'Bleach and ammonia', 'Degreaser and detergent', 'Floor cleaner and disinfectant'],
      ),
    );
    questions.add(
      QuestionModel(
        question: 'If a chemical spills on your skin, what should you do FIRST?',
        answers: ['Make the property look “ok”', 'Clean only visible areas', 'Meet landlord/agent inventory standards', 'Clean only floors and bathrooms'],
      ),
    );
    sectionList.add(SectionModel(title: 'Sec A – Chemicals & Products', questions: questions));
    sectionList.add(SectionModel(title: 'Sec B – End of Tenancy Cleaning', questions: questions));
    sectionList.add(SectionModel(title: 'Sec C – HMO, Office & After-Builders Cleaning', questions: questions));
    sectionList.add(SectionModel(title: 'Sec D – Residential Surface Cleaning', questions: questions));
    sectionList.add(SectionModel(title: 'Sec E – Residential Surface Cleaning', questions: questions));
    sectionList.add(SectionModel(title: 'Sec F – Residential Surface Cleaning', questions: questions));
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
      final firstName = signupFirstNameCtrl.text.trim().isNotEmpty
          ? signupFirstNameCtrl.text.trim()
          : signupEmailCtrl.text.trim();
      final lastName = signupLastNameCtrl.text.trim().isNotEmpty
          ? signupLastNameCtrl.text.trim()
          : signupEmailCtrl.text.trim();
      final password = signupPasswordCtrl.text;
      final roleStr = role == UserRole.client ? 'client' : 'staff';

      final result = await _authRepository.userRegister(
        firstName: firstName,
        lastName: lastName,
        email: signupEmailCtrl.text.trim(),
        password: password,
        passwordConfirmation: password,
        role: roleStr,
        phoneNumber: signupPhoneCtrl.text.trim().isNotEmpty ? signupPhoneCtrl.text.trim() : null,
      );

      switch (result) {
        case NetworkSuccess(data: final response):
          final data = response.data;
          if (data == null) throw Exception(response.message ?? 'Registration failed');
          await _saveUserData(data);
          setPushUserId(data.id?.toString());
          if (role == UserRole.client) {
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
        email: resetEmail.isNotEmpty ? resetEmail : forgotEmailCtrl.text.trim(),
        password: password,
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
    if (RoleConstants.isClient(roleId?.toInt())) {
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

    changePasswordCurrentCtrl.dispose();
    changePasswordNewCtrl.dispose();
    changePasswordConfirmCtrl.dispose();
    super.onClose();
  }
}
