import 'package:ccs_app/export.dart';

import 'auth_controller.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final role = controller.selectedRole.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: UiConstants.padding,
        child: ListView(
          children: [
            if (role == null) ...[
              CommonText.regular('Select a role to continue.'),
              const SizedBox(height: 12),
              AppButton(
                label: 'Select role',
                onPressed: controller.goToRoleSelection,
              ),
            ] else ...[
              CommonText.regular('Role: ${role.name}'),
              const SizedBox(height: 12),
              CommonTextField(
                controller: controller.signupFirstNameCtrl,
                label: 'First name',
                hint: 'First name',
                validator: (v) =>
                    Validator.requiredField(v, fieldName: 'First name'),
              ),
              const SizedBox(height: 12),
              CommonTextField(
                controller: controller.signupLastNameCtrl,
                label: 'Last name',
                hint: 'Last name',
                validator: (v) =>
                    Validator.requiredField(v, fieldName: 'Last name'),
              ),
              const SizedBox(height: 12),
              CommonTextField(
                controller: controller.signupEmailCtrl,
                label: 'Email',
                hint: 'you@example.com',
                validator: Validator.email,
              ),
              const SizedBox(height: 12),
              CommonTextField(
                controller: controller.signupPhoneCtrl,
                label: 'Phone',
                hint: '07...',
                validator: (v) =>
                    Validator.requiredField(v, fieldName: 'Phone'),
              ),
              const SizedBox(height: 12),
              Obx(
                () => CommonTextField(
                  controller: controller.signupPasswordCtrl,
                  label: 'Password',
                  hint: '••••••••',
                  obscure: controller.signupObscure.value,
                  validator: (v) =>
                      Validator.minLength(v, 8, fieldName: 'Password'),
                  suffixIcon: IconButton(
                    onPressed: () => controller.signupObscure.value =
                        !controller.signupObscure.value,
                    icon: Icon(
                      controller.signupObscure.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (role == AppRole.cleaner) ...[
                CommonTextField(
                  controller: controller.signupNiNumberCtrl,
                  label: 'NI number',
                  hint: 'AB123456C',
                  validator: Validator.nin,
                ),
                const SizedBox(height: 12),
              ],
              AppButton(label: 'Create account', onPressed: controller.signup),
              const SizedBox(height: 12),
              AppButton(
                label: 'Back to login',
                type: ButtonType.transparent,
                onPressed: controller.backToLogin,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

