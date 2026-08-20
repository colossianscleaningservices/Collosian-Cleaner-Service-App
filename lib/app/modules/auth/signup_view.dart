import 'package:ccs_app/app/gen/assets.gen.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import 'auth_controller.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return AppScaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: UiConstants.defaultPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Assets.imagesAppLogo.image().paddingSymmetric(horizontal: 24, vertical: 32),
                    AppCard(
                      child: Obx(() {
                        final role = controller.selectedRole.value;
                        if (role == null) {
                          return _buildSelectRoleContent(context);
                        }
                        return _buildSignupForm(context, role);
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectRoleContent(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommonText.bold('Select a role', size: 28),
        const SizedBox(height: 8),
        CommonText.regular(
          'Choose Client or Cleaner to continue.',
          color: scheme.onSurfaceVariant,
          size: 18,
        ),
        const SizedBox(height: 32),
        AppButton(label: 'Select role', onPressed: () => controller.goToRoleSelection(context)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonText.regular('Already have an account? ', color: scheme.onSurfaceVariant),
            CommonText.regular('Sign in', color: scheme.primary, onTap: () => Get.offAllNamed(Routes.LOGIN)),
          ],
        ),
      ],
    ).paddingSymmetric(horizontal: 24, vertical: 18);
  }

  Widget _buildSignupForm(BuildContext context, UserRole role) {
    final scheme = context.colorScheme;
    final isClient = role == UserRole.client;
    final subtitle = isClient ? 'Create your client account' : 'Create your cleaner account';

    return Form(
      key: controller.signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CommonText.bold(isClient ? 'Sign up as Client' : 'Sign up as Cleaner', size: 28),
          const SizedBox(height: 8),
          CommonText.regular(subtitle, color: scheme.onSurfaceVariant, size: 18),
          const SizedBox(height: 32),
          CommonTextField(
            controller: controller.signupFirstNameCtrl,
            label: 'First name',
            hint: 'First name',
            validator: (v) => Validator.requiredField(v, fieldName: 'First name'),
            autofillHints: const [AutofillHints.givenName],
            prefixIcon: Icon(IconsaxPlusLinear.user, size: 20, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: UiConstants.gap),
          CommonTextField(
            controller: controller.signupLastNameCtrl,
            label: 'Last name',
            hint: 'Last name',
            validator: (v) => Validator.requiredField(v, fieldName: 'Last name'),
            autofillHints: const [AutofillHints.familyName],
            prefixIcon: Icon(IconsaxPlusLinear.user, size: 20, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: UiConstants.gap),
          CommonTextField(
            controller: controller.signupEmailCtrl,
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: Validator.email,
            autofillHints: const [AutofillHints.email],
            prefixIcon: Icon(IconsaxPlusLinear.sms, size: 20, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: UiConstants.gap),
          CommonTextField(
            controller: controller.signupPhoneCtrl,
            label: 'Phone',
            hint: '07...',
            maxLength: 10,
            keyboardType: TextInputType.phone,
            validator: (v) => Validator.minLength(v, 10, fieldName: 'Phone'),
            autofillHints: const [AutofillHints.telephoneNumber],
            prefixIcon: Icon(IconsaxPlusLinear.call, size: 20, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: UiConstants.gap),
          Obx(
            () => CommonTextField(
              controller: controller.signupPasswordCtrl,
              label: 'Password',
              hint: '••••••••',
              obscure: controller.signupObscure.value,
              validator: (v) => Validator.minLength(v, 8, fieldName: 'Password'),
              autofillHints: const [AutofillHints.newPassword],
              prefixIcon: Icon(IconsaxPlusLinear.lock_1, size: 20, color: scheme.onSurfaceVariant),
              suffixIcon: IconButton(
                onPressed: () => controller.signupObscure.value = !controller.signupObscure.value,
                icon: Icon(
                  controller.signupObscure.value ? IconsaxPlusLinear.eye_slash : IconsaxPlusLinear.eye,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (!isClient) ...[
            const SizedBox(height: UiConstants.gap),
            CommonTextField(
              controller: controller.signupNiNumberCtrl,
              label: 'NI number',
              hint: 'AB123456C',
              validator: Validator.nin,
              prefixIcon: Icon(IconsaxPlusLinear.card, size: 20, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: UiConstants.gap),
            AppCheckBox(
              title: 'Are you Student?',
              value: controller.isStudent.value,
              onChange: (v) => controller.isStudent.value = v,
            ),
           /* const SizedBox(height: UiConstants.gap),
            CommonTextField(
              controller: controller.agencyController,
              label: 'Agency',
              isReadOnly: true,
              hint: 'Select Agency',
              keyboardType: TextInputType.text,
              onTap: () {
                Notifier.openSheet(
                  context,
                  top: true,
                  showPrimaryButton: false,
                  showSecondaryButton: false,
                  showIcon: false,
                  body: Expanded(
                    child: Column(
                      children: [
                        _SearchSection(controller: controller, scheme: scheme).marginOnly(bottom: 8),
                        Obx(() {
                          return controller.isLoadingAgency.value
                              ? Center(child: CircularProgressIndicator())
                              : controller.agencyList.isEmpty
                              ? Flexible(
                            child: Center(
                              child: NoDataView(
                                title: 'No Agencies Found',
                              ),
                            ),
                          )
                              : Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: controller.agencyList.length,
                              itemBuilder: (context, index) {
                                final item = controller.agencyList[index];
                                return AppCard(
                                  color: item.isSelect ? scheme.secondaryContainer : scheme.onPrimary,
                                  borderWidth: item.isSelect ? 1.5 : 0,
                                  borderColor: item.isSelect ? scheme.secondary : Colors.transparent,
                                  onTap: () {
                                    controller.agencyController.text = item.name ?? "";
                                    for (var cl in controller.agencyList) {
                                      cl.isSelect = false;
                                    }
                                    for (var cl in controller.mainAgencyList) {
                                      cl.isSelect = false;
                                    }
                                    controller.mainAgencyList.firstWhereOrNull((element) => element.name == item.name)?.isSelect =
                                    true;
                                    item.isSelect = true;
                                    controller.agencyList.refresh();
                                    Get.back();
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CommonText.semiBold('Owner Name : ${item.owner?.name ?? ""}' ).marginOnly(bottom: 4),
                                      CommonText.regular('Agency : ${item.name ?? ""}' ),
                                    ],
                                  ).paddingAll(16),
                                ).marginAll(8);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
              validator: (v) => controller.validateRequired(v, 'Agency'),
            ),*/
          ],
          const SizedBox(height: 32),
          AppButton(
            label: 'Create account',
            onPressed: () {
              if (controller.signupFormKey.currentState?.validate() ?? false) {
                controller.sendOTP(controller.signupEmailCtrl.text);
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonText.regular('Already have an account? ', color: scheme.onSurfaceVariant),
              CommonText.regular('Sign in', color: scheme.primary, onTap: () => Get.until((route) => Get.currentRoute == Routes.LOGIN)),
            ],
          ),
        ],
      ).paddingSymmetric(horizontal: 24, vertical: 18),
    );
  }
}

