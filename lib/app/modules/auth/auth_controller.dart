import 'package:ccs_app/app/network/repository/auth_repository.dart';
import 'package:ccs_app/app/network/request/save_cleaner_assessment_request.dart';
import 'package:ccs_app/app/network/response/assessment_category_response.dart';
import 'package:ccs_app/app/network/response/assessment_question_response.dart' as aq;
import 'package:ccs_app/app/network/response/base_response.dart';
import 'package:ccs_app/app/network/response/get_agency_response.dart';
import 'package:ccs_app/app/network/response/user_response.dart';
import 'package:ccs_app/app/services/onesignal_service.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/export.dart';
import 'package:pinput/pinput.dart';
import 'package:step_progress/step_progress.dart';

class AuthController extends GetxController {
  // ─── Dependencies & role ─────────────────────────────────────────────────
  final AuthRepository _authRepository = AuthRepository();
  final selectedRole = Rxn<UserRole>();

  final agencyList = <Agency>[].obs;
  final mainAgencyList = <Agency>[].obs;
  final agencyController = TextEditingController();
  var isLoadingAgency = false.obs;
  var searchController = TextEditingController();
  var searchFocus = FocusNode();
  var searchTerm = ''.obs;
  var prevSearch = '';

  // ─── Login ───────────────────────────────────────────────────────────────
  final loginFormKey = GlobalKey<FormState>();
  final loginEmailCtrl = TextEditingController();
  final loginPasswordCtrl = TextEditingController();
  final loginObscure = true.obs;

  // ─── Sign-up (shared) ────────────────────────────────────────────────────
  final signupFormKey = GlobalKey<FormState>();
  final signupFirstNameCtrl = TextEditingController();
  final signupLastNameCtrl = TextEditingController();
  final signupEmailCtrl = TextEditingController();
  final signupPhoneCtrl = TextEditingController();
  final signupPasswordCtrl = TextEditingController();
  final signupObscure = true.obs;
  final signupNiNumberCtrl = TextEditingController();

  // ─── Forgot / reset password ──────────────────────────────────────────────
  final forgotEmailCtrl = TextEditingController();
  final resetPasswordCtrl = TextEditingController();
  final resetConfirmPasswordCtrl = TextEditingController();
  final resetObscure = true.obs;
  final resetFormKey = GlobalKey<FormState>();

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

  // ─── Agreement (cleaner assessment steps) – API types only ───────────────
  late StepProgressController stepProgressController;
  var stepCurrentIndex = 0.obs;
  RxList<Categories> assessmentCategories = <Categories>[].obs;
  RxList<List<aq.Questions>> assessmentQuestionsByStep = <List<aq.Questions>>[].obs;
  ScrollController scrollController = ScrollController();
  ScrollController stepScrollController = ScrollController();
  final selectedAgreementAnswers = <int, Map<int, List<num>>>{}.obs;
  List<num?> answersId = [];
  var from = '';
  final isHiring = true.obs;
  final hiringMessage = ''.obs;

  final TextEditingController codeCtrl = TextEditingController();

  // ─── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void onInit() {
    stepProgressController = StepProgressController(initialStep: 0, totalSteps: 1);

    if (Get.arguments != null) {
      if (Get.arguments['from'] != null) {
        from = Get.arguments['from'];
      }
    }

/*    _loadAgencies(isFromInit: true);

    searchController.addListener(() {
      if (searchController.text.trim().length > 2) {
        if (searchController.text.isNotEmpty) {
          if (prevSearch == searchController.text.trim()) return;
        }
        _loadAgencies(isFromSearch: true);
      } else if (searchController.text.isEmpty) {
        if (mainAgencyList.isNotEmpty) {
          agencyList.clear();
          agencyList.addAll(mainAgencyList);
        }
      }
    });*/

    super.onInit();
  }

  @override
  void onReady() {
    if (from.isEmpty) loadAssessmentSections();
    super.onReady();
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
    // agencyController.dispose();
    super.onClose();
  }

  String? validateRequired(String? v, [String name = 'This field']) {
    if (v == null || v.isEmpty) return '$name is required';
    return null;
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
        Get.back();
        popUp();
      },
    );
  }

  void popUp() {
    Notifier.openSheet(
      Get.context as BuildContext,
      showPrimaryButton: true,
      showSecondaryButton: false,
      title: "Welcome to Colossians Cleaning Services",
      message:
          "Thank you for your interest in joining our team.\n\nBefore you can apply for cleaning operative positions, you will be asked to complete a short screening questionnaire. These questions help us assess your suitability, reliability, and readiness for the role.\n\nPlease answer all questions honestly and accurately. Only applicants who successfully meet our requirements will be eligible to apply for available cleaning jobs through the Colossians platform.\n\nWe wish you the best of luck and thank you for considering a career with Colossians Cleaning Services.",
      icon: IconsaxPlusLinear.profile_2user,
      primaryButtonLabel: "Okay",
      onPrimaryPressed: () {
        Get.back();
        selectRole(UserRole.cleaner);
        resetAgreement();

        isHiring.value ? Get.toNamed(Routes.AGREEMENT) : hiringClosedSheet(Get.context as BuildContext);
      },
    );
  }

  void hiringClosedSheet(BuildContext context) {
    Notifier.openSheet(
      context,
      showPrimaryButton: true,
      showSecondaryButton: false,
      title: "Hiring Closed",
      message: hiringMessage.value,
      icon: IconsaxPlusLinear.info_circle,
      primaryButtonLabel: "Okay",
      type: SheetType.info,
      onPrimaryPressed: () {},
      onSecondaryPressed: () {},
    );
  }

  // ─── Assessment API (cleaner onboarding) ─────────────────────────────────

  /// Load categories (steps), then for each category fetch questions via getAssessmentForms(categoryId). Uses API types only.
  Future<void> loadAssessmentSections() async {
    Loader.show();
    assessmentCategories.clear();
    assessmentQuestionsByStep.clear();
    try {
      final catResult = await _authRepository.getAssessmentCategories();

      catResult.handle(
        success: (value) async {
          final categories = value.data?.categories ?? [];

          isHiring.value = value.data?.isHiring ?? true;
          hiringMessage.value = value.message ?? 'Hiring Closed';

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
      Loader.hide();
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
  }) {
    return _authRepository.changePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  // ─── Agreement (assessment steps) ─────────────────────────────────────────

  void setAgreementAnswer(int sectionIndex, int questionIndex, num optionId) {
    selectedAgreementAnswers.value[sectionIndex] ??= {};
    selectedAgreementAnswers.value[sectionIndex]![questionIndex] = [optionId];
    selectedAgreementAnswers.refresh();
  }

  void toggleAgreementAnswer(int sectionIndex, int questionIndex, num optionId) {
    selectedAgreementAnswers.value[sectionIndex] ??= {};
    final current = List<num>.from(selectedAgreementAnswers.value[sectionIndex]![questionIndex] ?? []);
    if (current.contains(optionId)) {
      current.remove(optionId);
    } else {
      current.add(optionId);
    }
    selectedAgreementAnswers.value[sectionIndex]![questionIndex] = current;
    selectedAgreementAnswers.refresh();
  }

  List<num>? getAgreementAnswer(int sectionIndex, int questionIndex) => selectedAgreementAnswers.value[sectionIndex]?[questionIndex];

  bool isAgreementOptionSelected(int sectionIndex, int questionIndex, num optionId) {
    return getAgreementAnswer(sectionIndex, questionIndex)?.contains(optionId) ?? false;
  }

  bool isAgreementStepComplete(int sectionIndex) {
    if (sectionIndex >= assessmentQuestionsByStep.length) return true;
    final questions = assessmentQuestionsByStep[sectionIndex];
    if (questions.isEmpty) return true;
    final answers = selectedAgreementAnswers.value[sectionIndex];
    if (answers == null) return false;
    for (var i = 0; i < questions.length; i++) {
      if (questions[i].options?.isNotEmpty == true) {
        final selected = answers[i];
        if (selected == null || selected.isEmpty) return false;
      }
    }
    return true;
  }

  void resetAgreement() {
    selectedAgreementAnswers.value.clear();
    stepCurrentIndex.value = 0;
    stepProgressController.setCurrentStep(stepCurrentIndex.value);
  }

  Future<void> saveCleanerAssessment() async {
    answersId.clear();
    final answers = <Answers>[];
    selectedAgreementAnswers.value.forEach((sectionIndex, questionAnswers) {
      if (sectionIndex >= assessmentQuestionsByStep.length) return;
      final questions = assessmentQuestionsByStep[sectionIndex];
      for (var i = 0; i < questions.length; i++) {
        final optionIds = questionAnswers[i];
        if (optionIds == null || optionIds.isEmpty) continue;
        answers.add(Answers(
          categoryId: questions[i].categoryId,
          questionId: questions[i].id,
          option: optionIds,
        ));
      }
    });

    Loader.show();
    try {
      var request = SaveCleanerAssessmentRequest(answers: answers);
      log(runtimeType.toString(), 'SAVE CLEANER REQUEST ${request.toJson()}');

      final result = await _authRepository.saveCleanerAssessment(request);
      result.handle(
        success: (value) {
          Loader.hide();
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            answersId.clear();
            answersId.addAll(value.data?.answerIds as Iterable<num?>);
            if (value.data?.overall?.status == "pass") {
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
            } else {
              Notifier.openSheet(
                Get.context as BuildContext,
                title: 'Failed',
                type: SheetType.error,
                primaryButtonLabel: 'Okay',
                message: 'You have not passed the assessment.',
                showSecondaryButton: false,
                onPrimaryPressed: () {
                  resetAgreement();
                  stepCurrentIndex.value = 0;
                  stepProgressController.setCurrentStep(0);
                },
              );
            }
          });
        },
        contextTag: 'save_assessment',
      );
    } catch (e) {
      Notifier.error('Failed to change password');
    } finally {
      Loader.hide();
    }
  }

  // ─── Change password (submit) ────────────────────────────────

  Future<void> submitChangePassword() async {
    if (!(changePasswordFormKey.currentState?.validate() ?? false)) return;
    Loader.show();
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
      Loader.hide();
    }
  }

  // ─── Login & Sign-up ───────────────────────────────────────────────────────────────

  Future<void> login() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;
    (Get.context as BuildContext).hideKeyboard();
    Loader.show();
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

          // Defer sheet to next frame so Loader.hide() from finally can close the loader first.
          // Otherwise Get.back() from Loader may pop the sheet instead of the loader.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context == null) return;
            Notifier.openSheet(
              Get.context as BuildContext,
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
          });
        },
        contextTag: 'login',
      );
    } catch (e) {
      Loader.hide();
      await Notifier.apiError(e, contextTag: 'login');
    } finally {
      Loader.hide();
    }
  }

  Future<void> signup() async {
    if (!(signupFormKey.currentState?.validate() ?? false)) return;

    final role = selectedRole.value;

    if (role == null) {
      Notifier.error('Please choose Client or Cleaner.');
      return;
    }

    Loader.show();
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
          isVerified: true);
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
      Loader.hide();
    }
  }

  // ─── Forgot / reset password ──────────────────────────────────────────────

  Future<void> submitForgotPassword() async {
    if (!forgotEmailCtrl.text.trim().isNotEmpty) {
      Notifier.error('Please enter your email.');
      return;
    }
    (Get.context as BuildContext).hideKeyboard();
    Loader.show();
    try {
      final result = await _authRepository.forgotPassword(email: forgotEmailCtrl.text);
      result.handle(
        success: (_) {
          Notifier.success(
            'If an account exists for this email, you will receive a password reset link.',
            title: 'Check your email',
          );
          Get.until((route) => Get.currentRoute == Routes.LOGIN);
        },
        contextTag: 'forgot_password',
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'forgot_password');
    } finally {
      Loader.hide();
    }
  }

  Future<void> submitResetPassword() async {
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

    Loader.show();
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
      Loader.hide();
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

    if (data.imageUrl != null && data.imageUrl?.isNotEmpty == true) {
      prefs.putData(Prefs.image, data.imageUrl ?? "");
    }
  }

  void openOtpSheet() {
    codeCtrl.text = '';

    Notifier.openSheet(
      Get.context!,
      title: 'Verify OTP',
      type: SheetType.info,
      message: 'Enter the OTP that is sent your Email',
      isDismissable: false,
      body: Column(
        spacing: 8,
        children: [
          CommonText.bold('Verify OTP!', size: 24, color: Get.context?.colorScheme.primary, fontWeight: FontWeight.w900).marginOnly(bottom: 8),
          CommonText.regular('Enter the verification code sent to your email address.',
              textAlign: TextAlign.center, size: 18, color: Get.context?.colorScheme.onSurface.withValues(alpha: 0.7)),
          _pinCode(Get.context!)
        ],
      ).marginSymmetric(vertical: 8),
      showPrimaryButton: true,
      showSecondaryButton: false,
      primaryButtonLabel: 'Verify OTP',
      isSheetAutoClose: false,
      onPrimaryPressed: () => {verifyOTPCode(Get.context!, signupEmailCtrl.text, codeCtrl.text)},
    );
  }

  Widget _pinCode(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 48,
      textStyle: context.textTheme.titleMedium?.copyWith(fontSize: 18, color: context.colorScheme.onPrimary),
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
        color: context.colorScheme.surface,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      textStyle: context.textTheme.titleMedium?.copyWith(fontSize: 18, color: context.colorScheme.tertiary),
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.secondary),
        borderRadius: BorderRadius.circular(8),
        color: context.colorScheme.surface,
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      textStyle: context.textTheme.titleMedium?.copyWith(fontSize: 18, color: context.colorScheme.secondary),
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: context.colorScheme.secondary),
        color: context.colorScheme.secondaryContainer,
      ),
    );

    return Center(
      child: Pinput(
        controller: codeCtrl,
        onChanged: (code) => codeCtrl.text = code,
        onCompleted: (pin) {
          codeCtrl.text = pin;
          verifyOTPCode(Get.context!, signupEmailCtrl.text, pin);
        },
        submittedPinTheme: submittedPinTheme,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        length: 6,
      ),
    );
  }

  Future<void> verifyOTPCode(BuildContext context, String email, String otp) async {
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      Notifier.error('Please enter 6 digit OTP');
      return;
    }
    try {
      Loader.show();
      final result = await _authRepository.verifyOtp(email: email, otp: otp);
      result.handle(
        success: (_) {
          Loader.hide();
          Get.back();
          // Defer sheet to next frame so Loader.hide() from finally can close the loader first
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context == null) return;
            signup();
          });
        },
        contextTag: 'send_OTP',
      );
    } catch (e) {
      Loader.hide();
    }
  }

  Future<void> sendOTP(String email) async {
    (Get.context as BuildContext).hideKeyboard();

    Loader.show();
    try {
      final result = await _authRepository.sendOtp(email: email);
      result.handle(
        success: (_) {
          Loader.hide();
          // Defer sheet to next frame so Loader.hide() from finally can close the loader first
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context == null) return;
            openOtpSheet();
          });
        },
        contextTag: 'send_OTP',
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'send_OTP');
    } finally {
      Loader.hide();
    }
  }

  Future<void> _loadAgencies({bool isFromSearch = false, bool isFromInit = false}) async {
    isLoadingAgency.value = true;
    try {
      final result = await _authRepository.getAgencies(search: searchController.text);
      result.handle(
        success: (response) {
          final raw = response.data;
          agencyList.clear();
          if (!isFromSearch) {
            mainAgencyList.clear();
          } else {
            prevSearch = searchController.text.trim();
          }
          if (raw != null && raw.isNotEmpty) {
            agencyList.assignAll(raw);
            if (!isFromSearch) {
              mainAgencyList.assignAll(agencyList);
            }
          }

          if (searchController.text.isEmpty) {
            agencyList.clear();
            agencyList.addAll(mainAgencyList);
          }
        },
      );
    } finally {
      isLoadingAgency.value = false;
    }
  }
}
