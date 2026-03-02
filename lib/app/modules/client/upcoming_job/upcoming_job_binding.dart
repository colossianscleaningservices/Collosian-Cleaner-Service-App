import 'package:get/get.dart';

import 'upcoming_job_controller.dart';

class UpcomingJobBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpcomingJobController>(
      () => UpcomingJobController(),
    );
  }
}
