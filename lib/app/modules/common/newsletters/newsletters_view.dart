import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import '../../../network/response/newsletter_response.dart';
import 'newsletters_controller.dart';

class NewslettersView extends GetView<NewslettersController> {
  const NewslettersView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return AppScaffold(
      appBar: Header(title: 'Newsletters'),
      body: Obx(() {
        return SwipeRefresh(
          onRefresh: () => controller.refreshNewsletters(),
          child: SafeArea(
            child: controller.newsletters.isEmpty
                ? NoDataView(
              title: 'No newsletters',
              subtitle: "We'll share updates and offers here when they're available.",
              icon: IconsaxPlusLinear.sms_edit,
            )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    itemCount: controller.newsletters.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = controller.newsletters[index];
                      return _NewsletterCard(
                        item: item,
                        scheme: scheme,
                        onTap: () => {
                          /*_showNewsletterDetail(context, item, scheme)*/
                        },
                      );
                    },
                  ),
          ),
        );
      }),
    );
  }

  void _showNewsletterDetail(BuildContext context, Newsletters item, ColorScheme scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.isActive == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                  ),
                  child: CommonText.medium('Active', size: 12, color: scheme.onPrimaryContainer),
                ).marginOnly(bottom: 12),
              CommonText.semiBold(item.title ?? '', size: 20, color: scheme.onSurface),
              if (item.createdAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(IconsaxPlusLinear.calendar_1, size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    CommonText.regular(
                      _formatDate(DateTime.parse(item.createdAt??"")),
                      size: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              CommonText.regular(
                item.description ?? '',
                size: 15,
                color: scheme.onSurface.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _NewsletterCard extends StatelessWidget {
  const _NewsletterCard({
    required this.item,
    required this.scheme,
    required this.onTap,
  });

  final Newsletters item;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      borderWidth: 1,
      borderColor: scheme.outline.withValues(alpha: 0.08),
      enableShadows: true,
      color: scheme.onPrimary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            enableShadows: false,
            radius: UiConstants.radiusDefault,
            color: scheme.primary.withValues(alpha: 0.15),
            child: Icon(
              IconsaxPlusLinear.sms_edit,
              size: 22,
              color: scheme.primary,
            ).paddingAll(12),
          ).marginOnly(right: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CommonText.semiBold(
                        item.title ?? '',
                        size: 16,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (item.isActive == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                        ),
                        child: CommonText.medium(
                          'Active',
                          size: 11,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                CommonText.regular(
                  item.description ?? '',
                  size: 14,
                  color: scheme.onSurface.withValues(alpha: 0.85),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.createdAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(IconsaxPlusLinear.calendar_1, size: 14, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      CommonText.regular(
                        _timeAgo(DateTime.parse(item.createdAt??"")),
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
