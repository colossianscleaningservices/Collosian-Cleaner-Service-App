import 'package:ccs_app/export.dart';
import '../../../services/session_service.dart';
import 'cleaner_dashboard_controller.dart';

class CleanerProfileView extends GetView<CleanerDashboardController> {
  const CleanerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: UiConstants.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Row(
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
                        CommonText.semiBold('Cleaner', size: 18, color: scheme.onSurface),
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
            ),
            const SizedBox(height: 24),

            AppCard(
              child: AppGrid(
                physics: NeverScrollableScrollPhysics(),
                maxExtent: 60,
                child: List.generate(controller.profileItems.length, (index) {
                  return MenuItem(controller.profileItems[index], onTap: () {
                    switch (index) {
                      case 0:
                      // Get.toNamed(Routes.CHANGE_PASSWORD);
                        break;
                      case 1:
                        Get.toNamed(Routes.PROPERTY);
                        break;
                      case 2:
                      // Get.toNamed(Routes.PREFERRED_STAFF);
                        break;
                      case 3:
                      // Get.toNamed(Routes.NOTIFICATIONS);
                        break;
                      case 4:
                      Get.toNamed(Routes.TRAINING_AND_RESOURCES);
                        break;
                      case 5:
                      // Get.toNamed(Routes.HELP);
                        break;
                    }
                  });
                }),
              ).paddingSymmetric(horizontal: 16, vertical: 8),
            ),
            const SizedBox(height: 24),

            AppButton(
              label: 'Log out',
              type: ButtonType.outline,
              icon: IconsaxPlusLinear.logout,
              onPressed: () => Get.find<SessionService>().logout(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

