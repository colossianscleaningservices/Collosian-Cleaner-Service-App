import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import 'auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: Header(title: 'Forgot password'),
      body: Padding(
        padding: UiConstants.padding,
        child: Column(
          children: [
            CommonTextField(
              controller: controller.forgotEmailCtrl,
              label: 'Email',
              hint: 'you@example.com',
              validator: Validator.email,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Send reset link/code',
              onPressed: controller.submitForgotPassword,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Back to login',
              type: ButtonType.transparent,
              onPressed: controller.backToLogin,
            ),
          ],
        ),
      ),
    );
  }
}
