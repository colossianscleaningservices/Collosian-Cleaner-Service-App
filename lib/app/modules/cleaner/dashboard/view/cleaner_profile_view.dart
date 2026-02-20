import 'package:ccs_app/export.dart';

import '../../../../services/session_service.dart';
import '../cleaner_dashboard_controller.dart';

class CleanerProfileView extends GetView<CleanerDashboardController> {
  const CleanerProfileView({super.key});

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
                        child: Obx(() {
                          return (controller.userDisplayImage.isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                                  child: Image.network(
                                    controller.userDisplayImage.value,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(IconsaxPlusLinear.user, color: scheme.primary, size: 28);
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
    );
  }
}
