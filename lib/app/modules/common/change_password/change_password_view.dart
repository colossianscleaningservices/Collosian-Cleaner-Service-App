import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import 'change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return AppScaffold(
      appBar: Header(title: 'Change Password'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header info

                AppCard(
                  color: scheme.primaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                  enableShadows: false,
                  borderColor: scheme.primary.withValues(alpha: 0.2),
                  borderWidth: 1,
                  child: Row(
                    children: [
                      Icon(IconsaxPlusLinear.shield_tick, size: 24, color: scheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonText.regular(
                          'Choose a strong password with at least 8 characters, including uppercase and numbers.',
                          size: 13,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ).paddingAll(16),
                ),

                const SizedBox(height: 24),

                // Current password
                CommonText.medium('Current Password', size: 14, color: scheme.onSurface),
                const SizedBox(height: 8),
                Obx(() => CommonTextField(
                      controller: controller.currentPasswordCtrl,
                      hint: 'Enter current password',
                      obscure: !controller.showCurrentPassword.value,
                      validator: controller.validateCurrentPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.showCurrentPassword.value ? IconsaxPlusLinear.eye : IconsaxPlusLinear.eye_slash,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        onPressed: () => controller.showCurrentPassword.toggle(),
                      ),
                    )),
                const SizedBox(height: 20),

                // New password
                CommonText.medium('New Password', size: 14, color: scheme.onSurface),
                const SizedBox(height: 8),
                Obx(() => CommonTextField(
                      controller: controller.newPasswordCtrl,
                      hint: 'Enter new password',
                      obscure: !controller.showNewPassword.value,
                      validator: controller.validateNewPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.showNewPassword.value ? IconsaxPlusLinear.eye : IconsaxPlusLinear.eye_slash,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        onPressed: () => controller.showNewPassword.toggle(),
                      ),
                    )),
                const SizedBox(height: 20),

                // Confirm password
                CommonText.medium('Confirm New Password', size: 14, color: scheme.onSurface),
                const SizedBox(height: 8),
                Obx(() => CommonTextField(
                      controller: controller.confirmPasswordCtrl,
                      hint: 'Re-enter new password',
                      obscure: !controller.showConfirmPassword.value,
                      validator: controller.validateConfirmPassword,
                      action: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.showConfirmPassword.value ? IconsaxPlusLinear.eye : IconsaxPlusLinear.eye_slash,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        onPressed: () => controller.showConfirmPassword.toggle(),
                      ),
                    )),
                const SizedBox(height: 32),

                // Submit button
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Update Password',
                        type: ButtonType.primary,
                        isLoading: controller.isLoading.value,
                        onPressed: controller.changePassword,
                        btnVerticalPadding: 14,
                      ),
                    )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
