import 'package:ccs_app/export.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';

import 'help_support_controller.dart';

class HelpSupportView extends GetView<HelpSupportController> {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return AppScaffold(
      appBar: Header(title: 'Help & Support'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick actions
              CommonText.semiBold('Contact us', size: 16, color: scheme.onSurface),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      label: 'Email',
                      icon: IconsaxPlusLinear.sms,
                      scheme: scheme,
                      onTap: () => controller.openEmail(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionCard(
                      label: 'Call',
                      icon: IconsaxPlusLinear.call,
                      scheme: scheme,
                      onTap: () => controller.openDialPad(controller.supportPhone.value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contact info
              CommonText.semiBold('Contact information', size: 16, color: scheme.onSurface),
              const SizedBox(height: 12),
              Obx(() {
                return _ContactInfoCard(scheme: scheme, supportEmail: controller.supportMail.value, supportPhone: controller.supportPhone.value);
              }),

              // Contact Us
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(IconsaxPlusLinear.message_text_1, size: 20, color: scheme.primary),
                  const SizedBox(width: 8),
                  CommonText.semiBold('Send a message', size: 16, color: scheme.onSurface),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                    color: context.colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                    boxShadow: context.effectiveShadows()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CommonText.regular('Name', size: 14, color: scheme.onSurfaceVariant).marginOnly(bottom: 6),
                    CommonTextField(
                      hint: 'Your name',
                      controller: controller.nameController,
                      action: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    CommonText.regular('Email', size: 14, color: scheme.onSurfaceVariant).marginOnly(bottom: 6),
                    CommonTextField(
                      hint: 'your@email.com',
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      action: TextInputAction.next,
                      isReadOnly: true,
                    ),
                    const SizedBox(height: 14),
                    CommonText.regular('Message', size: 14, color: scheme.onSurfaceVariant).marginOnly(bottom: 6),
                    CommonTextField(
                      hint: 'How can we help?',
                      controller: controller.messageController,
                      maxLines: 4,
                      action: TextInputAction.done,
                    ),
                    const SizedBox(height: 18),
                    AppButton(
                      label: 'Send message',
                      onPressed: controller.onSubmitMessage,
                      btnVerticalPadding: 14,
                    ),
                  ],
                ).paddingAll(UiConstants.defaultPadding),
              ),
              const SizedBox(height: UiConstants.gap),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.scheme,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      borderWidth: 1,
      borderColor: scheme.outline.withValues(alpha: 0.15),
      color: scheme.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: scheme.secondary),
          const SizedBox(height: 8),
          CommonText.medium(label, size: 12, color: scheme.onSurface),
        ],
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard({required this.scheme, required this.supportEmail, required this.supportPhone});

  final ColorScheme scheme;
  final String supportEmail;
  final String supportPhone;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      borderWidth: 1,
      borderColor: scheme.outline.withValues(alpha: 0.15),
      color: scheme.surfaceContainerHighest,
      child: Column(
        children: [
          _InfoRow(icon: IconsaxPlusLinear.sms, value: supportEmail, scheme: scheme),
          const SizedBox(height: 12),
          _InfoRow(icon: IconsaxPlusLinear.call, value: supportPhone, scheme: scheme),
          const SizedBox(height: 12),
          _InfoRow(icon: IconsaxPlusLinear.clock, value: 'Mon-Fri, 9 AM - 6 PM', scheme: scheme),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.value, required this.scheme});

  final IconData icon;
  final String value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 12),
        CommonText.regular(value, size: 12, color: scheme.onSurface),
      ],
    );
  }
}
