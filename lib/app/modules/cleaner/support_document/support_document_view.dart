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
        if (controller.isLoadingDocuments.value && controller.documents.isEmpty) {
          return const Center(
            child: PageLoader(),
          );
        }
        if (controller.documents.isEmpty) {
          return _EmptyState(
            scheme: scheme,
            onAddDocument: () => _navigateToAddDocument(context),
          );
        }
        return SwipeRefresh(
          onRefresh: controller.refreshDocuments,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: controller.documents.length,
            itemBuilder: (context, index) {
              final item = controller.documents[index];
              return _DocumentCard(
                item: item,
                scheme: scheme,
                onViewFile: () => controller.onViewFile(item),
                onEdit: () => controller.onEditDocument(item),
                onDelete: () => controller.onDeleteDocument(item),
                iconForType: controller.iconForDocumentType(item.type),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddDocument(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Document'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }

  void _navigateToAddDocument(BuildContext context) {
    Get.toNamed(Routes.ADD_DOCUMENT)?.then((result) {
      if (result == true) controller.refreshDocuments();
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.scheme,
    required this.onAddDocument,
  });

  final ColorScheme scheme;
  final VoidCallback onAddDocument;

  @override
  Widget build(BuildContext context) {
    return NoDataView(
      icon: Icons.description_outlined,
      title: 'No documents yet',
      subtitle: 'Add your passport, visa, or other supporting documents so they appear here.',
      actionLabel: 'Add Document',
      onAction: onAddDocument,
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.item,
    required this.scheme,
    required this.onViewFile,
    required this.onEdit,
    required this.onDelete,
    required this.iconForType,
  });

  final SupportDocumentItem item;
  final ColorScheme scheme;
  final VoidCallback onViewFile;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final IconData iconForType;

  static const int _expiringDaysThreshold = 30;

  @override
  Widget build(BuildContext context) {
    final expiry = item.expiry;
    final expiryText = expiry != null ? CcsDateUtils.forInput(expiry) : '—';
    final expiryStatus = _expiryStatus(expiry);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      enableShadows: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard.iconContainer(
                context: context,
                child: Icon(iconForType, color: scheme.primary, size: 24),
              ).marginOnly(right: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                      ),
                      child: CommonText.medium(
                        item.type,
                        size: 12,
                        color: scheme.onPrimaryContainer,
                      ),
                    ).marginOnly(bottom: 8),
                    CommonText.regular(
                      'Number: ${item.number}',
                      size: 14,
                      color: scheme.onSurface,
                    ).marginOnly(bottom: 4),
                    Row(
                      children: [
                        CommonText.regular(
                          'Expiry: $expiryText',
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        if (expiryStatus != null) ...[
                          const SizedBox(width: 8),
                          _ExpiryChip(status: expiryStatus, scheme: scheme),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onViewFile,
            borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.open_in_new, size: 18, color: scheme.primary),
                  const SizedBox(width: 6),
                  CommonText.medium(
                    'View file',
                    size: 14,
                    color: scheme.primary,
                    isUnderLine: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              AppCard(
                onTap: onEdit,
                borderWidth: 1,
                enableShadows: false,
                borderColor: scheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: scheme.primary),
                    const SizedBox(width: 6),
                    CommonText.medium('Edit', color: scheme.primary, size: 14),
                  ],
                ),
              ).marginOnly(right: 10),
              AppCard(
                onTap: onDelete,
                color: scheme.errorContainer,
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.delete_outline_outlined,
                  size: 20,
                  color: scheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ],
      ).paddingAll(16),
    );
  }

  String? _expiryStatus(DateTime? expiry) {
    if (expiry == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDate = DateTime(expiry.year, expiry.month, expiry.day);
    if (expiryDate.isBefore(today)) return 'expired';
    final daysLeft = expiryDate.difference(today).inDays;
    if (daysLeft <= _expiringDaysThreshold) return 'expiring_soon';
    return null;
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
      ),
      child: CommonText.medium(label, size: 11, color: fg),
    );
  }
}
