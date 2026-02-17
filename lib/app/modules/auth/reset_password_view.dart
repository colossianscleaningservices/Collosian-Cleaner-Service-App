import 'package:ccs_app/export.dart';

import 'auth_controller.dart';

class ResetPasswordView extends GetView<AuthController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SingleChildScrollView(
        padding: UiConstants.padding,
        child: Form(
          key: controller.resetFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (controller.resetToken.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CommonText.regular(
                    'Invalid or expired link. Open the link from your reset email or request a new one.',
                    color: scheme.error,
                    size: 14,
                  ),
                ),
              Obx(
                () => CommonTextField(
                  controller: controller.resetPasswordCtrl,
                  label: 'New password',
                  hint: '••••••••',
                  obscure: controller.resetObscure.value,
                  validator: (v) =>
                      Validator.minLength(v, 8, fieldName: 'Password'),
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => CommonTextField(
                  controller: controller.resetConfirmPasswordCtrl,
                  label: 'Confirm password',
                  hint: '••••••••',
                  obscure: controller.resetObscure.value,
                  validator: (v) =>
                      Validator.minLength(v, 8, fieldName: 'Confirm password'),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => AppButton(
                  label: 'Reset password',
                  onPressed: controller.resetToken.isEmpty
                      ? null
                      : () => controller.submitResetPassword(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

