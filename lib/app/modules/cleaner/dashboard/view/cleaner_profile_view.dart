import 'package:ccs_app/app/network/response/profile_response.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/export.dart';

import '../../../../services/session_service.dart';
import '../cleaner_dashboard_controller.dart';

class CleanerProfileView extends GetView<CleanerDashboardController> {
  const CleanerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return SafeArea(
      child: SwipeRefresh(
        onRefresh: controller.getProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: UiConstants.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(UiConstants.radiusDefault)),
                          child: Obx(() {
                            final placeholder = Icon(IconsaxPlusLinear.user, color: scheme.primary, size: 28);
                            return (controller.userDisplayImage.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                                    child: Image.network(
                                      controller.userDisplayImage.value,
                                      fit: BoxFit.cover,
                                      width: 56,
                                      height: 56,
                                      errorBuilder: (_, __, ___) {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          if (controller.userDisplayImage.value.isEmpty) return;
                                          controller.userDisplayImage.value = '';
                                          Prefs.instance.putData(Prefs.image, '');
                                        });
                                        return placeholder;
                                      },
                                    ),
                                  )
                                : placeholder;
                          }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() {
                                return CommonText.semiBold(
                                  controller.userDisplayName.value,
                                  size: 18,
                                  color: scheme.onSurface,
                                );
                              }),
                              const SizedBox(height: 2),
                              CommonText.regular('Manage your account and preferences', size: 13, color: scheme.onSurfaceVariant),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(IconsaxPlusLinear.edit_2),
                          onPressed: () => Get.toNamed(Routes.CLEANER_EDIT_PROFILE),
                        ),
                      ],
                    ).paddingAll(UiConstants.defaultPadding),
                    AppGrid(
                      physics: NeverScrollableScrollPhysics(),
                      maxExtent: 60,
                      child: List.generate(controller.cleanerProfileItems.length, (index) {
                        return MenuItem(controller.cleanerProfileItems[index], onTap: () {
                          if (index == 7) {
                            Get.toNamed(Routes.SUPPORT_CHAT, arguments: {'type': ChatConstants.typeSupport});
                            return;
                          }
                          String route = switch (index) {
                            0 => Routes.CHANGE_PASSWORD,
                            1 => Routes.CLEANER_REFERENCES,
                            2 => Routes.SUPPORT_DOCUMENT,
                            3 => Routes.CLEANER_REVIEW,
                            4 => Routes.CLEANER_PAYOUT_COMPUTATION,
                            5 => Routes.NOTIFICATION,
                            6 => Routes.TRAINING_AND_RESOURCES,
                            8 => Routes.HELP_SUPPORT,
                            _ => Routes.CHANGE_PASSWORD
                          };

                          Get.toNamed(route, arguments: {'from': ' dash'});
                        });
                      }),
                    ).paddingSymmetric(horizontal: 18, vertical: 8),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _IssuedItemsSection(),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Log out',
                  txtClr: scheme.error,
                  type: ButtonType.tonal,
                  bgColor: scheme.errorContainer,
                  icon: IconsaxPlusLinear.logout,
                  onPressed: () {
                    Notifier.openSheet(
                      context,
                      title: "Logout",
                      type: SheetType.error,
                      showPrimaryButton: true,
                      showSecondaryButton: true,
                      icon: IconsaxPlusLinear.logout,
                      message: "Are you sure you want to log out?",
                      onPrimaryPressed: () => Get.find<SessionService>().logout(),
                    );
                  },
                ),
              ).marginSymmetric(vertical: 18),
              Obx(() {
                return CommonText.medium(
                  "Version v${controller.appVersion.value}",
                  size: 14,
                  color: context.colorScheme.primary,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _IssuedItemsSection extends GetView<CleanerDashboardController> {
  const _IssuedItemsSection();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Obx(() {
      final items = controller.issuedItems;
      final outstanding = controller.issuedItemsOutstandingCount.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: CommonText.semiBold('Issued items', size: 16, color: scheme.onSurface),
              ),
              if (outstanding > 0)
                InfoChip(
                  label: outstanding == 1 ? '1 to return' : '$outstanding to return',
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.secondary,
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            AppCard(
              enableShadows: false,
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(IconsaxPlusLinear.box_1, size: 22, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonText.regular(
                      'No items have been issued to you yet.',
                      size: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _IssuedItemCard(item: item, scheme: scheme),
              ),
            ),
        ],
      );
    });
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
