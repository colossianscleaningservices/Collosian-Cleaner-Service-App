import 'package:ccs_app/app/modules/auth/auth_controller.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

class ChangePasswordView extends GetView<AuthController> {
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
            key: controller.changePasswordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                CommonText.medium('Current Password', size: 14, color: scheme.onSurface),
                const SizedBox(height: 8),
                Obx(() => CommonTextField(
                      controller: controller.changePasswordCurrentCtrl,
                      hint: 'Enter current password',
                      obscure: !controller.showChangeCurrentPassword.value,
                      validator: controller.validateChangeCurrentPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.showChangeCurrentPassword.value ? IconsaxPlusLinear.eye : IconsaxPlusLinear.eye_slash,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        onPressed: () => controller.showChangeCurrentPassword.toggle(),
                      ),
                    )),
                const SizedBox(height: 20),

                CommonText.medium('New Password', size: 14, color: scheme.onSurface),
                const SizedBox(height: 8),
                Obx(() => CommonTextField(
                      controller: controller.changePasswordNewCtrl,
                      hint: 'Enter new password',
                      obscure: !controller.showChangeNewPassword.value,
                      validator: controller.validateChangeNewPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.showChangeNewPassword.value ? IconsaxPlusLinear.eye : IconsaxPlusLinear.eye_slash,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        onPressed: () => controller.showChangeNewPassword.toggle(),
                      ),
                    )),
                const SizedBox(height: 20),

                CommonText.medium('Confirm New Password', size: 14, color: scheme.onSurface),
                const SizedBox(height: 8),
                Obx(() => CommonTextField(
                      controller: controller.changePasswordConfirmCtrl,
                      hint: 'Re-enter new password',
                      obscure: !controller.showChangeConfirmPassword.value,
                      validator: controller.validateChangeConfirmPassword,
                      action: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.showChangeConfirmPassword.value ? IconsaxPlusLinear.eye : IconsaxPlusLinear.eye_slash,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        onPressed: () => controller.showChangeConfirmPassword.toggle(),
                      ),
                    )),
                const SizedBox(height: 32),

                Obx(() => SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Update Password',
                        type: ButtonType.primary,
                        isLoading: controller.isChangingPassword.value,
                        onPressed: controller.submitChangePassword,
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
