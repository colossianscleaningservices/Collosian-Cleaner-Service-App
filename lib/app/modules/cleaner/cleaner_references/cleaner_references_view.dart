import 'package:ccs_app/app/network/response/get_references_response.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../export.dart';
import 'cleaner_references_controller.dart';

class CleanerReferencesView extends GetView<CleanerReferencesController> {
  const CleanerReferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppScaffold(
      appBar: Header(title: "References"),
      body: Obx(() {
        if (controller.references.isEmpty) {
          return NoDataView(
            icon: IconsaxPlusLinear.profile_2user,
            title: 'No references yet',
            subtitle: 'Add professional or personal references to strengthen your profile. They\'ll appear here once added.',
            actionLabel: 'Add Reference',
            onAction: () {
              controller.clearForm();
              Get.toNamed(Routes.ADD_REFERENCES);
            },
          );
        }
        return SwipeRefresh(
          onRefresh: controller.refreshReferences,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Icon(IconsaxPlusLinear.profile_2user, size: 20, color: scheme.primary),
                    const SizedBox(width: 8),
                    CommonText.semiBold(
                      '${controller.references.length} ${controller.references.length == 1 ? 'reference' : 'references'}',
                      size: 16,
                      color: scheme.onSurface,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SlidableAutoCloseBehavior(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: controller.references.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ref = controller.references[index];
                      return _ReferenceTile(
                        key: ValueKey(ref.id),
                        reference: ref,
                        scheme: scheme,
                        onEdit: () => controller.onEditReference(ref),
                        onDelete: () => controller.onDeleteReference(ref),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.clearForm();
          Get.toNamed(Routes.ADD_REFERENCES);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Reference'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }
}

class _ReferenceTile extends StatelessWidget {
  const _ReferenceTile({
    super.key,
    required this.reference,
    required this.scheme,
    required this.onEdit,
    required this.onDelete,
  });

  final References reference;
  final ColorScheme scheme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final fullName = '${reference.firstName} ${reference.lastName}'.trim();
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

    final hasCompany = reference.companyName != null && reference.companyName!.isNotEmpty;
    final hasEmail = reference.email != null && reference.email!.isNotEmpty;
    final hasPhone = reference.phoneNumber != null && reference.phoneNumber!.isNotEmpty;
    final hasContactInfo = hasCompany || hasEmail || hasPhone;

    return Container(
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
      ),
      child: Slidable(
        key: ValueKey(reference.id),
        groupTag: 'references',
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
          margin: EdgeInsets.zero,
          enableScale: false,
          enableShadows: true,
          borderWidth: 1,
          borderColor: scheme.outline.withValues(alpha: 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: scheme.primaryContainer,
                    child: CommonText.semiBold(
                      initial,
                      size: 18,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.semiBold(
                          fullName.capitalize ?? '',
                          size: 16,
                          color: scheme.onSurface,
                        ),
                        if (reference.relationship != null && reference.relationship!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                            ),
                            child: CommonText.medium(
                              reference.relationship!,
                              size: 12,
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppCard(
                    onTap: onEdit,
                    borderWidth: 1,
                    enableShadows: false,
                    enableScale: false,
                    radius: 8,
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
              if (hasContactInfo) ...[
                Divider(
                  height: 24,
                  thickness: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.3),
                ),
                if (hasCompany)
                  _ContactRow(
                    icon: IconsaxPlusLinear.building_4,
                    label: reference.companyName!,
                    scheme: scheme,
                  ),
                if (hasCompany && (hasEmail || hasPhone))
                  const SizedBox(height: 10),
                if (hasEmail)
                  _ContactRow(
                    icon: IconsaxPlusLinear.sms,
                    label: reference.email!,
                    scheme: scheme,
                  ),
                if (hasEmail && hasPhone)
                  const SizedBox(height: 10),
                if (hasPhone)
                  _ContactRow(
                    icon: IconsaxPlusLinear.call,
                    label: reference.phoneNumber!,
                    scheme: scheme,
                  ),
              ],
            ],
          ).paddingAll(16),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.scheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.primary.withValues(alpha: 0.9)),
        const SizedBox(width: 10),
        Expanded(
          child: CommonText.regular(
            label,
            size: 14,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
