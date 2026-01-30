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
                      onTap: () => Notifier.info('support@collosian.com'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionCard(
                      label: 'Call',
                      icon: IconsaxPlusLinear.call,
                      scheme: scheme,
                      onTap: () => Notifier.info('+44 (0) 123 456 7890'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // FAQs
              CommonText.semiBold('FAQs', size: 16, color: scheme.onSurface),
              const SizedBox(height: 12),
              ..._buildFAQs(scheme),
              const SizedBox(height: 24),

              // Contact info
              CommonText.semiBold('Contact information', size: 16, color: scheme.onSurface),
              const SizedBox(height: 12),
              _ContactInfoCard(scheme: scheme),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFAQs(ColorScheme scheme) {
    final faqs = [
      {'q': 'How do I schedule a cleaning job?', 'a': 'Go to Calendar, tap "+", select date/time, and fill in details.'},
      {'q': 'How do I update my profile?', 'a': 'Go to Profile tab, tap "Edit Profile", update info, and save.'},
      {'q': 'How are payments processed?', 'a': 'Payments are processed after job completion. View earnings in the Earnings section.'},
    ];

    return faqs.map((faq) => _FAQItem(
      question: faq['q']!,
      answer: faq['a']!,
      scheme: scheme,
    )).toList();
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

class _FAQItem extends StatefulWidget {
  const _FAQItem({required this.question, required this.answer, required this.scheme});

  final String question;
  final String answer;
  final ColorScheme scheme;

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      borderWidth: 1,
      borderColor: widget.scheme.outline.withValues(alpha: 0.12),
      color: widget.scheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: CommonText.medium(widget.question, size: 14, color: widget.scheme.onSurface)),
              Icon(
                _isExpanded ? IconsaxPlusLinear.arrow_up_1 : IconsaxPlusLinear.arrow_down,
                size: 18,
                color: widget.scheme.onSurfaceVariant,
              ),
            ],
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 10),
            CommonText.regular(widget.answer, size: 12, color: widget.scheme.onSurfaceVariant),
          ],
        ],
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard({required this.scheme});

  final ColorScheme scheme;

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
          _InfoRow(icon: IconsaxPlusLinear.sms, value: 'support@collosian.com', scheme: scheme),
          const SizedBox(height: 12),
          _InfoRow(icon: IconsaxPlusLinear.call, value: '+44 (0) 123 456 7890', scheme: scheme),
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
