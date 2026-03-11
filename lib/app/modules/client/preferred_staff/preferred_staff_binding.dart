import 'package:get/get.dart';

import 'preferred_staff_controller.dart';

class PreferredStaffBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PreferredStaffController>(
      () => PreferredStaffController(),
    );
  }
}
