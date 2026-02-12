import 'package:ccs_app/app/modules/common/help_support/help_support_controller.dart';

import '../../../../export.dart';
import '../../../widget/layout/app_scaffold.dart';

class FaqView extends GetView<HelpSupportController> {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: Header(title: 'FAQs'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildFAQs(context.colorScheme),
                const SizedBox(height: 24),
              ],
            );
          }),
        ),
      ),
    );
  }

  List<Widget> _buildFAQs(ColorScheme scheme) {
    return controller.faqList.map((faq) =>
        _FAQItem(
          question: faq.question ?? '',
          answer: faq.answer ?? '',
          scheme: scheme,
        ))
        .toList();
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


