import 'package:ccs_app/app/gen/assets.gen.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import 'auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Assets.imagesAppLogo.image().paddingSymmetric(horizontal: 24, vertical: 32),
                    AppCard(
                      child: Form(
                        key: controller.loginFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CommonText.bold('Welcome back', size: 28),
                            const SizedBox(height: 8),
                            CommonText.regular('Sign in to your CCS account', color: scheme.onSurfaceVariant, size: 18),
                            const SizedBox(height: 40),
                            // Email
                            CommonTextField(
                              controller: controller.loginEmailCtrl,
                              label: 'Email',
                              hint: 'you@example.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: Validator.email,
                              autofillHints: const [AutofillHints.email],
                              prefixIcon: Icon(IconsaxPlusLinear.user, size: 20, color: scheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: UiConstants.gap),
                            // Password
                            Obx(
                              () => CommonTextField(
                                controller: controller.loginPasswordCtrl,
                                label: 'Password',
                                hint: '••••••••',
                                obscure: controller.loginObscure.value,
                                validator: (v) => Validator.requiredField(v, fieldName: 'Password'),
                                autofillHints: const [AutofillHints.password],
                                prefixIcon: Icon(IconsaxPlusLinear.lock_1, size: 20, color: scheme.onSurfaceVariant),
                                suffixIcon: IconButton(
                                  onPressed: () => controller.loginObscure.value = !controller.loginObscure.value,
                                  icon: Icon(
                                    controller.loginObscure.value ? Icons.visibility_off : Icons.visibility,
                                    size: 20,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Forgot password link
                            Align(
                              alignment: Alignment.centerRight,
                              child: CommonText.regular('Forgot password?', onTap: controller.goToForgotPassword),
                            ),
                            const SizedBox(height: 24),
                            // Login button
                            Obx(
                              () => AppButton(
                                label: 'Sign in',
                                onPressed: () {
                                  if (controller.loginFormKey.currentState?.validate() ?? false) {
                                    FocusScope.of(context).unfocus();
                                    controller.login();
                                  }
                                },
                                isLoading: controller.isLoggingIn.value,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Sign up row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CommonText.regular("Don't have an account? ", color: scheme.onSurfaceVariant),
                                CommonText.regular('Sign up', color: scheme.primary, onTap: () {
                                  FocusScope.of(context).unfocus();
                                  controller.goToRoleSelection(context);
                                }),
                              ],
                            ),
                          ],
                        ).paddingSymmetric(horizontal: 24, vertical: 18),
                      ),
                    ).paddingOnly(bottom: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
