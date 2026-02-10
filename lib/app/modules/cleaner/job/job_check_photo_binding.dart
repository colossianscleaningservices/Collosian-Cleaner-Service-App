import 'package:get/get.dart';

import 'job_check_photo_controller.dart';

class JobCheckPhotoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobCheckPhotoController>(() => JobCheckPhotoController());
  }
}
