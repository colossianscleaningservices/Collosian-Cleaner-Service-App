import 'package:ccs_app/app/network/repository/auth_repository.dart';
import 'package:ccs_app/app/network/request/save_cleaner_assessment_request.dart';
import 'package:ccs_app/app/network/response/assessment_category_response.dart';
import 'package:ccs_app/app/network/response/assessment_question_response.dart' as aq;
import 'package:ccs_app/app/network/response/base_response.dart';
import 'package:ccs_app/app/network/response/user_response.dart';
import 'package:ccs_app/app/services/onesignal_service.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/export.dart';
import 'package:step_progress/step_progress.dart';

class AuthController extends GetxController {
  // ─── Dependencies & role ─────────────────────────────────────────────────
  final AuthRepository _authRepository = AuthRepository();
  final selectedRole = Rxn<UserRole>();

  // ─── Login ───────────────────────────────────────────────────────────────
  final loginFormKey = GlobalKey<FormState>();
  final loginEmailCtrl = TextEditingController();
  final loginPasswordCtrl = TextEditingController();
  final loginObscure = true.obs;
  final isLoggingIn = false.obs;

  // ─── Sign-up (shared) ────────────────────────────────────────────────────
  final signupFormKey = GlobalKey<FormState>();
  final signupFirstNameCtrl = TextEditingController();
  final signupLastNameCtrl = TextEditingController();
  final signupEmailCtrl = TextEditingController();
  final signupPhoneCtrl = TextEditingController();
  final signupPasswordCtrl = TextEditingController();
  final signupObscure = true.obs;
  final isSigningUp = false.obs;
  final signupNiNumberCtrl = TextEditingController();

  // ─── Forgot / reset password ──────────────────────────────────────────────
  final forgotEmailCtrl = TextEditingController();
  final resetPasswordCtrl = TextEditingController();
  final resetConfirmPasswordCtrl = TextEditingController();
  final resetObscure = true.obs;
  final resetFormKey = GlobalKey<FormState>();
  final isResettingPassword = false.obs;
  final isForgotPassword = false.obs;

  String get resetToken => Get.parameters['token'] ?? '';

  String get resetEmail => Get.parameters['email'] ?? '';

  // ─── Change password (authenticated) ──────────────────────────────────────
  final changePasswordFormKey = GlobalKey<FormState>();
  final changePasswordCurrentCtrl = TextEditingController();
  final changePasswordNewCtrl = TextEditingController();
  final changePasswordConfirmCtrl = TextEditingController();
  final showChangeCurrentPassword = false.obs;
  final showChangeNewPassword = false.obs;
  final showChangeConfirmPassword = false.obs;
  final isChangingPassword = false.obs;

  // ─── Agreement (cleaner assessment steps) – API types only ───────────────
  final isAssessmentLoading = true.obs;
  var isSaveAssessment = false.obs;
  late StepProgressController stepProgressController;
  var stepCurrentIndex = 0.obs;
  RxList<Categories> assessmentCategories = <Categories>[].obs;
  RxList<List<aq.Questions>> assessmentQuestionsByStep = <List<aq.Questions>>[].obs;
  ScrollController scrollController = ScrollController();
  ScrollController stepScrollController = ScrollController();
  final selectedAgreementAnswers = <int, Map<int, String>>{}.obs;

  // ─── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void onInit() {
    stepProgressController = StepProgressController(initialStep: 0, totalSteps: 1);
    loadAssessmentSections();
    super.onInit();
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

  // ─── Role & navigation ───────────────────────────────────────────────────

  void selectRole(UserRole role) => selectedRole.value = role;

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
        Get.toNamed(Routes.SIGN_UP);
      },
      onSecondaryPressed: () {
        selectRole(UserRole.cleaner);
        resetAgreement();
        Get.toNamed(Routes.AGREEMENT);
      },
    );
  }

  // ─── Assessment API (cleaner onboarding) ─────────────────────────────────

  /// Load categories (steps), then for each category fetch questions via getAssessmentForms(categoryId). Uses API types only.
  Future<void> loadAssessmentSections() async {
    isAssessmentLoading.value = true;
    assessmentCategories.clear();
    assessmentQuestionsByStep.clear();
    try {
      final catResult = await _authRepository.getAssessmentCategories();

      catResult.handle(
        success: (value) async {
          final categories = value.data?.categories ?? [];
          if (categories.isEmpty) return;

          final questionsByStep = <List<aq.Questions>>[];

          for (final category in categories) {
            final id = category.id;
            if (id == null) continue;

            final formResult = await _authRepository.getAssessmentForms(categoryId: id.toInt());

            formResult.handle(
              success: (value) async {
                questionsByStep.add(value.data?.questions ?? []);
              },
              contextTag: 'getAssessmentCategories',
              onError: (_) => questionsByStep.add([]),
            );
          }
          assessmentCategories.assignAll(categories);
          assessmentQuestionsByStep.assignAll(questionsByStep);

          stepProgressController = StepProgressController(initialStep: 0, totalSteps: assessmentCategories.length);
          stepCurrentIndex.value = 0;
          stepProgressController.setCurrentStep(0);
        },
        contextTag: 'getAssessmentCategories',
      );
    } finally {
      isAssessmentLoading.value = false;
    }
  }

  Future<NetworkResult<BaseResponse>> saveAssessmentForms({
    required int formId,
    required List<Map<String, dynamic>> responses,
  }) {
    return _authRepository.saveAssessmentForms(formId: formId, responses: responses);
  }

  Future<NetworkResult<BaseResponse>> saveGovCode({required String verificationCode}) => _authRepository.saveGovCode(verificationCode: verificationCode);

  Future<NetworkResult<BaseResponse>> logout() => _authRepository.logout();

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

  // ─── Agreement (assessment steps) ─────────────────────────────────────────

  void setAgreementAnswer(int sectionIndex, int questionIndex, String answer) {
    selectedAgreementAnswers.value[sectionIndex] ??= {};
    selectedAgreementAnswers.value[sectionIndex]![questionIndex] = answer;
    selectedAgreementAnswers.refresh();
  }

  String? getAgreementAnswer(int sectionIndex, int questionIndex) {
    return selectedAgreementAnswers.value[sectionIndex]?[questionIndex];
  }

  bool isAgreementStepComplete(int sectionIndex) {
    if (sectionIndex >= assessmentQuestionsByStep.length) return true;
    final questions = assessmentQuestionsByStep[sectionIndex];
    if (questions.isEmpty) return true;
    final answers = selectedAgreementAnswers.value[sectionIndex];
    if (answers == null) return false;
    for (var i = 0; i < questions.length; i++) {
      if (questions[i].options?.isNotEmpty == true) if (!answers.containsKey(i) || answers[i]!.isEmpty) return false;
    }
    return true;
  }

  void resetAgreement() {
    selectedAgreementAnswers.value.clear();
    stepCurrentIndex.value = 0;
    stepProgressController.setCurrentStep(stepCurrentIndex.value);
  }

  List<num?> answersId = [];

  Future<void> saveCleanerAssessment() async {
    answersId.clear();
    List<Answers> answers = [];
    selectedAgreementAnswers.value.forEach((key, value) {
      if (assessmentQuestionsByStep[key].length == value.length) {
        for (var item in assessmentQuestionsByStep[key]) {
          answers.add(Answers(categoryId: item.categoryId, questionId: item.id, option: value[assessmentQuestionsByStep[key].indexOf(item)]));
        }
      }
    });

    isSaveAssessment.value = true;
    try {
      var request = SaveCleanerAssessmentRequest(answers: answers);
      log(runtimeType.toString(), 'SAVE CLEANER REQUEST ${request.toJson()}');

      final result = await _authRepository.saveCleanerAssessment(request);
      result.handle(
        success: (value) {
          answersId.clear();
          answersId.addAll(value.data?.answerIds as Iterable<num?>);
          if (value.data?.overall?.status == "fail") {
            Notifier.openSheet(
              Get.context as BuildContext,
              title: 'Failed',
              message: 'You have not passed the assessment.',
              showSecondaryButton: false,
              onPrimaryPressed: () {
                resetAgreement();
                stepCurrentIndex.value = 0;
                stepProgressController.setCurrentStep(0);
              },
            );
          } else {
            Notifier.openSheet(
              Get.context as BuildContext,
              title: 'Pass',
              message: 'You have passed the assessment.',
              showSecondaryButton: false,
              primaryButtonLabel: 'Go to Sign Up',
              onPrimaryPressed: () {
                Get.offAndToNamed(Routes.SIGN_UP);
              },
            );
          }
        },
        contextTag: 'save_assessment',
      );
    } catch (e) {
      Notifier.error('Failed to change password');
    } finally {
      isSaveAssessment.value = false;
    }
  }

  // ─── Change password (submit) ────────────────────────────────

  Future<void> submitChangePassword() async {
    if (!(changePasswordFormKey.currentState?.validate() ?? false)) return;
    isChangingPassword.value = true;
    try {
      final result = await _authRepository.changePassword(
        currentPassword: changePasswordCurrentCtrl.text,
        password: changePasswordNewCtrl.text,
        passwordConfirmation: changePasswordConfirmCtrl.text,
      );
      result.handle(
        success: (_) {
          Notifier.success('Password changed successfully');
          Get.back();
        },
        contextTag: 'change_password',
      );
    } catch (e) {
      Notifier.error('Failed to change password');
    } finally {
      isChangingPassword.value = false;
    }
  }

  // ─── Login & Sign-up ───────────────────────────────────────────────────────────────

  Future<void> login() async {
    if (isLoggingIn.value) return;
    if (!(loginFormKey.currentState?.validate() ?? false)) return;
    isLoggingIn.value = true;
    try {
      final result = await _authRepository.login(
        email: loginEmailCtrl.text,
        password: loginPasswordCtrl.text,
      );
      result.handle(
        success: (value) async {
          final data = value.data;
          log('test', ' Response : $data ');

          if (data == null) throw Exception(value.message ?? 'Login failed');

          await _saveUserData(data.user!);

          Notifier.openSheet(
            (Get.context as BuildContext),
            type: SheetType.success,
            title: "Success !",
            message: value.message,
            showSecondaryButton: false,
            isDismissable: false,
            icon: IconsaxPlusLinear.chart_success,
            onPrimaryPressed: () {
              if (RoleConstants.isClient(data.user?.roles?.first.id?.toInt())) {
                Get.offAllNamed(Routes.CLIENT_DASHBOARD);
              } else {
                Get.offAllNamed(Routes.CLEANER_DASHBOARD);
              }
            },
          );
        },
        contextTag: 'login',
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'login');
    } finally {
      isLoggingIn.value = false;
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

    isSigningUp.value = true;

    try {
      final firstName = signupFirstNameCtrl.text.trim().isNotEmpty ? signupFirstNameCtrl.text.trim() : signupEmailCtrl.text.trim();
      final lastName = signupLastNameCtrl.text.trim().isNotEmpty ? signupLastNameCtrl.text.trim() : signupEmailCtrl.text.trim();
      final roleStr = role == UserRole.client ? 'client' : 'staff';
      final result = await _authRepository.userRegister(
        firstName: firstName,
        lastName: lastName,
        email: signupEmailCtrl.text.trim(),
        password: signupPasswordCtrl.text,
        passwordConfirmation: signupPasswordCtrl.text,
        role: roleStr,
        phoneNumber: signupPhoneCtrl.text.trim().isNotEmpty ? signupPhoneCtrl.text.trim() : null,
        verificationCode: role == UserRole.cleaner ? signupNiNumberCtrl.text.trim() : null,
        answersId: role == UserRole.cleaner ? answersId : null,
      );
      result.handle(
        success: (response) async {
          final data = response.data;
          if (data == null) throw Exception(response.message ?? 'Registration failed');
          await _saveUserData(data.user!);
          if (role == UserRole.client) {
            Get.offAllNamed(Routes.CLIENT_DASHBOARD);
          } else {
            Get.offAllNamed(Routes.CLEANER_DASHBOARD);
          }
        },
        contextTag: 'signup',
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'signup');
    } finally {
      isSigningUp.value = false;
    }
  }

  // ─── Forgot / reset password ──────────────────────────────────────────────

  Future<void> submitForgotPassword() async {
    if (isForgotPassword.value) return;
    if (!forgotEmailCtrl.text.trim().isNotEmpty) {
      Notifier.error('Please enter your email.');
      return;
    }
    (Get.context as BuildContext).hideKeyboard();
    isForgotPassword.value = true;
    try {
      final result = await _authRepository.forgotPassword(email: forgotEmailCtrl.text);
      result.handle(
        success: (_) {
          isForgotPassword.value = false;
          Notifier.success(
            'If an account exists for this email, you will receive a password reset link.',
            title: 'Check your email',
          );
          Get.until((route) => Get.currentRoute == Routes.LOGIN);
        },
        contextTag: 'forgot_password',
        onError: (_) => isForgotPassword.value = false,
      );
    } catch (e) {
      isForgotPassword.value = false;
      await Notifier.apiError(e, contextTag: 'forgot_password');
    }
  }

  Future<void> submitResetPassword() async {
    if (isResettingPassword.value) return;
    if (!(resetFormKey.currentState?.validate() ?? false)) return;
    final password = resetPasswordCtrl.text;
    final confirm = resetConfirmPasswordCtrl.text;
    if (password != confirm) {
      Notifier.error('Passwords do not match.');
      return;
    }
    if (resetToken.isEmpty) {
      Notifier.error('Invalid or expired reset link. Please request a new one.');
      return;
    }

    isResettingPassword.value = true;

    try {
      final result = await _authRepository.resetPassword(
        token: resetToken,
        email: resetEmail.isNotEmpty ? resetEmail : forgotEmailCtrl.text.trim(),
        password: password,
        passwordConfirmation: confirm,
      );
      result.handle(
        success: (_) {
          Notifier.success('Your password has been reset. You can sign in now.', title: 'Password reset');
          Get.offAllNamed(Routes.LOGIN);
        },
        contextTag: 'reset_password',
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'reset_password');
    } finally {
      isResettingPassword.value = false;
    }
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  Future<void> _saveUserData(User data) async {
    OneSignalService.login(data.id.toString());

    final prefs = Prefs();
    await prefs.setToken(data.token ?? '');
    if (data.id != null) prefs.putData(Prefs.id, data.id.toString());
    if (data.email != null && data.email!.isNotEmpty) prefs.putData(Prefs.email, data.email!);
    if (data.phoneNumber != null) prefs.putData(Prefs.phoneNumber, data.phoneNumber!);
    if (data.firstName != null && data.firstName!.isNotEmpty) prefs.putData(Prefs.firstName, data.firstName!);
    if (data.lastName != null && data.lastName!.isNotEmpty) prefs.putData(Prefs.lastName, data.lastName!);
    if (data.roles?.first.id != null) prefs.putData(Prefs.roleId, data.roles!.first.id.toString());
  }
}
