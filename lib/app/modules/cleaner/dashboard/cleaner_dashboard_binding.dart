import 'package:ccs_app/export.dart';

import 'cleaner_dashboard_controller.dart';

class CleanerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CleanerDashboardController>(() => CleanerDashboardController());
  }
}
