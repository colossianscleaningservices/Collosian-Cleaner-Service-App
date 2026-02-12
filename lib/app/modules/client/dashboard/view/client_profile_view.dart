import 'package:ccs_app/export.dart';

import '../../../../services/session_service.dart';
import '../client_dashboard_controller.dart';

class ClientProfileView extends GetView<ClientDashboardController> {
  const ClientProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
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
                        child: Icon(IconsaxPlusLinear.user, color: scheme.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText.semiBold(
                              Get.find<SessionService>().userDisplayName,
                              size: 18,
                              color: scheme.onSurface,
                            ),
                            const SizedBox(height: 2),
                            CommonText.regular('Manage your account and preferences', size: 13, color: scheme.onSurfaceVariant),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(IconsaxPlusLinear.edit_2),
                        onPressed: () => Get.toNamed(Routes.CLIENT_EDIT_PROFILE),
                      ),
                    ],
                  ).paddingAll(UiConstants.defaultPadding),
                  AppGrid(
                    physics: NeverScrollableScrollPhysics(),
                    maxExtent: 60,
                    child: List.generate(controller.profileItems.length, (index) {
                      return MenuItem(controller.profileItems[index], onTap: () {
                        switch (index) {
                          case 0:
                            Get.toNamed(Routes.CHANGE_PASSWORD);
                            break;
                          case 1:
                            Get.toNamed(Routes.PROPERTY);
                            break;
                          case 2:
                            // Get.toNamed(Routes.PREFERRED_STAFF);
                            break;
                          case 3:
                            Get.toNamed(Routes.NOTIFICATION);
                            break;
                          case 4:
                            Get.toNamed(Routes.TRAINING_AND_RESOURCES);
                            break;
                          case 5:
                            Get.toNamed(Routes.NEWSLETTERS);
                            break;
                          case 6:
                            Get.toNamed(Routes.SUPPORT_CHAT, arguments: {'type': ChatConstants.typeSupport});
                            break;
                          case 7:
                            Get.toNamed(Routes.HELP_SUPPORT,arguments: {'from':'help_support'});
                            break;
                          case 8:
                            Get.toNamed(Routes.FAQ);
                            break;
                          default:
                            Get.toNamed(Routes.HELP_SUPPORT);
                            break;
                        }
                      });
                    }),
                  ).paddingSymmetric(horizontal: 16, vertical: 8),
                ],
              ),
            ),
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
            ).marginSymmetric(vertical: 24),
            Obx(() {
              return CommonText.medium(
                "Version ${controller.appVersion.value}",
                size: 14,
                color: context.colorScheme.primary,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.icon, required this.label, this.onTap});

  final IconData? icon;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
            ),
            child: Icon(icon, color: cs.secondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: CommonText.medium(label ?? "", size: 15, color: cs.onSurface)),
          Icon(IconsaxPlusLinear.arrow_right_3, size: 18, color: cs.onSurfaceVariant),
        ],
      ).paddingSymmetric(vertical: 12, horizontal: 4),
    );
  }
}
