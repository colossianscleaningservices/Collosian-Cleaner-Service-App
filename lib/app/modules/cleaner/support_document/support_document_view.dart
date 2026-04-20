import 'package:ccs_app/app/network/response/get_staff_document_response.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../export.dart';
import '../../../widget/layout/app_scaffold.dart';
import 'support_document_controller.dart';

class SupportDocumentView extends GetView<SupportDocumentController> {
  const SupportDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppScaffold(
      appBar: Header(title: "Your Supporting Documents"),
      body: Obx(() {
        if (controller.documents.isEmpty) {
          return NoDataView(
            icon: Icons.description_outlined,
            title: 'No documents yet',
            subtitle: 'Add your passport, visa, or other supporting documents so they appear here.',
            actionLabel: 'Add Document',
            onAction: () => _navigateToAddDocument(context),
          );
        }
        return SwipeRefresh(
          onRefresh: controller.refreshDocuments,
          child: SlidableAutoCloseBehavior(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: controller.documents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = controller.documents[index];
                return _DocumentTile(
                  key: ValueKey(item.id),
                  item: item,
                  scheme: scheme,
                  onViewFile: () => controller.onViewFile(item),
                  onEdit: () => controller.onEditDocument(item),
                  onDelete: () => controller.onDeleteDocument(item),
                  iconForType: controller.iconForDocumentType(
                    item.documentName?.replaceAll('_', ' ').toLowerCase() ?? '',
                  ),
                );
              },
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddDocument(context),
        icon: const Icon(Icons.add),
        label: CommonText.regular(
          'Add Document',
          color: context.colorScheme.onPrimary,
        ),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }

  void _navigateToAddDocument(BuildContext context) {
    controller.clearData();
    Get.toNamed(Routes.ADD_DOCUMENT)?.then((result) {
      if (result == true) controller.refreshDocuments();
    });
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    super.key,
    required this.item,
    required this.scheme,
    required this.onViewFile,
    required this.onEdit,
    required this.onDelete,
    required this.iconForType,
  });

  final Documents item;
  final ColorScheme scheme;
  final VoidCallback onViewFile;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final IconData iconForType;

  static const int _expiringDaysThreshold = 30;

  @override
  Widget build(BuildContext context) {
    final expiry = item.expiryDate;
    final expiryStatus = _expiryStatus(expiry);

    return Container(
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
      ),
      child: Slidable(
        key: ValueKey(item.id),
        groupTag: 'documents',
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              onPressed: (_) => onDelete(),
              backgroundColor: Colors.transparent,
              foregroundColor: scheme.error,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: AppCard(
          onTap: onViewFile,
          enableScale: false,
          margin: EdgeInsets.zero,
          enableShadows: true,
          borderWidth: 1,
          borderColor: expiryStatus == 'expired'
              ? scheme.error.withValues(alpha: 0.4)
              : scheme.outline.withValues(alpha: 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppCard.iconContainer(
                    context: context,
                    child: Icon(iconForType, color: scheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.semiBold(
                          item.documentName?.replaceAll('_', ' ').capitalize ?? '',
                          size: 15,
                          color: scheme.onSurface,
                        ),
                        if (item.status != null) ...[
                          const SizedBox(height: 4),
                          _StatusBadge(status: item.status!, scheme: scheme),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppCard(
                    onTap: onEdit,
                    borderWidth: 1,
                    radius: 8,
                    enableShadows: false,
                    enableScale: false,
                    borderColor: scheme.primary.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 16, color: scheme.primary),
                        const SizedBox(width: 4),
                        CommonText.medium('Edit', color: scheme.primary, size: 13),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.3),
              ),
              _InfoRow(
                label: 'Number',
                value: item.documentNumber ?? '-',
                scheme: scheme,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: 'Expiry',
                value: expiry ?? '-',
                scheme: scheme,
                trailing: expiryStatus != null
                    ? _ExpiryChip(status: expiryStatus, scheme: scheme)
                    : null,
              ),
            ],
          ).paddingAll(16),
        ),
      ),
    );
  }

  String? _expiryStatus(String? expiry) {
    if (expiry == null || expiry.isEmpty) return null;

    final expiryDate = DateTime.parse(expiry);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalizedExpiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    if (normalizedExpiry.isBefore(today)) return 'expired';

    final daysLeft = normalizedExpiry.difference(today).inDays;

    if (daysLeft <= _expiringDaysThreshold) return 'expiring_soon';

    return null;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.scheme,
    this.trailing,
  });

  final String label;
  final String value;
  final ColorScheme scheme;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: CommonText.regular(label, size: 13, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CommonText.medium(value, size: 14, color: scheme.onSurface),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.scheme});

  final String status;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final isPending = status.toLowerCase() == 'pending';
    final bg = isPending
        ? scheme.tertiaryContainer
        : scheme.primaryContainer.withValues(alpha: 0.6);
    final fg = isPending
        ? scheme.onTertiaryContainer
        : scheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
      ),
      child: CommonText.medium(
        status.capitalize!,
        size: 11,
        color: fg,
      ),
    );
  }
}

class _ExpiryChip extends StatelessWidget {
  const _ExpiryChip({required this.status, required this.scheme});

  final String status;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final isExpired = status == 'expired';
    final bg = isExpired ? scheme.errorContainer : scheme.tertiaryContainer;
    final fg = isExpired ? scheme.onErrorContainer : scheme.onTertiaryContainer;
    final label = isExpired ? 'Expired' : 'Expiring soon';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
      ),
      child: CommonText.medium(label, size: 12, color: fg),
    );
  }
}
