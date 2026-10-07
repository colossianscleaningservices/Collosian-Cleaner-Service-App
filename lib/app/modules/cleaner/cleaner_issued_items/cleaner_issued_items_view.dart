import 'package:ccs_app/app/network/response/profile_response.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import 'cleaner_issued_items_controller.dart';

class CleanerIssuedItemsView extends GetView<CleanerIssuedItemsController> {
  const CleanerIssuedItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppScaffold(
      appBar: Header(
        title: 'Issued items',
        headerLogoIcon: false,
        hasBackIcon: true,
        titleCentered: false,
      ),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SwipeRefresh(
          onRefresh: controller.refreshIssuedItems,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(left: 18,right: 18,bottom: 18,top: 4),
            child: Obx(() {
              final items = controller.issuedItems;
              final outstanding = controller.issuedItemsOutstandingCount.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CommonText.semiBold('Issued items overview', size: 16, color: scheme.onSurface),
                      ),
                      if (outstanding > 0)
                        InfoChip(
                          label: outstanding == 1 ? '1 to return' : '$outstanding to return',
                          backgroundColor: scheme.secondaryContainer,
                          foregroundColor: scheme.secondary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    NoDataView(
                      title: 'No issued items',
                      subtitle: 'No items have been issued to you yet.',
                      icon: IconsaxPlusLinear.box_1,
                    )
                  else
                    ...items.map(
                      (IssuedItem item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _IssuedItemCard(item: item, scheme: scheme),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _IssuedItemCard extends StatelessWidget {
  const _IssuedItemCard({required this.item, required this.scheme});

  final IssuedItem item;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final status = item.statusLabel?.trim();
    final qty = item.quantity?.toInt();
    final issuedBy = item.issuedByName?.trim();
    final issuedAt = item.issuedAt?.trim();
    final notes = item.notes?.trim();
    final returnedAt = item.returnedAt?.trim();
    final returnedTo = item.returnedToName?.trim();
    final condition = item.conditionOnReturn?.trim();

    final meta = <String>[
      if (qty != null && qty > 0) 'Qty $qty',
      if (issuedAt != null && issuedAt.isNotEmpty) 'Issued $issuedAt',
      if (issuedBy != null && issuedBy.isNotEmpty) 'by $issuedBy',
    ].join(' · ');

    final statusColors = _issuedStatusColors(item, scheme);

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
            ),
            child: Icon(IconsaxPlusLinear.box_1, size: 22, color: scheme.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CommonText.semiBold(
                        item.itemLabel?.trim().isNotEmpty == true ? item.itemLabel!.trim() : 'Issued item',
                        size: 15,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (status != null && status.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      InfoChip(
                        label: status,
                        backgroundColor: statusColors.$1,
                        foregroundColor: statusColors.$2,
                      ),
                    ],
                  ],
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  CommonText.regular(meta, size: 12, color: scheme.onSurfaceVariant),
                ],
                if (notes != null && notes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  CommonText.regular(notes, size: 12, color: scheme.onSurfaceVariant),
                ],
                if (item.isReturned == true) ...[
                  if (returnedAt != null && returnedAt.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    CommonText.regular('Returned $returnedAt', size: 12, color: scheme.onSurfaceVariant),
                  ],
                  if (returnedTo != null && returnedTo.isNotEmpty)
                    CommonText.regular('Returned to $returnedTo', size: 12, color: scheme.onSurfaceVariant),
                  if (condition != null && condition.isNotEmpty)
                    CommonText.regular('Condition: $condition', size: 12, color: scheme.onSurfaceVariant),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

(Color, Color) _issuedStatusColors(IssuedItem item, ColorScheme scheme) {
  final label = item.statusLabel?.toLowerCase() ?? '';
  if (item.isReturned == true || label.contains('returned')) {
    return (scheme.tertiaryContainer, scheme.tertiary);
  }
  if (item.isReturnable == false || label.contains('not returnable')) {
    return (scheme.surfaceContainerHighest, scheme.onSurfaceVariant);
  }
  return (scheme.secondaryContainer, scheme.secondary);
}
