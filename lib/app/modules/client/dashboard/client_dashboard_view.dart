import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import '../../../gen/assets.gen.dart';
import 'client_dashboard_controller.dart';

class ClientDashboardView extends GetView<ClientDashboardController> {
  const ClientDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffold(
        appBar: Header(
          widget: Assets.imagesAppLogo.svg(width: 120, colorFilter: ColorFilter.mode(context.colorScheme.secondary, BlendMode.srcATop)),
          title: "",
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
