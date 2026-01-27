import 'package:ccs_app/export.dart';

import 'auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: UiConstants.padding,
        child: Column(
          children: [
            CommonTextField(
              controller: controller.loginEmailCtrl,
              label: 'Email',
              hint: 'you@example.com',
              validator: Validator.email,
            ),
            const SizedBox(height: 12),
            Obx(
              () => CommonTextField(
                controller: controller.loginPasswordCtrl,
                label: 'Password',
                hint: '••••••••',
                obscure: controller.loginObscure.value,
                suffixIcon: IconButton(
                  onPressed: () => controller.loginObscure.value =
                      !controller.loginObscure.value,
                  icon: Icon(
                    controller.loginObscure.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Login',
              onPressed: controller.login,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Forgot password?',
              type: ButtonType.transparent,
              onPressed: controller.goToForgotPassword,
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Create an account',
              type: ButtonType.tonal,
              onPressed: controller.goToRoleSelection,
            ),
          ],
        ),
      ),
    );
  }
}

