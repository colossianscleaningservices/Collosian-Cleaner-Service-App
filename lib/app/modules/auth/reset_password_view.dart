import 'package:ccs_app/export.dart';

import 'auth_controller.dart';

class ResetPasswordView extends GetView<AuthController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: Padding(
        padding: UiConstants.padding,
        child: Column(
          children: [
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
            AppButton(
              label: 'Reset password',
              onPressed: controller.submitResetPassword,
            ),
          ],
        ),
      ),
    );
  }
}

