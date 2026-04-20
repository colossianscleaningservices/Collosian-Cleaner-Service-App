import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

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
                      minLines: 4,
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

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard({required this.scheme, required this.supportEmail, required this.supportPhone});

  final ColorScheme scheme;
  final String supportEmail;
  final String supportPhone;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HelpSupportController>();
    final radius = BorderRadius.circular(UiConstants.radiusDefault);

    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      borderWidth: 1,
      borderColor: scheme.outline.withValues(alpha: 0.12),
      color: scheme.onPrimary,
      enableShadows: true,
      radius: UiConstants.radiusDefault,
      child: Column(
        children: [
          _ContactActionRow(
            scheme: scheme,
            icon: IconsaxPlusLinear.sms,
            title: 'Email',
            value: supportEmail,
            onTap: controller.openEmail,
            inkBorderRadius: BorderRadius.only(topLeft: radius.topLeft, topRight: radius.topRight),
          ),
          Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: scheme.outline.withValues(alpha: 0.12)),
          _ContactActionRow(
            scheme: scheme,
            icon: IconsaxPlusLinear.call,
            title: 'Phone',
            value: supportPhone,
            onTap: () => controller.openDialPad(supportPhone),
            inkBorderRadius: BorderRadius.only(bottomLeft: radius.bottomLeft, bottomRight: radius.bottomRight),
          ),
        ],
      ),
    );
  }
}

class _ContactActionRow extends StatelessWidget {
  const _ContactActionRow({
    required this.scheme,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    required this.inkBorderRadius,
  });

  final ColorScheme scheme;
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final BorderRadius inkBorderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: inkBorderRadius,
        splashColor: scheme.primary.withValues(alpha: 0.08),
        highlightColor: scheme.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppCard(
                radius: UiConstants.radiusDefault,
                color: scheme.secondary.withValues(alpha: 0.07),
                enableShadows: false,
                padding: const EdgeInsets.all(10),
                child: Icon(icon, size: 24, color: scheme.secondary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.semiBold(title, size: 12, color: scheme.onSurfaceVariant),
                    const SizedBox(height: 4),
                    CommonText.regular(
                      value,
                      size: 14,
                      color: scheme.onSurface,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(IconsaxPlusLinear.arrow_right_3, size: 20, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
