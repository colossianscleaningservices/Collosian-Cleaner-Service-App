import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import '../../../gen/assets.gen.dart';
import 'cleaner_dashboard_controller.dart';

/// Cleaner dashboard (root with bottom nav).
/// Any "detail" pages opened via Get.toNamed() will NOT show this bottom bar.
class CleanerDashboardView extends GetView<CleanerDashboardController> {
  const CleanerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffold(
        appBar: Header(
          widget: Assets.imagesAppLogo.image(width: 120),
          title: "",
          actions: [
            if (controller.tabIndex.value == 1)
              IconButton(
                icon: const Icon(IconsaxPlusLinear.filter),
                onPressed: () => controller.openFilter(context),
              ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(IconsaxPlusLinear.notification),
                  onPressed: () => Get.toNamed(Routes.NOTIFICATION),
                  style: filledIconButtonStyle(context),
                ),

                // Badge
                if (controller.hasUnreadNotifications.value)
                  Positioned(
                    right: 6,
                    top: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          hasBackIcon: false,
        ),
        body: IndexedStack(
          index: controller.tabIndex.value,
          children: controller.pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.tabIndex.value,
          onDestinationSelected: controller.setTab,
          destinations: Constants.cleanerBottomBarItems,
        ),
      ),
    );
  }
}
