import 'package:ccs_app/export.dart';

import 'schedule_job_controller.dart';

class ScheduleJobBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScheduleJobController>(() => ScheduleJobController());
  }
}
