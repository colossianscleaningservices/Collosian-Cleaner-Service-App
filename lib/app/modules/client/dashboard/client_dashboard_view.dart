import 'package:ccs_app/app/modules/client/dashboard/view/client_notifications_view.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';
import 'client_dashboard_controller.dart';

class ClientDashboardView extends GetView<ClientDashboardController> {
  const ClientDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffold(
        appBar: Header(
          title: Constants.clientTopHeading[controller.tabIndex.value].$1,
          subtitle: Constants.clientTopHeading[controller.tabIndex.value].$2,
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
          destinations: Constants.clientBottomBarItems,
        ),
      ),
    );
  }
}

