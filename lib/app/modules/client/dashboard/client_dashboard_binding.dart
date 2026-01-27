import 'package:ccs_app/export.dart';

import 'client_dashboard_controller.dart';

class ClientDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientDashboardController>(() => ClientDashboardController(), fenix: true);
  }
}
