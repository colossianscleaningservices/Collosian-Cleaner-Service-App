import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import 'contact_us_controller.dart';

/// Contact Us: contact options (email, phone, hours) and optional message form.
class ContactUsView extends GetView<ContactUsController> {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final c = controller;

    return AppScaffold(
      appBar: Header(
        title: 'Contact Us',
        headerLogoIcon: false,
        hasBackIcon: true,
        titleCentered: false,
      ),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: UiConstants.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonText.regular(
                'Get in touch with our team. We\'re here to help with any questions or feedback.',
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 24),

              // Contact options
              Row(
                children: [
                  Icon(IconsaxPlusLinear.call_calling, size: 20, color: scheme.primary),
                  const SizedBox(width: 8),
                  CommonText.semiBold('Contact options', size: 16, color: scheme.onSurface),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ContactOptionCard(
                      label: 'Email',
                      icon: IconsaxPlusLinear.sms,
                      scheme: scheme,
                      onTap: c.onEmailTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ContactOptionCard(
                      label: 'Call',
                      icon: IconsaxPlusLinear.call,
                      scheme: scheme,
                      onTap: c.onCallTap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contact information
              Row(
                children: [
                  Icon(IconsaxPlusLinear.info_circle, size: 20, color: scheme.primary),
                  const SizedBox(width: 8),
                  CommonText.semiBold('Contact information', size: 16, color: scheme.onSurface),
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    _InfoRow(icon: IconsaxPlusLinear.sms, label: 'Email', value: 'support@collosian.com', scheme: scheme, onTap: c.onEmailTap),
                    const SizedBox(height: 14),
                    _InfoRow(icon: IconsaxPlusLinear.call, label: 'Phone', value: '+44 (0) 123 456 7890', scheme: scheme, onTap: c.onCallTap),
                    const SizedBox(height: 14),
                    _InfoRow(icon: IconsaxPlusLinear.clock, label: 'Hours', value: 'Mon–Fri, 9 AM – 6 PM', scheme: scheme),
                  ],
                ).paddingAll(UiConstants.defaultPadding),
              ),
              const SizedBox(height: 24),

              // Send a message
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
                      controller: c.nameController,
                      action: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    CommonText.regular('Email', size: 14, color: scheme.onSurfaceVariant).marginOnly(bottom: 6),
                    CommonTextField(
                      hint: 'your@email.com',
                      controller: c.emailController,
                      keyboardType: TextInputType.emailAddress,
                      action: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    CommonText.regular('Message', size: 14, color: scheme.onSurfaceVariant).marginOnly(bottom: 6),
                    CommonTextField(
                      hint: 'How can we help?',
                      controller: c.messageController,
                      maxLines: 4,
                      action: TextInputAction.done,
                    ),
                    const SizedBox(height: 18),
                    AppButton(
                      label: 'Send message',
                      onPressed: c.onSubmitMessage,
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

class _ContactOptionCard extends StatelessWidget {
  const _ContactOptionCard({
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
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      borderWidth: 1,
      borderColor: scheme.outline.withValues(alpha: 0.15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: scheme.primary),
          const SizedBox(height: 10),
          CommonText.medium(label, size: 14, color: scheme.onSurface),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText.regular(label, size: 12, color: scheme.onSurfaceVariant),
              const SizedBox(height: 2),
              CommonText.medium(value, size: 14, color: scheme.onSurface),
            ],
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      );
    }
    return content;
  }
}
