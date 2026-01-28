import 'package:ccs_app/export.dart';
import 'cleaner_dashboard_controller.dart';

/// Cleaner dashboard (root with bottom nav).
/// Any "detail" pages opened via Get.toNamed() will NOT show this bottom bar.
class CleanerDashboardView extends GetView<CleanerDashboardController> {
  const CleanerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: Header(
          title: Constants.cleanerTopHeading[controller.tabIndex.value].$1,
          subtitle: Constants.cleanerTopHeading[controller.tabIndex.value].$2,
          actions: [
            IconButton(
              icon: const Icon(IconsaxPlusLinear.notification),
              onPressed: () {},
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

