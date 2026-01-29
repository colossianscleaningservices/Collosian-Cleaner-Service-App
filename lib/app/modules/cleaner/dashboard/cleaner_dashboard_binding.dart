import 'package:ccs_app/export.dart';

import 'cleaner_dashboard_controller.dart';
import 'cleaner_jobs_controller.dart';

class CleanerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CleanerDashboardController>(() => CleanerDashboardController());
    Get.lazyPut<CleanerJobsController>(() => CleanerJobsController());
  }
}
