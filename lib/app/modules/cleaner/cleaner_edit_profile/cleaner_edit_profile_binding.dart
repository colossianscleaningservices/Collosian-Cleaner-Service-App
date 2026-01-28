import 'package:get/get.dart';

import 'cleaner_edit_profile_controller.dart';

class CleanerEditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CleanerEditProfileController>(
      () => CleanerEditProfileController(),
    );
  }
}
